#!/usr/bin/env bash
# cli-tool-discovery.sh — resolve a CLI tool through environment wrappers and standard PATH locations
#
# Usage:
#   cli-tool-discovery.sh <tool-name> [--json]          # resolve only, print result
#   cli-tool-discovery.sh -- <tool-name> [args...]      # resolve and exec the tool
#   cli-tool-discovery.sh --runner <ecosystem>          # resolve the ad-hoc runner for an ecosystem
#
# Output (resolve mode, text): FOUND: <path> | WRAPPER: <wrapper-cmd> | NOT_FOUND: <tool>
# Output (resolve mode, json): {"status":"found|wrapper|not_found", "path": "...", "wrapper": "...", "tool": "..."}
# Output (exec mode): the tool's own stdout/stderr/exit code
# Output (runner mode, json only):
#   {"ecosystem":"python","binary":"uv","binary_status":"found|wrapper|not_found",
#    "binary_path":"...","wrapper":"...","script":"uv run --script","package":"uvx",
#    "fallback":"...","fallback_runner":"...","recommendation":"..."}
#
# Resolution order (resolve/exec mode):
#   1. Devbox shell check (DEVBOX_SHELL / IN_DEVBOX_SHELL) — first, because
#      if true it simplifies all downstream logic: devbox binaries are on
#      PATH, no wrapper detection needed.
#      a. command -v (PATH — devbox-managed binaries are here)
#      b. Path-exhaustion (standard locations + package managers)
#      c. `devbox add <tool>` then retry (a) and (b)
#      d. If still not found, skip other wrappers, go to nix/uv fallback
#   2. Not in devbox shell — if devbox is available AND a devbox.json exists
#      up the tree, verify the tool exists inside the devbox environment
#      (`devbox run -- command -v <tool>`). If not found, try `devbox add`
#      and recheck. If confirmed available, return WRAPPER:devbox run --.
#      If still not found inside devbox, fall through to step 3.
#   3. Normal flow (no devbox involved):
#      a. Already on PATH (command -v)
#      b. Other environment wrappers (mise, flox, direnv, nix) — walks up from cwd
#      c. Tech-stack-aware standard PATH locations (30+ dirs)
#      d. Package manager lookup (brew, mise, asdf)
#      e. Repo-root fallback dirs ($repo_root/bin, scripts/, .local/bin) —
#         LAST and least secure: a cloned repo could contain malicious
#         executables in bin/. Covers Hermit shims and similar project-local
#         tool layouts.
#   4. nix/uv fallback (common exit from both branches):
#      a. If tool == uv: uv→pip fallback (ensure_devbox_package + pip)
#      b. nix: is nix available? search nixpkgs for <tool>. If found,
#         `nix profile install` and recheck PATH.
#      c. uv: is uv available? search PyPI for <tool>. If found,
#         `uv tool install` and recheck PATH.
#   5. Reports NOT_FOUND with what was checked
#
# Runner mode (--runner <ecosystem>):
#   Resolves the canonical ad-hoc runner for an ecosystem per the tech-stack table.
#   Supported ecosystems: python, node, rust, go.
#   - python: uv (script: `uv run --script`, package: `uvx`); fallback pip+python3
#   - node:   pnpm on host (`pnpm dlx`), bun in container (`bunx`); no fallback (install pnpm)
#   - rust:   cargo (`cargo binstall` preferred, `cargo install` fallback); no fallback
#   - go:     go (`go install <pkg>@latest`); no fallback
#   When the binary is not_found and a devbox.json exists up the tree, the
#   `recommendation` field tells the caller to add the binary to devbox.json.
#
# Timeout configuration (env vars):
#   CLTOOL_PROBE_TIMEOUT_SECS   (default 30)  — lookups: brew list, mise which,
#     nix eval, devbox run -- command -v, etc.
#   CLTOOL_INSTALL_TIMEOUT_SECS (default 45)  — network installs: devbox add,
#     nix profile install, uv tool install. Reduced from 120s to 45s to avoid
#     blocking the resolver for 6+ minutes when multiple install fallbacks fire
#     for a missing tool. Real installs in a devbox/nix environment typically
#     complete in under 30s; 45s is a safe ceiling. Set higher if on a slow
#     connection and you want installs to succeed rather than fail fast.
#   CLTOOL_INSTALL_DISABLED     (default 0)   — set to 1 to skip ALL install
#     fallbacks (devbox add, nix profile install, uv tool install). Resolve-only
#     mode: the script checks PATH, wrappers, standard locations, and package
#     managers, but never attempts to install a missing tool. Use this when
#     you only need to find a tool that already exists, not bootstrap one.
#     Also set by wrapper-helpers.sh's probe_devbox() when devbox is broken.
#   DEVBOX_PROBE_TIMEOUT_SECS   (default 30)  — devbox run -- probes specifically.
#   Exec mode (-- <tool> [args]) is never timed — it's the user's command.
set -euo pipefail

