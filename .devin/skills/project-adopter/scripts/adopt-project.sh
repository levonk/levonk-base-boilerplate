#!/bin/bash

# Project Adopter Script
# Uses project-detection and surgical-config skills for intelligent project adoption

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Loop prevention
readonly PROJECT_ADOPTER_LOCK_FILE="/tmp/.project-adopter.lock"
readonly SURGICAL_CONFIG_LOCK_FILE="/tmp/.surgical-config.lock"
LOOP_DETECTION_ENABLED=true

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check for potential infinite loops
check_for_loops() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip loop detection if forced
    if [[ "${FORCE_ADOPTION:-}" == "true" ]]; then
        log_info "Force adoption enabled - skipping loop prevention"
        return 0
    fi

    # Check if project-adopter is already running
    if [[ -f "$PROJECT_ADOPTER_LOCK_FILE" ]]; then
        local adopter_pid
        adopter_pid=$(cat "$PROJECT_ADOPTER_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$adopter_pid" ]] && kill -0 "$adopter_pid" 2>/dev/null; then
            log_warn "Project-adopter is already running (PID: $adopter_pid)"
            log_warn "Avoiding potential infinite loop - exiting"
            exit 1
        else
            # Stale lock file, remove it
            rm -f "$PROJECT_ADOPTER_LOCK_FILE"
        fi
    fi

    # Check if surgical-config is already running (might indicate nested call)
    if [[ -f "$SURGICAL_CONFIG_LOCK_FILE" ]]; then
        local surgical_pid
        surgical_pid=$(cat "$SURGICAL_CONFIG_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$surgical_pid" ]] && kill -0 "$surgical_pid" 2>/dev/null; then
            # Check if this is a nested call from the same process tree
            local current_ppid
            current_ppid=$(ps -o ppid= -p $$ 2>/dev/null | tr -d ' ')
            local surgical_ppid
            surgical_ppid=$(ps -o ppid= -p "$surgical_pid" 2>/dev/null | tr -d ' ' || echo "")

            if [[ "$current_ppid" == "$surgical_ppid" ]] || [[ "$current_ppid" == "$surgical_pid" ]]; then
                log_warn "Nested call detected - surgical-config is running from same process tree"
                log_warn "Avoiding potential infinite loop - exiting"
                exit 1
            fi
        else
            # Stale lock file, remove it
            rm -f "$SURGICAL_CONFIG_LOCK_FILE"
        fi
    fi

    return 0
}

# Create lock file for this process
create_lock_file() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    echo $$ > "$PROJECT_ADOPTER_LOCK_FILE"
    # Set up cleanup on exit
    trap 'rm -f "$PROJECT_ADOPTER_LOCK_FILE"' EXIT
}

# Check if we're being called by another project-adopter instance
check_caller() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip caller check if forced
    if [[ "${FORCE_ADOPTION:-}" == "true" ]]; then
        log_info "Force adoption enabled - skipping caller check"
        return 0
    fi

    local parent_process
    parent_process=$(ps -o comm= -p $(ps -o ppid= -p $$ | tr -d ' ') 2>/dev/null || echo "")

    # Check if parent process looks like project-adopter
    if [[ "$parent_process" == *"adopt-project"* ]] || [[ "$parent_process" == *"project-adopter"* ]]; then
        log_warn "Called by another project-adopter process: $parent_process"
        log_warn "Avoiding potential infinite loop - exiting"
        exit 1
    fi

    # Check environment variables that might indicate recursive call
    if [[ -n "${PROJECT_ADOPTER_RUNNING:-}" ]] || [[ -n "${ADOPTER_MODE:-}" ]]; then
        log_warn "Running in project-adopter context (detected from environment)"
        log_warn "Avoiding potential infinite loop - exiting"
        exit 1
    fi

    return 0
}

# Set project path
PROJECT_PATH="${1:-.}"
PROJECT_NAME="${2:-$(basename "$PROJECT_PATH")}"

# Skill paths (auto-detect context)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# Determine context and set skill paths
determine_context() {
    if [[ "$SCRIPT_DIR" == *".chezmoitemplates"* ]]; then
        echo "chezmoi-templates:$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
    elif [[ "$SCRIPT_DIR" == *"/.config/ai/skills/"* ]]; then
        echo "deployed-config:$(dirname "$(dirname "$SCRIPT_DIR")")"
    elif [[ "$SCRIPT_DIR" == *"/skills/"* ]] && [[ "$SCRIPT_DIR" != *".config"* ]]; then
        echo "ai-tools:$(dirname "$SCRIPT_DIR")"
    else
        echo "default:$(dirname "$SCRIPT_DIR")"
    fi
}

# Get skill paths based on context
get_skill_paths() {
    local context_info
    context_info=$(determine_context)
    local context_type="${context_info%%:*}"
    local base_path="${context_info##*:}"

    case "$context_type" in
        "chezmoi-templates")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        "deployed-config")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        "ai-tools")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        *)
            echo "$base_path/../project-detection/scripts"
            echo "$base_path/../surgical-config/scripts"
            ;;
    esac
}

# Load project detection functions
load_project_detection() {
    local skill_paths
    readarray -t skill_paths < <(get_skill_paths)
    local detection_path="${skill_paths[0]}"

    if [[ -f "$detection_path/detect-build-systems.sh" ]]; then
        source "$detection_path/detect-build-systems.sh"
        source "$detection_path/detect-ci-cd-systems.sh"
        source "$detection_path/detect-workspace-configs.sh"
        log_info "✓ Project detection functions loaded from: $detection_path"
        return 0
    else
        log_error "Project detection scripts not found at: $detection_path"
        return 1
    fi
}

# Load surgical-config functions
load_surgical_config() {
    local skill_paths
    readarray -t skill_paths < <(get_skill_paths)
    local surgical_path="${skill_paths[1]}"

    if [[ -f "$surgical_path/surgical-edit.sh" ]]; then
        SURGICAL_EDIT="$surgical_path/surgical-edit.sh"
        SURGICAL_ENV="$surgical_path/ensure-environment.sh"
        log_info "✓ Surgical config functions found at: $surgical_path"
        return 0
    else
        log_error "Surgical config scripts not found at: $surgical_path"
        return 1
    fi
}

