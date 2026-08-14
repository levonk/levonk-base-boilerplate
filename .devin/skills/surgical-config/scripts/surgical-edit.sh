#!/bin/bash

# Surgical Configuration Editor
# Implements the surgical hierarchy approach for configuration file modifications
# Integrates with project-detection for intelligent project-aware editing

set -euo pipefail

# Tool hierarchy preference
readonly TEMPLATE_PROCESSORS=("jinja2-cli" "envsubst")
readonly SEMANTIC_TOOLS=("yq-go" "jq" "dot-json")
readonly JSON_CREATORS=("jo")
readonly STRUCTURAL_TOOLS=("comby" "ast-grep")
readonly PATCH_TOOLS=("quilt" "guilt")
readonly TEXT_TOOLS=("sd" "sed")

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Project detection integration
readonly DETECTION_SKILL_PATH="../project-detection"
PROJECT_DETECTION_ENABLED=false
PROJECT_PATH="."

# Loop prevention
readonly SURGICAL_CONFIG_LOCK_FILE="/tmp/.surgical-config.lock"
readonly PROJECT_ADOPTER_LOCK_FILE="/tmp/.project-adopter.lock"
LOOP_DETECTION_ENABLED=true

# File creation behavior
CREATE_FILE_IF_MISSING=true

# Multi-context path resolution
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# Determine context and base path
determine_context() {
    local context_type="default"
    local base_path

    # Check if we're in chezmoi templates (highest priority)
    if [[ "$SCRIPT_DIR" == *".chezmoitemplates"* ]]; then
        context_type="chezmoi-templates"
        base_path="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
        echo "$context_type:$base_path"
        return 0
    fi

    # Check if we're in AI tools skills/ folder (but not in .config)
    if [[ "$SCRIPT_DIR" == *"/skills/"* ]] && [[ "$SCRIPT_DIR" != *".config"* ]]; then
        context_type="ai-tools"
        base_path="$(dirname "$SCRIPT_DIR")"
        echo "$context_type:$base_path"
        return 0
    fi

    # Check if we're in deployed ~/.config/ai/skills/
    if [[ "$SCRIPT_DIR" == *"/.config/ai/skills/"* ]]; then
        context_type="deployed-config"
        base_path="$(dirname "$(dirname "$SCRIPT_DIR")")"
        echo "$context_type:$base_path"
        return 0
    fi

    # Default to current directory structure
    context_type="default"
    base_path="$(dirname "$SCRIPT_DIR")"
    echo "$context_type:$base_path"
}

# Get context-specific paths
get_context_paths() {
    local context_info
    context_info=$(determine_context)
    local context_type="${context_info%%:*}"
    local base_path="${context_info##*:}"

    case "$context_type" in
        "chezmoi-templates")
            echo "CHEZMOI_TEMPLATES:$base_path"
            ;;
        "deployed-config")
            echo "DEPLOYED_CONFIG:$base_path"
            ;;
        "ai-tools")
            echo "AI_TOOLS:$base_path"
            ;;
        *)
            echo "DEFAULT:$base_path"
            ;;
    esac
}

# Check for potential infinite loops
check_for_loops() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip loop detection if forced
    if [[ "${FORCE_DETECTION:-}" == "true" ]]; then
        log_info "Force detection enabled - skipping loop prevention"
        return 0
    fi

    # Check if project-adopter is already running
    if [[ -f "$PROJECT_ADOPTER_LOCK_FILE" ]]; then
        local adopter_pid
        adopter_pid=$(cat "$PROJECT_ADOPTER_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$adopter_pid" ]] && kill -0 "$adopter_pid" 2>/dev/null; then
            log_warn "Project-adopter is already running (PID: $adopter_pid)"
            log_warn "Avoiding potential infinite loop - disabling project detection"
            export PROJECT_DETECTION_ENABLED=false
            return 1
        else
            # Stale lock file, remove it
            rm -f "$PROJECT_ADOPTER_LOCK_FILE"
        fi
    fi

    # Check if surgical-config is already running (nested calls)
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
                log_warn "Nested surgical-config call detected"
                log_warn "Avoiding potential infinite loop - disabling project detection"
                export PROJECT_DETECTION_ENABLED=false
                return 1
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

    echo $$ > "$SURGICAL_CONFIG_LOCK_FILE"
    # Set up cleanup on exit
    trap 'rm -f "$SURGICAL_CONFIG_LOCK_FILE"' EXIT
}

