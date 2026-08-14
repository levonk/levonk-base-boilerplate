#!/usr/bin/env bash
# Lint (and optionally auto-fix) the artifacts nixify created.
# Usage: lint-artifacts.sh [--fix] [--threshold N] <file> [<file> ...]
#
# Categorizes files by extension and runs the appropriate linter:
#   .yml/.yaml -> yamllint (check-only — no reliable auto-fix)
#   .md/.mdx   -> markdownlint-cli2 (--fix in fix mode)
#   .nix       -> statix (check or fix) + deadnix (check or --edit -L)
#
# Each linter auto-discovers the project's own config files (.yamllint.yaml,
# .markdownlint.json, statix.toml, etc.) and conforms to the project's
# standards. If no project config exists, the linters run with their built-in
# defaults — nixify's templates are written to pass default lint settings.
#
# If a linter is not on the host PATH, the script falls back to
# `nix run nixpkgs#<tool>` — Nix is a prerequisite for this skill, so this
# always works. Running inside `devbox shell` makes the tools available on the
# host PATH if they're listed in devbox.json.
#
# Only the files passed as arguments are linted — never the whole repo.
#
# MASSIVE-CHANGE GUARD (--fix mode only):
# After auto-fixing, the script checks each file against HEAD (the feature
# commit). Files that did NOT exist at HEAD~1 (nixify-created) keep all fixes.
# Files that DID exist at HEAD~1 (nixify-modified, e.g. README) are checked:
# if the combined format+lint-induced diff exceeds --threshold lines (default
# 20), the file is reverted to HEAD (all style changes discarded) and a
# warning is printed. The guard checks the combined diff because format
# (format-artifacts.sh) runs before this script — git diff against HEAD
# includes both format and lint changes. This prevents a formatter or linter
# from reformatting an entire file nixify only added a section to — those
# changes belong to the project, not to nixify's PR.
#
# yamllint has no auto-fix, so its findings are always reported as check-only.
# The AI agent fixes yamllint findings manually (only in nixify's sections for
# modified files).
#
# Exits non-zero if any linter reports unfixable findings or if check-only
# mode finds issues.

set -euo pipefail

FIX=false
THRESHOLD=20
files=()

# Parse args.
for arg in "$@"; do
  case "$arg" in
    --fix)        FIX=true; shift ;;
    --threshold)  shift; THRESHOLD="${1:?--threshold requires a number}"; shift ;;
    --threshold=*) THRESHOLD="${arg#*=}"; shift ;;
    -*) echo "unknown flag: $arg" >&2; exit 1 ;;
    *) files+=("$arg") ;;
  esac
done

