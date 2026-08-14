#!/usr/bin/env bash
# Validate Nix flake: check, build, run, and test
# Usage: validate-flake.sh <binary-name> [project-name]
# Use --verbose for full output

set -euo pipefail

BINARY="${1:?Usage: validate-flake.sh <binary-name> [project-name]}"
PROJECT_NAME="${2:-}"
VERBOSE="${3:-}"

# Structural guard: a nixify flake MUST expose package outputs, not just
# devShells. A devShell-only flake cannot be installed via nix run / nix
# profile add / home-manager. (Reference: 9router PR #1405 review feedback.)
if ! grep -qE 'packages\.' flake.nix 2>/dev/null; then
  echo "FAILED: flake.nix has no packages output — devShell-only flakes are not installable"
  echo "  A nixify flake must expose packages.<system>.default (or a named output)"
  echo "  so users can run: nix run github:... / nix profile add github:..."
  exit 1
fi
echo "ok: flake.nix exposes package outputs"

run_step() {
  local desc="$1"
  shift
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "Running: $desc"
    "$@" || { echo "FAILED: $desc"; return 1; }
    echo "PASSED: $desc"
  else
    "$@" >/dev/null 2>&1 || { echo "FAILED: $desc"; return 1; }
    echo "ok: $desc"
  fi
}

run_step "flake check --all-systems" nix flake check --all-systems --no-build
run_step "nix build" nix build .
run_step "binary --version" sh -c "result/bin/$BINARY --version"
run_step "nix run --help" nix run . -- --help

# Test the project-named output if a project name was given. Users naturally
# try .#<project-name>; a flake that only exposes `default` is reported broken.
if [ -n "$PROJECT_NAME" ] && nix flake show . 2>/dev/null | grep -q "packages\..*\.$PROJECT_NAME"; then
  run_step "nix run .#$PROJECT_NAME" nix run .#"$PROJECT_NAME" -- --help
fi

# Test named outputs if they exist
if nix flake show . 2>/dev/null | grep -q 'source'; then
  run_step "nix run .#source" nix run .#source -- --help
fi

echo "all checks passed"