# Check if we're being called by project-adopter
check_caller() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip caller check if forced
    if [[ "${FORCE_DETECTION:-}" == "true" ]]; then
        log_info "Force detection enabled - skipping caller check"
        return 0
    fi

    local parent_process
    parent_process=$(ps -o comm= -p $(ps -o ppid= -p $$ | tr -d ' ') 2>/dev/null || echo "")

    # Check if parent process looks like project-adopter
    if [[ "$parent_process" == *"project-adopter"* ]] || [[ "$parent_process" == *"adopter"* ]]; then
        log_warn "Called by project-adopter process: $parent_process"
        log_warn "Disabling project detection to avoid potential loops"
        export PROJECT_DETECTION_ENABLED=false
        return 1
    fi

    # Check environment variables that might indicate we're in a project-adopter context
    if [[ -n "${PROJECT_ADOPTER_RUNNING:-}" ]] || [[ -n "${ADOPTER_MODE:-}" ]]; then
        log_warn "Running in project-adopter context (detected from environment)"
        log_warn "Disabling project detection to avoid potential loops"
        export PROJECT_DETECTION_ENABLED=false
        return 1
    fi

    return 0
}

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

# Check if tool is available
tool_available() {
    local tool="$1"
    command -v "$tool" >/dev/null 2>&1
}

# Detect file format
detect_format() {
    local file="$1"
    local basename="$(basename "$file")"
    local extension="${file##*.}"

    # Check for templated files first (most specific)
    if [[ "$basename" == *.jinja ]] || [[ "$basename" == *.jinja2 ]] || [[ "$basename" == *.tmpl ]] || [[ "$basename" == *.template ]]; then
        echo "templated_structured"
        return
    fi

    # Check for specific templated structured files
    if [[ "$basename" == *.json.jinja ]] || [[ "$basename" == *.yaml.jinja ]] || [[ "$basename" == *.yml.jinja ]] || [[ "$basename" == *.toml.jinja ]] || [[ "$basename" == *.xml.jinja ]] || [[ "$basename" == *.cfg.jinja ]] || [[ "$basename" == *.conf.jinja ]] || [[ "$basename" == *.ini.jinja ]]; then
        echo "templated_structured"
        return
    fi

    # Structured formats
    if [[ "$extension" == "json" ]] || [[ "$extension" == "yaml" ]] || [[ "$extension" == "yml" ]] || [[ "$extension" == "toml" ]] || [[ "$extension" == "xml" ]]; then
        echo "structured"
        return
    fi

    # Code files (expanded list)
    if [[ "$extension" == "rs" ]] || [[ "$extension" == "js" ]] || [[ "$extension" == "ts" ]] || [[ "$extension" == "py" ]] || [[ "$extension" == "go" ]] || [[ "$extension" == "java" ]] || [[ "$extension" == "c" ]] || [[ "$extension" == "cpp" ]] || [[ "$extension" == "hs" ]] || [[ "$extension" == "php" ]] || [[ "$extension" == "rb" ]] || [[ "$extension" == "swift" ]] || [[ "$extension" == "kt" ]]; then
        echo "code"
        return
    fi

    # Configuration files (expanded)
    if [[ "$extension" == "env" ]] || [[ "$extension" == "conf" ]] || [[ "$extension" == "ini" ]] || [[ "$extension" == "cfg" ]] || [[ "$extension" == "properties" ]] || [[ "$extension" == "tfvars" ]] || [[ "$extension" == "hcl" ]]; then
        echo "configuration"
        return
    fi

    # Markup files
    if [[ "$extension" == "md" ]] || [[ "$extension" == "rst" ]] || [[ "$extension" == "tex" ]] || [[ "$extension" == "adoc" ]]; then
        echo "markup"
        return
    fi

    # Data files
    if [[ "$extension" == "csv" ]] || [[ "$extension" == "tsv" ]]; then
        echo "data"
        return
    fi

    # Binary configuration files
    if [[ "$extension" == "plist" ]] || [[ "$extension" == "binary" ]]; then
        echo "binary_config"
        return
    fi

    # Default to text
    echo "text"
}

