#!/usr/bin/env bash
# skill-config.sh — resolve skill configuration across three layers with trust enforcement
#
# Layers (modeled on XDG Base Directory Specification):
#   SYSTEM  $XDG_CONFIG_DIRS/skills/levonk/skills-releases/skills/<skill-path>/config.toml
#   USER    $XDG_CONFIG_HOME/skills/levonk/skills-releases/skills/<skill-path>/config.toml
#   PROJ    <target-repo>/.agents/config/skills/<owner>/<repo>/<skill-path>/config.toml
#
# Two flows:
#   Trust flows downward (SYSTEM -> USER -> gates PROJ).
#     [trust] section is read from USER (fallback SYSTEM).
#     PROJ [trust] keys are silently ignored.
#     PROJ can tighten trust policy (more restrictive), never loosen.
#   Behavior flows upward (PROJ > USER > SYSTEM).
#     Project wins over user wins over system, but only if PROJ passes the trust gate.
#
# Usage:
#   skill-config.sh get <dotted.key.path> [--default <value>]
#       Print the merged value for the key, or --default if absent.
#   skill-config.sh get-all
#       Print the entire merged config as TOML.
#   skill-config.sh set --layer <user|proj> <dotted.key.path> <value>
#       Set a value at the specified layer. SYSTEM is read-only.
#   skill-config.sh invalidate --layer <user|proj> <dotted.key.path>
#       Delete a key (and its subtree) from the specified layer.
#   skill-config.sh trust-status
#       Print the merged trust policy and whether PROJ is honored for this run.
#
# Environment:
#   SKILL_CONFIG_OWNER    GitHub owner of the skill's source repo (e.g. levonk)
#   SKILL_CONFIG_REPO     GitHub repo name of the skill's source repo (e.g. skills-releases)
#   SKILL_CONFIG_PATH     Skill path within source repo (e.g. software-dev/github-pr)
#   SKILL_CONFIG_TARGET   Target repo root (defaults to git rev-parse --show-toplevel)
#   SKILL_CONFIG_INSTALL  Install location: "project-local" | "non-local" (auto-detected if unset)
#
# Exit codes: 0 = success, 1 = usage error, 2 = config error, 3 = yq missing

set -euo pipefail

# --- yq detection (require mikefarah/yq — Go version, supports TOML) ---
YQ_BIN=""
if command -v yq >/dev/null 2>&1; then
  YQ_BIN="yq"
elif command -v devbox >/dev/null 2>&1; then
  if devbox run -- command -v yq >/dev/null 2>&1; then
    YQ_BIN="devbox run -- yq"
  fi
fi
if [ -z "$YQ_BIN" ]; then
  echo "skill-config.sh: yq (mikefarah/yq, Go version) is required but not found." >&2
  echo "Install it: devbox add yq  (or: brew install yq)" >&2
  exit 3
fi

# --- Path resolution ---

resolve_paths() {
  # SYSTEM: first entry in XDG_CONFIG_DIRS that contains the config file
  local xdg_config_dirs="${XDG_CONFIG_DIRS:-/etc/xdg}"
  local IFS=":"
  SYSTEM_PATH=""
  for d in $xdg_config_dirs; do
    local p="$d/skills/levonk/skills-releases/skills/${SKILL_CONFIG_PATH}/config.toml"
    if [ -f "$p" ]; then
      SYSTEM_PATH="$p"
      break
    fi
  done

  # USER: XDG_CONFIG_HOME (default ~/.config)
  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  USER_PATH="$xdg_config_home/skills/levonk/skills-releases/skills/${SKILL_CONFIG_PATH}/config.toml"

  # PROJ: target repo + .agents/config/skills/<owner>/<repo>/<skill-path>/config.toml
  local target_root="${SKILL_CONFIG_TARGET:-}"
  if [ -z "$target_root" ]; then
    target_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
  fi
  PROJ_PATH=""
  if [ -n "$target_root" ]; then
    PROJ_PATH="$target_root/.agents/config/skills/${SKILL_CONFIG_OWNER}/${SKILL_CONFIG_REPO}/${SKILL_CONFIG_PATH}/config.toml"
  fi
}

# --- Install location detection ---

