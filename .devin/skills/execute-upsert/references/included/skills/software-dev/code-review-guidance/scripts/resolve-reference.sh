#!/usr/bin/env bash
# resolve-reference.sh — three-tier fallback resolver for skill/bundle references
#
# Usage:
#   resolve-reference.sh <ref> [--tier <1|2|3>] [--out <path>]
#   resolve-reference.sh <ref>                     # resolve, print content to stdout
#   resolve-reference.sh <ref> --out <path>        # resolve, write content to <path>
#   resolve-reference.sh <ref> --tier 3            # force tier 3 (materialized copy only)
#
# A <ref> is a relative path like:
#   knowledge/foo/overview.md           (a knowledge bundle file)
#   skills/content/bar/SKILL.md         (a skill file)
#
# Resolution order (three-tier fallback):
#   Tier 1: Local relative path — walk up from $PWD looking for a `src/` tree
#           or a `knowledge/` / `skills/` directory that contains the ref.
#           Works in development and full-profile installs.
#   Tier 2: Fetch from the published distribution repo.
#           - Skill refs: `pnpm dlx skills add <repo> --yes --skill <name>`
#             (pulls the whole skill tree so intra-skill links work).
#           - Knowledge refs: `curl -fsSL` from raw.githubusercontent.com
#             (bundles have no SKILL.md entry point, so the skills CLI
#             can't install them).
#           Works for online standalone installs.
#   Tier 3: Materialized copy inside this skill/bundle's
#           `references/included/<ref>` tree. Populated at build time by
#           the templater's `includeTree` function. Works for offline
#           standalone installs.
#
# Telemetry gating (per good-skills.sh pattern):
#   - levonk-owned skills: telemetry allowed (env -u DISABLE_TELEMETRY -u DO_NOT_TRACK)
#   - third-party skills: telemetry disabled (DISABLE_TELEMETRY=1 DO_NOT_TRACK=1)
#   - knowledge bundles: curl sends no telemetry regardless
#
# Exit codes:
#   0  — resolved, content on stdout (or written to --out path)
#   1  — usage error
#   2  — could not resolve at any tier
#   3  — tier was forced (--tier) and that tier failed
set -euo pipefail

# --- Defaults ---
REF=""
TIER=""
OUT_PATH=""

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier)
            TIER="$2"
            shift 2
            ;;
        --out)
            OUT_PATH="$2"
            shift 2
            ;;
        --help|-h)
            sed -n '2,40p' "$0"
            exit 0
            ;;
        *)
            if [[ -z "$REF" ]]; then
                REF="$1"
                shift
            else
                echo "ERROR: unexpected argument: $1" >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$REF" ]]; then
    echo "ERROR: missing reference argument" >&2
    echo "Usage: resolve-reference.sh <ref> [--tier <1|2|3>] [--out <path>]" >&2
    exit 1
fi

# --- Determine the script's own directory (for tier 3 materialized copies) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Determine the distribution repo for tier 2 skill fetches ---
# Public profile content → levonk/skills-releases
# Private profile content → levonk/skills-private
# Default to public; override via RESOLVE_REFERENCE_REPO env var.
RESOLVE_REFERENCE_REPO="${RESOLVE_REFERENCE_REPO:-levonk/skills-releases}"