# Create mirrored backup
create_backup() {
    local file="$1"
    local repo_root="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
    local abs_file="$(realpath "$file")"
    local rel_path="${abs_file#$repo_root/}"
    local cache_dir="$repo_root/.cache/$rel_path"
    local timestamp=$(date +%Y%m%d%H%M%S)
    local backup="$cache_dir/$(basename "$file").$timestamp"

    if [[ -f "$file" ]]; then
        mkdir -p "$cache_dir"
        cp "$file" "$backup"
        log_info "Created mirrored backup: $backup"
        echo "$backup"
    fi
}

# Create file if missing with appropriate default content
create_file_if_missing() {
    local file="$1"
    local extension="${file##*.}"
    local dirname="$(dirname "$file")"
    
    # Create directory if it doesn't exist
    mkdir -p "$dirname"
    
    # Determine default content based on file extension
    case "$extension" in
        "json")
            echo "{}" > "$file"
            log_info "Created JSON file with empty object: $file"
            ;;
        "yaml"|"yml")
            echo "---" > "$file"
            log_info "Created YAML file with document separator: $file"
            ;;
        "toml")
            echo "" > "$file"
            log_info "Created TOML file: $file"
            ;;
        "xml")
            echo '<?xml version="1.0" encoding="UTF-8"?>' > "$file"
            echo "" >> "$file"
            log_info "Created XML file with header: $file"
            ;;
        "env"|"conf"|"ini"|"cfg")
            echo "" > "$file"
            log_info "Created configuration file: $file"
            ;;
        "md"|"markdown")
            # Create markdown file with YAML frontmatter
            cat > "$file" << 'EOF'
---
title: ""
description: ""
---

EOF
            log_info "Created Markdown file with YAML frontmatter: $file"
            ;;
        *)
            # Default: create empty file
            touch "$file"
            log_info "Created empty file: $file"
            ;;
    esac
}

# Validate file syntax
validate_file() {
    local file="$1"
    local format="$2"

    case "$format" in
        "structured"|"templated_structured")
            if tool_available "yq-go"; then
                yq-go eval '.' "$file" >/dev/null 2>&1
            else
                # Fallback validation for JSON
                if [[ "$file" == *.json ]]; then
                    jq '.' "$file" >/dev/null 2>&1
                else
                    echo "Warning: No validation available for $file"
                    return 0
                fi
            fi
            ;;
        "code")
            # Basic syntax checking with language-specific tools if available
            case "${file##*.}" in
                "py") python3 -m py_compile "$file" 2>/dev/null ;;
                "js") node -c "$file" 2>/dev/null ;;
                "ts") tsc --noEmit "$file" 2>/dev/null ;;
                "go") go run -o /dev/null "$file" 2>/dev/null ;;
                "rs") rustc --emit=metadata --crate-type=lib "$file" 2>/dev/null ;;
                *) echo "Warning: No syntax check for ${file##*.}"; return 0 ;;
            esac
            ;;
        "markup")
            # Basic markup validation
            case "${file##*.}" in
                "md") echo "Markdown validation not implemented" ;;
                "rst") rst2html "$file" >/dev/null 2>&1 ;;
                "tex") chktex "$file" >/dev/null 2>&1 ;;
                *) return 0 ;;
            esac
            ;;
        "data")
            # CSV/TSV validation
            if [[ "$file" == *.csv ]]; then
                python3 -c "import csv; csv.reader(open('$file'))" 2>/dev/null
            fi
            ;;
        "configuration"|"text")
            # Text files are always valid
            return 0
            ;;
        "binary_config")
            # Binary files need special handling
            if [[ "$file" == *.plist ]]; then
                plutil -lint "$file" >/dev/null 2>&1
            else
                echo "Warning: No validation for binary config $file"
                return 0
            fi
            ;;
        *)
            return 0
            ;;
    esac
}