detect_install_location() {
  if [ -n "${SKILL_CONFIG_INSTALL:-}" ]; then
    INSTALL_LOCATION="$SKILL_CONFIG_INSTALL"
    return
  fi
  # Determine the skill's own install directory (where SKILL.md lives)
  local skill_dir
  skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || echo "")"
  if [ -z "$skill_dir" ]; then
    INSTALL_LOCATION="non-local"
    return
  fi
  local target_root="${SKILL_CONFIG_TARGET:-}"
  if [ -z "$target_root" ]; then
    target_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
  fi
  if [ -n "$target_root" ]; then
    for skills_subdir in ".agents/skills" ".claude/skills" ".devin/skills" ".cursor/skills"; do
      if [[ "$skill_dir" == "$target_root/$skills_subdir"/* ]]; then
        INSTALL_LOCATION="project-local"
        return
      fi
    done
  fi
  INSTALL_LOCATION="non-local"
}

# --- Trust policy reading and merging ---

# Restrictiveness ordering for tighten-not-loosen merge
non_local_rank() {
  case "$1" in
    deny) echo 3 ;;
    ask)  echo 2 ;;
    allow) echo 1 ;;
    *)    echo 0 ;;
  esac
}

auto_honor_rank() {
  case "$1" in
    false) echo 2 ;;
    true)  echo 1 ;;
    *)     echo 0 ;;
  esac
}

# Read [trust] from a config file (if it exists). Prints "key=value" lines.
read_trust_from_file() {
  local file="$1"
  [ -z "$file" ] || [ ! -f "$file" ] && return 0
  $YQ_BIN e '.trust // {}' "$file" 2>/dev/null | grep -E '^[a-z_]+:' || true
}

# Merge trust policy: USER (fallback SYSTEM) tightened by PROJ.
# PROJ can only tighten (more restrictive), never loosen.
merge_trust_policy() {
  # Start with SYSTEM trust (fallback)
  local sys_nl="" sys_ah=""
  if [ -n "${SYSTEM_PATH:-}" ] && [ -f "$SYSTEM_PATH" ]; then
    sys_nl="$($YQ_BIN e '.trust.non_local_default // ""' "$SYSTEM_PATH" 2>/dev/null || echo "")"
    sys_ah="$($YQ_BIN e '.trust.project_local_auto_honor // ""' "$SYSTEM_PATH" 2>/dev/null || echo "")"
  fi

  # USER trust overrides SYSTEM as the base
  local base_nl="${sys_nl:-ask}" base_ah="${sys_ah:-true}"
  if [ -n "${USER_PATH:-}" ] && [ -f "$USER_PATH" ]; then
    local user_nl user_ah
    user_nl="$($YQ_BIN e '.trust.non_local_default // ""' "$USER_PATH" 2>/dev/null || echo "")"
    user_ah="$($YQ_BIN e '.trust.project_local_auto_honor // ""' "$USER_PATH" 2>/dev/null || echo "")"
    [ -n "$user_nl" ] && base_nl="$user_nl"
    [ -n "$user_ah" ] && base_ah="$user_ah"
  fi

  # PROJ can only tighten
  local merged_nl="$base_nl" merged_ah="$base_ah"
  if [ -n "${PROJ_PATH:-}" ] && [ -f "$PROJ_PATH" ]; then
    local proj_nl proj_ah
    proj_nl="$($YQ_BIN e '.trust.non_local_default // ""' "$PROJ_PATH" 2>/dev/null || echo "")"
    proj_ah="$($YQ_BIN e '.trust.project_local_auto_honor // ""' "$PROJ_PATH" 2>/dev/null || echo "")"
    if [ -n "$proj_nl" ]; then
      if [ "$(non_local_rank "$proj_nl")" -gt "$(non_local_rank "$base_nl")" ]; then
        merged_nl="$proj_nl"
      fi
    fi
    if [ -n "$proj_ah" ]; then
      if [ "$(auto_honor_rank "$proj_ah")" -gt "$(auto_honor_rank "$base_ah")" ]; then
        merged_ah="$proj_ah"
      fi
    fi
  fi

  MERGED_NON_LOCAL="$merged_nl"
  MERGED_AUTO_HONOR="$merged_ah"
}

# --- Trust gate: determine whether PROJ behavior config is honored ---

# Sets HONOR_PROJ to "true" or "false" and PROJ_REASON to a short explanation.
evaluate_trust_gate() {
  HONOR_PROJ="false"
  PROJ_REASON=""

  # If no PROJ file exists, nothing to honor
  if [ -z "${PROJ_PATH:-}" ] || [ ! -f "$PROJ_PATH" ]; then
    HONOR_PROJ="false"
    PROJ_REASON="no proj config file"
    return
  fi

  if [ "$INSTALL_LOCATION" = "project-local" ]; then
    if [ "$MERGED_AUTO_HONOR" = "true" ]; then
      HONOR_PROJ="true"
      PROJ_REASON="project-local install, auto-honor enabled"
    else
      # Must ask the user (tightened by PROJ or USER)
      HONOR_PROJ="ask"
      PROJ_REASON="project-local install but auto-honor disabled — ask user"
    fi
  else
    case "$MERGED_NON_LOCAL" in
      deny)
        HONOR_PROJ="false"
        PROJ_REASON="non-local install, trust policy = deny"
        ;;
      allow)
        HONOR_PROJ="true"
        PROJ_REASON="non-local install, trust policy = allow"
        ;;
      ask|*)
        HONOR_PROJ="ask"
        PROJ_REASON="non-local install, trust policy = ask"
        ;;
    esac
  fi
}

# --- Config merging (behavior flows upward: SYSTEM <- USER <- PROJ) ---

# Print merged TOML honoring the trust gate.
# If HONOR_PROJ is "ask", the caller must have already prompted the user
# and set HONOR_PROJ to "true" or "false" before calling this.
merged_config_toml() {
  local tmp_sys="" tmp_user="" tmp_proj=""
  local have_sys="false" have_user="false" have_proj="false"

  if [ -n "${SYSTEM_PATH:-}" ] && [ -f "$SYSTEM_PATH" ]; then
    tmp_sys="$(cat "$SYSTEM_PATH")"
    have_sys="true"
  fi
  if [ -n "${USER_PATH:-}" ] && [ -f "$USER_PATH" ]; then
    tmp_user="$(cat "$USER_PATH")"
    have_user="true"
  fi
  if [ "$HONOR_PROJ" = "true" ] && [ -n "${PROJ_PATH:-}" ] && [ -f "$PROJ_PATH" ]; then
    tmp_proj="$(cat "$PROJ_PATH")"
    have_proj="true"
  fi

  # Strip [trust] sections from the merge — trust is resolved separately
  # and must not leak into behavior config.
  local stripped_sys="" stripped_user="" stripped_proj=""
  if [ "$have_sys" = "true" ]; then
    stripped_sys="$(printf '%s' "$tmp_sys" | $YQ_BIN e 'del(.trust)' - 2>/dev/null || printf '%s' "$tmp_sys")"
  fi
  if [ "$have_user" = "true" ]; then
    stripped_user="$(printf '%s' "$tmp_user" | $YQ_BIN e 'del(.trust)' - 2>/dev/null || printf '%s' "$tmp_user")"
  fi
  if [ "$have_proj" = "true" ]; then
    stripped_proj="$(printf '%s' "$tmp_proj" | $YQ_BIN e 'del(.trust)' - 2>/dev/null || printf '%s' "$tmp_proj")"
  fi

  # Overlay: SYSTEM <- USER <- PROJ (later wins)
  local result="{}"
  if [ "$have_sys" = "true" ]; then
    result="$(printf '%s' "$stripped_sys" | $YQ_BIN ea '.' - 2>/dev/null || echo "{}")"
  fi
  if [ "$have_user" = "true" ]; then
    result="$(printf '%s\n---\n%s' "$result" "$stripped_user" | $YQ_BIN ea '.' - 2>/dev/null || echo "$result")"
  fi
  if [ "$have_proj" = "true" ]; then
    result="$(printf '%s\n---\n%s' "$result" "$stripped_proj" | $YQ_BIN ea '.' - 2>/dev/null || echo "$result")"
  fi

  printf '%s' "$result"
}

# --- Commands ---

cmd_get() {
  local key="${1:?usage: skill-config.sh get <dotted.key> [--default <value>]}"
  shift
  local default_val=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --default) default_val="$2"; shift 2 ;;
      *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
  done

  resolve_paths
  detect_install_location
  merge_trust_policy
  evaluate_trust_gate

  # If trust gate says "ask", the AI caller must handle the prompt.
  # For non-interactive get, we treat "ask" as "false" (don't honor PROJ)
  # to avoid silently honoring untrusted config. The AI should call
  # trust-status first, prompt the user if needed, then re-run get with
  # SKILL_CONFIG_INSTALL forced or HONOR_PROJ confirmed.
  if [ "$HONOR_PROJ" = "ask" ]; then
    HONOR_PROJ="false"
  fi

  local merged
  merged="$(merged_config_toml)"
  local val
  val="$(printf '%s' "$merged" | $YQ_BIN e ".${key} // null" - 2>/dev/null || echo "null")"
  if [ "$val" = "null" ] || [ -z "$val" ]; then
    if [ -n "$default_val" ]; then
      printf '%s' "$default_val"
    else
      exit 0  # key absent, no default — print nothing
    fi
  else
    printf '%s' "$val"
  fi
}

cmd_get_all() {
  resolve_paths
  detect_install_location
  merge_trust_policy
  evaluate_trust_gate
  if [ "$HONOR_PROJ" = "ask" ]; then
    HONOR_PROJ="false"
  fi
  merged_config_toml
}

cmd_set() {
  local layer=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --layer) layer="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  if [ -z "$layer" ]; then
    echo "usage: skill-config.sh set --layer <user|proj> <dotted.key> <value>" >&2
    exit 1
  fi
  local key="${1:?usage: skill-config.sh set --layer <user|proj> <dotted.key> <value>}"
  local value="${2:?usage: skill-config.sh set --layer <user|proj> <dotted.key> <value>}"

  resolve_paths
  local target_file=""
  case "$layer" in
    user) target_file="$USER_PATH" ;;
    proj) target_file="$PROJ_PATH" ;;
    system)
      echo "skill-config.sh: SYSTEM layer is read-only" >&2
      exit 2
      ;;
    *)
      echo "skill-config.sh: unknown layer '$layer' (use user|proj)" >&2
      exit 1
      ;;
  esac

  if [ -z "$target_file" ]; then
    echo "skill-config.sh: cannot resolve $layer layer path (missing SKILL_CONFIG_PATH or target repo)" >&2
    exit 2
  fi

  mkdir -p "$(dirname "$target_file")"
  if [ ! -f "$target_file" ]; then
    : > "$target_file"
  fi

  # yq handles TOML; auto-detect type (string/number/boolean)
  # Quote strings, leave numbers/booleans bare
  local yq_value
  case "$value" in
    true|false|[0-9]*|[0-9]*.*[0-9])
      yq_value="$value"
      ;;
    *)
      yq_value="\"$value\""
      ;;
  esac

  $YQ_BIN e ".${key} = $yq_value" -i "$target_file" 2>/dev/null || {
    # Fallback: yq might need explicit TOML output mode
    $YQ_BIN e --toToml ".${key} = $yq_value" -i "$target_file"
  }
}

cmd_invalidate() {
  local layer=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --layer) layer="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  if [ -z "$layer" ]; then
    echo "usage: skill-config.sh invalidate --layer <user|proj> <dotted.key>" >&2
    exit 1
  fi
  local key="${1:?usage: skill-config.sh invalidate --layer <user|proj> <dotted.key>}"

  resolve_paths
  local target_file=""
  case "$layer" in
    user) target_file="$USER_PATH" ;;
    proj) target_file="$PROJ_PATH" ;;
    system)
      echo "skill-config.sh: SYSTEM layer is read-only" >&2
      exit 2
      ;;
    *)
      echo "skill-config.sh: unknown layer '$layer'" >&2
      exit 1
      ;;
  esac

  if [ -z "$target_file" ] || [ ! -f "$target_file" ]; then
    exit 0  # nothing to invalidate
  fi

  $YQ_BIN e "del(.${key})" -i "$target_file" 2>/dev/null || true
}

cmd_trust_status() {
  resolve_paths
  detect_install_location
  merge_trust_policy
  evaluate_trust_gate

  cat <<EOF
install_location: $INSTALL_LOCATION
merged_trust:
  non_local_default: $MERGED_NON_LOCAL
  project_local_auto_honor: $MERGED_AUTO_HONOR
proj_honored: $HONOR_PROJ
proj_reason: $PROJ_REASON
paths:
  system: ${SYSTEM_PATH:-<none>}
  user:   ${USER_PATH:-<none>}
  proj:   ${PROJ_PATH:-<none>}
EOF
}

# --- Main ---

main() {
  local cmd="${1:-}"
  [ -z "$cmd" ] && {
    echo "usage: skill-config.sh <get|get-all|set|invalidate|trust-status> [args]" >&2
    exit 1
  }
  shift
  case "$cmd" in
    get)         cmd_get "$@" ;;
    get-all)     cmd_get_all "$@" ;;
    set)         cmd_set "$@" ;;
    invalidate)  cmd_invalidate "$@" ;;
    trust-status) cmd_trust_status ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      ;;
    *)
      echo "skill-config.sh: unknown command '$cmd'" >&2
      echo "commands: get, get-all, set, invalidate, trust-status" >&2
      exit 1
      ;;
  esac
}

main "$@"

