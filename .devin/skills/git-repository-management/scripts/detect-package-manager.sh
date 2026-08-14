#!/usr/bin/env bash
# detect-package-manager.sh — resolve the active package manager for a project
#
# Single source of truth for "which package runner should I invoke?" Used by
# git-repository-management (git-collect.sh quality checks) and project-detection
# (detect-build-systems.sh) so both skills agree on the same answer.
#
# Resolution order (first match wins):
#   1. `packageManager` field in package.json (e.g. "pnpm@9.10.0" → pnpm)
#   2. Lockfile presence (pnpm-lock.yaml / yarn.lock / bun.lockb / package-lock.json)
#   3. `engines.npm` / `engines.yarn` / `engines.pnpm` hints in package.json
#   4. Fallback: npm (always installed with Node)
#
# Usage:
#   detect-package-manager.sh [repo-path]            # text: <manager>
#   detect-package-manager.sh [repo-path] --json     # JSON
#   detect-package-manager.sh [repo-path] --exec     # print the runner command
#                                                     # (e.g. "pnpm" or "devbox run -- pnpm")
#
# Output (text mode):  pnpm | yarn | npm | bun | deno
# Output (json mode):  {"manager":"pnpm","source":"...","runner":"...","available":true|false,"recommendation":"..."}
# Output (exec mode):  the runner command the caller should invoke (no args)
#
# Notes:
#   - Walks up from the given path (or $PWD) to find the nearest package.json /
#     lockfile, so it works from any subdirectory of a monorepo.
#   - Does NOT execute the package manager — only reports which one to use.
#   - Detects environment wrappers (devbox/mise/flox/direnv/nix) via
#     cli-tool-discovery.sh and prefixes the runner with the wrapper when
#     appropriate. Callers that already wrap commands themselves can ignore
#     the `runner` field and use `manager` directly.
#   - Fallback (no package.json, no lockfile, no engines hint) is pnpm, NOT
#     npm — pnpm is the canonical package manager for this workspace. If pnpm
#     isn't available, the JSON `recommendation` field and a stderr warning
#     tell the caller to add pnpm to devbox.json.
#   - Availability check: uses cli-tool-discovery.sh to verify the manager
#     is actually runnable (on PATH or via env wrapper). When not available,
#     `available` is false and `recommendation` contains install instructions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Parse args ---
json_output=0
exec_output=0
repo_path="${PWD}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)
            json_output=1
            shift
            ;;
        --exec)
            exec_output=1
            shift
            ;;
        --help|-h)
            cat <<'EOF'
Usage: detect-package-manager.sh [repo-path] [--json|--exec]
  --json   Emit JSON: {"manager":"...","source":"...","runner":"...","available":...,"recommendation":"..."}
  --exec   Emit the runner command (may include wrapper prefix)
Default output: the manager name (pnpm|yarn|npm|bun|deno)
Fallback (no package.json): pnpm — add to devbox.json if not available.
EOF
            exit 0
            ;;
        *)
            repo_path="$1"
            shift
            ;;
    esac
done

# --- Walk up from a starting dir looking for a file ---
walk_up_find() {
    local start="$1" needle="$2"
    local dir="$start"
    while [[ "$dir" != "/" && -n "$dir" ]]; do
        if [[ -f "$dir/$needle" ]]; then
            printf '%s\n' "$dir/$needle"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# --- Resolve repo root from repo_path (git) ---
resolve_repo_root() {
    local path="$1"
    if command -v git >/dev/null 2>&1; then
        (cd "$path" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null) || true
    fi
}

# --- Detect environment wrapper via cli-tool-discovery.sh ---
# Returns the wrapper prefix (e.g. "devbox run --") or empty string.
detect_wrapper() {
    local cli_discovery="$SCRIPT_DIR/cli-tool-discovery.sh"
    [[ -f "$cli_discovery" ]] || return 0
    local result
    result="$(bash "$cli_discovery" __wrapper_probe__ 2>/dev/null || true)"
    case "$result" in
        "WRAPPER: "*)
            local wrapper_full="${result#WRAPPER: }"
            local prefix="${wrapper_full% __wrapper_probe__}"
            printf '%s\n' "$prefix"
            ;;
    esac
}

