#!/usr/bin/env bash
# Detect the inherent platform scope of a project.
# Usage: detect-platform-scope.sh [project-dir] [--verbose]
#
# Some software is inherently platform-specific by design — a macOS menu-bar
# app cannot run on Linux (no AppKit/Cocoa), and a GRUB/systemd tool cannot
# run on Darwin (no Linux kernel ABI). For such projects, the nixify flake
# should target only the platforms the software actually supports, rather
# than the default 4-system set. This script inspects the repo for
# platform-defining signals and reports a target_platforms list that
# downstream steps use instead of the hardcoded 4-system default.
#
# Output: JSON with:
#   - target_platforms: array of Nix system strings (subset of the 4 defaults)
#   - platform_scope:   "all" | "darwin_only" | "linux_only"
#   - signals:          array of { signal, scope, source, confidence }
#   - confidence:       "high" | "medium" | "low"
#   - rationale:        short human-readable summary
#
# Detection is conservative: when signals conflict or are weak, the script
# falls back to platform_scope="all" (the 4-system default). A high-confidence
# darwin_only or linux_only result requires either an explicit CI matrix that
# only runs on one OS family, OR multiple corroborating source/manifest
# signals. The agent should still confirm with the user before narrowing
# scope on a medium-confidence result.
#
# Use --verbose for full scan details.

set -euo pipefail

