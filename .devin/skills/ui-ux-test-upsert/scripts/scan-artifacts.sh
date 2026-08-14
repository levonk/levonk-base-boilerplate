#!/usr/bin/env bash
# scan-artifacts.sh — scan generated files for identity leaks before committing
#
# Resolves the current machine's actual identity values from the environment
# and system commands, then scans staged files (or specified files) for those
# specific strings. This is a deterministic scan — it finds real leaks, not
# conceptual references. The AI reviews each finding to decide if it's a true
# leak or a legitimate reference.
#
# All values are resolved dynamically — nothing is hardcoded. The script
# works on macOS and Linux.
#
# Usage:
#   scan-artifacts.sh                          # scan git diff --cached (staged files)
#   scan-artifacts.sh <file> [<file> ...]      # scan specific files
#   scan-artifacts.sh --verbose                # show matching lines
#   scan-artifacts.sh --private                # private use: informational only, exit 0
#
# Exit 0 = clean (or --private mode). Exit 1 = findings detected (review required).
#
# --private: eases scrutiny for files the user says are for private use.
# HARD findings become informational (printed but don't block). Use this when
# the user has confirmed the generated files are for a private repo that won't
# be shared or made public. The findings are still printed so the user can
# make an informed choice — they just don't block the commit.
#
# What it scans for (all resolved from the current machine):
#   1. $HOME path (resolved from $HOME env var) — HARD leak in any file
#   2. Username in path context (/Users/<user>, /home/<user>) — HARD leak
#   3. Hostname / machine name (hostname -s) — REVIEW (may be legitimate in some configs)
#   4. WiFi SSID (current network name) — HARD leak (reveals physical location context)
#   5. DNS search domain (e.g. lan, tailnet name) — REVIEW (may be legitimate in network configs)
#   6. Bonjour/local hostname — REVIEW (same as hostname but with .local suffix)
#   7. Literal $HOME/$USER in non-shell files (README, .yml, .json, .md) — REVIEW
#
# What it does NOT scan for:
#   - $HOME/$USER in .sh files — legitimate runtime variables for end users
#   - Generic paths like /usr/local/bin — not identity leaks
#
# Consumers:
#   - nixify (scripts/scan-artifacts.sh.tmpl materializes this)
#   - container-image-build (scripts/scan-artifacts.sh.tmpl materializes this)
#   - Any skill that generates files — add via scripts/scan-artifacts.sh.tmpl
#
# Published to skills-releases/includes/scan-artifacts.sh for skills without
# a scripts/ directory (fetch via the online URL fallback).

set -euo pipefail

VERBOSE=0
PRIVATE=0
FILES=()

# Parse args
for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=1 ;;
    --private) PRIVATE=1 ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# //; s/^#//'
      exit 0
      ;;
    *) FILES+=("$arg") ;;
  esac
done

# --- Resolve actual identity values from the environment and system ---

# $HOME and username — from environment, always available
HOME_VAL="${HOME:-}"
USER_VAL="$(whoami 2>/dev/null || echo '')"

# Hostname — short form preferred, fall back to full, then empty
HOST_VAL="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo '')"

# Bonjour/local hostname — macOS: scutil --get LocalHostName; Linux: usually hostname.local
LOCAL_HOST_VAL=""
if command -v scutil >/dev/null 2>&1; then
  LOCAL_HOST_VAL="$(scutil --get LocalHostName 2>/dev/null || echo '')"
fi
# ponytail: scutil is macOS-only. On Linux, hostname -s already covers the
# short name. The .local variant is rarely in generated files and would be
# caught by HOST_VAL matching. Ceiling: Linux Bonjour name not separately
# resolved — but it's almost always the same as hostname -s + ".local", and
# the hostname check catches the short form.

# WiFi SSID — current network name
# macOS: networksetup -getairportnetwork en0
# Linux: nmcli or iwgetid
WIFI_SSID=""
if command -v networksetup >/dev/null 2>&1; then
  # macOS — try en0 first, then en1
  WIFI_SSID="$(networksetup -getairportnetwork en0 2>/dev/null | sed 's/Current Wi-Fi Network: //' || true)"
  if [ -z "$WIFI_SSID" ] || echo "$WIFI_SSID" | grep -qi 'error\|not a wi-fi'; then
    WIFI_SSID="$(networksetup -getairportnetwork en1 2>/dev/null | sed 's/Current Wi-Fi Network: //' || true)"
  fi
  echo "$WIFI_SSID" | grep -qi 'error\|not a wi-fi\|is not a' && WIFI_SSID=""
