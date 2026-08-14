#!/usr/bin/env bash
# =====================================================================
# Git Repository Setup Script (Configuration-Driven, Unified)
# Bundled from levonk/dotfiles (home/current/dot_local/bin/executable_git-repo-init.bash)
# for the git-repository-management skill. Sources git-vcs-config.bash from the
# same directory (the bundled copy has chezmoi template expressions stripped to
# empty-string defaults; identity fallbacks still work standalone).
#
# Purpose:
#   Unified git repository management. Auto-detects mode:
#     - target dir does not exist OR is empty/non-git  -> CREATE mode
#     - target dir is an existing git repo             -> CONFIG mode
#
#   CREATE mode (also gated by --init-structure for destructive steps):
#     - git init with configured default branch
#     - initial README commit
#     - archive tags (root, pre-init-branches)
#     - environment branches (env/prod, env/stage, env/dev)
#     - personal user branch (u/{user}/env/dev)
#     - orphan gh_pages branch with starter index.html
#     - add origin remote and push branches + tags
#
#   CONFIG mode (always safe, idempotent):
#     - set user.name / user.email (--local or --global scope)
#     - configure origin-GH / origin-GL failover remotes
#       (or default gh/gl remotes when no remotes exist)
#
# Usage:
#   git-repo-init [OPTIONS] [REMOTE-URL] [TARGET-DIRECTORY]
#
# Examples:
#   git-repo-init                                    # auto-detect in cwd
#   git-repo-init git@github.com:user/repo.git       # clone + create + config
#   git-repo-init --init-structure                   # force structural ops
#   git-repo-init --force                            # allow overwrites
#   git-repo-init --user me --email me@x.com         # config-only on existing repo
#   git-repo-init --dry-run -v                       # preview, verbose
#
# Configuration: ~/.config/git/public-vcs.toml and ~/.local/share/git/public-vcs.toml
# Security: No sensitive data, safe for all environments
# =====================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Source base helper (prefixed in source, unprefixed when installed) ---
BASE_HELPER=""
for p in "$SCRIPT_DIR/executable_base-helper.bash" "$SCRIPT_DIR/base-helper.bash"; do
    if [[ -f "$p" ]]; then
        BASE_HELPER="$p"
        break
    fi
done

if [[ -n "$BASE_HELPER" ]]; then
    # shellcheck source=/dev/null
    . "$BASE_HELPER"
else
    # Minimal logging fallback
    vcs_log_info() { [[ "${LOG_LEVEL:-3}" -ge 3 ]] && echo "info: $*" >&2; }
    vcs_log_success() { [[ "${LOG_LEVEL:-3}" -ge 2 ]] && echo "success: $*" >&2; }
    vcs_log_warning() { [[ "${LOG_LEVEL:-3}" -ge 2 ]] && echo "warning: $*" >&2; }
    vcs_log_error() { [[ "${LOG_LEVEL:-3}" -ge 1 ]] && echo "error: $*" >&2; }
    vcs_log_debug() { [[ "${LOG_LEVEL:-3}" -ge 4 ]] && echo "debug: $*" >&2; }
fi

# --- Source VCS config library (try both prefixed and unprefixed, with/without .tmpl) ---
VCS_CONFIG_LIB=""
for p in \
    "$SCRIPT_DIR/executable_git-vcs-config.bash.tmpl" \
    "$SCRIPT_DIR/git-vcs-config.bash.tmpl" \
    "$SCRIPT_DIR/executable_git-vcs-config.bash" \
    "$SCRIPT_DIR/git-vcs-config.bash"; do
    if [[ -f "$p" ]]; then
        VCS_CONFIG_LIB="$p"
        break
    fi
done

if [[ -z "$VCS_CONFIG_LIB" ]]; then
    echo "Error: VCS configuration library not found in $SCRIPT_DIR" >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$VCS_CONFIG_LIB"

# --- Logging level control ---
# LOG_LEVEL: 1=error, 2=warning/success, 3=info (default), 4=debug, 0=silent
# --quiet   -> 1 (errors only)
# --verbose -> 4 (debug)
# default   -> 3 (info)
LOG_LEVEL="${LOG_LEVEL:-3}"

# Re-export logging functions that respect LOG_LEVEL (override library defaults
# only if base-helper fallback was used; library versions still honor DEBUG_VCS).
if [[ -z "$BASE_HELPER" ]]; then
    export LOG_LEVEL
fi
# Make library's vcs_log_debug honor LOG_LEVEL>=4 as well as DEBUG_VCS=1
if [[ "${LOG_LEVEL:-3}" -ge 4 ]]; then
    export DEBUG_VCS=1
fi

# --- Configuration ---
CURRENT_YEAR=$(date +%Y)
CURRENT_USER="${USER:-${USERNAME:-$(whoami)}}"

# Legacy logging aliases (compatibility with older code paths)
log_info() { vcs_log_info "$1"; }
log_success() { vcs_log_success "$1"; }
log_warning() { vcs_log_warning "$1"; }
log_error() { vcs_log_error "$1"; }

# --- Global state (populated by parse_arguments / detect_mode) ---
DRY_RUN=false
INIT_STRUCTURE=false
FORCE=false
FORCE_SCOPE="" # "global" | "local" | "" (auto)
CLI_USER=""
CLI_EMAIL=""
REMOTE_URL=""
TARGET_DIR=""
CLONE_ONLY=false
INIT_ONLY=false
GIT_CONFIG_SCOPE="" # "--local" | "--global" (resolved)
SCOPE_DESCRIPTION=""

# URL_PARTS is populated when REMOTE_URL is provided; otherwise stays empty.
# get_account_config_value handles missing keys via [[ -v ]] checks.
declare -A URL_PARTS

# --- Helpers ---

# Run a command, or print it in dry-run mode.
run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        vcs_log_info "[DRY-RUN] Would execute: $*"
        return 0
    fi
    "$@"
}