DIR="${1:-.}"
VERBOSE=""
if [ "${2:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
fi

if [ ! -d "$DIR" ]; then
  echo "error: directory '$DIR' not found" >&2
  exit 1
fi

ALL_SYSTEMS='["x86_64-linux","aarch64-linux","x86_64-darwin","aarch64-darwin"]'
DARWIN_SYSTEMS='["x86_64-darwin","aarch64-darwin"]'
LINUX_SYSTEMS='["x86_64-linux","aarch64-linux"]'

signals_file=$(mktemp)
trap 'rm -f "$signals_file"' EXIT

# Format: signal|scope|source|confidence
# scope is "darwin" or "linux"; confidence is "high" or "medium"
add_signal() {
  echo "$1|$2|$3|$4" >> "$signals_file"
}

# ── 1. CI matrix (strongest signal) ─────────────────────────────────────────
# A workflow that only runs on macos-* or only on ubuntu-* is a clear
# statement of supported platforms. A mixed matrix is treated as "all".
ci_darwin=0
ci_linux=0
ci_other=0
ci_sources=""

# Use a nullglob-friendly check: collect matching files first, then iterate.
# `ls glob1 glob2` exits non-zero if either glob is empty, which under
# `set -euo pipefail` would skip the entire CI block whenever a repo has
# .yml but no .yaml (or vice versa). Build the list with compgen instead.
mapfile -t _wf_files < <(compgen -G "$DIR/.github/workflows/*.yml" || true; compgen -G "$DIR/.github/workflows/*.yaml" || true)
if [ "${#_wf_files[@]}" -gt 0 ]; then
  for wf in "${_wf_files[@]}"; do
    [ -f "$wf" ] || continue
    # Extract runs-on values (handles both string and matrix list forms).
    # We look for runs-on: <value> and runs-on: ${{ matrix.os }} with the
    # matrix include list. A simple grep catches the common cases.
    runs=$(grep -E '^\s*runs-on:' "$wf" 2>/dev/null | sed -E 's/.*runs-on:\s*//' | tr -d '"' || true)
    matrix_os=$(grep -E '^\s*os:' "$wf" 2>/dev/null | sed -E 's/.*:\s*//' | tr -d '"' || true)
    combined="$runs $matrix_os"
    if echo "$combined" | grep -qiE 'macos|darwin|apple-silicon'; then
      ci_darwin=$((ci_darwin + 1))
      ci_sources="$ci_sources $wf"
    fi
    if echo "$combined" | grep -qiE 'ubuntu|linux|debian'; then
      ci_linux=$((ci_linux + 1))
      ci_sources="$ci_sources $wf"
    fi
    if echo "$combined" | grep -qiE 'windows|win'; then
      ci_other=$((ci_other + 1))
    fi
  done
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "CI: darwin=$ci_darwin linux=$ci_linux other=$ci_other"
fi

# High-confidence CI signal: only one OS family appears across all workflows.
if [ "$ci_darwin" -gt 0 ] && [ "$ci_linux" -eq 0 ]; then
  add_signal "ci_matrix_darwin_only" "darwin" ".github/workflows/" "high"
elif [ "$ci_linux" -gt 0 ] && [ "$ci_darwin" -eq 0 ]; then
  add_signal "ci_matrix_linux_only" "linux" ".github/workflows/" "high"
fi

# ── 2. Rust manifests (Cargo.toml / Cargo.lock) ─────────────────────────────
# Darwin-only crates: AppKit, Cocoa, objc, core-foundation (when paired with
#   GUI frameworks), swift-bridge, metal, webkit. These have no Linux build.
# Linux-only crates: systemd, nix (the crate — careful, cross-platform by
#   default, but `nix/sys/*` linux-only modules count), linux-keyutils,
#   epoll, inotify, netlink, capsules (kernel modules).
darwin_crates='cocoa|objc|objc_id|core_foundation|core-graphics|core-text|appkit|swift-bridge|metal|webkit|cain|icrate|fruit-salad|nsstring|kit|menu-bar|menubar|tray-icon.*darwin'
linux_crates='systemd|nix-systemd|linux-keyutils|epoll|inotify|netlink|capsules|kmod|libudev|udev|systemd-zbus|zbus_systemd'

if [ -f "$DIR/Cargo.toml" ] || [ -f "$DIR/Cargo.lock" ]; then
  cargo_combined=""
  [ -f "$DIR/Cargo.toml" ] && cargo_combined="$cargo_combined$(cat "$DIR/Cargo.toml")"
  for f in "$DIR"/crates/*/Cargo.toml "$DIR"/packages/*/Cargo.toml; do
    [ -f "$f" ] && cargo_combined="$cargo_combined$(cat "$f")"
  done
  [ -f "$DIR/Cargo.lock" ] && cargo_combined="$cargo_combined$(grep -E '^name = ' "$DIR/Cargo.lock" || true)"

  if echo "$cargo_combined" | grep -qiE "(^|[^a-z-])($darwin_crates)([^a-z-]|$)" 2>/dev/null; then
    add_signal "cargo_darwin_frameworks" "darwin" "Cargo.toml/Cargo.lock" "medium"
  fi
  if echo "$cargo_combined" | grep -qiE "(^|[^a-z-])($linux_crates)([^a-z-]|$)" 2>/dev/null; then
    add_signal "cargo_linux_only_crates" "linux" "Cargo.toml/Cargo.lock" "medium"
  fi
fi

# ── 3. Swift / SwiftUI / AppKit source files ────────────────────────────────
# A `.swift` project that imports SwiftUI/AppKit/UIKit is darwin-only.
# Use find(1) instead of globstar — bash globstar (**) is off by default and
# `ls glob1 glob2` exits non-zero under pipefail if either glob is empty.
_swift_files=$(find "$DIR" -maxdepth 4 -name '*.swift' -type f 2>/dev/null || true)
if [ -n "$_swift_files" ]; then
  swift_imports=$(echo "$_swift_files" | xargs grep -hE '^import (SwiftUI|AppKit|UIKit|Cocoa|WebKit|Metal|Combine)' 2>/dev/null | sort -u || true)
  if [ -n "$swift_imports" ]; then
    add_signal "swift_darwin_frameworks" "darwin" "*.swift imports" "high"
  fi
fi

# ── 4. Node.js: Electron / native darwin-only deps ──────────────────────────
if [ -f "$DIR/package.json" ]; then
  pkg=$(cat "$DIR/package.json")
  # Electron + a main process that uses Menu/Tray is darwin-leaning but not
  # darwin-only (Electron runs on Linux too). Only flag darwin-only when the
  # package explicitly declares darwin-only native modules.
  if echo "$pkg" | grep -qiE '"(@napi-rs/[^"]*-(darwin|macos))|"(electron).*darwin' 2>/dev/null; then
    add_signal "node_darwin_native" "darwin" "package.json" "medium"
  fi
  # A `@types/node` build that uses `process.platform === 'darwin'` exclusively
  # is too weak a signal — skip.
fi

# ── 5. Go: linux-only stdlib imports ────────────────────────────────────────
# `golang.org/x/sys/unix` is cross-platform. Linux-only signals: build tags
# `//go:build linux`, imports of `github.com/godbus/dbus`, `golang.org/x/sys/unix`
# paired with syscall numbers only on linux. The cleanest signal is a
# `//go:build linux` constraint appearing with no `//go:build darwin`.
_go_files=$(find "$DIR" -maxdepth 4 -name '*.go' -type f 2>/dev/null || true)
if [ -n "$_go_files" ]; then
  go_linux_tags=$(echo "$_go_files" | xargs grep -lE '//go:build linux' 2>/dev/null | wc -l | tr -d ' ' || true)
  go_darwin_tags=$(echo "$_go_files" | xargs grep -lE '//go:build darwin' 2>/dev/null | wc -l | tr -d ' ' || true)
  [ -z "$go_linux_tags" ] && go_linux_tags=0
  [ -z "$go_darwin_tags" ] && go_darwin_tags=0
  if [ "$go_linux_tags" -gt 0 ] && [ "$go_darwin_tags" -eq 0 ]; then
    add_signal "go_linux_build_tags" "linux" "*.go //go:build" "medium"
  elif [ "$go_darwin_tags" -gt 0 ] && [ "$go_linux_tags" -eq 0 ]; then
    add_signal "go_darwin_build_tags" "darwin" "*.go //go:build" "medium"
  fi
fi

# ── 6. README / docs / badges ───────────────────────────────────────────────
# "macOS only", "Linux only", "menu bar app", "GRUB", "systemd service".
# These are weak signals on their own but corroborate stronger ones.
readme_files=""
for f in "$DIR/README.md" "$DIR/README" "$DIR/readme.md" "$DIR/README.rst"; do
  [ -f "$f" ] && readme_files="$readme_files $f"
done

if [ -n "$readme_files" ]; then
  readme_text=$(cat $readme_files 2>/dev/null | tr '[:upper:]' '[:lower:]')
  if echo "$readme_text" | grep -qiE 'macos.?only|mac.?only|menu.?bar|menubar|appkit|cocoa|darwin.?only'; then
    add_signal "readme_darwin_only" "darwin" "README" "medium"
  fi
  if echo "$readme_text" | grep -qiE 'linux.?only|gnu.?only|grub|systemd.?service|udev|/proc/sys|/sys/class'; then
    add_signal "readme_linux_only" "linux" "README" "medium"
  fi
fi

# ── 7. Tally signals and decide ─────────────────────────────────────────────
count_match() {
  local file="$1" pat="$2"
  [ -f "$file" ] || { echo 0; return; }
  local n
  n=$(grep -c "$pat" "$file" 2>/dev/null || true)
  [ -n "$n" ] || n=0
  echo "$n"
}
darwin_high=$(count_match "$signals_file" '|darwin|.*|high$')
darwin_med=$(count_match "$signals_file" '|darwin|.*|medium$')
linux_high=$(count_match "$signals_file" '|linux|.*|high$')
linux_med=$(count_match "$signals_file" '|linux|.*|medium$')

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Signals: darwin high=$darwin_high med=$darwin_med, linux high=$linux_high med=$linux_med"
  cat "$signals_file"
fi

# Decision rules:
# - Any high-confidence signal for one family AND zero signals for the other
#   -> narrow to that family, confidence=high.
# - Two or more medium signals for one family AND zero for the other
#   -> narrow to that family, confidence=medium.
# - Otherwise (mixed, weak, or no signals) -> all 4 systems, confidence=high
#   (the default is well-supported; narrowing requires evidence).
platform_scope="all"
target_platforms="$ALL_SYSTEMS"
confidence="high"
rationale="No platform-narrowing signals detected; defaulting to all 4 Nix target systems."

if [ "$darwin_high" -gt 0 ] && [ "$linux_high" -eq 0 ] && [ "$linux_med" -eq 0 ]; then
  platform_scope="darwin_only"
  target_platforms="$DARWIN_SYSTEMS"
  confidence="high"
  rationale="High-confidence darwin-only signal(s) with no linux signals."
elif [ "$linux_high" -gt 0 ] && [ "$darwin_high" -eq 0 ] && [ "$darwin_med" -eq 0 ]; then
  platform_scope="linux_only"
  target_platforms="$LINUX_SYSTEMS"
  confidence="high"
  rationale="High-confidence linux-only signal(s) with no darwin signals."
elif [ "$darwin_med" -ge 2 ] && [ "$linux_high" -eq 0 ] && [ "$linux_med" -eq 0 ]; then
  platform_scope="darwin_only"
  target_platforms="$DARWIN_SYSTEMS"
  confidence="medium"
  rationale="Multiple medium-confidence darwin-only signals with no linux signals."
elif [ "$linux_med" -ge 2 ] && [ "$darwin_high" -eq 0 ] && [ "$darwin_med" -eq 0 ]; then
  platform_scope="linux_only"
  target_platforms="$LINUX_SYSTEMS"
  confidence="medium"
  rationale="Multiple medium-confidence linux-only signals with no darwin signals."
elif [ "$darwin_high" -gt 0 ] && [ "$linux_high" -eq 0 ]; then
  # darwin high but linux medium present — conflicting, fall back to all
  platform_scope="all"
  target_platforms="$ALL_SYSTEMS"
  confidence="low"
  rationale="Conflicting signals (darwin high, linux medium); falling back to all 4."
elif [ "$linux_high" -gt 0 ] && [ "$darwin_high" -eq 0 ]; then
  platform_scope="all"
  target_platforms="$ALL_SYSTEMS"
  confidence="low"
  rationale="Conflicting signals (linux high, darwin medium); falling back to all 4."
fi

# ── 8. Emit JSON ────────────────────────────────────────────────────────────
signals_json=$(awk -F'|' '
  BEGIN { printf "["; sep="" }
  { printf "%s{\"signal\":\"%s\",\"scope\":\"%s\",\"source\":\"%s\",\"confidence\":\"%s\"}", sep, $1, $2, $3, $4; sep="," }
  END { printf "]" }
' "$signals_file" 2>/dev/null || echo "[]")

cat <<EOF
{"target_platforms": $target_platforms, "platform_scope": "$platform_scope", "signals": $signals_json, "confidence": "$confidence", "rationale": "$rationale"}
EOF