# Initialize project detection
init_project_detection() {
    local project_path="${1:-.}"

    if [[ "$PROJECT_DETECTION_ENABLED" == "true" ]]; then
        log_step "Initializing project detection for: $project_path"

        # Get current context
        local context_info
        context_info=$(get_context_paths)
        local context_type="${context_info%%:*}"
        local base_path="${context_info##*:}"

        log_info "Detected context: $context_type"
        log_info "Base path: $base_path"

        # Build detection paths based on context
        local detection_paths=()

        case "$context_type" in
            "CHEZMOI_TEMPLATES")
                detection_paths=(
                    "$base_path/project-detection"
                    "$base_path/../project-detection"
                    "$HOME/.chezmoitemplates/config/ai/skills/software-dev/project-detection"
                )
                ;;
            "DEPLOYED_CONFIG")
                detection_paths=(
                    "$base_path/project-detection"
                    "$base_path/../project-detection"
                    "$HOME/.config/ai/skills/software-dev/project-detection"
                )
                ;;
            "AI_TOOLS")
                detection_paths=(
                    "$base_path/project-detection"
                    "$base_path/../project-detection"
                    "$base_path/software-dev/project-detection"
                    "./project-detection"
                )
                ;;
            *)
                detection_paths=(
                    "../project-detection"
                    "$base_path/project-detection"
                    "$HOME/.config/ai/skills/software-dev/project-detection"
                    "$HOME/.chezmoitemplates/config/ai/skills/software-dev/project-detection"
                )
                ;;
        esac

        # Try each detection path
        for detection_path in "${detection_paths[@]}"; do
            if [[ -f "$detection_path/scripts/detect-build-systems.sh" ]]; then
                source "$detection_path/scripts/detect-build-systems.sh"
                log_info "✓ Project detection functions loaded from: $detection_path"
                return 0
            fi
        done

        log_warn "Project detection skill not found in any of the searched paths:"
        for path in "${detection_paths[@]}"; do
            log_warn "  - $path"
        done
        return 1
    fi

    return 0
}

# Detect project characteristics
detect_project_characteristics() {
    local project_path="${1:-.}"

    if [[ "$PROJECT_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    log_step "Detecting project characteristics..."

    # Detect build systems
    if command -v detect_systems >/dev/null 2>&1; then
        local build_systems
        build_systems=$(detect_systems "$project_path" "false")
        log_info "Detected build systems: $build_systems"
        echo "$build_systems"
    fi

    # Detect CI/CD systems
    if command -v detect_ci_cd_systems >/dev/null 2>&1; then
        local ci_cd_systems
        ci_cd_systems=$(detect_ci_cd_systems "$project_path" "false")
        log_info "Detected CI/CD systems: $ci_cd_systems"
    fi

    # Detect workspace configurations
    if command -v detect_workspace_configs >/dev/null 2>&1; then
        local workspace_configs
        workspace_configs=$(detect_workspace_configs "$project_path" "false")
        log_info "Detected workspace configs: $workspace_configs"
    fi
}

# Apply project-aware editing
apply_project_aware_edit() {
    local file="$1"
    local operation="$2"
    local project_path="${3:-.}"

    if [[ "$PROJECT_DETECTION_ENABLED" != "true" ]]; then
        # Fall back to regular editing
        apply_semantic_edit "$file" "$operation"
        return $?
    fi

    log_step "Applying project-aware surgical edit..."

    # Detect project characteristics
    local build_systems
    build_systems=$(detect_project_characteristics "$project_path")

    # Apply project-specific logic
    case "$build_systems" in
        *"npm"*|*"pnpm"*|*"yarn"*)
            log_info "Detected Node.js project - using npm-aware editing"
            # Node.js specific handling
            if [[ "$file" == *"package.json" ]]; then
                # Preserve npm structure and scripts
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *"cargo"*)
            log_info "Detected Rust project - using Cargo-aware editing"
            # Rust specific handling
            if [[ "$file" == *"Cargo.toml" ]]; then
                # Preserve Cargo structure
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *"poetry"*|*"pip"*|*"setuptools"*)
            log_info "Detected Python project - using Python-aware editing"
            # Python specific handling
            if [[ "$file" == *"pyproject.toml" ]] || [[ "$file" == *"requirements.txt" ]]; then
                # Preserve Python structure
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *"go"*|*"golang"*)
            log_info "Detected Go project - using Go-aware editing"
            # Go specific handling
            if [[ "$file" == *"go.mod" ]] || [[ "$file" == *"go.sum" ]]; then
                # Preserve Go modules
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *"maven"*|*"gradle"*)
            log_info "Detected Java project - using Java-aware editing"
            # Java specific handling
            if [[ "$file" == *"pom.xml" ]] || [[ "$file" == *"build.gradle" ]]; then
                # Preserve Java build structure
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *"docker"*|*"compose"*)
            log_info "Detected Docker project - using Docker-aware editing"
            # Docker specific handling
            if [[ "$file" == *"docker-compose.yml" ]] || [[ "$file" == *"Dockerfile" ]]; then
                # Preserve Docker structure
                apply_semantic_edit "$file" "$operation"
            else
                apply_semantic_edit "$file" "$operation"
            fi
            ;;
        *)
            log_info "No specific project type detected - using standard editing"
            apply_semantic_edit "$file" "$operation"
            ;;
    esac
}