elif command -v nmcli >/dev/null 2>&1; then
  # Linux with NetworkManager
  WIFI_SSID="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 || true)"
elif command -v iwgetid >/dev/null 2>&1; then
  # Linux with wireless-tools
  WIFI_SSID="$(iwgetid -r 2>/dev/null || true)"
fi
# ponytail: WiFi SSID detection is best-effort. If no tool is available or
# the machine isn't on WiFi, WIFI_SSID is empty and WiFi checks are skipped.
# Ceiling: wired-only machines won't have a WiFi SSID to scan for. That's
# correct — there's no WiFi name to leak if you're not on WiFi.

# DNS search domain — from system DNS config
# macOS: scutil --dns; Linux: /etc/resolv.conf
DNS_DOMAIN=""
if command -v scutil >/dev/null 2>&1; then
  DNS_DOMAIN="$(scutil --dns 2>/dev/null | grep 'search domain' | head -1 | sed 's/.*: *//' || true)"
elif [ -f /etc/resolv.conf ]; then
  DNS_DOMAIN="$(grep '^search ' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}' || true)"
fi
# ponytail: DNS search domain is often a generic value like "lan" or a
# tailnet name like "mytailnet.ts.net". Flagged as REVIEW because network
# config files may legitimately reference it. Ceiling: machines without a
# search domain configured won't have this check — correct, nothing to leak.

if [ ${#FILES[@]} -gt 0 ]; then
  # Scan specific files — filter to existing files
  SCAN_FILES=()
  for f in "${FILES[@]}"; do
    [ -f "$f" ] && SCAN_FILES+=("$f")
  done
  if [ ${#SCAN_FILES[@]} -eq 0 ]; then
    echo "scan-artifacts: no existing files among args, skipping"
    exit 0
  fi
  SCAN_MODE="files"
else
  SCAN_MODE="staged"
fi

FINDINGS=0

# --- Helper: print a finding ---
print_finding() {
  local severity="$1" file="$2" line="$3" match="$4" pattern="$5"
  if [ "$PRIVATE" -eq 1 ] && [ "$severity" = "HARD" ]; then
    echo "INFO: [$severity] $file:$line — $pattern (non-blocking: --private)"
  elif [ "$severity" = "HARD" ]; then
    echo "FAIL: [$severity] $file:$line — $pattern"
  else
    echo "REVIEW: [$severity] $file:$line — $pattern"
  fi
  FINDINGS=$((FINDINGS + 1))
  if [ "$VERBOSE" -eq 1 ]; then
    echo "    | $match"
  fi
}

# --- Helper: check a resolved value against a line ---
# Args: severity, file, lineno, line, label, value, grep_mode (F=literal, E=regex)
check_value() {
  local severity="$1" file="$2" lineno="$3" line="$4" label="$5" value="$6" mode="$7"
  [ -z "$value" ] && return 1
  if [ "$mode" = "F" ]; then
    printf '%s' "$line" | grep -qF "$value" || return 1
  else
    printf '%s' "$line" | grep -qE "$value" || return 1
  fi
  print_finding "$severity" "$file" "$lineno" "$line" "$label"
  return 0
}

# --- Scan a single file ---
scan_file() {
  local file="$1"

  # Skip non-text files
  local mime
  mime=$(file --mime-type -b "$file" 2>/dev/null || echo "")
  case "$mime" in
    text/*|application/json|application/x-yaml|application/xml|inode/x-empty) ;;
    *) return 0 ;;
  esac

  local basename="${file##*/}"
  local ext="${basename##*.}"
  local is_shell=0
  case "$ext" in
    sh|bash|zsh|fish) is_shell=1 ;;
  esac

  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))

    # 1. Resolved $HOME path — HARD leak in any file
    check_value "HARD" "$file" "$lineno" "$line" "resolved \$HOME path ($HOME_VAL)" "$HOME_VAL" "F" && continue

    # 2. Resolved username in path context — HARD leak
    # Match /Users/<user>, /home/<user>, or C:\Users\<user> to avoid false
    # positives on common words containing the username substring.
    if [ -n "$USER_VAL" ]; then
      check_value "HARD" "$file" "$lineno" "$line" "resolved username in path (/Users|home/$USER_VAL)" "/(Users|home)/${USER_VAL}([/[:space:]\"']|$)|C:\\\\Users\\\\${USER_VAL}" "E" && continue
    fi

    # 3. WiFi SSID — HARD leak (reveals physical location context)
    check_value "HARD" "$file" "$lineno" "$line" "WiFi SSID ($WIFI_SSID)" "$WIFI_SSID" "F" && continue

    # 4. Resolved hostname — REVIEW (may be legitimate in some configs)
    # Word-boundary match to avoid substring false positives.
    if [ -n "$HOST_VAL" ]; then
      check_value "REVIEW" "$file" "$lineno" "$line" "resolved hostname ($HOST_VAL)" "\b${HOST_VAL}\b" "E" && continue
    fi

    # 5. Bonjour/local hostname — REVIEW
    if [ -n "$LOCAL_HOST_VAL" ] && [ "$LOCAL_HOST_VAL" != "$HOST_VAL" ]; then
      check_value "REVIEW" "$file" "$lineno" "$line" "local hostname ($LOCAL_HOST_VAL)" "\b${LOCAL_HOST_VAL}\b" "E" && continue
    fi

    # 6. DNS search domain — REVIEW (may be legitimate in network configs)
    # Use word-boundary matching to reduce false positives on short domains like "lan"
    if [ -n "$DNS_DOMAIN" ]; then
      check_value "REVIEW" "$file" "$lineno" "$line" "DNS search domain ($DNS_DOMAIN)" "\b${DNS_DOMAIN}\b" "E" && continue
    fi

    # 7. Literal $HOME/$USER in non-shell files — REVIEW
    if [ "$is_shell" -eq 0 ]; then
      if printf '%s' "$line" | grep -qE '\$(HOME|USER)\b'; then
        print_finding "REVIEW" "$file" "$lineno" "$line" "literal \$HOME/\$USER in non-shell file"
        continue
      fi
    fi

  done < "$file"
}