# --- Timeout configuration ---
# Probes (brew list, mise which, nix eval, etc.): short — these are lookups.
# Installs (devbox add, nix profile install, uv tool install): long — network fetches.
# Override via environment. macOS lacks timeout(1); see run_timed fallback.
probe_timeout="${CLTOOL_PROBE_TIMEOUT_SECS:-30}"
install_timeout="${CLTOOL_INSTALL_TIMEOUT_SECS:-45}"
install_disabled="${CLTOOL_INSTALL_DISABLED:-0}"

# --- Parse args: runner mode vs exec mode vs resolve mode ---
exec_mode=0
json_output=0
runner_mode=0
runner_ecosystem=""
tool=""
tool_args=()

if [[ "${1:-}" == "--runner" ]]; then
    runner_mode=1
    shift
    runner_ecosystem="${1:?Usage: cli-tool-discovery.sh --runner <python|node|rust|go>}"
    shift
elif [[ "${1:-}" == "--" ]]; then
    exec_mode=1
    shift
    tool="${1:?Usage: cli-tool-discovery.sh -- <tool-name> [args...]}"
    shift
    tool_args=("$@")
elif [[ "${1:-}" == "--json" ]]; then
    json_output=1
    shift
    tool="${1:?Usage: cli-tool-discovery.sh --json <tool-name>}"
else
    tool="${1:?Usage: cli-tool-discovery.sh <tool-name> [--json] | -- <tool-name> [args...] | --runner <ecosystem>}"
    shift
    [[ "${1:-}" == "--json" ]] && json_output=1
fi

repo_root=""
if command -v git >/dev/null 2>&1; then
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

# --- Walk up from cwd looking for config files ---
walk_up() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        for pattern in "$@"; do
            if [[ -f "$dir/$pattern" ]]; then echo "$dir"; return 0; fi
        done
        dir="$(dirname "$dir")"
    done
    return 1
}

# --- Hang-safe command runner ---
# Run <cmd...> with a timeout (seconds). If the command hangs, kill it and
# return 124 (matching timeout(1) convention). stdout is preserved via temp
# file in the background+kill fallback so command substitution works.
# Uses timeout(1) if available, gtimeout(1) (GNU coreutils on macOS), or
# falls back to background + kill.
run_timed() {
    local _timeout="$1"; shift
    if command -v timeout >/dev/null 2>&1; then
        timeout "$_timeout" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$_timeout" "$@"
    else
        # No timeout(1) — background + kill, capturing stdout via temp file
        # so command substitution works. Stderr passes through normally.
        local _tmp; _tmp="$(mktemp 2>/dev/null || echo "/tmp/ctd.$$.tmp")"
        "$@" >"$_tmp" 2>&1 &
        local _pid=$!
        local _elapsed=0
        while kill -0 "$_pid" 2>/dev/null; do
            if [[ "$_elapsed" -ge "$_timeout" ]]; then
                kill -9 "$_pid" 2>/dev/null
                wait "$_pid" 2>/dev/null || true
                rm -f "$_tmp"
                return 124
            fi
            sleep 1
            _elapsed=$((_elapsed + 1))
        done
        wait "$_pid"; local _rc=$?
        cat "$_tmp" 2>/dev/null; rm -f "$_tmp"
        return "$_rc"
    fi
}

# --- Hang-safe devbox run ---
# Run `devbox run -- <cmd>` with a timeout. If devbox hangs (broken wrapper
# recursion, nix store issues), kill it and return 124 (timeout). This prevents
# the resolver from hanging forever when devbox is broken.
# Override timeout via DEVBOX_PROBE_TIMEOUT_SECS (default 30).
devbox_run_timed() {
    run_timed "${DEVBOX_PROBE_TIMEOUT_SECS:-30}" devbox run -- "$@"
}