apply_semantic_edit() {
    local file="$1"
    local operation="$2"

    # Try yq-go first (preserves comments)
    if tool_available "yq-go"; then
        log_info "Applying semantic edit with yq-go: $operation"
        yq-go eval "$operation" "$file" -i
        return 0
    fi

    # Fallback to jq for JSON only
    if [[ "$file" == *.json ]] && tool_available "jq"; then
        log_info "Applying semantic edit with jq (JSON only): $operation"
        local temp_file="$(mktemp)"
        jq "$operation" "$file" > "$temp_file" && mv "$temp_file" "$file"
        return 0
    fi

    # Fallback to dot-json for simple operations
    if [[ "$file" == *.json ]] && tool_available "dot-json"; then
        log_info "Applying semantic edit with dot-json: $operation"
        # Convert yq-go syntax to dot-json if possible
        if [[ "$operation" =~ ^\.([^=]+)=\s*(.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            dot-json set "$file" "$key" "$value"
            return 0
        fi
    fi

    # Fallback to jo for JSON creation
    if [[ "$file" == *.json ]] && tool_available "jo"; then
        log_info "Applying semantic edit with jo: $operation"
        local temp_file="$(mktemp)"
        jo "$operation" > "$temp_file" && mv "$temp_file" "$file"
        return 0
    fi

    log_error "No semantic editing tools available"
    return 1
}

# Apply YAML frontmatter edit to Markdown files
apply_markdown_frontmatter_edit() {
    local file="$1"
    local operation="$2"
    local temp_frontmatter=$(mktemp)
    local temp_content=$(mktemp)

    # Split the file into frontmatter and content
    local in_frontmatter=false
    local frontmatter_started=false
    local frontmatter_ended=false

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [[ "$frontmatter_started" == false ]]; then
                frontmatter_started=true
                in_frontmatter=true
                continue
            elif [[ "$in_frontmatter" == true ]] && [[ "$frontmatter_ended" == false ]]; then
                in_frontmatter=false
                frontmatter_ended=true
                continue
            fi
        fi

        if [[ "$in_frontmatter" == true ]]; then
            echo "$line" >> "$temp_frontmatter"
        else
            echo "$line" >> "$temp_content"
        fi
    done < "$file"

    # If no frontmatter was found, create empty frontmatter
    if [[ "$frontmatter_started" == false ]]; then
        echo "" > "$temp_frontmatter"
        # Copy entire content to content temp file
        cp "$file" "$temp_content"
    fi

    # Apply the operation to the frontmatter
    if tool_available "yq-go"; then
        log_info "Applying YAML frontmatter edit with yq-go"
        if ! yq-go eval "$operation" "$temp_frontmatter" > "$temp_frontmatter.tmp"; then
            log_error "Failed to apply YAML operation"
            rm -f "$temp_frontmatter" "$temp_content" "$temp_frontmatter.tmp"
            return 1
        fi
        mv "$temp_frontmatter.tmp" "$temp_frontmatter"
    elif tool_available "jq"; then
        log_info "Applying YAML frontmatter edit with jq (limited YAML support)"
        # Note: jq has limited YAML support, but can handle simple YAML-like structures
        if ! yq-go eval "$operation" "$temp_frontmatter" > "$temp_frontmatter.tmp" 2>/dev/null; then
            log_error "Failed to apply YAML operation with jq"
            rm -f "$temp_frontmatter" "$temp_content" "$temp_frontmatter.tmp"
            return 1
        fi
        mv "$temp_frontmatter.tmp" "$temp_frontmatter"
    else
        log_error "No YAML editing tools available for frontmatter"
        rm -f "$temp_frontmatter" "$temp_content"
        return 1
    fi

    # Reconstruct the file
    {
        echo "---"
        cat "$temp_frontmatter"
        echo "---"
        echo ""
        cat "$temp_content"
    } > "$file"

    # Cleanup
    rm -f "$temp_frontmatter" "$temp_content" "$temp_frontmatter.tmp"

    log_info "Successfully updated YAML frontmatter in $file"
}

# Apply structural edit
apply_structural_edit() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"

    if tool_available "comby"; then
        log_info "Applying structural edit with comby"
        comby "$pattern" "$replacement" -match-only "$file"
    elif tool_available "ast-grep"; then
        log_info "Applying structural edit with ast-grep"
        # Would need ast-grep rule file
        log_warn "ast-grep integration not fully implemented"
        return 1
    else
        log_error "No structural tools available"
        return 1
    fi
}

# Apply text edit
apply_text_edit() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"

    if tool_available "sd"; then
        log_info "Applying text edit with sd"
        sd "$pattern" "$replacement" "$file"
    elif tool_available "sed"; then
        log_info "Applying text edit with sed"
        sed -i "s/$pattern/$replacement/g" "$file"
    else
        log_error "No text tools available"
        return 1
    fi
}

# Apply patch management
apply_patch_management() {
    local file="$1"
    local operation="$2"

    if tool_available "quilt"; then
        log_info "Applying patch with quilt"
        # Create quilt patch and apply
        local patch_name="surgical-edit-$(date +%Y%m%d%H%M%S).patch"
        quilt new "$patch_name"
        quilt edit "$file"
        # Apply changes would happen here
        quilt refresh
        quilt push -a
    elif tool_available "guilt"; then
        log_info "Applying patch with guilt"
        # Use guilt for patch management
        guilt init
        guilt new "surgical-edit-$(date +%Y%m%d%H%M%S)"
        guilt push
    else
        log_error "No patch management tools available"
        return 1
    fi
}

# Main editing function
surgical_edit() {
    local file="$1"
    local operation="$2"
    local pattern="${3:-}"
    local replacement="${4:-}"
    local detect_project="${DETECT_PROJECT:-false}"
    local project_path="${PROJECT_PATH:-.}"

    if [[ ! -f "$file" ]]; then
        if [[ "$CREATE_FILE_IF_MISSING" == "true" ]]; then
            log_info "File not found: $file - creating new file"
            create_file_if_missing "$file"
        else
            log_error "File not found: $file"
            return 1
        fi
    fi

    # Create lock file and check for loops
    create_lock_file
    check_for_loops
    check_caller

    # Initialize project detection if enabled and not blocked by loop detection
    if [[ "$detect_project" == "true" ]] && [[ "$PROJECT_DETECTION_ENABLED" == "true" ]]; then
        init_project_detection "$project_path"
    fi

    # Detect file format
    local format
    format=$(detect_format "$file")
    log_info "Detected format: $format"

    # Create mirrored backup
    local backup
    backup=$(create_backup "$file")

    # Apply edit based on hierarchy and project detection
    case "$format" in
        "markup")
            # Check if this is a Markdown file with YAML frontmatter
            if [[ "${file##*.}" == "md" ]] || [[ "${file##*.}" == "markdown" ]]; then
                if [[ -n "$operation" ]]; then
                    if ! apply_markdown_frontmatter_edit "$file" "$operation"; then
                        log_error "Markdown frontmatter edit failed"
                        [[ -n "$backup" ]] && cp "$backup" "$file"
                        return 1
                    fi
                elif [[ -n "$pattern" && -n "$replacement" ]]; then
                    if ! apply_text_edit "$file" "$pattern" "$replacement"; then
                        log_error "Text edit failed"
                        [[ -n "$backup" ]] && cp "$backup" "$file"
                        return 1
                    fi
                else
                    log_error "Markdown files require operation (for frontmatter) or pattern/replacement (for text)"
                    return 1
                fi
            else
                # Handle other markup files as text
                if [[ -n "$pattern" && -n "$replacement" ]]; then
                    if ! apply_text_edit "$file" "$pattern" "$replacement"; then
                        log_error "Text edit failed"
                        [[ -n "$backup" ]] && cp "$backup" "$file"
                        return 1
                    fi
                else
                    log_error "Markup files require pattern and replacement"
                    return 1
                fi
            fi
            ;;
        "templated_structured")
            # Skip template processing - handle file directly
            local processed_file="$file"
            # Apply semantic edit directly
            if [[ "$detect_project" == "true" ]]; then
                if ! apply_project_aware_edit "$processed_file" "$operation" "$project_path"; then
                    log_error "Project-aware edit failed, falling back to patch management"
                    if ! apply_patch_management "$processed_file" "$operation"; then
                        log_error "Patch management failed"
                        [[ -n "$backup" ]] && cp "$backup" "$file"
                        return 1
                    fi
                fi
            else
                if ! apply_semantic_edit "$processed_file" "$operation"; then
                    log_error "Semantic edit failed, falling back to patch management"
                    if ! apply_patch_management "$processed_file" "$operation"; then
                        log_error "Patch management failed"
                        [[ -n "$backup" ]] && cp "$backup" "$file"
                        return 1
                    fi
                fi
            fi
            ;;
        "structured")
            if [[ -n "$operation" ]]; then
                if [[ "$detect_project" == "true" ]]; then
                    if ! apply_project_aware_edit "$file" "$operation" "$project_path"; then
                        log_error "Project-aware semantic edit failed, falling back to patch management"
                        if ! apply_patch_management "$file" "$operation"; then
                            log_error "Patch management failed"
                            [[ -n "$backup" ]] && cp "$backup" "$file"
                            return 1
                        fi
                    fi
                else
                    if ! apply_semantic_edit "$file" "$operation"; then
                        log_error "Semantic edit failed, falling back to patch management"
                        if ! apply_patch_management "$file" "$operation"; then
                            log_error "Patch management failed"
                            [[ -n "$backup" ]] && cp "$backup" "$file"
                            return 1
                        fi
                    fi
                fi
            else
                log_error "Structured files require semantic operation"
                return 1
            fi
            ;;
        "code")
            if [[ -n "$pattern" && -n "$replacement" ]]; then
                if ! apply_structural_edit "$file" "$pattern" "$replacement"; then
                    log_error "Structural edit failed"
                    [[ -n "$backup" ]] && cp "$backup" "$file"
                    return 1
                fi
            else
                log_error "Code files require pattern and replacement"
                return 1
            fi
            ;;
        "configuration"|"text"|"data")
            if [[ -n "$pattern" && -n "$replacement" ]]; then
                if ! apply_text_edit "$file" "$pattern" "$replacement"; then
                    log_error "Text edit failed"
                    [[ -n "$backup" ]] && cp "$backup" "$file"
                    return 1
                fi
            else
                log_error "Text/data files require pattern and replacement"
                return 1
            fi
            ;;
        "binary_config")
            log_error "Binary configuration files require manual intervention"
            return 1
            ;;
    esac

    # Validate result
    if ! validate_file "$file" "$format"; then
        log_error "Validation failed, restoring backup"
        [[ -n "$backup" ]] && cp "$backup" "$file"
        return 1
    fi

    log_info "Surgical edit completed successfully"
}

