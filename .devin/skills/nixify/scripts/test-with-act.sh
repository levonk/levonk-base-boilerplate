#!/usr/bin/env bash
# Test the generated flake on BOTH ubuntu (via act) AND the host OS (via direct nix).
# Usage: test-with-act.sh [project-dir] [--workflow <path>] [--smoke <cmd>]
#
# A flake must pass on BOTH platforms it targets:
#   - ubuntu (what GitHub CI runs on) — validated via `act` inside an ubuntu container
#   - darwin (the macOS host platform) — validated via direct nix commands on the host
#
# `act` only simulates ubuntu containers; it cannot simulate darwin. Direct nix on
# the macOS host validates darwin but not ubuntu. Running BOTH gives full coverage:
#   - act catches Linux-only autoPatchelf issues, glibc linking, ubuntu stdenv
#   - direct nix catches Darwin framework issues, macOS SDK, darwin stdenv
#
# Note: Garnix (https://garnix.io) hosted CI is NOT validated by this script.
# Garnix is a maintainer-opt-in hosted service that activates when the maintainer
# installs the Garnix GitHub App — it is not a local workflow and cannot be
# simulated by `act`. The garnix.yaml (Step 16c) is inert until the app is
# installed. This script validates the required `.github/workflows/nix.yml`
# (the contributor-controlled CI), not Garnix.
#
# Default mode (--both): run act (ubuntu) THEN direct nix (host). Both must pass.
# --host-only: skip act, run direct nix only (use when Docker is unavailable;
#              validates ONLY the host OS — darwin on macOS, linux on Linux)
# --act-only:  skip direct nix, run act only (validates ONLY ubuntu)
#
# Options:
#   --workflow <path>  Path to the workflow file (default: .github/workflows/nix.yml)
#   --smoke <cmd>      Override the smoke command (default: --version)
#   --both             Run both act (ubuntu) and direct nix (host) — DEFAULT
#   --host-only        Run direct nix only (host OS; darwin on macOS)
#   --act-only         Run act only (ubuntu container)
#   --verbose          Full output
#
# Prerequisites:
#   - Docker installed and running (for act; required unless --host-only)
#   - Nix installed (for direct nix commands; always required)
#   - `act` in devbox.json (so `devbox shell` provides it) or nixpkgs fallback
#
# Exit codes:
#   0 — all requested validations passed
#   1 — one or more validations failed
#   2 — prerequisites missing (Docker unavailable for act mode)

set -euo pipefail

DIR="."
WORKFLOW=""
SMOKE="--version"
MODE="both"
VERBOSE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --workflow)  WORKFLOW="$2"; shift 2 ;;
    --smoke)     SMOKE="$2"; shift 2 ;;
    --both)      MODE="both"; shift ;;
    --host-only) MODE="host"; shift ;;
    --act-only)  MODE="act"; shift ;;
    --verbose)   VERBOSE="--verbose"; shift ;;
    -h|--help)
      echo "Usage: $0 [project-dir] [--workflow <path>] [--smoke <cmd>] [--both|--host-only|--act-only] [--verbose]"
      echo ""
      echo "Validates the generated flake on BOTH ubuntu (via act) and the host OS (via direct nix)."
      echo "Default: --both (run act then direct nix; both must pass)."
      echo "  --host-only  Run direct nix only (host OS; darwin on macOS). Use when Docker unavailable."
      echo "  --act-only   Run act only (ubuntu container)."
      echo "Catches real build failures on both platforms before pushing the PR."
      exit 0
      ;;
    *) DIR="$1"; shift ;;
  esac
done

if [ -z "$WORKFLOW" ]; then
  WORKFLOW="$DIR/.github/workflows/nix.yml"
fi

if [ ! -f "$DIR/flake.nix" ]; then
  echo "ERROR: flake.nix not found in $DIR" >&2
  exit 1
fi