# --- Ensure a package is listed in devbox.json, walking up from cwd ---
# Uses `devbox add` if devbox is on PATH, otherwise falls back to a Python
# or jq edit. Idempotent — does nothing if the package is already present.
# Returns 0 if devbox.json was found and updated (or already contains pkg),
# 1 if no devbox.json was found.
ensure_devbox_package() {
    local pkg="$1"
    local devbox_dir
    if ! devbox_dir="$(walk_up devbox.json)"; then
        return 1
    fi
    local devbox_json="$devbox_dir/devbox.json"

    # If devbox is available, prefer `devbox add` (idempotent in devbox).
    # Skipped when CLTOOL_INSTALL_DISABLED=1 — falls through to the JSON edit
    # fallback below, which records the package without running devbox add.
    if [[ "$install_disabled" -eq 0 ]] && command -v devbox >/dev/null 2>&1; then
        (cd "$devbox_dir" && run_timed "$install_timeout" devbox add "$pkg" >/dev/null 2>&1) || true
        return 0
    fi

    # Fallback: edit devbox.json in place.
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$pkg" "$devbox_json" <<'PY'
import json, sys, os
pkg, path = sys.argv[1], sys.argv[2]
with open(path, 'r') as f:
    data = json.load(f)
packages = data.get('packages', {})
if isinstance(packages, dict):
    if pkg not in packages:
        packages[pkg] = ""
        data['packages'] = packages
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
            f.write('\n')
elif isinstance(packages, list):
    if pkg not in packages:
        packages.append(pkg)
        data['packages'] = packages
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
            f.write('\n')
PY
        return 0
    fi

    # Last resort: simple grep check, then append (assumes trailing object/map).
    if ! grep -qE "\"$pkg\"|'$pkg'" "$devbox_json" 2>/dev/null; then
        # Insert before the final closing brace. This is a best-effort edit.
        local tmp
        tmp="$(mktemp)"
        if tail -c 20 "$devbox_json" | grep -q '}' 2>/dev/null; then
            python3 -c "
import json, sys
with open('$devbox_json', 'r') as f: data=json.load(f)
pkgs = data.setdefault('packages', {})
if isinstance(pkgs, dict) and '$pkg' not in pkgs: pkgs['$pkg'] = ''
if isinstance(pkgs, list) and '$pkg' not in pkgs: pkgs.append('$pkg')
with open('$devbox_json', 'w') as f: json.dump(data, f, indent=2); f.write('\n')
" 2>/dev/null || return 0
        fi
        rm -f "$tmp"
    fi
    return 0
}