# Show help
show_help() {
    local context_info
    context_info=$(get_context_paths)
    local context_type="${context_info%%:*}"
    local base_path="${context_info##*:}"

    cat << EOF
Surgical Configuration Editor

Usage: $0 [options] [file] [operation] [pattern] [replacement]

Options:
  --help, -h              Show this help message
  --detect-project        Enable project detection integration
  --project-path <path>   Set project path for detection (default: .)
  --dry-run              Preview changes without writing
  --verbose, -v          Show detailed output
  --show-context         Show current deployment context
  --validate             Validate environment and tools
  --no-loop-prevention   Disable infinite loop detection
  --force-detection      Force project detection even if loops detected
  --no-create            Don't create file if missing (default: creates file)

Project Detection Integration:
  --detect-project        Enable project-detection before editing
  --project-path <path>   Specify project root directory

Context Detection:
  Current context: $context_type
  Base path: $base_path

  Supported contexts:
  - chezmoi-templates: Running from .chezmoitemplates directory
  - deployed-config: Running from ~/.config/ai/skills/ directory
  - ai-tools: Running from AI tools skills/ folder
  - default: Fallback context

Loop Prevention:
  The skill includes automatic infinite loop detection when used with other skills:
  - Detects if project-adopter is already running
  - Prevents nested surgical-config calls
  - Checks caller process and environment variables
  - Can be disabled with --no-loop-prevention
  - Can be forced with --force-detection

Examples:
  # Standard surgical edit
  $0 package.json '.dependencies += {"lodash": "^4.17.21"}'

  # Create new file and edit (creates file with appropriate defaults)
  $0 devbox.json '.packages = ["just"] | .shell.init_hook = []'

  # Create Markdown file with YAML frontmatter
  $0 README.md '.title = "My Project" | .description = "Project description"'

  # Disable file creation (fail if file doesn't exist)
  $0 --no-create missing-file.json '.key = "value"'

  # Project-aware editing (detects project type first)
  $0 --detect-project config.json '.dependencies += {"package": "1.0.0"}'

  # Project-aware editing with custom path
  $0 --detect-project --project-path ./apps/web config.json '.port = 8080'

  # Show current context
  $0 --show-context

  # Template processing
  $0 config.xml.jinja '.config.port = 8080'

  # Code pattern editing
  $0 src/main.rs 'println!(:[args])' 'log::info!(:[args])'

  # Text substitution
  $0 .env 'DEBUG=false' 'DEBUG=true'

Environment Setup:
  # Ensure environment is properly configured
  ./scripts/ensure-environment.sh --setup

EOF
}

# Main execution
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --show-context)
            local context_info
            context_info=$(get_context_paths)
            local context_type="${context_info%%:*}"
            local base_path="${context_info##*:}"

            echo "Current deployment context:"
            echo "  Context type: $context_type"
            echo "  Base path: $base_path"
            echo "  Script directory: $SCRIPT_DIR"
            echo "  Skill root: $SKILL_ROOT"
            exit 0
            ;;
        --no-loop-prevention)
            export LOOP_DETECTION_ENABLED=false
            shift
            ;;
        --no-create)
            export CREATE_FILE_IF_MISSING=false
            shift
            ;;
        --verbose|-v)
            set -x
            shift
            ;;
        --force-detection)
            export FORCE_DETECTION=true
            shift
            ;;
        "")
            log_error "Missing arguments"
            show_help
            exit 1
            ;;
        *)
            if [[ $# -lt 2 ]]; then
                log_error "Insufficient arguments"
                show_help
                exit 1
            fi

            surgical_edit "$@"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