# Run a command and capture its stdout, or print a placeholder in dry-run mode.
# Use this for read ops whose output is consumed by downstream logic (e.g.
# `root_commit=$(run_cmd_capture git rev-list ...)`). In dry-run, returns 0
# and emits "[DRY-RUN-PLACEHOLDER]" so downstream logic can proceed without a
# real repository.
run_cmd_capture() {
    if [[ "$DRY_RUN" == "true" ]]; then
        vcs_log_info "[DRY-RUN] Would capture output of: $*"
        echo "[DRY-RUN-PLACEHOLDER]"
        return 0
    fi
    "$@"
}

# Change directory, with dry-run awareness.
run_cd() {
    local dir="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        vcs_log_info "[DRY-RUN] Would change directory to: $dir"
        if [[ -d "$dir" ]]; then
            cd "$dir" || return 1
        else
            vcs_log_warning "[DRY-RUN] Directory $dir does not exist, skipping cd."
        fi
        return 0
    fi
    cd "$dir" || return 1
}

# Check whether the current directory is inside a git work tree.
is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Check whether a branch exists locally.
# In dry-run mode, returns false (1) so the "would create" branch is taken and
# the creation command is logged via run_cmd. This only applies to create mode
# where the target repo doesn't exist yet; config mode callers should use the
# real check by setting DRY_RUN=false before calling (or call git directly).
branch_exists() {
    local branch="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        return 1
    fi
    git show-ref --verify --quiet "refs/heads/$branch"
}

# Check whether a tag exists.
# In dry-run mode, returns false (1) so the "would create" branch is taken and
# the creation command is logged via run_cmd.
tag_exists() {
    local tag="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        return 1
    fi
    git tag -l "$tag" | grep -q "$tag"
}

# =====================================================================
# MODE DETECTION
# =====================================================================

# Detect operation mode based on TARGET_DIR / REMOTE_URL / current state.
# Sets globals: MODE ("create" | "config"), SHOULD_CLONE, SHOULD_INIT_STRUCTURE
detect_mode() {
    local effective_dir="$TARGET_DIR"
    [[ -z "$effective_dir" ]] && effective_dir="$(pwd)"

    # If a remote URL was supplied, we are cloning -> create mode.
    if [[ -n "$REMOTE_URL" ]]; then
        MODE="create"
        SHOULD_CLONE=true
        SHOULD_INIT_STRUCTURE=true
        vcs_log_debug "Mode: create (remote URL provided)"
        return 0
    fi

    # If target directory does not exist -> create mode (will mkdir).
    if [[ ! -e "$effective_dir" ]]; then
        MODE="create"
        SHOULD_CLONE=false
        SHOULD_INIT_STRUCTURE=true
        vcs_log_debug "Mode: create (target dir does not exist: $effective_dir)"
        return 0
    fi

    # If target directory exists but is empty (no files, no .git) -> create mode.
    if [[ -d "$effective_dir" ]] && [[ -z "$(ls -A "$effective_dir" 2>/dev/null)" ]]; then
        MODE="create"
        SHOULD_CLONE=false
        SHOULD_INIT_STRUCTURE=true
        vcs_log_debug "Mode: create (target dir empty: $effective_dir)"
        return 0
    fi

    # If target dir is (or contains) a git repo -> config mode by default.
    if [[ -d "$effective_dir" ]]; then
        if (cd "$effective_dir" && is_git_repo); then
            MODE="config"
            SHOULD_CLONE=false
            SHOULD_INIT_STRUCTURE=false
            vcs_log_debug "Mode: config (existing git repo at $effective_dir)"
            return 0
        fi
    fi

    # Fallback: treat as create mode (non-git, non-empty dir -> init in place).
    MODE="create"
    SHOULD_CLONE=false
    SHOULD_INIT_STRUCTURE=true
    vcs_log_debug "Mode: create (fallback for non-git target: $effective_dir)"
}

# =====================================================================
# CONFIG MODE: identity + remote failover (always safe, idempotent)
# =====================================================================

# Resolve --global / --local scope, with interactive confirmation for global
# when not inside a repo and no flag was given.
resolve_config_scope() {
    if [[ -n "$FORCE_SCOPE" ]]; then
        if [[ "$FORCE_SCOPE" == "local" ]]; then
            if ! is_git_repo; then
                vcs_log_error "--local scope forced but not inside a git repository."
                exit 1
            fi
            GIT_CONFIG_SCOPE="--local"
            SCOPE_DESCRIPTION="local repository git configuration"
        else
            GIT_CONFIG_SCOPE="--global"
            SCOPE_DESCRIPTION="global git configuration"
        fi
        vcs_log_info "Forcing ${SCOPE_DESCRIPTION} due to command-line flag."
        return 0
    fi

    if is_git_repo; then
        GIT_CONFIG_SCOPE="--local"
        SCOPE_DESCRIPTION="local repository git configuration"
        local repo_root
        repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
        vcs_log_info "Configuring ${SCOPE_DESCRIPTION} at ${repo_root}"
    else
        # Not in a repo: require confirmation before touching global config.
        if [[ -t 0 && -t 1 ]]; then
            printf "Apply Git defaults globally? (y/N, 5s timeout): " >&2
            local user_choice=""
            if ! read -r -t 5 user_choice; then
                user_choice=""
                echo >&2
            fi
            if [[ ! "$user_choice" =~ ^[Yy]$ ]]; then
                vcs_log_info "Skipping global git configuration."
                exit 0
            fi
            vcs_log_info "Applying global git configuration."
        else
            vcs_log_info "No interactive terminal detected; skipping global git configuration."
            exit 0
        fi
        GIT_CONFIG_SCOPE="--global"
        SCOPE_DESCRIPTION="global git configuration"
    fi
}

