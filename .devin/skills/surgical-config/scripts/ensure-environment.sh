#!/bin/bash

# Surgical Configuration Environment Assurance
# Ensures all required tools are available and environment is properly configured

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

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

# Required tools for surgical configuration
declare -A REQUIRED_TOOLS=(
    # Primary semantic parser
    ["yq-go"]="https://github.com/mikefarah/yq/v4"
    
    # Alternative semantic parsers
    ["jq"]="https://github.com/stedolan/jq"
    ["dot-json"]="https://github.com/xeedcm/dot-json"
    ["jo"]="https://github.com/jpmens/jo"
    
    # Structural rewriters
    ["comby"]="https://github.com/comby-tools/comby"
    ["ast-grep"]="https://github.com/ast-grep/ast-grep"
    
    # Patch managers
    ["quilt"]="https://savannah.nongnu.org/projects/quilt"
    ["guilt"]="https://github.com/jeffpc/guilt"
    
    # Text utilities
    ["sd"]="https://github.com/chmln/sd"
    
    # Template processors
    ["jinja2-cli"]="https://github.com/khaledh/jinja2-cli"
    
    # Validation tools
    ["plutil"]="macOS built-in"
)

# Optional tools with enhanced functionality
declare -A OPTIONAL_TOOLS=(
    ["pandoc"]="https://pandoc.org"
    ["chktex"]="https://www.nongnu.org/chktex/"
    ["rst2html"]="Python docutils"
)

# Check if tool is available
check_tool() {
    local tool="$1"
    command -v "$tool" >/dev/null 2>&1
}

# Install tool using appropriate package manager
install_tool() {
    local tool="$1"
    local method="${2:-auto}"
    
    log_step "Installing $tool..."
    
    case "$method" in
        "brew")
            if command -v brew >/dev/null 2>&1; then
                brew install "$tool"
            else
                log_error "Homebrew not available for $tool installation"
                return 1
            fi
            ;;
        "apt")
            if command -v apt >/dev/null 2>&1; then
                sudo apt update && sudo apt install -y "$tool"
            else
                log_error "apt not available for $tool installation"
                return 1
            fi
            ;;
        "cargo")
            if command -v cargo >/dev/null 2>&1; then
                cargo install "$tool"
            else
                log_error "Cargo not available for $tool installation"
                return 1
            fi
            ;;
        "npm")
            if command -v npm >/dev/null 2>&1; then
                npm install -g "$tool"
            else
                log_error "npm not available for $tool installation"
                return 1
            fi
            ;;
        "pip")
            if command -v pip3 >/dev/null 2>&1; then
                pip3 install "$tool"
            else
                log_error "pip3 not available for $tool installation"
                return 1
            fi
            ;;
        "go")
            if command -v go >/dev/null 2>&1; then
                go install "$tool@latest"
            else
                log_error "Go not available for $tool installation"
                return 1
            fi
            ;;
        "auto")
            # Try multiple package managers
            if command -v brew >/dev/null 2>&1; then
                install_tool "$tool" "brew"
            elif command -v apt >/dev/null 2>&1; then
                install_tool "$tool" "apt"
            elif command -v cargo >/dev/null 2>&1 && [[ "$tool" == "sd" ]]; then
                install_tool "$tool" "cargo"
            elif command -v npm >/dev/null 2>&1 && [[ "$tool" == "dot-json" ]]; then
                install_tool "$tool" "npm"
            elif command -v pip3 >/dev/null 2>&1 && [[ "$tool" == "jinja2-cli" ]]; then
                install_tool "$tool" "pip"
            elif command -v go >/dev/null 2>&1 && [[ "$tool" == "yq-go" ]]; then
                install_tool "github.com/mikefarah/yq/v4" "go"
            else
                log_error "No suitable package manager found for $tool"
                return 1
            fi
            ;;
        *)
            log_error "Unknown installation method: $method"
            return 1
            ;;
    esac
}

# Ensure .cache directory is properly configured
ensure_cache_directory() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"
    local cache_dir="$repo_root/.cache"
    
    if [[ ! -d "$cache_dir" ]]; then
        log_step "Creating cache directory: $cache_dir"
        mkdir -p "$cache_dir"
    fi
    
    # Ensure .cache is in .gitignore
    local gitignore="$repo_root/.gitignore"
    if [[ -f "$gitignore" ]]; then
        if ! grep -q "^\.cache/" "$gitignore"; then
            log_step "Adding .cache/ to .gitignore"
            echo "" >> "$gitignore"
            echo "# Surgical configuration backups" >> "$gitignore"
            echo ".cache/" >> "$gitignore"
        fi
    else
        log_step "Creating .gitignore with .cache/ entry"
        echo "# Surgical configuration backups" > "$gitignore"
        echo ".cache/" >> "$gitignore"
    fi
    
    log_info "Cache directory configured: $cache_dir"
}