if [ ${#files[@]} -eq 0 ]; then
  echo "Usage: lint-artifacts.sh [--fix] [--threshold N] <file> [<file> ...]" >&2
  exit 1
fi

# Filter to files that exist.
lintable=()
for f in "${files[@]}"; do
  [ -f "$f" ] && lintable+=("$f")
done
if [ ${#lintable[@]} -eq 0 ]; then
  echo "no lintable files among args, skipping"
  exit 0
fi

# Categorize by extension.
yaml_files=()
md_files=()
nix_files=()
for f in "${lintable[@]}"; do
  case "$f" in
    *.yml|*.yaml) yaml_files+=("$f") ;;
    *.md|*.mdx)   md_files+=("$f") ;;
    *.nix)        nix_files+=("$f") ;;
  esac
done

# Run a linter, falling back to `nix run nixpkgs#<tool>` if not on host PATH.
run_linter() {
  local tool="$1"
  shift
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  tool: $tool (host)"
    "$tool" "$@"
  else
    echo "  tool: $tool (nix run nixpkgs#$tool)"
    nix run nixpkgs#"$tool" -- "$@"
  fi
}

# Check if a file existed at HEAD~1 (i.e. nixify modified it, not created it).
# Returns 0 (true) if the file is modified, 1 (false) if created.
is_modified_file() {
  git show "HEAD~1:$1" >/dev/null 2>&1
}

# Count lines changed by lint (working tree vs HEAD).
# Outputs a single number (total added + deleted lines).
lint_diff_lines() {
  local f="$1"
  local stats
  stats=$(git diff --numstat -- "$f" 2>/dev/null | awk '{print $1+$2}')
  echo "${stats:-0}"
}

# Guard: if a modified file has a massive format+lint diff, revert it.
# Only applies in --fix mode. Created files are never reverted.
# Checks combined diff (format from Step 18 + lint from Step 19) against HEAD.
guard_massive_changes() {
  if [ "$FIX" != "true" ]; then
    return
  fi
  for f in "${lintable[@]}"; do
    if is_modified_file "$f"; then
      local changed
      changed=$(lint_diff_lines "$f")
      if [ "$changed" -gt "$THRESHOLD" ]; then
        echo "  GUARD: $f is a modified file with ${changed} lint-changed lines (threshold ${THRESHOLD}) — reverting lint changes to avoid massive diff on a file nixify didn't create" >&2
        git checkout HEAD -- "$f"
      fi
    fi
  done
}

exit_code=0

# --- YAML (yamllint — always check-only, no auto-fix) ---
if [ ${#yaml_files[@]} -gt 0 ]; then
  echo "--- YAML files (${#yaml_files[@]}) ---"
  if run_linter yamllint -d default "${yaml_files[@]}"; then
    echo "  ok: yamllint"
  else
    echo "  FAILED: yamllint — fix findings above (manual; yamllint has no auto-fix)" >&2
    exit_code=1
  fi
fi

# --- Markdown (markdownlint-cli2) ---
if [ ${#md_files[@]} -gt 0 ]; then
  echo "--- Markdown files (${#md_files[@]}) ---"
  if [ "$FIX" = "true" ]; then
    if run_linter markdownlint-cli2 --fix "${md_files[@]}"; then
      echo "  ok: markdownlint-cli2 (fixed)"
    else
      # --fix may still exit non-zero for unfixable findings
      echo "  NOTE: markdownlint-cli2 fixed what it could; unfixable findings remain above" >&2
      exit_code=1
    fi
  else
    if run_linter markdownlint-cli2 "${md_files[@]}"; then
      echo "  ok: markdownlint-cli2"
    else
      echo "  FAILED: markdownlint-cli2 — fix findings above before proceeding" >&2
      exit_code=1
    fi
  fi
fi

# --- Nix (statix + deadnix) ---
if [ ${#nix_files[@]} -gt 0 ]; then
  echo "--- Nix files (${#nix_files[@]}) ---"
  # statix: check or fix
  if [ "$FIX" = "true" ]; then
    if run_linter statix fix "${nix_files[@]}"; then
      echo "  ok: statix (fixed)"
    else
      echo "  FAILED: statix — could not fix all findings, see above" >&2
      exit_code=1
    fi
  else
    if run_linter statix check "${nix_files[@]}"; then
      echo "  ok: statix"
    else
      echo "  FAILED: statix — fix findings above before proceeding" >&2
      exit_code=1
    fi
  fi
  # deadnix: --fail (check) or --edit -L (fix; -L avoids breaking callPackage)
  if [ "$FIX" = "true" ]; then
    if run_linter deadnix --edit -L "${nix_files[@]}"; then
      echo "  ok: deadnix (fixed)"
    else
      echo "  FAILED: deadnix — could not edit all dead code, see above" >&2
      exit_code=1
    fi
  else
    if run_linter deadnix --fail -L "${nix_files[@]}"; then
      echo "  ok: deadnix"
    else
      echo "  FAILED: deadnix — remove dead code (unused let bindings) reported above" >&2
      exit_code=1
    fi
  fi
fi

# Guard: revert massive lint changes on modified files.
guard_massive_changes

if [ $exit_code -eq 0 ]; then
  echo "lint-artifacts: all clean"
else
  echo "lint-artifacts: issues found (see above)" >&2
fi
exit $exit_code