# ── Check prerequisites ────────────────────────────────────────────────────
check_docker() {
  command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

check_act() {
  command -v act >/dev/null 2>&1
}

# ── Direct nix validation (host OS — darwin on macOS, linux on Linux) ──────
# This catches Darwin framework issues, macOS SDK problems, darwin stdenv
# failures — everything `act` (ubuntu-only) cannot see.
run_host_nix() {
  local dir="$1"
  local smoke="$2"
  local host_os
  host_os="$(uname -s)"
  echo "[test-with-act] === HOST-OS validation ($host_os) ==="
  echo "[test-with-act] Running nix commands directly on the host to validate the"
  echo "[test-with-act] $host_os platform. This catches Darwin framework / macOS SDK"
  echo "[test-with-act] issues that act (ubuntu-only) cannot see."
  echo ""

  local failed=0

  echo "── nix flake check --all-systems --no-build ──"
  if (cd "$dir" && nix flake check --all-systems --no-build); then
    echo "ok: flake check"
  else
    echo "FAILED: flake check"
    failed=1
  fi

  echo ""
  echo "── nix build .#default (host system) ──"
  if (cd "$dir" && nix build .#default --print-build-logs); then
    echo "ok: nix build .#default"
  else
    echo "FAILED: nix build .#default"
    failed=1
  fi

  echo ""
  echo "── nix run .#default -- $smoke ──"
  if (cd "$dir" && nix run .#default -- "$smoke"); then
    echo "ok: smoke test ($smoke)"
  else
    echo "FAILED: smoke test ($smoke)"
    failed=1
  fi

  # Test #source output if it exists
  if (cd "$dir" && nix flake show --json 2>/dev/null | jq -e 'any(.packages[]?; has("source"))' >/dev/null 2>&1); then
    echo ""
    echo "── nix build .#source (host system) ──"
    if (cd "$dir" && nix build .#source --print-build-logs); then
      echo "ok: source build"
    else
      echo "FAILED: source build"
      failed=1
    fi
  fi

  echo ""
  if [ "$failed" -eq 0 ]; then
    echo "[test-with-act] HOST-OS validation PASSED ($host_os)."
  else
    echo "[test-with-act] HOST-OS validation FAILED ($host_os)."
  fi
  return $failed
}

# ── act validation (ubuntu container — what GitHub CI runs on) ─────────────
# This catches Linux-only autoPatchelf issues, glibc linking, ubuntu stdenv
# failures — everything direct nix on macOS cannot see.
run_act() {
  local dir="$1"
  local workflow="$2"

  if [ ! -f "$workflow" ]; then
    echo "[test-with-act] WARNING: Workflow file not found: $workflow" >&2
    echo "[test-with-act] Skipping act (ubuntu) validation — no nix.yml generated yet." >&2
    echo "[test-with-act] Generate the workflow first (see references/advanced-features.md)." >&2
    return 0
  fi

  if ! check_docker; then
    echo "[test-with-act] Docker is not available or not running — cannot run act." >&2
    echo "[test-with-act] act (ubuntu validation) is REQUIRED for --both and --act-only modes." >&2
    echo "[test-with-act] Install Docker, or use --host-only to validate only the host OS." >&2
    return 2
  fi

  # Get act — prefer system act, fall back to nix run nixpkgs#act
  local act_cmd
  if check_act; then
    act_cmd="act"
  else
    echo "[test-with-act] act not on PATH — will use 'nix run nixpkgs#act'"
    act_cmd="nix run nixpkgs#act --"
  fi

  echo "[test-with-act] === UBUNTU validation (via act) ==="
  echo "[test-with-act] Running workflow: $workflow"
  echo "[test-with-act] Using: $act_cmd"
  echo "[test-with-act] This validates the ubuntu runner that GitHub CI uses — catches"
  echo "[test-with-act] Linux-only autoPatchelf, glibc linking, ubuntu stdenv issues."
  echo ""

  # Run the workflow's check job via act.
  # -W: specify workflow file
  # -j: specify job name (the nix.yml template uses "check")
  # --rm: remove container after run
  #
  # The DeterminateSystems/nix-installer-action in the workflow will install
  # Nix inside the act container. We use the default ubuntu image which has
  # the prerequisites (systemd, curl, etc.).
  local job_name="check"

  if [ -n "$VERBOSE" ]; then
    echo "[test-with-act] Running: $act_cmd -W \"$workflow\" -j $job_name --rm -v"
    (cd "$dir" && $act_cmd -W "$workflow" -j "$job_name" --rm -v)
  else
    (cd "$dir" && $act_cmd -W "$workflow" -j "$job_name" --rm)
  fi

  local result=$?
  echo ""
  if [ $result -eq 0 ]; then
    echo "[test-with-act] UBUNTU validation PASSED (via act)."
  else
    echo "[test-with-act] UBUNTU validation FAILED (via act)."
    echo "[test-with-act] Common fixes:"
    echo "  - Missing runtime deps: run scripts/detect-runtime-deps.sh"
    echo "  - cleanSource issues: see references/flake-templates/source-build/rust.md"
    echo "  - Linux autoPatchelf: see references/flake-templates/prebuilt-tarball.md"
  fi
  return $result
}

# ── Main: run the requested validations ────────────────────────────────────
overall_failed=0

if [ "$MODE" = "host" ]; then
  # Host-only: direct nix on the host OS (darwin on macOS)
  run_host_nix "$DIR" "$SMOKE" || overall_failed=1
elif [ "$MODE" = "act" ]; then
  # Act-only: ubuntu container
  run_act "$DIR" "$WORKFLOW" || overall_failed=1
else
  # Both (default): act (ubuntu) THEN direct nix (host). Both must pass.
  echo "[test-with-act] Running BOTH validations: ubuntu (act) + host OS ($(uname -s))."
  echo "[test-with-act] Both must pass — act catches Linux issues, direct nix catches"
  echo "[test-with-act] Darwin issues. Neither alone is sufficient."
  echo ""
  echo "============================================================"
  run_act "$DIR" "$WORKFLOW" || overall_failed=1
  echo ""
  echo "============================================================"
  run_host_nix "$DIR" "$SMOKE" || overall_failed=1
  echo ""
  echo "============================================================"
fi

echo ""
if [ "$overall_failed" -eq 0 ]; then
  echo "[test-with-act] All validations PASSED — the generated flake is ready to push."
else
  echo "[test-with-act] One or more validations FAILED — fix the issues above before pushing."
fi
exit $overall_failed