# --- Read packageManager field from package.json (jq if available, else grep) ---
read_package_manager_field() {
    local pkg="$1"
    [[ -f "$pkg" ]] || return 1
    if command -v jq >/dev/null 2>&1; then
        jq -r '.packageManager // empty' "$pkg" 2>/dev/null || true
    else
        # Fallback: grep the field. Tolerant of single/double quotes and spaces.
        grep -m1 -E '"packageManager"[[:space:]]*:' "$pkg" 2>/dev/null \
            | sed -E 's/.*"packageManager"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' \
            | head -1 || true
    fi
}

# --- Read engines field from package.json ---
read_engines_field() {
    local pkg="$1" key="$2"
    [[ -f "$pkg" ]] || return 1
    if command -v jq >/dev/null 2>&1; then
        jq -r ".engines.${key} // empty" "$pkg" 2>/dev/null || true
    else
        grep -m1 -E "\"${key}\"[[:space:]]*:" "$pkg" 2>/dev/null \
            | sed -E "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\1/" \
            | head -1 || true
    fi
}

# --- Main detection ---
manager=""
source=""
runner=""

# Find the nearest package.json (walk up from repo_path)
pkg_path=""
if command -v git >/dev/null 2>&1; then
    repo_root="$(cd "$repo_path" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
fi
[[ -z "$repo_root" ]] && repo_root="$repo_path"

# Walk up from repo_path to find the nearest package.json
nearest_pkg="$(walk_up_find "$repo_path" "package.json" || true)"
if [[ -z "$nearest_pkg" ]]; then
    # Fall back to repo root
    [[ -f "$repo_root/package.json" ]] && nearest_pkg="$repo_root/package.json"
fi

if [[ -n "$nearest_pkg" ]]; then
    nearest_dir="$(dirname "$nearest_pkg")"

    # 1. packageManager field
    pm_field="$(read_package_manager_field "$nearest_pkg")"
    if [[ -n "$pm_field" ]]; then
        # Strip version: "pnpm@9.10.0" → "pnpm", "yarn@4.0.0" → "yarn"
        manager="${pm_field%%@*}"
        source="packageManager-field"
    fi

    # 2. Lockfile presence (only if packageManager didn't match)
    if [[ -z "$manager" ]]; then
        if [[ -f "$nearest_dir/pnpm-lock.yaml" ]]; then
            manager="pnpm"; source="lockfile"
        elif [[ -f "$nearest_dir/yarn.lock" ]]; then
            manager="yarn"; source="lockfile"
        elif [[ -f "$nearest_dir/bun.lockb" ]]; then
            manager="bun"; source="lockfile"
        elif [[ -f "$nearest_dir/deno.json" ]]; then
            manager="deno"; source="lockfile"
        elif [[ -f "$nearest_dir/package-lock.json" ]]; then
            manager="npm"; source="lockfile"
        fi
    fi

    # 3. engines hints (only if still unmatched)
    if [[ -z "$manager" ]]; then
        if [[ -n "$(read_engines_field "$nearest_pkg" "pnpm")" ]]; then
            manager="pnpm"; source="engines"
        elif [[ -n "$(read_engines_field "$nearest_pkg" "yarn")" ]]; then
            manager="yarn"; source="engines"
        elif [[ -n "$(read_engines_field "$nearest_pkg" "npm")" ]]; then
            manager="npm"; source="engines"
        fi
    fi
fi

# 4. Fallback to pnpm (canonical choice per tech-stack-table include).
# When there's no package.json, lockfile, or engines hint, default to pnpm
# rather than npm — pnpm is the standard package manager for this workspace.
# If pnpm isn't available on PATH or via an env wrapper, emit a recommendation
# to add it to devbox.json so callers (git-collect.sh, detect-build-systems.sh)
# can either install it or skip package-manager-dependent checks.
if [[ -z "$manager" ]]; then
    manager="pnpm"
    source="fallback"