# --- Detect whether we are inside a container ---
# Used by runner mode to pick bunx (container) vs pnpm dlx (host) for node.
# Signals: /.dockerenv file, $DOCKER_CONTAINER env var, or cgroup v1/v2 container markers.
in_container() {
    [[ -f /.dockerenv ]] && return 0
    [[ -n "${DOCKER_CONTAINER:-}" ]] && return 0
    if [[ -f /proc/1/cgroup ]]; then
        if grep -qE '(docker|containerd|lxc|kubepods)' /proc/1/cgroup 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# --- Resolve the ad-hoc runner for an ecosystem (runner mode) ---
# Prints JSON to stdout describing the binary, the script runner, the package
# runner, the fallback, and a recommendation when the binary is not found.
#
# Ecosystems: python, node, rust, go. See the script header for the mapping.
resolve_runner() {
    local eco="$1"
    local binary="" script_runner="" package_runner="" fallback="" fallback_runner=""
    case "$eco" in
        python)
            binary="uv"
            script_runner="uv run --script"
            package_runner="uvx"
            fallback="pip install + python3"
            fallback_runner="python3"
            ;;
        node)
            if in_container; then
                binary="bun"
                package_runner="bunx"
                script_runner=""
                fallback=""
                fallback_runner=""
            else
                binary="pnpm"
                package_runner="pnpm dlx"
                script_runner=""
                fallback=""
                fallback_runner=""
            fi
            ;;
        rust)
            binary="cargo"
            script_runner=""
            package_runner="cargo binstall -y"
            fallback="cargo install"
            fallback_runner="cargo"
            ;;
        go)
            binary="go"
            script_runner=""
            package_runner="go install"
            fallback=""
            fallback_runner=""
            ;;
        *)
            echo "ERROR: unknown ecosystem: $eco (supported: python, node, rust, go)" >&2
            exit 2
            ;;
    esac

    # Resolve the binary via the existing resolve_tool path.
    # Temporarily set $tool so resolve_tool picks it up.
    tool="$binary"
    local result status value
    result="$(resolve_tool)" || true
    status="${result%%:*}"
    value="${result#*:}"

    local binary_status="" binary_path="" wrapper=""
    case "$status" in
        FOUND)
            binary_status="found"
            binary_path="$value"
            ;;
        WRAPPER)
            binary_status="wrapper"
            wrapper="$value"
            ;;
        FALLBACK)
            # uv → pip fallback already resolved by resolve_tool.
            # Treat as not_found for runner purposes; the caller uses
            # fallback/fallback_runner instead of the binary.
            binary_status="not_found"
            ;;
        NOT_FOUND)
            binary_status="not_found"
            ;;
    esac

    # Build recommendation when the binary is not found.
    local recommendation=""
    if [[ "$binary_status" == "not_found" ]]; then
        if walk_up devbox.json >/dev/null 2>&1; then
            recommendation="add ${binary} to devbox.json (run: devbox add ${binary})"
        elif [[ -n "$fallback_runner" ]]; then
            recommendation="use ${fallback_runner} as fallback"
        else
            recommendation="${binary} not found; install before running ${eco} ad-hoc commands"
        fi
    fi

    # Emit JSON. Empty fields are emitted as empty strings; callers can check
    # binary_status to decide which field to use.
    # Escape any double quotes in paths/recommendation (rare but safe).
    local esc_path="${binary_path//\"/\\\"}"
    local esc_rec="${recommendation//\"/\\\"}"
    printf '{"ecosystem":"%s","binary":"%s","binary_status":"%s","binary_path":"%s","wrapper":"%s","script":"%s","package":"%s","fallback":"%s","fallback_runner":"%s","recommendation":"%s"}\n' \
        "$eco" "$binary" "$binary_status" "$esc_path" "$wrapper" \
        "$script_runner" "$package_runner" "$fallback" "$fallback_runner" "$esc_rec"
}