# Detect project characteristics
detect_project() {
    log_step "Detecting project characteristics..."

    # Detect build systems
    local build_systems
    build_systems=$(detect_systems "$PROJECT_PATH" "false")
    log_info "Detected build systems: $build_systems"

    # Detect CI/CD systems
    local ci_cd_systems
    ci_cd_systems=$(detect_ci_cd_systems "$PROJECT_PATH" "false")
    log_info "Detected CI/CD systems: $ci_cd_systems"

    # Detect workspace configurations
    local workspace_configs
    workspace_configs=$(analyze_workspace_configs "$PROJECT_PATH" "$PROJECT_NAME" "false")
    log_info "Workspace configs: $workspace_configs"

    echo "$build_systems|$ci_cd_systems|$workspace_configs"
}

# Detect languages in project and apply per-language configurations
apply_surgical_configs() {
    local detected_characteristics="$1"

    log_step "Applying per-language configuration updates..."

    # Parse characteristics to get build systems, app type, and project type
    parse_project_characteristics "$detected_characteristics"

    # Detect languages based on build systems
    local detected_languages=""
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "npm\|pnpm\|yarn\|bun"; then
        detected_languages="$detected_languages nodejs"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "cargo\|rust"; then
        detected_languages="$detected_languages rust"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "poetry\|python\|pip"; then
        detected_languages="$detected_languages python"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "go\|golang"; then
        detected_languages="$detected_languages go"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "maven\|gradle"; then
        detected_languages="$detected_languages java"
    fi

    log_info "Detected languages: $detected_languages"

    # Load per-language configuration scripts
    load_language_config_scripts

    # Configure each detected language
    for lang in $detected_languages; do
        case "$lang" in
            "nodejs")
                configure_nodejs_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "rust")
                configure_rust_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "python")
                configure_python_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "go")
                configure_go_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "java")
                configure_java_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            *)
                log_warn "Unknown language: $lang"
                ;;
        esac
    done

    # If no languages detected, use generic configuration
    if [[ -z "$detected_languages" ]]; then
        log_info "No specific languages detected, using generic configuration"
        configure_generic_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
    fi
}

# Load per-language configuration scripts
load_language_config_scripts() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Source language configuration scripts
    for script in "$script_dir"/configure-*.sh; do
        if [[ -f "$script" ]]; then
            # shellcheck source=/dev/null
            source "$script"
            log_info "✓ Loaded $(basename "$script")"
        fi
    done
}

# Configure Node.js project using per-language script
configure_nodejs_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Node.js project with per-language script..."

    if command -v configure_nodejs_project >/dev/null 2>&1; then
        configure_nodejs_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Node.js project configured"
    else
        log_warn "Node.js configuration function not available"
    fi
}

# Configure Rust project using per-language script
configure_rust_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Rust project with per-language script..."

    if command -v configure_rust_project >/dev/null 2>&1; then
        configure_rust_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Rust project configured"
    else
        log_warn "Rust configuration function not available"
    fi
}

# Configure Python project using per-language script
configure_python_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Python project with per-language script..."

    if command -v configure_python_project >/dev/null 2>&1; then
        configure_python_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Python project configured"
    else
        log_warn "Python configuration function not available"
    fi
}

# Configure Go project using per-language script
configure_go_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Go project with per-language script..."

    if command -v configure_go_project >/dev/null 2>&1; then
        configure_go_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Go project configured"
    else
        log_warn "Go configuration function not available"
    fi
}

# Configure Java project using per-language script
configure_java_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Java project with per-language script..."

    if command -v configure_java_project >/dev/null 2>&1; then
        configure_java_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Java project configured"
    else
        log_warn "Java configuration function not available"
    fi
}

# Configure generic project using per-language script
configure_generic_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring generic project with per-language script..."

    if command -v configure_generic_project >/dev/null 2>&1; then
        configure_generic_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Generic project configured"
    else
        log_warn "Generic configuration function not available"
    fi
}

# Create/update configuration files
create_config_files() {
    local detected_characteristics="$1"

    log_step "Creating/updating configuration files..."

    # Parse characteristics for use in configuration generation
    parse_project_characteristics "$detected_characteristics"

    # Create/update .envrc
    # .envrc configuration delegated to dev-env-upsert skill — see SKILL.md step 5.
    # dev-env-upsert's `setup` call (below, in the devbox section) already
    # handles .envrc via --envrc-async-prime (runs `devbox generate direnv
    # --print-envrc` and appends the async prime_impl trigger). The fallback
    # heredoc below is kept for when dev-env-upsert is not installed.
    if [[ ! -f "$PROJECT_PATH/.envrc" ]]; then
        log_info "Creating .envrc..."
        cat > "$PROJECT_PATH/.envrc" << 'EOF'
# Project Environment Configuration

# Use devbox if available
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox shellenv)"
fi

# Project-specific environment
export PROJECT_NAME="$(basename "$PWD)"
export PROJECT_PATH="$PWD"