# Idempotently set a single git config property within the resolved scope.
set_git_config_property() {
    local property_name="$1"
    local property_desc="$2"
    local final_value="$3"

    if [[ -z "$final_value" ]]; then
        return
    fi

    if [[ "$GIT_CONFIG_SCOPE" == "--local" ]]; then
        local current_local_value
        current_local_value=$(git config --local "$property_name" 2>/dev/null || true)

        if [[ "$current_local_value" == "$final_value" ]]; then
            vcs_log_info "Local git $property_desc is already set to '$final_value'. No change made."
        else
            run_cmd git config "$GIT_CONFIG_SCOPE" "$property_name" "$final_value"
            if [[ -n "$current_local_value" ]]; then
                vcs_log_success "Updated local git $property_desc from '$current_local_value' to '$final_value'."
            else
                local global_value
                global_value=$(git config --global "$property_name" 2>/dev/null || true)
                if [[ -z "$global_value" ]]; then
                    vcs_log_success "Set local git $property_desc to '$final_value'. No global $property_desc was set."
                elif [[ "$final_value" == "$global_value" ]]; then
                    vcs_log_success "Set local git $property_desc to '$final_value' (matches global)."
                else
                    vcs_log_success "Set local git $property_desc to '$final_value', overriding global ('$global_value')."
                fi
            fi
        fi
    else
        run_cmd git config "$GIT_CONFIG_SCOPE" "$property_name" "$final_value"
        vcs_log_success "Set git $property_desc to '$final_value' for ${SCOPE_DESCRIPTION}."
    fi
}

# Ensure a remote exists with the desired URL (add or update).
ensure_remote_url() {
    local remote_name="$1"
    local remote_url="$2"
    local existing_url

    if [[ -z "$remote_name" || -z "$remote_url" ]]; then
        return
    fi

    if existing_url=$(git remote get-url "$remote_name" 2>/dev/null); then
        if [[ "$existing_url" == "$remote_url" ]]; then
            vcs_log_info "Remote $remote_name already points to $remote_url."
        else
            if run_cmd git remote set-url "$remote_name" "$remote_url" >/dev/null 2>&1; then
                vcs_log_success "Updated remote $remote_name to $remote_url (was $existing_url)."
            else
                vcs_log_warning "Failed to update remote $remote_name to $remote_url."
            fi
        fi
    else
        if run_cmd git remote add "$remote_name" "$remote_url" >/dev/null 2>&1; then
            vcs_log_success "Added remote $remote_name pointing to $remote_url."
        else
            vcs_log_warning "Failed to add remote $remote_name pointing to $remote_url."
        fi
    fi
}

# Configure origin-GH / origin-GL failover remotes based on existing origin,
# or create default gh/gl remotes when no remotes exist.
configure_origin_failover() {
    local final_user="$1"
    local final_email="$2"

    if [[ "$GIT_CONFIG_SCOPE" != "--local" ]]; then
        vcs_log_info "Skipping remote configuration because scope is ${SCOPE_DESCRIPTION}."
        return
    fi

    local remotes
    remotes=$(git remote 2>/dev/null || true)

    if [[ -z "$remotes" ]]; then
        vcs_log_warning "No remotes found in this repository. Configuring default 'gh' and 'gl' remotes."
        local project_name
        project_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo '.')")

        if [[ -z "$final_user" || -z "$project_name" ]]; then
            vcs_log_error "Could not determine user or project name. Skipping remote creation."
            return
        fi

        local gh_url="git@github.com:${final_user}/${project_name}.git"
        local gl_url="git@gitlab.com:${final_user}/${project_name}.git"
        ensure_remote_url "gh" "$gh_url"
        ensure_remote_url "gl" "$gl_url"
        return
    fi

    local origin_url
    if ! origin_url=$(git remote get-url origin 2>/dev/null || true); then
        vcs_log_info "Remote 'origin' not found, but other remotes exist. Skipping origin-based failover."
        return
    fi

    local origin_host="" origin_path="" origin_format="" origin_user_prefix="" origin_scheme=""

    if [[ "$origin_url" =~ ^([[:alnum:]._-]+@)([^:]+):(.*)$ ]]; then
        origin_user_prefix="${BASH_REMATCH[1]}"
        origin_host="${BASH_REMATCH[2]}"
        origin_path="${BASH_REMATCH[3]}"
        origin_format="scp"
    elif [[ "$origin_url" =~ ^ssh://([^@]+@)?([^/]+)/(.+)$ ]]; then
        origin_user_prefix="${BASH_REMATCH[1]}"
        origin_host="${BASH_REMATCH[2]}"
        origin_path="${BASH_REMATCH[3]}"
        origin_format="ssh"
    elif [[ "$origin_url" =~ ^(https?://)([^/]+)/(.+)$ ]]; then
        origin_scheme="${BASH_REMATCH[1]}"
        origin_host="${BASH_REMATCH[2]}"
        origin_path="${BASH_REMATCH[3]}"
        origin_format="http"
    else
        vcs_log_info "Unsupported origin URL format '$origin_url'; skipping failover configuration."
        return
    fi

    local normalized_host="${origin_host,,}"
    local primary_acronym="" fallback_acronym="" fallback_host=""

    case "$normalized_host" in
    github.com | www.github.com)
        primary_acronym="GH"
        fallback_acronym="GL"
        fallback_host="gitlab.com"
        ;;
    gitlab.com | www.gitlab.com)
        primary_acronym="GL"
        fallback_acronym="GH"
        fallback_host="github.com"
        ;;
    *)
        vcs_log_info "Origin host '$origin_host' is not GitHub or GitLab; skipping failover configuration."
        return
        ;;
    esac

    local primary_remote="origin-${primary_acronym}"
    local fallback_remote="origin-${fallback_acronym}"

    vcs_log_info "Configuring remotes '${primary_remote}' and '${fallback_remote}' for $origin_host origin."
    ensure_remote_url "$primary_remote" "$origin_url"

    local fallback_url=""
    if [[ "$origin_format" == "http" ]]; then
        fallback_url="${origin_scheme}${fallback_host}/${origin_path}"
    elif [[ "$origin_format" == "ssh" ]]; then
        local ssh_user="${origin_user_prefix:-git@}"
        fallback_url="ssh://${ssh_user}${fallback_host}/${origin_path}"
    else
        local scp_user="${origin_user_prefix:-git@}"
        fallback_url="${scp_user}${fallback_host}:${origin_path}"
    fi

    if [[ "$fallback_url" == "$origin_url" ]]; then
        vcs_log_info "Fallback URL matches origin; skipping remote '${fallback_remote}'."
    else
        ensure_remote_url "$fallback_remote" "$fallback_url"
    fi
}

# Run the config-mode workflow: resolve scope, set identity, set failover remotes.
run_config_mode() {
    local cli_user="$1"
    local cli_email="$2"

    # In dry-run, preview scope and intended actions without touching git config
    # or validating chezmoi-template values (which are unresolved when the script
    # is run directly rather than via chezmoi apply).
    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ -n "$FORCE_SCOPE" ]]; then
            vcs_log_info "[DRY-RUN] Would apply ${FORCE_SCOPE} git configuration scope."
        elif is_git_repo; then
            vcs_log_info "[DRY-RUN] Would apply local git configuration (inside a git repository)."
        else
            vcs_log_info "[DRY-RUN] Would apply global git configuration (not inside a git repository)."
        fi
        vcs_log_info "[DRY-RUN] Would set user.name, user.email, and configure origin failover remotes."
        vcs_log_success "[DRY-RUN] Git configuration preview complete."
        return 0
    fi

    # Ensure we are inside a repo for --local scope detection.
    resolve_config_scope
    export GIT_CONFIG_SCOPE

    local final_user final_email
    final_user=$(determine_git_user "$cli_user")
    final_email=$(determine_git_email "$cli_email")

    if [[ -z "$final_user" ]]; then
        vcs_log_warning "Git user name is not set. Provide --user or set it in your chezmoi config."
    elif [[ "$final_user" == *"{{"* ]]; then
        vcs_log_error "Git user name contains unprocessed chezmoi template syntax."
        vcs_log_error "Run via chezmoi apply, or pass --user and --email explicitly."
        exit 1
    fi

    if [[ -z "$final_email" ]]; then
        vcs_log_warning "Git user email is not set. Provide --email or set it in your chezmoi config."
    elif [[ "$final_email" == *"{{"* ]]; then
        vcs_log_error "Git user email contains unprocessed chezmoi template syntax."
        vcs_log_error "Run via chezmoi apply, or pass --user and --email explicitly."
        exit 1
    fi

    set_git_config_property "user.name" "user name" "$final_user"
    set_git_config_property "user.email" "user email" "$final_email"

    configure_origin_failover "$final_user" "$final_email"

    vcs_log_success "Git configuration setup complete!"
}

