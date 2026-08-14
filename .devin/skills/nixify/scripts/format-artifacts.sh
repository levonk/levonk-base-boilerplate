#!/usr/bin/env bash
# Run the project's own formatter on the non-Nix artifacts nixify created.
# Usage: format-artifacts.sh <file> [<file> ...]
#
# Detects the project's formatter from config files / package.json and runs it
# on the passed files only (not the whole repo). If no formatter is detected,
# prints a note and exits 0 — most Nix-only projects don't have one.
#
# This prevents review feedback like "run our formatter on the file you created"
# (e.g. yusukebe/ax#27 asked for `bunx oxfmt --write .github/workflows/nix.yml` —
# we would run `pnpm dlx oxfmt --write` instead; never use npx/bunx on host).
#
# Runs BEFORE lint-artifacts.sh so the linter sees already-formatted files.
# The massive-change guard in lint-artifacts.sh (run after this script) checks
# the combined format+lint diff against the feature commit, so it catches
# massive changes from either the formatter or the linter on modified files.

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: format-artifacts.sh <file> [<file> ...]" >&2
  exit 1
fi

# Filter to files that exist (some args may be README sections that were
# edited in-place, not standalone files we can pass to a formatter).
files=()
for f in "$@"; do
  [ -f "$f" ] && files+=("$f")
done
if [ ${#files[@]} -eq 0 ]; then
  echo "no formattable files among args, skipping"
  exit 0
fi

# Detect the project's formatter. Checks are ordered by specificity — config
# files first, then package.json scripts. First match wins.
run_formatter() {
  local cmd=()
  local pkg_json="${PWD}/package.json"

  # oxfmt — .oxfmtrc.json or oxfmt in package.json
  if [ -f .oxfmtrc.json ] || \
     { [ -f "$pkg_json" ] && grep -q '"oxfmt"' "$pkg_json" 2>/dev/null; }; then
    if command -v pnpm >/dev/null 2>&1; then
      cmd=(pnpm dlx oxfmt --write)
    else
      echo "oxfmt detected but pnpm not available, skipping (never use npx/bunx on host)" >&2
      return 0
    fi
    echo "formatter: oxfmt"
    "${cmd[@]}" "${files[@]}"
    return 0
  fi

  # prettier — .prettierrc* or prettier in package.json
  if ls .prettierrc* >/dev/null 2>&1 || [ -f .prettierignore ] || \
     { [ -f "$pkg_json" ] && grep -q '"prettier"' "$pkg_json" 2>/dev/null; }; then
    if command -v pnpm >/dev/null 2>&1; then
      cmd=(pnpm dlx prettier --write)
    else
      echo "prettier detected but pnpm not available, skipping (never use npx/bunx on host)" >&2
      return 0
    fi
    echo "formatter: prettier"
    "${cmd[@]}" "${files[@]}"
    return 0
  fi

  # biome — biome.json or biome.jsonc
  if [ -f biome.json ] || [ -f biome.jsonc ]; then
    if command -v pnpm >/dev/null 2>&1; then
      cmd=(pnpm dlx @biomejs/biome format --write)
    else
      echo "biome detected but pnpm not available, skipping (never use npx/bunx on host)" >&2
      return 0
    fi
    echo "formatter: biome"
    "${cmd[@]}" "${files[@]}"
    return 0
  fi

  # deno fmt — deno.json or deno.jsonc
  if [ -f deno.json ] || [ -f deno.jsonc ]; then
    if command -v deno >/dev/null 2>&1; then
      echo "formatter: deno fmt"
      deno fmt "${files[@]}"
      return 0
    fi
    echo "deno fmt detected but deno not in PATH, skipping" >&2
    return 0
  fi

  echo "no project formatter detected (no .oxfmtrc.json, .prettierrc*, biome.json, deno.json), skipping"
  return 0
}

run_formatter
echo "format-artifacts: done"