# Watch for changes
watch_file devbox.json
watch_file package.json
watch_file Cargo.toml
watch_file pyproject.toml
watch_file go.mod
EOF
        log_info "✓ .envrc created"
    fi

    # Create/update devbox.json
    # devbox.json configuration delegated to dev-env-upsert skill — see SKILL.md step 3.
    # The existing generate_devbox_json logic below is a FALLBACK for when
    # dev-env-upsert is not installed. Do NOT remove it.
    local dev_env_upsert_dir=""
    local cli_discovery="$SCRIPT_DIR/cli-tool-discovery.sh"

    # Resolve the dev-env-upsert skill directory via sibling-skill context
    # detection (same pattern used for project-detection / surgical-config).
    # cli-tool-discovery.sh is used to resolve the uv runner (NOT bare command -v)
    # so the dev_env_upsert.py script runs through the correct environment.
    local context_info
    context_info=$(determine_context)
    local context_type="${context_info%%:*}"
    local base_path="${context_info##*:}"
    case "$context_type" in
        chezmoi-templates|deployed-config|ai-tools)
            if [[ -f "$base_path/dev-env-upsert/scripts/dev_env_upsert.py" ]]; then
                dev_env_upsert_dir="$base_path/dev-env-upsert"
            fi
            ;;
        *)
            if [[ -f "$SKILL_ROOT/../dev-env-upsert/scripts/dev_env_upsert.py" ]]; then
                dev_env_upsert_dir="$SKILL_ROOT/../dev-env-upsert"
            fi
            ;;
    esac

    # Resolve uv via cli-tool-discovery (not bare command -v)
    local uv_runner="uv"
    if [[ -x "$cli_discovery" ]]; then
        local uv_resolve
        uv_resolve="$("$cli_discovery" uv 2>/dev/null || true)"
        if [[ "$uv_resolve" == FOUND:* ]]; then
            uv_runner="uv"
        elif [[ "$uv_resolve" == WRAPPER:* ]]; then
            uv_runner="${uv_resolve#WRAPPER: } uv"
        fi
    fi

    if [[ -n "$dev_env_upsert_dir" ]] && [[ -f "$dev_env_upsert_dir/scripts/dev_env_upsert.py" ]]; then
        log_info "Delegating devbox.json configuration to dev-env-upsert skill..."
        if [[ ! -f "$PROJECT_PATH/devbox.json" ]]; then
            $uv_runner run --script "$dev_env_upsert_dir/scripts/dev_env_upsert.py" reconcile --target "$PROJECT_PATH" || {
                log_warn "dev-env-upsert reconcile failed, falling back to generate_devbox_json"
                local detection_script="../../project-detection/scripts/detect-build-systems.sh"
                local detected_characteristics=""
                if [[ -f "$detection_script" ]]; then
                    detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
                fi
                generate_devbox_json "$PROJECT_PATH" "$detected_characteristics"
            }
        else
            log_info "devbox.json already exists — running dev-env-upsert reconcile to update packages"
            $uv_runner run --script "$dev_env_upsert_dir/scripts/dev_env_upsert.py" reconcile --target "$PROJECT_PATH" || {
                log_warn "dev-env-upsert reconcile failed on existing devbox.json, skipping"
            }
        fi
    else
        # Fallback: existing logic (dev-env-upsert not installed)
        if [[ ! -f "$PROJECT_PATH/devbox.json" ]]; then
            log_info "Creating devbox.json with language-specific packages (fallback — dev-env-upsert not available)..."
            # Detect project characteristics for devbox.json generation
            local detection_script="../../project-detection/scripts/detect-build-systems.sh"
            local detected_characteristics=""
            if [[ -f "$detection_script" ]]; then
                detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
            fi
            generate_devbox_json "$PROJECT_PATH" "$detected_characteristics"
        else
            log_info "devbox.json already exists, skipping creation"
        fi
    fi

    # Indexed AST tool detection + setup (delegated to dev-env-upsert — see SKILL.md step 3a).
    # Detection is file-type-aware:
    #   - Source code files → CodeGraph
    #   - Multi-repo workspace (pnpm workspaces, Nx monorepo, git submodules) → GitNexus
    #     (procure commercial license for business use before setup)
    #   - Non-code docs/PDFs/video → Graphify
    # Only ONE tool is installed — do NOT install all three by default.
    # Indexing folds into the existing prime_impl target via dev-env-upsert's
    # setup or add-prime-steps command — do NOT create new index/index_impl targets.
    if [[ -n "$dev_env_upsert_dir" ]] && [[ -f "$dev_env_upsert_dir/scripts/dev_env_upsert.py" ]]; then
        local indexed_ast_tool=""
        # Detect source code extensions
        local code_file_count
        code_file_count=$(find "$PROJECT_PATH" -maxdepth 3 \
            \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
               -o -name '*.py' -o -name '*.rs' -o -name '*.go' -o -name '*.java' \
               -o -name '*.kt' -o -name '*.swift' -o -name '*.c' -o -name '*.cpp' \) \
            -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/target/*' \
            2>/dev/null | head -1)
        # Detect multi-repo workspace
        local is_workspace=0
        if [[ -f "$PROJECT_PATH/pnpm-workspace.yaml" ]] \
           || [[ -f "$PROJECT_PATH/nx.json" ]] \
           || [[ -f "$PROJECT_PATH/lerna.json" ]] \
           || [[ -f "$PROJECT_PATH/.gitmodules" ]]; then
            is_workspace=1
        fi
        # Detect non-code docs/PDFs/video
        local doc_file_count
        doc_file_count=$(find "$PROJECT_PATH" -maxdepth 3 \
            \( -name '*.pdf' -o -name '*.docx' -o -name '*.pptx' \
               -o -name '*.mp4' -o -name '*.mov' -o -name '*.md' \) \
            -not -path '*/node_modules/*' -not -path '*/.git/*' \
            2>/dev/null | head -1)

        if [[ -n "$code_file_count" ]]; then
            indexed_ast_tool="codegraph"
        elif [[ "$is_workspace" -eq 1 ]]; then
            indexed_ast_tool="gitnexus"
            log_warn "GitNexus selected — procure a commercial license for business use before proceeding"
        elif [[ -n "$doc_file_count" ]]; then
            indexed_ast_tool="graphify"
        fi

        if [[ -n "$indexed_ast_tool" ]]; then
            log_info "Detected indexed AST tool: $indexed_ast_tool — delegating setup to dev-env-upsert..."
            # setup = batch: add-packages + add-prime-steps + update-envrc in ONE call.
            # The indexer invocation folds into prime_impl — no new index/index_impl targets.
            $uv_runner run --script "$dev_env_upsert_dir/scripts/dev_env_upsert.py" setup \
                --packages "$indexed_ast_tool,direnv,just" \
                --prime-steps "$indexed_ast_tool index .:$indexed_ast_tool" \
                --envrc-async-prime \
                --target "$PROJECT_PATH" \
                || log_warn "dev-env-upsert setup for $indexed_ast_tool failed — prime_impl lines may need manual addition"
        else
            log_info "No indexed AST tool detected (no source code, workspace, or doc-heavy files) — skipping setup"
        fi
    fi

    # Create/update justfile with integrated generation
    if [[ ! -f "$PROJECT_PATH/justfile" ]]; then
        log_info "Creating integrated justfile with devbox support..."
        # Detect project characteristics for justfile generation
        local detection_script="../../project-detection/scripts/detect-build-systems.sh"
        local detected_characteristics=""
        if [[ -f "$detection_script" ]]; then
            detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
        fi
        parse_project_characteristics "$detected_characteristics"
        generate_project_justfile "$PROJECT_PATH"
    else
        log_info "justfile already exists, skipping creation"
    fi

    # AGENTS.md generation is delegated to the agent-file-upsert skill.
    # Do NOT hand-write AGENTS.md here — that produces a flat single-audience
    # doc that mixes user and developer content, with no JIT Index, no
    # Knowledge Bundles section, no Developer Guide link, and no
    # Out of Scope/Improvements/Anti-Patterns references.
    #
    # The orchestrating AI agent should read and follow the bundled
    # agent-file-upsert SKILL.md at:
    #   references/included/skills/ai/agent-file-upsert/SKILL.md
    # That SKILL.md drives its own workflow (Phase 1: repo analysis →
    # Phase 2: scaffold via scripts/init-agents-md.py + fill in content →
    # Phase 3: sub-folder AGENTS.md → Phase 4/5: special considerations).
    # Do NOT call init-agents-md.py directly from this script — let the
    # bundled SKILL.md drive its own scripts.
    #
    # See SKILL.md -> "Repository & Ignore File Management" for the full contract.
    if [[ ! -f "$PROJECT_PATH/AGENTS.md" ]]; then
        log_info "ℹ AGENTS.md absent — will be generated by agent-file-upsert (delegated; see SKILL.md step 10)"
    else
        log_info "ℹ AGENTS.md present — run agent-file-upsert to update via delta analysis (delegated; see SKILL.md step 10)"
    fi

    # README.md generation is delegated to the readme-upsert skill.
    # Do NOT hand-write README content here — that duplicates readme-upsert's
    # template (references/README-project-root-template.md.tmpl), required-
    # sections list, and verify_consistency.py checks (README<->AGENTS.md
    # name match, no content duplication, no wrong sections in either file).
    # The orchestrating AI agent should invoke readme-upsert after AGENTS.md
    # is in place. See SKILL.md -> "Repository & Ignore File Management".
    if [[ ! -f "$PROJECT_PATH/README.md" ]] || [[ ! -s "$PROJECT_PATH/README.md" ]]; then
        log_info "ℹ README.md absent — will be generated by readme-upsert (delegated; see SKILL.md)"
    else
        log_info "ℹ README.md present — run readme-upsert to preserve accurate sections and update stale ones (delegated; see SKILL.md)"
    fi
}

# Generate justfile based on detected project type
generate_project_justfile() {
    local project_path="${1:-.}"

    log_info "Generating justfile for project: $project_path"

    # Change to project directory
    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # First try to extract from existing configurations
    local extraction_script="../../project-detection/scripts/extract-build-targets.sh"
    if [[ -f "$extraction_script" ]]; then
        log_info "Attempting to extract targets from existing configurations..."
        if "$extraction_script" generate "$project_path" justfile 2>/dev/null; then
            log_info "✓ Generated justfile from existing configurations"
            return 0
        else
            log_warn "Could not extract from existing configs, falling back to integrated generation"
        fi
    fi

    # Fallback to integrated generation with devbox support
    local detection_script="../../project-detection/scripts/detect-build-systems.sh"
    if [[ ! -f "$detection_script" ]]; then
        log_error "Project detection script not found: $detection_script"
        return 1
    fi

    # Detect build systems
    local detected_systems
    detected_systems=$("$detection_script" "$project_path" --verbose 2>/dev/null || echo "")

    if [[ -z "$detected_systems" ]]; then
        log_warn "No build systems detected, creating generic justfile"
        create_generic_justfile
        return 0
    fi

    log_info "Detected systems: $detected_systems"

    # Generate integrated devbox.json + justfile setup
    generate_devbox_json "$project_path" "$detected_systems"
    generate_integrated_justfile "$project_path" "$detected_systems"

    log_info "✓ Generated integrated devbox.json + justfile with language-specific targets"
}

# Create Node.js justfile
create_nodejs_justfile() {
    local systems="$1"
    local pkg_manager="npm"

    # Determine package manager priority
    if echo "$systems" | grep -q "pnpm"; then
        pkg_manager="pnpm"
    elif echo "$systems" | grep -q "yarn"; then
        pkg_manager="yarn"
    elif echo "$systems" | grep -q "bun"; then
        pkg_manager="bun"
    fi

    log_info "Creating Node.js justfile with $pkg_manager"

    cat > justfile << EOF
# Node.js development targets
# Package manager: $pkg_manager

default:
    @just --list

# Install dependencies
install:
    $pkg_manager install

# Clean dependencies and artifacts
clean:
    rm -rf node_modules/
    rm -rf dist/
    rm -rf .nuxt/
    rm -rf .next/
    rm -rf .vite/
    rm -rf .turbo/

# Development server
dev:
    $pkg_manager run dev

# Build project
build:
    $pkg_manager run build

# Run tests
test:
    $pkg_manager test

# Run tests with coverage
test-coverage:
    $pkg_manager run test:coverage || $pkg_manager run test --coverage

# Run linting
lint:
    $pkg_manager run lint

# Run linting and fix
lint-fix:
    $pkg_manager run lint:fix || $pkg_manager run lint --fix

# Type checking
typecheck:
    $pkg_manager run typecheck || $pkg_manager run tsc --noEmit

# Format code
format:
    $pkg_manager run format || $pkg_manager run prettier --write .

# Security audit
audit:
    $pkg_manager audit || $pkg_manager audit --audit-level moderate

# Update dependencies
update:
    $pkg_manager update

# Bootstrap project
bootstrap:
    @just install
    @echo "Node.js project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install build lint test dev)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# E2E tests (if Playwright is available)
e2e:
    pnpm exec playwright test || echo "Playwright not configured"

EOF
    log_info "✓ Node.js justfile created"
}

# Create Rust justfile
create_rust_justfile() {
    local systems="$1"

    log_info "Creating Rust justfile"

    cat > justfile << EOF
# Rust development targets

default:
    @just --list

# Install dependencies
install:
    cargo build

# Clean build artifacts
clean:
    cargo clean

# Development build
dev:
    cargo build

# Release build
build:
    cargo build --release

# Run tests
test:
    cargo test

# Run tests with coverage
test-coverage:
    cargo tarpaulin --out Html || cargo test

# Run linting
lint:
    cargo clippy -- -D warnings

# Format code
format:
    cargo fmt

# Type checking (already done by cargo check)
typecheck:
    cargo check

# Run application
run:
    cargo run

# Bootstrap project
bootstrap:
    @just install
    @echo "Rust project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test build)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# Security audit
audit:
    cargo audit || echo "cargo-audit not installed"

# Update dependencies
update:
    cargo update

EOF
    log_info "✓ Rust justfile created"
}

# Create Python justfile
create_python_justfile() {
    local systems="$1"
    local install_cmd="pip install"

    if echo "$systems" | grep -q "poetry"; then
        install_cmd="poetry install"
    fi

    log_info "Creating Python justfile"

    cat > justfile << EOF
# Python development targets

default:
    @just --list

# Install dependencies
install:
    $install_cmd

# Clean artifacts
clean:
    rm -rf __pycache__/
    rm -rf *.egg-info/
    rm -rf dist/
    rm -rf build/
    find . -type d -name __pycache__ -delete
    find . -type f -name "*.pyc" -delete

# Development server (if applicable)
dev:
    python -m uvicorn main:app --reload || python main.py

# Build package
build:
    python -m build

# Run tests
test:
    python -m pytest

# Run tests with coverage
test-coverage:
    python -m pytest --cov=. --cov-report=html

# Run linting
lint:
    python -m ruff check . || python -m flake8 .

# Run linting and fix
lint-fix:
    python -m ruff check . --fix || python -m black .

# Type checking
typecheck:
    python -m mypy . || echo "MyPy not configured"

# Format code
format:
    python -m black . || python -m ruff format .

# Security audit
audit:
    python -m bandit -r . || echo "Bandit not installed"

# Bootstrap project
bootstrap:
    @just install
    @echo "Python project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test dev)

# Complete CI pipeline
ci: || (install lint typecheck test build)

EOF
    log_info "✓ Python justfile created"
}

# Create Go justfile
create_go_justfile() {
    local systems="$1"

    log_info "Creating Go justfile"

    cat > justfile << EOF
# Go development targets

default:
    @just --list

# Install dependencies
install:
    go mod download
    go mod tidy

# Clean build artifacts
clean:
    rm -rf bin/
    go clean

# Development build
dev:
    go build -o bin/dev ./cmd/...

# Build project
build:
    go build -o bin/main ./cmd/...

# Run tests
test:
    go test ./...

# Run tests with coverage
test-coverage:
    go test -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html

# Run linting
lint:
    golangci-lint run || go vet ./...

# Format code
format:
    go fmt ./...

# Type checking (built into go build)
typecheck:
    go build ./...

# Run application
run:
    go run ./cmd/...

# Bootstrap project
bootstrap:
    @just install
    @echo "Go project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test build)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# Security audit
audit:
    gosec ./... || echo "gosec not installed"

# Update dependencies
update:
    go get -u ./...
    go mod tidy

EOF
    log_info "✓ Go justfile created"
}

# Create Java justfile
create_java_justfile() {
    local systems="$1"
    local build_cmd="mvn"

    if echo "$systems" | grep -q "gradle"; then
        build_cmd="./gradlew"
    elif echo "$systems" | grep -q "maven"; then
        build_cmd="mvn"
    fi

    log_info "Creating Java justfile with $build_cmd"

    cat > justfile << EOF
# Java development targets
# Build system: $build_cmd

default:
    @just --list

# Install dependencies
install:
    $build_cmd dependency:resolve || $build_cmd dependencies

# Clean build artifacts
clean:
    $build_cmd clean

# Development build
dev:
    $build_cmd compile

# Build project
build:
    $build_cmd package

# Run tests
test:
    $build_cmd test

# Run tests with coverage
test-coverage:
    $build_cmd test jacoco:report || $build_cmd test

# Run linting
lint:
    $build_cmd checkstyle:check || echo "Checkstyle not configured"

# Type checking (built into compilation)
typecheck:
    $build_cmd compile

# Run application
run:
    $build_cmd exec:java || java -jar target/*.jar

# Bootstrap project
bootstrap:
    @just install
    @echo "Java project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install compile test package)

# Complete CI pipeline
ci: || (install lint test package)

# Security audit
audit:
    $build_cmd dependency-check || echo "Dependency check not configured"

EOF
    log_info "✓ Java justfile created"
}

# Parse project characteristics string into individual variables
parse_project_characteristics() {
    local characteristics="$1"

    # Default values
    local build_systems=""
    local app_type=""
    local project_type=""

    # Parse the characteristics string
    if [[ -n "$characteristics" ]]; then
        build_systems=$(echo "$characteristics" | grep -o 'build_systems:[^|]*' | cut -d: -f2- || echo "")
        app_type=$(echo "$characteristics" | grep -o 'app_type:[^|]*' | cut -d: -f2- || echo "")
        project_type=$(echo "$characteristics" | grep -o 'project_type:[^|]*' | cut -d: -f2- || echo "")
    fi

    # Export variables for use in other functions
    export DETECTED_BUILD_SYSTEMS="$build_systems"
    export DETECTED_APP_TYPE="$app_type"
    export DETECTED_PROJECT_TYPE="$project_type"

    if [[ -n "$build_systems" ]]; then
        log_info "✓ Detected build systems: $build_systems"
    fi
    if [[ -n "$app_type" ]]; then
        log_info "✓ Detected application type: $app_type"
    fi
    if [[ -n "$project_type" ]]; then
        log_info "✓ Detected project type: $project_type"
    fi
}

# Generate devbox.json with language-specific packages
generate_devbox_json() {
    local project_path="${1:-.}"
    local detected_characteristics="$2"

    log_info "Generating devbox.json for project: $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Parse the characteristics into individual variables
    parse_project_characteristics "$detected_characteristics"

    # Base packages always included
    local packages='["just"]'
    local language_packages=""
    local ai_tools='["yq-go", "jq", "ripgrep", "fd", "bat"]'

    # Add language-specific packages based on detection
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "pnpm\|npm\|yarn\|bun"; then
        language_packages='"nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest"'

        # Add web-specific tooling for web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"frontend-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]]; then
            # Add Playwright only for web applications
            ai_tools="$ai_tools, \"playwright\""
            language_packages="$language_packages, \"vite\", \"@vitejs/plugin-react\""
        fi

        # Add CLI-specific tooling for CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"commander\", \"yargs\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "cargo\|rust"; then
        language_packages='"rustc", "cargo", "clippy", "rustfmt", "rust-analyzer"'

        # Add web-specific tooling for Rust web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"frontend-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]]; then
            language_packages="$language_packages, \"trunk\", \"wasm-bindgen-cli\""
        fi

        # Add CLI-specific tooling for Rust CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"clap\", \"structopt\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "poetry\|python"; then
        language_packages='"python3", "poetry", "black", "ruff", "mypy", "pytest"'

        # Add web-specific tooling for Python web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"fastapi\", \"uvicorn\", \"django\""
        fi

        # Add CLI-specific tooling for Python CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"click\", \"typer\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "go\|golang"; then
        language_packages='"go", "gopls", "golangci-lint", "go-swagger"'

        # Add web-specific tooling for Go web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"gin\", \"echo\", \"fiber\""
        fi

        # Add CLI-specific tooling for Go CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"cobra\", \"urfave-cli\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "maven\|gradle"; then
        language_packages='"openjdk", "maven", "gradle", "checkstyle"'

        # Add web-specific tooling for Java web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"spring-boot\", \"tomcat\""
        fi
    fi

    # Combine all packages
    local all_packages="[$packages, $ai_tools"
    if [[ -n "$language_packages" ]]; then
        all_packages="[$packages, $ai_tools, $language_packages]"
    fi

    # Create devbox.json
    cat > devbox.json << EOF
{
  "packages": $all_packages,
  "shell": {
    "init_hook": [
      "just bootstrap_impl"
    ]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl",
    "clean": "just clean_impl"
  }
}
EOF

    log_info "✓ devbox.json created with AI tools and language-specific packages"
}

# Generate justfile with proper *_impl targets
generate_integrated_justfile() {
    local project_path="${1:-.}"
    local detected_systems="$2"

    log_info "Generating integrated justfile for project: $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Start justfile with header
    cat > justfile << 'EOF'
# Integrated justfile with devbox support
# Auto-generated by project-adopter with language-specific targets

default:
    @just --list

# Devbox auto-detection helper (hidden from --list)
# Passes through extra arguments to the target recipe.
_devbox target *args:
    #!/usr/bin/env bash
    if [ "${DEVBOX_SHELL_ENABLED:-0}" = "1" ]; then
        exec just "{{target}}" {{args}}
    elif command -v devbox >/dev/null 2>&1; then
        exec devbox run -- just "{{target}}" {{args}}
    else
        echo "❌ devbox not found in PATH." >&2
        echo "💡 Running doctor to diagnose environment issues..." >&2
        just doctor 2>/dev/null || true
        exit 1
    fi

# Normal targets - Developer interface (REQUIRED)
clean:
    just _devbox clean_impl

dev:
    just _devbox dev_impl

build:
    just _devbox build_impl

test:
    just _devbox test_impl

lint:
    just _devbox lint_impl

typecheck:
    just _devbox typecheck_impl

# Bootstrap recipes (REQUIRED)
bootstrap:
    just _devbox bootstrap_impl

EOF

    # Add language-specific bootstrap_impl
    echo "bootstrap_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm install" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo build" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry install" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go mod download" >> justfile
        echo "	go mod tidy" >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew compileJava || mvn compile" >> justfile
    fi
    echo "	echo \"Development environment ready!\"" >> justfile
    echo "" >> justfile

    # Add implementation targets
    echo "# Implementation targets (REQUIRED)" >> justfile

    # build_impl
    echo "build_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run build" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo build --release" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry build" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go build ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew build || mvn package" >> justfile
    fi
    echo "" >> justfile

    # test_impl
    echo "test_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm test" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo test" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run pytest" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go test ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew test || mvn test" >> justfile
    fi
    echo "" >> justfile

    # dev_impl
    echo "dev_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run dev" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo run" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run python -m src || poetry run python main.py" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go run ./cmd/... || go run ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew bootRun || mvn exec:java" >> justfile
    fi
    echo "" >> justfile

    # lint_impl
    echo "lint_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run lint" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo clippy -- -D warnings" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run ruff check . || poetry run flake8 ." >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	golangci-lint run || go vet ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew checkstyle:main || echo \"Lint not configured\"" >> justfile
    fi
    echo "" >> justfile

    # typecheck_impl
    echo "typecheck_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run typecheck || pnpm run tsc --noEmit" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo check" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run mypy . || echo \"MyPy not configured\"" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go build ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew compileJava || mvn compile" >> justfile
    fi
    echo "" >> justfile

    # clean_impl
    echo "clean_impl:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	rm -rf node_modules/ dist/ .next/ .nuxt/ .vite/" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo clean" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	rm -rf __pycache__/ *.egg-info/ dist/ build/" >> justfile
        echo "	find . -type d -name __pycache__ -delete" >> justfile
        echo "	find . -type f -name \"*.pyc\" -delete" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	rm -rf bin/" >> justfile
        echo "	go clean" >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew clean || mvn clean" >> justfile
    fi
    echo "" >> justfile

    # Add loop targets
    echo "# Development loop targets" >> justfile
    echo "loop: || (bootstrap build test dev)" >> justfile
    echo "ci: || (bootstrap lint typecheck test build)" >> justfile

    log_info "✓ Integrated justfile created with language-specific *_impl targets"
}

# Create generic justfile
create_generic_justfile() {
    log_info "Creating generic justfile"

    cat > justfile << 'EOF'
# Standard development targets

default:
    @just --list

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    @rm -rf dist/ build/ target/ node_modules/.cache/ __pycache__/ bin/

# Development server
dev:
    @echo "Starting development server..."
    @echo "Configure this target based on your project type"

# Build project
build:
    @echo "Building project..."
    @echo "Configure this target based on your project type"

# Run tests
test:
    @echo "Running tests..."
    @echo "Configure this target based on your project type"

# Run linting
lint:
    @echo "Running linter..."
    @echo "Configure this target based on your project type"

# Type checking
typecheck:
    @echo "Running type checker..."
    @echo "Configure this target based on your project type"

# Install dependencies
install:
    @echo "Installing dependencies..."
    @echo "Configure this target based on your project type"

# Bootstrap project
bootstrap:
    @just install
    @echo "Project bootstrapped!"

# Development loop
loop: || (install build lint test dev)

EOF
    log_info "✓ Generic justfile created"
}

# NOTE: generate_agents_md() has been REMOVED.
# AGENTS.md generation is delegated to the agent-file-upsert skill via
# progressive disclosure. The orchestrating AI agent reads the bundled
# SKILL.md at references/included/skills/ai/agent-file-upsert/SKILL.md
# and follows its workflow (which calls scripts/init-agents-md.py itself).
# Do NOT reimplement AGENTS.md generation here — that produces a flat
# single-audience doc that bypasses the progressive-disclosure structure
# (root AGENTS.md as user-facing index + .agents/knowledge/developer.md
# as developer guide + internal-docs/oos/ + improvements/ + anti-patterns/).

# Post-adoption consistency check.
# Verifies the adoption produced the expected progressive-disclosure structure.
# Run after all adoption steps are complete (step 20 in SKILL.md Quick Start).
post_adoption_check() {
    local project_path="${1:-.}"
    local errors=0
    local warnings=0

    echo "Post-adoption consistency check for: $project_path"
    echo "=================================================="

    # 1. AGENTS.md exists and contains "Developer Guide" link
    if [[ ! -f "$project_path/AGENTS.md" ]]; then
        echo "  FAIL: AGENTS.md missing — agent-file-upsert did not run (see SKILL.md step 10)"
        errors=$((errors + 1))
    elif ! grep -q 'Developer Guide' "$project_path/AGENTS.md"; then
        echo "  FAIL: AGENTS.md exists but has no 'Developer Guide' link — it is a flat hand-written doc, not the progressive-disclosure structure from agent-file-upsert"
        errors=$((errors + 1))
    else
        echo "  OK: AGENTS.md exists with Developer Guide link"
    fi

    # 2. .agents/knowledge/developer.md exists
    if [[ ! -f "$project_path/.agents/knowledge/developer.md" ]]; then
        echo "  FAIL: .agents/knowledge/developer.md missing — agent-file-upsert scaffolder did not run"
        errors=$((errors + 1))
    else
        echo "  OK: .agents/knowledge/developer.md exists"
    fi

    # 3. .agents/knowledge/bundles/ exists and is non-empty
    if [[ ! -d "$project_path/.agents/knowledge/bundles/" ]]; then
        echo "  FAIL: .agents/knowledge/bundles/ missing — install-knowledge-bundles.py did not run (see SKILL.md step 14)"
        errors=$((errors + 1))
    elif [[ -z "$(ls -A "$project_path/.agents/knowledge/bundles/" 2>/dev/null)" ]]; then
        echo "  FAIL: .agents/knowledge/bundles/ exists but is empty — install-knowledge-bundles.py ran but installed nothing"
        errors=$((errors + 1))
    else
        echo "  OK: .agents/knowledge/bundles/ exists and is non-empty"
    fi

    # 4. internal-docs/oos/ directory exists
    if [[ ! -d "$project_path/internal-docs/oos/" ]]; then
        echo "  FAIL: internal-docs/oos/ missing — agent-file-upsert scaffolder did not create out-of-scope directory"
        errors=$((errors + 1))
    else
        echo "  OK: internal-docs/oos/ exists"
    fi

    # 5. internal-docs/improvements/INDEX.md exists
    if [[ ! -f "$project_path/internal-docs/improvements/INDEX.md" ]]; then
        echo "  FAIL: internal-docs/improvements/INDEX.md missing — agent-file-upsert scaffolder did not run"
        errors=$((errors + 1))
    else
        echo "  OK: internal-docs/improvements/INDEX.md exists"
    fi

    # 6. internal-docs/anti-patterns/INDEX.md exists
    if [[ ! -f "$project_path/internal-docs/anti-patterns/INDEX.md" ]]; then
        echo "  FAIL: internal-docs/anti-patterns/INDEX.md missing — agent-file-upsert scaffolder did not run"
        errors=$((errors + 1))
    else
        echo "  OK: internal-docs/anti-patterns/INDEX.md exists"
    fi

    # 7. README.md exists and contains "AI Agent Documentation" section
    if [[ ! -f "$project_path/README.md" ]]; then
        echo "  FAIL: README.md missing — readme-upsert did not run (see SKILL.md step 13)"
        errors=$((errors + 1))
    elif ! grep -qi 'AI Agent Documentation' "$project_path/README.md"; then
        echo "  FAIL: README.md exists but has no 'AI Agent Documentation' section — readme-upsert did not run or used a non-standard template"
        errors=$((errors + 1))
    else
        echo "  OK: README.md exists with AI Agent Documentation section"
    fi

    # 8. No banned commands in kept files
    local banned_files
    banned_files=$(grep -rlE '\bnpx\b|\bnpm \b|\byarn \b' "$project_path/.windsurf/" "$project_path/docs/" "$project_path/.claude/" 2>/dev/null || true)
    if [[ -n "$banned_files" ]]; then
        echo "  WARN: Banned commands (npx, npm, yarn) found in kept files — review and replace with pnpm equivalents:"
        echo "$banned_files" | while read -r f; do
            echo "    - $f"
        done
        warnings=$((warnings + 1))
    else
        echo "  OK: No banned commands in kept files"
    fi

    echo "=================================================="
    echo "Result: $errors error(s), $warnings warning(s)"
    if [[ $errors -gt 0 ]]; then
        echo "POST-ADOPTION CHECK FAILED — fix the errors above before committing"
        return 1
    fi
    if [[ $warnings -gt 0 ]]; then
        echo "POST-ADOPTION CHECK PASSED WITH WARNINGS — review the warnings above"
    else
        echo "POST-ADOPTION CHECK PASSED"
    fi
    return 0
}

adopt_project() {
    local mode="${1:-adopt}"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --mode)
                mode="$2"
                shift 2
                ;;
            --no-loop-prevention)
                LOOP_DETECTION_ENABLED=false
                shift
                ;;
            --force)
                FORCE_ADOPTION=true
                shift
                ;;
            --verbose|-v)
                set -x  # Enable verbose output
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Set mode based on parameter or default
    if [[ "$mode" != "adopt" && "$mode" != "standardize" ]]; then
        log_error "Invalid mode: $mode. Use --mode adopt or --mode standardize"
        show_help
        exit 1
    fi

    # Store mode globally for other functions
    ADOPTION_MODE="$mode"

    log_info "Starting project adoption in $mode mode for: $PROJECT_PATH"
    log_info "Project name: $PROJECT_NAME"

    # Run pre-adoption health review
    log_step "Running pre-adoption repository health review"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local health_review_script="$script_dir/../repository-health-review/scripts/repository-health-review.sh"

    if [[ -f "$health_review_script" ]]; then
        local pre_adoption_health="$PROJECT_PATH/.pre-adoption-health.json"
        if "$health_review_script" --report "$pre_adoption_health" "$PROJECT_PATH" "$PROJECT_NAME"; then
            log_info "Pre-adoption health review completed: $pre_adoption_health"

            # Show health score if available
            if command -v jq >/dev/null 2>&1 && [[ -f "$pre_adoption_health" ]]; then
                local health_score
                health_score=$(jq -r '.health_score' "$pre_adoption_health" 2>/dev/null || echo "unknown")
                local critical_issues
                critical_issues=$(jq -r '.issues.critical' "$pre_adoption_health" 2>/dev/null || echo "0")
                log_info "  Health Score: $health_score/100"
                log_info "  Critical Issues: $critical_issues"

                if [[ $critical_issues -gt 0 ]]; then
                    log_warn "  ⚠️  Critical issues detected - review health report before proceeding"
                fi
            fi
        else
            log_warn "Pre-adoption health review failed, continuing with adoption"
        fi
    else
        log_info "Repository health review skill not found, skipping pre-adoption analysis"
    fi

    # Load skill functions
    if ! load_project_detection; then
        log_error "Failed to load project detection"
        exit 1
    fi

    if ! load_surgical_config; then
        log_error "Failed to load surgical config"
        exit 1
    fi

    # Detect project characteristics
    local detection_result
    detection_result=$(detect_project)
    local detected_characteristics="$detection_result"

    # Apply surgical configurations using per-language scripts
    apply_surgical_configs "$detected_characteristics"

    # Create configuration files
    create_config_files "$detected_characteristics"

    # Run post-adoption health review
    log_step "Running post-adoption repository health review"
    if [[ -f "$health_review_script" ]]; then
        local post_adoption_health="$PROJECT_PATH/.post-adoption-health.json"
        if "$health_review_script" --report "$post_adoption_health" "$PROJECT_PATH" "$PROJECT_NAME"; then
            log_info "Post-adoption health review completed: $post_adoption_health"

            # Show improvement if available
            if command -v jq >/dev/null 2>&1 && [[ -f "$pre_adoption_health" ]] && [[ -f "$post_adoption_health" ]]; then
                local pre_score
                local post_score
                pre_score=$(jq -r '.health_score' "$pre_adoption_health" 2>/dev/null || echo "0")
                post_score=$(jq -r '.health_score' "$post_adoption_health" 2>/dev/null || echo "0")

                if [[ $post_score -gt $pre_score ]]; then
                    local improvement=$((post_score - pre_score))
                    log_info "  🎉 Health score improved by +$improvement points ($pre_score → $post_score)"
                elif [[ $post_score -lt $pre_score ]]; then
                    local degradation=$((pre_score - post_score))
                    log_warn "  ⚠️  Health score decreased by -$degradation points ($pre_score → $post_score)"
                else
                    log_info "  ➡️  Health score unchanged: $post_score/100"
                fi
            fi
        else
            log_warn "Post-adoption health review failed"
        fi
    fi

    log_info "✅ Project adoption completed successfully!"
    log_info "Next steps:"
    log_info "  1. Review the generated configuration files"
    log_info "  2. Review health reports (.pre-adoption-health.json and .post-adoption-health.json)"
    log_info "  3. Run 'just bootstrap' to install dependencies"
    log_info "  4. Run 'just dev' to start development"
    log_info "  5. Address any critical issues identified in health reviews"
}

# Show help
show_help() {
    cat << EOF
Project Adopter - Intelligent project setup with surgical-config integration

Usage: $0 [options] [project_path] [project_name]

Options:
  --help, -h              Show this help message
  --no-loop-prevention   Disable infinite loop detection
  --force-adoption       Force adoption even if loops detected
  --verbose, -v          Show detailed output

Arguments:
  project_path    Path to the project directory (default: .)
  project_name    Name of the project (default: basename of project_path)

Examples:
  # Adopt current directory
  $0

  # Adopt specific project
  $0 /path/to/my-project my-project

  # Adopt with custom name
  $0 ./my-cool-app cool-app

Features:
  - Automatic project detection (build systems, CI/CD, workspace tools)
  - Surgical configuration updates (preserves comments, formatting)
  - Standard developer UX setup (devbox, justfile, .envrc)
  - Multi-context support (chezmoi templates, deployed config, AI tools)
  - Loop prevention for safe skill integration
  - Recursive call protection
  - Process tree analysis

Loop Prevention:
  The script includes automatic infinite loop detection:
  - Detects if project-adopter is already running
  - Prevents nested calls from the same process tree
  - Checks for surgical-config execution conflicts
  - Can be disabled with --no-loop-prevention
  - Can be forced with --force-adoption

Requirements:
  - project-detection skill
  - surgical-config skill
  - devbox (recommended)

EOF
}

# Main execution
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --justfile-only)
                create_justfile_only "$2"
                exit $?
                ;;
            --no-loop-prevention)
                LOOP_DETECTION_ENABLED=false
                shift
                ;;
            --force)
                FORCE_ADOPTION=true
                shift
                ;;
            --verbose|-v)
                set -x  # Enable verbose output
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    case "${1:-}" in
        "")
            adopt_project
            ;;
        "justfile-only")
            create_justfile_only "$2"
            ;;
        *)
            adopt_project "$@"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