# Update devbox.json with required tools
update_devbox_json() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"
    local devbox_file="$repo_root/devbox.json"
    
    if [[ ! -f "$devbox_file" ]]; then
        log_step "Creating devbox.json"
        cat > "$devbox_file" << 'EOF'
{
  "$schema": "https://json-schema.org/draft-2020-12/schema",
  "name": "surgical-config-env",
  "packages": {
    "yq": "4.44.2",
    "jq": "1.7.1",
    "sd": "1.0.0"
  },
  "shell": {
    "init_hook": [
      "echo 'Surgical configuration environment loaded'"
    ]
  }
}
EOF
        return 0
    fi
    
    log_step "Updating devbox.json with surgical config tools"
    
    # Backup original devbox.json
    local backup="$devbox_file.backup.$(date +%Y%m%d%H%M%S)"
    cp "$devbox_file" "$backup"
    
    # Update packages using yq-go if available, otherwise use jq
    if check_tool "yq-go"; then
        yq-go eval '.packages.yq = "4.44.2" | .packages.jq = "1.7.1" | .packages.sd = "1.0.0"' "$devbox_file" -i
    elif check_tool "jq"; then
        local temp_file=$(mktemp)
        jq '.packages.yq = "4.44.2" | .packages.jq = "1.7.1" | .packages.sd = "1.0.0"' "$devbox_file" > "$temp_file" && mv "$temp_file" "$devbox_file"
    else
        log_warn "Cannot update devbox.json automatically (no yq-go or jq available)"
        return 1
    fi
    
    log_info "Updated devbox.json with surgical config tools"
}

# Check and install missing tools
check_and_install_tools() {
    local missing_tools=()
    local install_missing="${1:-false}"
    
    log_step "Checking required tools..."
    
    for tool in "${!REQUIRED_TOOLS[@]}"; do
        if check_tool "$tool"; then
            log_info "✓ $tool is available"
        else
            log_warn "✗ $tool is missing"
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        log_info "All required tools are available!"
        return 0
    fi
    
    if [[ "$install_missing" == "true" ]]; then
        log_step "Installing missing tools..."
        for tool in "${missing_tools[@]}"; do
            if install_tool "$tool"; then
                log_info "✓ Successfully installed $tool"
            else
                log_error "✗ Failed to install $tool"
            fi
        done
    else
        log_warn "Missing tools: ${missing_tools[*]}"
        log_info "Run with --install to install missing tools"
        return 1
    fi
}

# Check optional tools
check_optional_tools() {
    log_step "Checking optional tools..."
    
    for tool in "${!OPTIONAL_TOOLS[@]}"; do
        if check_tool "$tool"; then
            log_info "✓ $tool is available (enhanced functionality)"
        else
            log_info "- $tool not available (optional)"
        fi
    done
}

# Validate environment
validate_environment() {
    log_step "Validating surgical configuration environment..."
    
    # Check primary tool
    if ! check_tool "yq-go"; then
        log_error "yq-go is required but not available"
        return 1
    fi
    
    # Test yq-go functionality
    local test_file=$(mktemp)
    echo '{"test": "value"}' > "$test_file"
    if ! yq-go eval '.test' "$test_file" >/dev/null 2>&1; then
        log_error "yq-go functionality test failed"
        rm -f "$test_file"
        return 1
    fi
    rm -f "$test_file"
    
    log_info "✓ yq-go is functional"
    
    # Check cache directory
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"
    local cache_dir="$repo_root/.cache"
    
    if [[ ! -d "$cache_dir" ]]; then
        log_error "Cache directory not found: $cache_dir"
        return 1
    fi
    
    log_info "✓ Cache directory exists: $cache_dir"
    
    # Check .gitignore
    local gitignore="$repo_root/.gitignore"
    if [[ -f "$gitignore" ]] && grep -q "^\.cache/" "$gitignore"; then
        log_info "✓ .cache/ is in .gitignore"
    else
        log_warn ".cache/ not found in .gitignore"
    fi
    
    log_info "Environment validation completed"
    return 0
}

# Show help
show_help() {
    cat << EOF
Surgical Configuration Environment Assurance

Usage: $0 [options]

Options:
  --check              Check tool availability (default)
  --install            Install missing tools
  --setup              Full environment setup
  --validate           Validate environment configuration
  --update-devbox      Update devbox.json with required packages
  --ensure-cache       Ensure cache directory and .gitignore
  --help, -h           Show this help message

Examples:
  $0 --check                    # Check what tools are available
  $0 --install                  # Install missing tools
  $0 --setup                    # Full setup (install + configure)
  $0 --validate                  # Validate current environment

Environment Setup:
  - Ensures all required tools are available
  - Configures .cache/ directory for backups
  - Updates .gitignore to exclude .cache/
  - Updates devbox.json with required packages
  - Validates tool functionality

Required Tools:
EOF
    for tool in "${!REQUIRED_TOOLS[@]}"; do
        echo "  - $tool (${REQUIRED_TOOLS[$tool]})"
    done
    echo
}

# Main execution
main() {
    local action="check"
    local install_missing=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                action="check"
                shift
                ;;
            --install)
                action="install"
                install_missing=true
                shift
                ;;
            --setup)
                action="setup"
                install_missing=true
                shift
                ;;
            --validate)
                action="validate"
                shift
                ;;
            --update-devbox)
                action="update-devbox"
                shift
                ;;
            --ensure-cache)
                action="ensure-cache"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Execute action
    case "$action" in
        "check")
            check_and_install_tools false
            check_optional_tools
            ;;
        "install")
            check_and_install_tools true
            ;;
        "setup")
            ensure_cache_directory
            update_devbox_json
            check_and_install_tools true
            validate_environment
            ;;
        "validate")
            validate_environment
            ;;
        "update-devbox")
            update_devbox_json
            ;;
        "ensure-cache")
            ensure_cache_directory
            ;;
        *)
            log_error "Unknown action: $action"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