# --- Run scan ---
if [ "$SCAN_MODE" = "staged" ]; then
  STAGED="$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)"
  if [ -z "$STAGED" ]; then
    echo "scan-artifacts: no staged files to scan"
    exit 0
  fi
  while IFS= read -r f; do
    [ -n "$f" ] && scan_file "$f"
  done <<< "$STAGED"
else
  for f in "${SCAN_FILES[@]}"; do
    scan_file "$f"
  done
fi

# --- Report ---
if [ "$FINDINGS" -eq 0 ]; then
  echo "ok: no identity leaks detected"
  exit 0
fi

echo ""
if [ "$PRIVATE" -eq 1 ]; then
  echo "Found $FINDINGS potential identity leak(s) (--private mode: informational only):"
  echo "  HARD   = would block without --private — user confirmed private use, non-blocking"
  echo "  REVIEW = context-dependent — the AI must decide if it's legitimate"
  echo ""
  echo "Files are for private use per user confirmation. Findings are informational."
  echo "If the repo may be shared or made public, re-run without --private and fix HARD leaks."
  exit 0
fi

echo "Found $FINDINGS potential identity leak(s). Review each finding:"
echo "  HARD   = definite leak — remove the personal reference, use a relative/generic path"
echo "  REVIEW = context-dependent — the AI must decide if it's legitimate"
echo ""
echo "For \$HOME/\$USER in shell scripts (.sh): legitimate runtime variables, not leaks."
echo "For \$HOME/\$USER in READMEs/configs: replace with generic ~ or upstream-relative path."
echo "For resolved paths (/Users/<you>, /home/<you>): always remove — use relative paths."
echo "For WiFi SSID / DNS domain / hostname: remove unless the file is network config that legitimately references them."
echo ""
echo "If the user confirms these files are for private use only, re-run with --private to ease scrutiny."

exit 1