fi

# Build the runner by delegating to cli-tool-discovery --runner node.
# The runner mode is the single source of truth for "how do I invoke an
# ad-hoc command in ecosystem X?" — it pairs binary resolution with the
# canonical invocation pattern (pnpm dlx on host, bunx in container) from
# the tech-stack table. We use the `package` field as the runner since
# detect-package-manager is about ad-hoc package execution, not scripts.
#
# We still emit the `manager` field (pnpm/yarn/bun/deno/npm) separately so
# callers that need to dispatch `pnpm test` vs `npm test` vs `yarn test`
# can use `manager` directly — the `runner` field is for ad-hoc execution.
runner=""
if [[ -f "$SCRIPT_DIR/cli-tool-discovery.sh" ]]; then
    runner_json="$(bash "$SCRIPT_DIR/cli-tool-discovery.sh" --runner node 2>/dev/null || true)"
    if [[ -n "$runner_json" ]]; then
        # Extract the package field. jq if available, else grep.
        if command -v jq >/dev/null 2>&1; then
            runner="$(printf '%s' "$runner_json" | jq -r '.package // empty' 2>/dev/null || true)"
        else
            runner="$(printf '%s' "$runner_json" | grep -oE '"package"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"package"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
        fi
    fi
fi

# Fallback to the old behavior if cli-tool-discovery --runner failed or
# isn't available: prefix the manager with the detected wrapper.
if [[ -z "$runner" ]]; then
    wrapper="$(detect_wrapper || true)"
    if [[ -n "$wrapper" ]]; then
        runner="${wrapper} ${manager}"
    else
        runner="${manager}"
    fi
fi

# Check availability: is the manager actually runnable?
# Uses cli-tool-discovery.sh if available, else falls back to command -v.
manager_available=1
availability_check=""
if [[ -x "$SCRIPT_DIR/cli-tool-discovery.sh" ]]; then
    avail_result="$("$SCRIPT_DIR/cli-tool-discovery.sh" "$manager" 2>/dev/null || true)"
    case "$avail_result" in
        "FOUND:"*|"WRAPPER:"*)
            manager_available=1
            ;;
        "NOT_FOUND:"*)
            manager_available=0
            ;;
    esac
else
    if ! command -v "$manager" >/dev/null 2>&1; then
        manager_available=0
    fi
fi

# Build recommendation when the manager isn't available.
# pnpm is the canonical fallback — recommend adding it to devbox.json so
# `devbox run -- pnpm ...` works. For other managers, recommend installing
# via the appropriate channel.
recommendation=""
if [[ "$manager_available" -eq 0 ]]; then
    case "$manager" in
        pnpm)
            recommendation="pnpm not found — add to devbox.json (run: devbox add pnpm) or install via npm i -g pnpm"
            ;;
        yarn)
            recommendation="yarn not found — install via corepack enable yarn or npm i -g yarn"
            ;;
        bun)
            recommendation="bun not found — install via curl -fsSL https://bun.sh/install | bash"
            ;;
        deno)
            recommendation="deno not found — install via curl -fsSL https://deno.land/install.sh | sh"
            ;;
        *)
            recommendation="${manager} not found — install before running package-manager commands"
            ;;
    esac
    # Warn on stderr so text-mode stdout stays clean but the caller sees the issue
    echo "⚠️ ${recommendation}" >&2
fi

# --- Output ---
if [[ "$json_output" -eq 1 ]]; then
    printf '{"manager":"%s","source":"%s","runner":"%s","available":%s,"recommendation":"%s"}\n' \
        "$manager" "$source" "$runner" \
        "$([[ "$manager_available" -eq 1 ]] && echo true || echo false)" \
        "$recommendation"
elif [[ "$exec_output" -eq 1 ]]; then
    printf '%s\n' "$runner"
else
    printf '%s\n' "$manager"
fi