# --- Path-exhaustion search: standard PATH locations + package managers ---
# Prints "FOUND:<path>" to stdout and returns 0 if the tool is found, returns 1
# otherwise. Called by resolve_tool() and by the devbox-aware retry path.
search_standard_paths() {
    local arch=""
    arch="$(uname -m 2>/dev/null || true)"
    local search_dirs=()
    search_dirs+=(
        "${XDG_BIN_HOME:-}"
        "$HOME/.local/bin"
        "$HOME/.nix-profile/bin"
        "/nix/var/nix/profiles/default/bin"
        "$HOME/bin"
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/sbin"
        "/usr/bin"
        "/sbin"
        "/bin"
    )
    # Homebrew: only check the prefix for the current arch.
    # A Time Machine restore across arches can leave a stale directory
    # with non-universal binaries that won't run.
    case "$arch" in
        arm64)      search_dirs+=("/opt/homebrew/bin" "/opt/homebrew/sbin") ;;
        #x86_64|i386) search_dirs+=("/usr/local/bin" "/usr/local/sbin") ;;
    esac
    # MacPorts (both arches use /opt/local)
    search_dirs+=("/opt/local/bin")
    search_dirs+=("/snap/bin" "/run/current-system/sw/bin")
    search_dirs+=(
        "$HOME/.cargo/bin"
        "$HOME/.bun/bin"
        "$HOME/.deno/bin"
        "$HOME/.volta/bin"
        "$HOME/go/bin"
        "$HOME/.rbenv/shims"
        "$HOME/.pyenv/shims"
        "$HOME/.pixi/bin"
        "$HOME/.krew/bin"
        "$HOME/.foundry/bin"
    )
    if [[ -d "$HOME/.nvm/versions/node" ]]; then
        for nv in "$HOME/.nvm/versions/node"/*/bin; do
            [[ -d "$nv" ]] && search_dirs+=("$nv")
        done
    fi
    for inst_dir in "$HOME/.local/share/mise/installs"/*/bin "$HOME/.local/share/rtx/installs"/*/bin; do
        [[ -d "$inst_dir" ]] && search_dirs+=("$inst_dir")
    done
    if [[ -n "$repo_root" ]]; then
        if [[ -f "$repo_root/package.json" ]]; then
            search_dirs+=("$repo_root/node_modules/.bin" "$repo_root/.bin")
        fi
        if [[ -f "$repo_root/Cargo.toml" ]]; then
            search_dirs+=("$repo_root/target/release" "$repo_root/target/debug")
        fi
        if [[ -f "$repo_root/go.mod" ]]; then
            search_dirs+=("$repo_root/bin" "$repo_root/.bin")
        fi
        if [[ -f "$repo_root/pyproject.toml" || -f "$repo_root/requirements.txt" ]]; then
            search_dirs+=("$repo_root/.venv/bin" "$repo_root/.local/bin")
        fi
        if [[ -f "$repo_root/Gemfile" ]]; then
            search_dirs+=("$repo_root/bin" "$repo_root/.bundle/bin")
        fi
        if [[ -f "$repo_root/composer.json" ]]; then
            search_dirs+=("$repo_root/vendor/bin")
        fi
        # NOTE: Unconditional $repo_root/bin is searched LAST (after package
        # managers below) because a cloned repo could contain malicious
        # executables in bin/. Tech-stack-specific dirs above (node_modules/.bin,
        # target/release, .venv/bin, vendor/bin, etc.) are build-system-managed
        # and stay here. Covers Hermit's bin/ shims and similar project-local
        # tool layouts — but only as a last resort.
    fi
    for d in "${search_dirs[@]}"; do
        [[ -z "$d" ]] && continue
        if [[ -x "$d/$tool" ]]; then
            echo "FOUND:$d/$tool"
            return 0
        fi
    done

    # Package manager lookup
    if command -v brew >/dev/null 2>&1; then
        if run_timed "$probe_timeout" brew list "$tool" >/dev/null 2>&1; then
            local prefix
            prefix="$(run_timed "$probe_timeout" brew --prefix "$tool" 2>/dev/null || true)"
            if [[ -n "$prefix" && -x "$prefix/bin/$tool" ]]; then
                echo "FOUND:$prefix/bin/$tool"
                return 0
            fi
            local brew_prefix
            brew_prefix="$(run_timed "$probe_timeout" brew --prefix 2>/dev/null || true)/bin"
            if [[ -x "$brew_prefix/$tool" ]]; then
                echo "FOUND:$brew_prefix/$tool"
                return 0
            fi
        fi
    fi
    if command -v mise >/dev/null 2>&1; then
        if mise_path="$(run_timed "$probe_timeout" mise which "$tool" 2>/dev/null || true)" && [[ -n "$mise_path" ]]; then
            echo "FOUND:$mise_path"
            return 0
        fi
    fi
    if command -v asdf >/dev/null 2>&1; then
        if asdf_path="$(run_timed "$probe_timeout" asdf which "$tool" 2>/dev/null || true)" && [[ -n "$asdf_path" ]]; then
            echo "FOUND:$asdf_path"
            return 0
        fi
    fi

    # Repo-root fallback dirs — searched LAST (least secure: a cloned repo
    # could contain malicious executables in bin/). Covers Hermit's bin/ shims
    # and similar project-local tool layouts that aren't caught by the
    # tech-stack-specific dirs above.
    if [[ -n "$repo_root" ]]; then
        for d in "$repo_root/bin" "$repo_root/scripts" "$repo_root/.local/bin"; do
            if [[ -x "$d/$tool" ]]; then
                echo "FOUND:$d/$tool"
                return 0
            fi
        done
    fi

    return 1
}

# --- Resolve tool: prints "FOUND: <path>" or "WRAPPER: <cmd>" to stdout, returns 0/1 ---
resolve_tool() {
    # 1. Devbox shell check — FIRST, because if true it simplifies all
    #    downstream logic: devbox-managed binaries are on PATH, no wrapper
    #    detection needed (skip mise/flox/direnv/nix).
    local in_devbox_shell=0
    if [[ -n "${DEVBOX_SHELL:-}" || -n "${IN_DEVBOX_SHELL:-}" ]]; then
        in_devbox_shell=1
    fi

    if [[ "$in_devbox_shell" -eq 1 ]]; then
        # We're inside `devbox shell` — devbox-managed binaries are on PATH.
        # a. command -v (PATH — devbox binaries are here)
        if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
            echo "FOUND:$path"
            return 0
        fi
        # b. Path-exhaustion (standard locations + package managers)
        local found
        if found="$(search_standard_paths)" && [[ -n "$found" ]]; then
            echo "$found"
            return 0
        fi
        # c. `devbox add <tool>` then retry — install into the project's
        #    devbox environment. devbox add is idempotent; failures are
        #    non-fatal (the tool may not be a nixpkgs package under this name).
        #    Skipped when CLTOOL_INSTALL_DISABLED=1 (resolve-only mode).
        local devbox_json_dir
        devbox_json_dir="$(walk_up devbox.json 2>/dev/null || true)"
        if [[ "$install_disabled" -eq 0 ]] && [[ -n "$devbox_json_dir" ]] && command -v devbox >/dev/null 2>&1; then
            (cd "$devbox_json_dir" && run_timed "$install_timeout" devbox add "$tool" >/dev/null 2>&1) || true
            if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
                echo "FOUND:$path"
                return 0
            fi
            if found="$(search_standard_paths)" && [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        fi
        # d. Still not found — skip other wrappers (we're in devbox), go
        #    directly to uv fallback / NOT_FOUND (common exit below).
    else
        # 2. Not in devbox shell — if devbox is available AND a devbox.json
        #    exists up the tree, verify the tool exists inside the devbox
        #    environment before returning WRAPPER. If not found inside devbox,
        #    try `devbox add` and recheck. If still not found, fall through
        #    to normal flow and nix/uv fallback.
        if command -v devbox >/dev/null 2>&1; then
            local devbox_json_dir
            devbox_json_dir="$(walk_up devbox.json 2>/dev/null || true)"
            if [[ -n "$devbox_json_dir" ]]; then
                # 2a. On PATH inside devbox? (devbox run -- command -v)
                # Use devbox_run_timed for hang-safety — if devbox hangs, fall
                # through to normal flow instead of blocking the resolver.
                if (cd "$devbox_json_dir" && devbox_run_timed command -v "$tool" >/dev/null 2>&1); then
                    echo "WRAPPER:devbox run --"
                    return 0
                fi
                # 2b. devbox add + recheck inside devbox
                #     Skipped when CLTOOL_INSTALL_DISABLED=1 (resolve-only mode).
                if [[ "$install_disabled" -eq 0 ]]; then
                    (cd "$devbox_json_dir" && run_timed "$install_timeout" devbox add "$tool" >/dev/null 2>&1) || true
                    if (cd "$devbox_json_dir" && devbox_run_timed command -v "$tool" >/dev/null 2>&1); then
                        echo "WRAPPER:devbox run --"
                        return 0
                    fi
                fi
                # Still not found inside devbox — fall through to normal flow
                # and nix/uv fallback (don't return WRAPPER for a tool that
                # isn't available inside devbox).
            fi
        fi

        # 3. Normal flow (no devbox involved)
        # a. Already on PATH?
        if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
            echo "FOUND:$path"
            return 0
        fi
        # b. Other environment wrappers (mise, flox, direnv, nix)
        # mise
        if command -v mise >/dev/null 2>&1; then
            if [[ -z "${MISE_SHELL:-}" ]]; then
                if walk_up .mise.toml .mise/config.toml mise.toml >/dev/null 2>&1; then
                    echo "WRAPPER:mise exec --"
                    return 0
                fi
            fi
        fi
        # flox
        if command -v flox >/dev/null 2>&1; then
            if [[ -z "${FLOX_ACTIVE:-}" ]]; then
                if walk_up flox.nix >/dev/null 2>&1; then
                    echo "WRAPPER:flox activate --"
                    return 0
                fi
            fi
        fi
        # direnv: NOT emitted as a wrapper prefix.
        # direnv activation is eval-based (`eval "$(direnv export bash)"`),
        # not prefix-based. The wrapper_prefix mechanism (`$wrapper "$@"`)
        # cannot activate direnv — `direnv export && git ...` fails because
        # `direnv export` requires a shell argument and outputs shell code to
        # stdout, it does not execute the following command.
        # When inside direnv (DIRENV_DIR set), tools are already on PATH and
        # found by the PATH check above. When outside direnv, the exec mode
        # (line ~671) handles activation correctly via
        # `eval "$(direnv export bash)" && exec "$tool"`. The wrapper_prefix
        # path skips direnv entirely and falls through to nix / standard paths.
        # See internal-docs/issues/direnv-wrapper-prefix-broken.md for details.
        # nix
        if command -v nix >/dev/null 2>&1; then
            if [[ -z "${IN_NIX_SHELL:-}" ]]; then
                if nix_root="$(walk_up shell.nix flake.nix 2>/dev/null)"; then
                    if [[ -f "$nix_root/flake.nix" ]]; then
                        echo "WRAPPER:nix develop --command"
                    else
                        echo "WRAPPER:nix-shell --run"
                    fi
                    return 0
                fi
            fi
        fi

        # c. Global path-exhaustion (standard locations + package managers)
        local found
        if found="$(search_standard_paths)" && [[ -n "$found" ]]; then
            echo "$found"
            return 0
        fi
    fi

    # 4. nix/uv fallback (common exit — reached from both devbox and non-devbox
    #    branches). Tries to install the not-found tool via available package
    #    managers, searching the repo first before attempting install.
    #
    # a. uv→pip fallback (special case for tool == uv):
    #    if uv is not found, ensure it is recorded in devbox.json (so devbox
    #    can provide it next time) and fall back to pip/pip3/python3 -m pip
    #    for Python package operations.
    if [[ "$tool" == "uv" ]]; then
        # Add uv to the nearest devbox.json if one exists.
        ensure_devbox_package uv >/dev/null 2>&1 || true

        # Fall back to pip if available.
        local pip_cmd=""
        for candidate in pip3 pip "python3 -m pip"; do
            if command -v "$candidate" >/dev/null 2>&1; then
                pip_cmd="$candidate"
                break
            fi
        done
        # For the compound command "python3 -m pip", command -v on the whole
        # string fails. Check its components separately.
        if [[ -z "$pip_cmd" ]]; then
            if command -v python3 >/dev/null 2>&1; then
                pip_cmd="python3 -m pip"
            fi
        fi
        if [[ -n "$pip_cmd" ]]; then
            echo "FALLBACK:pip:$pip_cmd"
            return 0
        fi
    fi

    # b. nix fallback: is nix available? Search nixpkgs for <tool>. If a
    #    package exists, install it via `nix profile install` and recheck PATH.
    #    Skipped when CLTOOL_INSTALL_DISABLED=1 (resolve-only mode) — the nix
    #    eval search still runs (it's a fast probe), but the install is skipped.
    if command -v nix >/dev/null 2>&1; then
        # Search: check if the package exists in nixpkgs (fast, non-destructive).
        # nix eval succeeds if the package exists, fails otherwise.
        if run_timed "$probe_timeout" nix eval nixpkgs#"${tool}".meta.mainProgram >/dev/null 2>&1; then
            # Package exists — install it (unless resolve-only mode).
            if [[ "$install_disabled" -eq 0 ]]; then
                run_timed "$install_timeout" nix profile install nixpkgs#"${tool}" >/dev/null 2>&1 || true
                # Recheck PATH after install.
                if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
                    echo "FOUND:$path"
                    return 0
                fi
                local found
                if found="$(search_standard_paths)" && [[ -n "$found" ]]; then
                    echo "$found"
                    return 0
                fi
            fi
        fi
    fi

    # c. uv fallback: is uv available? Search PyPI for <tool>. If a package
    #    exists, install it via `uv tool install` and recheck PATH.
    #    (uv tool install fails fast if the package doesn't exist on PyPI,
    #    so the install attempt itself serves as the search.)
    #    Skipped when CLTOOL_INSTALL_DISABLED=1 (resolve-only mode).
    if [[ "$install_disabled" -eq 0 ]] && command -v uv >/dev/null 2>&1; then
        # Try to install the tool from PyPI via uv.
        # uv tool install fails fast if the package doesn't exist.
        if run_timed "$install_timeout" uv tool install "${tool}" >/dev/null 2>&1; then
            # Recheck PATH after install.
            if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
                echo "FOUND:$path"
                return 0
            fi
            local found
            if found="$(search_standard_paths)" && [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        fi
    fi

    # 5. Not found
    echo "NOT_FOUND:"
    return 1
}

# --- Main ---
if [[ "$runner_mode" -eq 1 ]]; then
    resolve_runner "$runner_ecosystem"
    exit 0
fi

result="$(resolve_tool)" || true
status="${result%%:*}"
value="${result#*:}"

if [[ "$exec_mode" -eq 1 ]]; then
    case "$status" in
        FOUND)
            exec "$value" "${tool_args[@]}"
            ;;
        WRAPPER)
            # Wrapper commands need different arg passing
            case "$value" in
                "devbox run --")        exec devbox run -- "$tool" "${tool_args[@]}" ;;
                "mise exec --")         exec mise exec -- "$tool" "${tool_args[@]}" ;;
                "flox activate --")     exec flox activate -- "$tool" "${tool_args[@]}" ;;
                "direnv export &&")     eval "$(direnv export bash)" && exec "$tool" "${tool_args[@]}" ;;
                "nix develop --command") exec nix develop --command "$tool" "${tool_args[@]}" ;;
                "nix-shell --run")      exec nix-shell --run "$tool ${tool_args[*]}" ;;
                *) echo "Unknown wrapper: $value" >&2; exit 1 ;;
            esac
            ;;
        FALLBACK)
            # Fallback mode: for uv with pip fallback, install uv then exec it.
            if [[ "$tool" == "uv" ]]; then
                local pip_cmd="${value#pip:}"
                if [[ -n "$pip_cmd" ]]; then
                    echo "[cli-tool-discovery] uv not found; installing uv via $pip_cmd" >&2
                    $pip_cmd install --user uv >/dev/null 2>&1 || true
                    # Try to find uv again after install
                    if path="$(command -v uv 2>/dev/null || true)" && [[ -n "$path" ]]; then
                        exec "$path" "${tool_args[@]}"
                    fi
                    # If install failed or uv still not on PATH, try pip directly
                    echo "[cli-tool-discovery] uv install failed; running through pip directly is not supported" >&2
                    exit 127
                fi
            fi
            echo "NOT_FOUND: $tool" >&2
            exit 127
            ;;
        NOT_FOUND)
            echo "NOT_FOUND: $tool" >&2
            echo "Checked: PATH, devbox, mise, flox, direnv, nix, standard locations, package managers" >&2
            exit 127
            ;;
    esac
else
    case "$status" in
        FOUND)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"found","path":"%s","tool":"%s"}\n' "$value" "$tool"
            else
                echo "FOUND: $value"
            fi
            ;;
        WRAPPER)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"wrapper","wrapper":"%s","tool":"%s"}\n' "$value $tool" "$tool"
            else
                echo "WRAPPER: $value $tool"
            fi
            ;;
        FALLBACK)
            # Fallback mode: uv → pip
            if [[ "$tool" == "uv" ]]; then
                local pip_cmd="${value#pip:}"
                if [[ "$json_output" -eq 1 ]]; then
                    printf '{"status":"fallback","tool":"%s","fallback":"pip","runner":"%s","message":"uv not found; %s is available as a fallback for Python package operations. Consider running `devbox install` or `%s install --user uv` to install uv."}\n' "$tool" "$pip_cmd" "$pip_cmd" "$pip_cmd"
                else
                    echo "FALLBACK: pip ($pip_cmd) — uv not found; use pip for Python package operations or install uv with '$pip_cmd install --user uv'"
                fi
            else
                if [[ "$json_output" -eq 1 ]]; then
                    printf '{"status":"fallback","tool":"%s","fallback":"%s"}\n' "$tool" "$value"
                else
                    echo "FALLBACK: $value"
                fi
            fi
            ;;
        NOT_FOUND)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"not_found","tool":"%s","checked":["PATH","devbox","mise","flox","direnv","nix","standard_locations","package_managers"]}\n' "$tool"
            else
                echo "NOT_FOUND: $tool"
                echo "Checked: PATH, devbox, mise, flox, direnv, nix, standard locations, package managers"
            fi
            exit 1
            ;;
    esac
fi