# --- Walk up from $PWD looking for a directory containing the ref ---
# Tier 1: local relative path (development, full-profile install)
find_local_ref() {
    local ref="$1"
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        # Try: <dir>/src/<ref>  (skills-src source tree)
        if [[ -f "$dir/src/$ref" ]]; then
            echo "$dir/src/$ref"
            return 0
        fi
        # Try: <dir>/<ref>  (build output, or a flat knowledge/skills tree)
        if [[ -f "$dir/$ref" ]]; then
            echo "$dir/$ref"
            return 0
        fi
        # Try: <dir>/current/<ref>  (profile-specific layout)
        if [[ -f "$dir/current/$ref" ]]; then
            echo "$dir/current/$ref"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# --- Tier 2: fetch from published repo ---
# Skill refs use `pnpm dlx skills add`; knowledge refs use curl.
fetch_remote_ref() {
    local ref="$1"
    if [[ "$ref" == skills/* ]]; then
        # Skill reference — use the official skills CLI.
        # Derive skill name: skills/<category>/<skill-name>/<rest>
        local skill_name
        skill_name="$(echo "$ref" | awk -F/ '{print $3}')"
        if [[ -z "$skill_name" ]]; then
            return 1
        fi
        local rest
        rest="$(echo "$ref" | awk -F/ '{for(i=4;i<=NF;i++) printf "%s%s", $i, (i<NF?"/":"")}')"
        # Telemetry gating: allow for levonk-owned repos, disable for third-party.
        local telemetry_env=()
        if [[ "$RESOLVE_REFERENCE_REPO" == levonk/* ]]; then
            telemetry_env=(env -u DISABLE_TELEMETRY -u DO_NOT_TRACK)
        else
            telemetry_env=(env DISABLE_TELEMETRY=1 DO_NOT_TRACK=1)
        fi
        # Install the skill to a temp dir, then read the file.
        local tmp_install
        tmp_install="$(mktemp -d)"
        if ! "${telemetry_env[@]}" pnpm dlx skills add "$RESOLVE_REFERENCE_REPO" --yes --skill "$skill_name" --path "$tmp_install" >/dev/null 2>&1; then
            rm -rf "$tmp_install"
            return 1
        fi
        local installed_file="$tmp_install/.agents/skills/$skill_name/$rest"
        if [[ -f "$installed_file" ]]; then
            cat "$installed_file"
            rm -rf "$tmp_install"
            return 0
        fi
        rm -rf "$tmp_install"
        return 1
    elif [[ "$ref" == knowledge/* ]]; then
        # Knowledge reference — curl from raw.githubusercontent.com.
        # raw.githubusercontent.com returns file content directly (not HTML).
        local url="https://raw.githubusercontent.com/${RESOLVE_REFERENCE_REPO}/main/$ref"
        if curl -fsSL "$url" 2>/dev/null; then
            return 0
        fi
        return 1
    else
        # Unknown ref type — try curl as a last resort.
        local url="https://raw.githubusercontent.com/${RESOLVE_REFERENCE_REPO}/main/$ref"
        if curl -fsSL "$url" 2>/dev/null; then
            return 0
        fi
        return 1
    fi
}

# --- Tier 3: materialized copy inside this skill/bundle ---
find_materialized_ref() {
    local ref="$1"
    # The materialized tree lives at references/included/<ref> relative to
    # the skill's root directory. The script is in <skill-root>/scripts/,
    # so the skill root is the parent of SCRIPT_DIR.
    local skill_root
    skill_root="$(dirname "$SCRIPT_DIR")"
    local mat_path="$skill_root/references/included/$ref"
    if [[ -f "$mat_path" ]]; then
        echo "$mat_path"
        return 0
    fi
    return 1
}

# --- Output helper: write content to stdout or to --out path ---
emit_content() {
    local content="$1"
    if [[ -n "$OUT_PATH" ]]; then
        mkdir -p "$(dirname "$OUT_PATH")"
        printf '%s' "$content" > "$OUT_PATH"
        echo "Wrote: $OUT_PATH" >&2
    else
        printf '%s' "$content"
    fi
}

# --- Main resolution logic ---
resolve() {
    local content=""

    # Tier 1: local relative path
    if [[ -z "$TIER" || "$TIER" == "1" ]]; then
        local local_path
        if local_path="$(find_local_ref "$REF" 2>/dev/null)" && [[ -n "$local_path" ]]; then
            content="$(cat "$local_path")"
            emit_content "$content"
            echo "[resolve-reference] tier 1 (local): $local_path" >&2
            return 0
        fi
        if [[ "$TIER" == "1" ]]; then
            echo "ERROR: tier 1 forced but local path not found for: $REF" >&2
            return 3
        fi
    fi

    # Tier 2: fetch from published repo
    if [[ -z "$TIER" || "$TIER" == "2" ]]; then
        if content="$(fetch_remote_ref "$REF" 2>/dev/null)" && [[ -n "$content" ]]; then
            emit_content "$content"
            echo "[resolve-reference] tier 2 (remote): $RESOLVE_REFERENCE_REPO/$REF" >&2
            return 0
        fi
        if [[ "$TIER" == "2" ]]; then
            echo "ERROR: tier 2 forced but remote fetch failed for: $REF" >&2
            return 3
        fi
    fi

    # Tier 3: materialized copy
    if [[ -z "$TIER" || "$TIER" == "3" ]]; then
        local mat_path
        if mat_path="$(find_materialized_ref "$REF" 2>/dev/null)" && [[ -n "$mat_path" ]]; then
            content="$(cat "$mat_path")"
            emit_content "$content"
            echo "[resolve-reference] tier 3 (materialized): $mat_path" >&2
            return 0
        fi
        if [[ "$TIER" == "3" ]]; then
            echo "ERROR: tier 3 forced but materialized copy not found for: $REF" >&2
            return 3
        fi
    fi

    echo "ERROR: could not resolve reference at any tier: $REF" >&2
    echo "  Tier 1 (local): not found in src/ tree walking up from $PWD" >&2
    echo "  Tier 2 (remote): fetch from $RESOLVE_REFERENCE_REPO failed" >&2
    echo "  Tier 3 (materialized): not found in $SCRIPT_DIR/../references/included/" >&2
    return 2
}

resolve