# =====================================================================
# CREATE MODE: structural initialization
# =====================================================================

# Initialize git repository if not already one; create initial README commit.
init_git_repo() {
    local target_dir="${1:-$(pwd)}"
    local default_branch
    default_branch=$(get_account_config_value URL_PARTS "init.defaultBranch" "main")

    run_cd "$target_dir"

    # In dry-run, skip the "already a repo" short-circuit so init/structure
    # ops proceed and get logged via run_cmd. Otherwise a dry-run against a
    # nonexistent target would silently no-op against the current directory.
    if [[ "$DRY_RUN" != "true" ]] && is_git_repo; then
        vcs_log_info "Already in a git repository at $target_dir"
        return 0
    fi

    run_cmd git init --initial-branch="$default_branch"
    vcs_log_success "Git repository initialized with branch '$default_branch'"

    # In dry-run, assume no HEAD exists so the initial-commit path runs and
    # gets logged via run_cmd. Otherwise check for real HEAD.
    if [[ "$DRY_RUN" == "true" ]] || ! git rev-parse HEAD >/dev/null 2>&1; then
        if [[ ! -f README.md ]]; then
            local env_branches user_branch_pattern archive_tag_pattern
            local namespace="${URL_PARTS[namespace]:-}"

            if [[ -n "$namespace" ]]; then
                env_branches=$(get_config_value "accounts.$namespace.init.environment-branches" "")
                user_branch_pattern=$(get_config_value "accounts.$namespace.init.user-branch-pattern" "")
                archive_tag_pattern=$(get_config_value "accounts.$namespace.init.archive-tag-pattern" "")
            fi

            if [[ -z "$env_branches" ]]; then
                env_branches=$(get_config_value "accounts.init.environment-branches" "[\"env/prod\", \"env/stage\", \"env/dev\"]")
            fi
            if [[ -z "$user_branch_pattern" ]]; then
                user_branch_pattern=$(get_config_value "accounts.init.user-branch-pattern" "u/{user}/env/dev")
            fi
            if [[ -z "$archive_tag_pattern" ]]; then
                archive_tag_pattern=$(get_config_value "accounts.init.archive-tag-pattern" "tag/archive/{year}/{type}")
            fi

            local user_branch="${user_branch_pattern//\{user\}/$CURRENT_USER}"
            local root_tag="${archive_tag_pattern//\{year\}/$CURRENT_YEAR}"
            root_tag="${root_tag//\{type\}/git-root-node}"
            local pre_branches_tag="${archive_tag_pattern//\{year\}/$CURRENT_YEAR}"
            pre_branches_tag="${pre_branches_tag//\{type\}/pre-init-branches}"

            if [[ "$DRY_RUN" == "true" ]]; then
                vcs_log_info "[DRY-RUN] Would create README.md with repository documentation"
            else
                cat >README.md <<EOF
# $(basename "$(pwd)")

Repository initialized with git-repo-init script (configuration-driven).

## Branch Structure

- \`$default_branch\` - Main development branch
- \`env/prod\` - Production environment
- \`env/stage\` - Staging environment
- \`env/dev\` - Development environment
- \`$user_branch\` - Personal development branch
- \`gh_pages\` - GitHub Pages documentation (if enabled)

## Archive Tags

- \`$root_tag\` - Root commit
- \`$pre_branches_tag\` - State before branch creation

## Configuration

This repository uses configuration-driven git management:
- Config: \`~/.config/git/public-vcs.toml\`
- User Data: \`~/.local/share/git/public-vcs.toml\`
EOF
            fi
        fi

        run_cmd git add README.md
        run_cmd git commit -m "feat: initial repository setup

Initialize repository with standard branch structure and documentation.
Created by git-repo-init script on $(date -Iseconds).

Configuration-driven setup with:
- Default branch: $default_branch
- User: $CURRENT_USER
- Year: $CURRENT_YEAR"
        vcs_log_success "Initial commit created"
    fi
}

# Create archive tag for the root commit (idempotent; --force re-creates).
create_root_tag() {
    local root_commit
    root_commit=$(run_cmd_capture git rev-list --max-parents=0 HEAD)
    local tag_name="tag/archive/$CURRENT_YEAR/git-root-node"

    if tag_exists "$tag_name"; then
        if [[ "$FORCE" == "true" ]]; then
            vcs_log_warning "Re-creating root tag $tag_name (--force)"
            run_cmd git tag -d "$tag_name"
            run_cmd git tag -a "$tag_name" "$root_commit" -m "Archive tag for git root node

This tag marks the initial commit of the repository.
Re-created by git-repo-init script on $(date -Iseconds)."
            vcs_log_success "Re-created root archive tag: $tag_name"
        else
            vcs_log_warning "Root tag $tag_name already exists (use --force to re-create)"
        fi
    else
        run_cmd git tag -a "$tag_name" "$root_commit" -m "Archive tag for git root node

This tag marks the initial commit of the repository.
Created by git-repo-init script on $(date -Iseconds)."
        vcs_log_success "Created root archive tag: $tag_name"
    fi
}

# Create pre-branches archive tag (idempotent; --force re-creates).
create_pre_branches_tag() {
    local tag_name="tag/archive/$CURRENT_YEAR/pre-init-branches"

    if tag_exists "$tag_name"; then
        if [[ "$FORCE" == "true" ]]; then
            vcs_log_warning "Re-creating pre-branches tag $tag_name (--force)"
            run_cmd git tag -d "$tag_name"
            run_cmd git tag -a "$tag_name" HEAD -m "Archive tag before branch initialization

This tag marks the state of main branch before creating
environment and user branches.
Re-created by git-repo-init script on $(date -Iseconds)."
            vcs_log_success "Re-created pre-branches archive tag: $tag_name"
        else
            vcs_log_warning "Pre-branches tag $tag_name already exists (use --force to re-create)"
        fi
    else
        run_cmd git tag -a "$tag_name" HEAD -m "Archive tag before branch initialization

This tag marks the state of main branch before creating
environment and user branches.
Created by git-repo-init script on $(date -Iseconds)."
        vcs_log_success "Created pre-branches archive tag: $tag_name"
    fi
}

# Create and clean GitHub Pages branch (orphan). --force allows cleanup of
# an existing gh_pages branch.
setup_gh_pages() {
    local gh_pages_branch="gh_pages"

    if branch_exists "$gh_pages_branch"; then
        if [[ "$FORCE" != "true" ]]; then
            vcs_log_warning "GitHub Pages branch already exists (use --force to clean and rebuild)"
            return 0
        fi
        vcs_log_warning "Cleaning existing GitHub Pages branch (--force)..."
        run_cmd git checkout "$gh_pages_branch"

        if [[ -n "$(git ls-files)" ]]; then
            run_cmd git rm -rf .
            run_cmd git commit -m "chore: clean GitHub Pages branch

Remove all files to prepare for documentation.
Cleaned by git-repo-init script on $(date -Iseconds)." || true
        fi
    else
        vcs_log_info "Creating clean GitHub Pages branch..."
        run_cmd git checkout --orphan "$gh_pages_branch"
        run_cmd git rm -rf . 2>/dev/null || true

        if [[ "$DRY_RUN" == "true" ]]; then
            vcs_log_info "[DRY-RUN] Would create index.html for GitHub Pages"
        else
            cat >index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(basename "$(pwd)") Documentation</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
               max-width: 800px; margin: 0 auto; padding: 2rem; line-height: 1.6; }
        h1 { color: #333; border-bottom: 2px solid #eee; padding-bottom: 0.5rem; }
        .meta { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>$(basename "$(pwd)") Documentation</h1>
    <p class="meta">Generated by git-repo-init on $(date)</p>
    <p>This is the GitHub Pages site for the $(basename "$(pwd)") repository.</p>
    <p>Add your documentation here.</p>
</body>
</html>
EOF
        fi

        run_cmd git add index.html
        run_cmd git commit -m "feat: initialize GitHub Pages

Create basic GitHub Pages site structure.
Created by git-repo-init script on $(date -Iseconds)."
    fi

    vcs_log_success "GitHub Pages branch ready"
}

# Create environment branches from config (idempotent; --force is unused here
# because branch creation is non-destructive — existing branches are skipped).
create_environment_branches() {
    local create_env_branches
    create_env_branches=$(get_account_config_value URL_PARTS "init.create-environment-branches" "true")

    if [[ "$create_env_branches" != "true" ]]; then
        vcs_log_info "Environment branch creation disabled by configuration"
        return 0
    fi

    local env_branches_config
    env_branches_config=$(get_account_config_value URL_PARTS "init.environment-branches" "env/prod,env/stage,env/dev")

    local branches=()
    if [[ "$env_branches_config" =~ ^\[.*\]$ ]]; then
        IFS=',' read -ra branches <<<"$(echo "$env_branches_config" | sed 's/\[//;s/\]//;s/"//g;s/ //g')"
    else
        IFS=',' read -ra branches <<<"$env_branches_config"
    fi

    local default_branch
    default_branch=$(get_account_config_value URL_PARTS "init.defaultBranch" "main")
    run_cmd git checkout "$default_branch"

    vcs_log_info "Creating environment branches: ${branches[*]}"
    local branch
    for branch in "${branches[@]}"; do
        branch=$(echo "$branch" | xargs)
        [[ -z "$branch" ]] && continue

        if branch_exists "$branch"; then
            vcs_log_warning "Branch $branch already exists"
        else
            run_cmd git checkout -b "$branch"
            vcs_log_success "Created branch: $branch"
            run_cmd git checkout "$default_branch"
        fi
    done
}

# Add origin remote and push all branches + tags.
setup_remote_and_push() {
    local remote_url="$1"

    if [[ -z "$remote_url" ]]; then
        vcs_log_warning "No remote URL provided, skipping remote setup"
        vcs_log_info "To add remote later: git remote add origin <url>"
        vcs_log_info "To push: git push -u origin --all && git push origin --tags"
        return 0
    fi

    # In dry-run, assume origin doesn't exist so `git remote add` gets logged.
    if [[ "$DRY_RUN" == "true" ]] || ! git remote get-url origin >/dev/null 2>&1; then
        run_cmd git remote add origin "$remote_url"
        vcs_log_success "Added remote origin: $remote_url"
    else
        vcs_log_info "Remote origin already exists: $(git remote get-url origin)"
    fi

    vcs_log_info "Pushing all branches to remote..."
    run_cmd git push -u origin --all

    vcs_log_info "Pushing all tags to remote..."
    run_cmd git push origin --tags

    vcs_log_success "All branches and tags pushed to remote"
}

# Switch to the user's personal development branch.
switch_to_user_branch() {
    local user_branch_pattern
    user_branch_pattern=$(get_account_config_value URL_PARTS "init.user-branch-pattern" "u/{user}/env/dev")

    local user_branch="${user_branch_pattern//\{user\}/$CURRENT_USER}"

    if ! branch_exists "$user_branch"; then
        local default_branch
        default_branch=$(get_account_config_value URL_PARTS "init.defaultBranch" "main")
        run_cmd git checkout "$default_branch"
        run_cmd git checkout -b "$user_branch"
        vcs_log_success "Created user development branch: $user_branch"
    fi

    run_cmd git checkout "$user_branch"
    vcs_log_success "Switched to user development branch: $user_branch"
}

# Clone repository (with fallback to original URL if constructed URL fails).
# NOTE: nameref is intentionally named clone_url_parts_ref (not url_parts_ref)
# to avoid a circular name reference when construct_clone_url internally calls
# get_account_config_value, which declares its own `local -n url_parts_ref`.
# If this nameref were also named url_parts_ref, bash's dynamic scoping would
# chain url_parts_ref (get_account_config_value) -> url_parts (construct_clone_url)
# -> url_parts_ref (clone_repository) and emit a circular reference warning.
clone_repository() {
    local remote_url="$1"
    local target_dir="$2"
    local -n clone_url_parts_ref=$3

    local repo_dir="${clone_url_parts_ref[project]}"
    local repo_path="$target_dir/$repo_dir"

    if [[ -d "$repo_dir" ]]; then
        vcs_log_warning "Directory $repo_dir already exists. Skipping clone."
    else
        local clone_url
        clone_url=$(construct_clone_url clone_url_parts_ref)
        vcs_log_info "Clone URL: $clone_url"

        vcs_log_info "Cloning repository..."
        if run_cmd git clone "$clone_url" "$repo_dir"; then
            vcs_log_success "Repository cloned successfully"
        else
            vcs_log_error "Failed to clone repository"
            if [[ "$clone_url" != "$remote_url" ]]; then
                vcs_log_info "Retrying with original URL: $remote_url"
                if run_cmd git clone "$remote_url" "$repo_dir"; then
                    vcs_log_success "Repository cloned with original URL"
                else
                    vcs_log_error "Clone failed with both URLs"
                    exit 5
                fi
            else
                exit 5
            fi
        fi
    fi

    run_cd "$repo_dir"

    if [[ "$DRY_RUN" != "true" ]] && [[ ! -d .git ]]; then
        vcs_log_error "$PWD is not a valid git repository"
        exit 6
    fi

    echo "$PWD"
}

# Display final status summary.
show_final_status() {
    echo
    vcs_log_info "Repository initialization complete!"
    echo
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] Would list branches, tags, and current branch."
    else
        echo "Created branches:"
        git branch -a | sed 's/^/  /'
        echo
        echo "Created tags:"
        git tag | grep "tag/archive/$CURRENT_YEAR" | sed 's/^/  /'
        echo
        echo "Current branch: $(git branch --show-current)"
    fi
    echo
    vcs_log_info "Ready for development!"
}

# Apply account-specific git config (user.name, user.email, init.defaultBranch)
# using the shared library's configure_git_repo. Used in create mode after
# clone or init, before structural ops.
apply_account_config() {
    local repo_path="$1"
    local git_user="$2"
    local git_email="$3"

    if [[ -d "$repo_path/.git" ]] || is_git_repo; then
        run_cmd configure_git_repo URL_PARTS "$repo_path" "$git_user" "$git_email"
    else
        vcs_log_warning "Not a git repository: $repo_path"
    fi
}

# Run the create-mode workflow.
run_create_mode() {
    local remote_url="$1"
    local target_dir="$2"
    local cli_user="$3"
    local cli_email="$4"
    local repo_path
    repo_path="$(pwd)"

    # Initialize configuration files (shared library).
    ensure_config_files

    # Parse remote URL if provided.
    if [[ -n "$remote_url" ]]; then
        if validate_git_url "$remote_url" && parse_git_url "$remote_url" URL_PARTS; then
            vcs_log_info "Parsed repository: ${URL_PARTS[namespace]}/${URL_PARTS[project]}"
            if [[ -z "$target_dir" ]]; then
                target_dir=$(resolve_repo_path URL_PARTS)
                vcs_log_info "Resolved target directory: $target_dir"
            fi
        else
            vcs_log_warning "Could not parse remote URL, using current directory"
        fi
    fi

    # Create / enter target directory.
    if [[ -n "$target_dir" ]]; then
        run_cmd mkdir -p "$target_dir"
        run_cd "$target_dir"
        repo_path="$target_dir"
    fi

    # Determine user/email for create mode.
    local git_user git_email
    git_user=$(determine_git_user "$cli_user")
    git_email=$(determine_git_email "$cli_email")

    vcs_log_info "Starting git repository management..."
    vcs_log_info "User: $git_user"
    vcs_log_info "Email: $git_email"
    vcs_log_info "Year: $CURRENT_YEAR"
    vcs_log_info "Repository path: $repo_path"
    [[ -n "$remote_url" ]] && vcs_log_info "Remote URL: $remote_url"
    echo

    # Clone if requested.
    if [[ "$SHOULD_CLONE" == "true" ]]; then
        repo_path=$(clone_repository "$remote_url" "$target_dir" URL_PARTS)
        apply_account_config "$repo_path" "$git_user" "$git_email"

        if [[ "$CLONE_ONLY" == "true" ]]; then
            vcs_log_success "Clone operation completed successfully"
            echo
            echo "Repository Path: $repo_path"
            echo "Git Configuration:"
            echo "  User Name:  $(git config user.name 2>/dev/null || echo 'Not set')"
            echo "  User Email: $(git config user.email 2>/dev/null || echo 'Not set')"
            echo "  Default Branch: $(git config init.defaultBranch 2>/dev/null || echo 'Not set')"
            echo
            printf '\a' # Ring system bell
            return 0
        fi
    fi

    # Structural initialization (gated by --init-structure, which is auto-set
    # in create mode but can be disabled with --no-init-structure).
    if [[ "$SHOULD_INIT_STRUCTURE" == "true" ]]; then
        init_git_repo "$repo_path"
        create_root_tag
        create_pre_branches_tag

        # Account-specific optional features.
        # NOTE: assign empty strings in the local declaration — `local x` alone
        # leaves x unset, which triggers "unbound variable" under `set -u`.
        local create_gh_pages="" create_user_branch="" namespace=""
        namespace="${URL_PARTS[namespace]:-}"

        if [[ -n "$namespace" ]]; then
            create_gh_pages=$(get_config_value "accounts.$namespace.init.create-gh-pages" "")
            create_user_branch=$(get_config_value "accounts.$namespace.init.create-user-branch" "")
        fi
        if [[ -z "$create_gh_pages" ]]; then
            create_gh_pages=$(get_config_value "accounts.init.create-gh-pages" "true")
        fi
        if [[ -z "$create_user_branch" ]]; then
            create_user_branch=$(get_config_value "accounts.init.create-user-branch" "true")
        fi

        if [[ "$create_gh_pages" == "true" ]]; then
            setup_gh_pages
        else
            vcs_log_info "Skipping GitHub Pages setup (disabled in configuration)"
        fi

        create_environment_branches

        # Apply account config if not already done via clone path.
        if [[ -n "$remote_url" ]] && [[ -v URL_PARTS ]] && [[ "$SHOULD_CLONE" == "false" ]]; then
            apply_account_config "$repo_path" "$git_user" "$git_email"
        fi

        # Set up origin and push (only when URL provided and not already cloned).
        if [[ -n "$remote_url" ]] && [[ "$SHOULD_CLONE" == "false" ]]; then
            setup_remote_and_push "$remote_url"
        fi

        if [[ "$create_user_branch" == "true" ]]; then
            switch_to_user_branch
        else
            vcs_log_info "Skipping user branch creation (disabled in configuration)"
        fi

        show_final_status
    fi

    # Always run config-mode workflow at the end so identity + failover remotes
    # are applied idempotently on the freshly created (or freshly entered) repo.
    if [[ "$CLONE_ONLY" != "true" ]]; then
        vcs_log_info "Applying git configuration defaults..."
        # Force local scope for create mode (we are inside the repo).
        FORCE_SCOPE="local"
        run_config_mode "$cli_user" "$cli_email"
    fi
}

# =====================================================================
# CLI
# =====================================================================

show_usage() {
    echo "Usage: git-repo-init [OPTIONS] [REMOTE-URL] [TARGET-DIRECTORY]"
    echo "Try 'git-repo-init --help' for more information."
}

show_help() {
    cat <<EOF
Git Repository Setup Script (Configuration-Driven, Unified)

USAGE:
    git-repo-init [OPTIONS] [REMOTE-URL] [TARGET-DIRECTORY]

DESCRIPTION:
    Unified git repository management. Auto-detects mode:
      - target dir does not exist OR is empty/non-git  -> CREATE mode
      - target dir is an existing git repo             -> CONFIG mode

    CREATE mode runs structural initialization (branches, tags, gh_pages,
    remote push) plus config-mode (identity + failover remotes).
    CONFIG mode only sets user.name/user.email and origin-GH/origin-GL
    failover remotes, idempotently.

MODES:
    Auto-detect        Based on target directory state (default)
    --clone-only       Clone remote URL, skip structural init
    --init-only        Skip cloning, work in current/target dir
    --init-structure   Force structural ops even in config mode
    --no-init-structure  Skip structural ops even in create mode

OPTIONS:
    -u, --user NAME        Specify git user name
    -e, --email EMAIL      Specify git user email
    -g, --global           Force global git config scope (config mode)
    -l, --local            Force local git config scope (config mode)
    -c, --clone-only       Clone only, skip branch structure setup
    -i, --init-only        Initialize only (skip cloning)
    -s, --init-structure   Enable structural ops (branches, tags, gh_pages, push)
        --no-init-structure  Disable structural ops
    -f, --force            Allow destructive overwrites (re-tag, gh_pages cleanup)
    -n, --dry-run          Show what would be done without making changes
    -v, --verbose          Verbose output (debug-level logging)
    -q, --quiet            Quiet output (errors only)
    -h, --help             Show this help message
        --usage            Show short usage information

ARGUMENTS:
    remote-url             Optional git repository URL (any protocol)
    target-directory       Optional target directory (auto-resolved if URL provided)

CONFIGURATION:
    ~/.config/git/public-vcs.toml       - System configuration
    ~/.local/share/git/public-vcs.toml  - User-specific settings

EXAMPLES:
    # Auto-detect in current directory
    git-repo-init

    # Clone + create + config
    git-repo-init git@github.com:user/repo.git

    # Clone only
    git-repo-init --clone-only git@github.com:user/repo.git

    # Initialize only in specific directory
    git-repo-init --init-only /path/to/existing/repo

    # Config-only on existing repo with explicit identity
    git-repo-init --user me --email me@x.com /path/to/repo

    # Force structural ops on an existing repo (destructive)
    git-repo-init --init-structure --force /path/to/repo

    # Preview what would happen, verbose
    git-repo-init --dry-run -v git@github.com:user/repo.git

ENVIRONMENT:
    DEBUG_VCS=1      Enable debug logging (equivalent to --verbose)
    LOG_LEVEL        0=silent 1=error 2=warn/success 3=info 4=debug

CONFIGURATION KEYS:
    mappings.*                                  - Host to directory acronym mappings
    accounts.*.user.name                       - Account-specific git user name
    accounts.*.user.email                      - Account-specific git user email
    accounts.*.protocol                        - Preferred protocol (ssh/https)
    accounts.*.host-alias                      - SSH host alias mapping (legacy)
    accounts.*.init.defaultBranch              - Account-specific default branch
    accounts.*.init.create-gh-pages            - Account-specific GitHub Pages setting
    accounts.*.init.create-user-branch         - Account-specific user branch setting
    accounts.*.init.create-environment-branches  - Account-specific env branch toggle
    accounts.*.init.environment-branches       - Account-specific environment branches
    accounts.*.init.user-branch-pattern        - Account-specific user branch pattern
    accounts.*.init.archive-tag-pattern        - Account-specific archive tag pattern
    accounts.*.paths.base                      - Account-specific base project directory
    accounts.*.paths.pattern                   - Account-specific directory structure pattern
    ssh-aliases."host/namespace"               - Namespace-specific SSH aliases
    ssh-aliases.defaults.*                     - Default host-only SSH aliases

EOF
}

# Parse command line arguments.
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
        -u | --user)
            CLI_USER="$2"
            shift
            shift
            ;;
        -e | --email)
            CLI_EMAIL="$2"
            shift
            shift
            ;;
        -g | --global)
            if [[ "$FORCE_SCOPE" == "local" ]]; then
                vcs_log_error "--global and --local cannot be used together."
                exit 1
            fi
            FORCE_SCOPE="global"
            shift
            ;;
        -l | --local)
            if [[ "$FORCE_SCOPE" == "global" ]]; then
                vcs_log_error "--global and --local cannot be used together."
                exit 1
            fi
            FORCE_SCOPE="local"
            shift
            ;;
        -c | --clone-only)
            CLONE_ONLY=true
            shift
            ;;
        -i | --init-only)
            INIT_ONLY=true
            shift
            ;;
        -s | --init-structure)
            INIT_STRUCTURE=true
            shift
            ;;
        --no-init-structure)
            INIT_STRUCTURE="no"
            shift
            ;;
        -f | --force)
            FORCE=true
            shift
            ;;
        -n | --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v | --verbose)
            LOG_LEVEL=4
            export DEBUG_VCS=1
            shift
            ;;
        -q | --quiet)
            LOG_LEVEL=1
            shift
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        --usage)
            show_usage
            exit 0
            ;;
        -*)
            vcs_log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$REMOTE_URL" ]]; then
                REMOTE_URL="$1"
            elif [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            else
                vcs_log_error "Too many arguments: $1"
                show_help
                exit 1
            fi
            shift
            ;;
        esac
    done

    # Validate argument combinations.
    if [[ "$CLONE_ONLY" == true && "$INIT_ONLY" == true ]]; then
        vcs_log_error "Cannot specify both --clone-only and --init-only"
        exit 1
    fi

    if [[ "$CLONE_ONLY" == true && -z "$REMOTE_URL" ]]; then
        vcs_log_error "--clone-only requires a remote URL"
        exit 1
    fi

    export DRY_RUN INIT_STRUCTURE FORCE FORCE_SCOPE CLI_USER CLI_EMAIL
    export REMOTE_URL TARGET_DIR CLONE_ONLY INIT_ONLY LOG_LEVEL
}

# =====================================================================
# MAIN
# =====================================================================

main() {
    parse_arguments "$@"

    # If no arguments at all, show help.
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    # If only identity flags were provided with no remote/target, treat as
    # config mode on the current directory (matches git-config-defaults usage).
    local identity_only=true
    [[ -n "$REMOTE_URL" ]] && identity_only=false
    [[ -n "$TARGET_DIR" ]] && identity_only=false
    [[ "$CLONE_ONLY" == true ]] && identity_only=false
    [[ "$INIT_ONLY" == true ]] && identity_only=false
    [[ "$INIT_STRUCTURE" == true ]] && identity_only=false

    if [[ "$identity_only" == true ]]; then
        # Pure config-mode invocation (e.g. --user/--email/--global/--local only).
        run_config_mode "$CLI_USER" "$CLI_EMAIL"
        return 0
    fi

    # Determine mode based on target state.
    detect_mode

    # Allow --init-structure to force structural ops in config mode.
    if [[ "$INIT_STRUCTURE" == true && "$MODE" == "config" ]]; then
        SHOULD_INIT_STRUCTURE=true
        MODE="create"
        vcs_log_info "Forcing create mode due to --init-structure"
    fi
    # Allow --no-init-structure to disable structural ops in create mode.
    if [[ "$INIT_STRUCTURE" == "no" ]]; then
        SHOULD_INIT_STRUCTURE=false
    fi
    # --init-only forces create mode (no clone). Respect an explicit
    # --no-init-structure: only force structural ops if the user did NOT opt out.
    if [[ "$INIT_ONLY" == true ]]; then
        MODE="create"
        SHOULD_CLONE=false
        if [[ "$INIT_STRUCTURE" != "no" ]]; then
            SHOULD_INIT_STRUCTURE=true
        fi
    fi
    # --clone-only forces clone without structural init.
    if [[ "$CLONE_ONLY" == true ]]; then
        MODE="create"
        SHOULD_CLONE=true
        SHOULD_INIT_STRUCTURE=false
    fi

    vcs_log_info "Mode: $MODE | clone=${SHOULD_CLONE:-false} | structure=${SHOULD_INIT_STRUCTURE:-false} | force=$FORCE | dry-run=$DRY_RUN"

    if [[ "$MODE" == "create" ]]; then
        run_create_mode "$REMOTE_URL" "$TARGET_DIR" "$CLI_USER" "$CLI_EMAIL"
    else
        run_config_mode "$CLI_USER" "$CLI_EMAIL"
    fi
}

main "$@"
