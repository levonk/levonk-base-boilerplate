#!/bin/bash
# Deterministic tool verification for monorepo extraction
# Ensures all required tools are available with minimum versions

set -euo pipefail

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Required tools and minimum versions
declare -A REQUIRED_TOOLS=(
    ["git"]="2.25.0"
    ["jq"]="1.6"
    ["find"]="4.7.0"
    ["sed"]="4.8"
    ["awk"]="5.0"
)

# Optional but recommended tools
declare -A RECOMMENDED_TOOLS=(
    ["git-filter-repo"]="2.38.0"
    ["gh"]="2.0.0"
)

log_info() {
    echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

version_compare() {
    local required="$1"
    local current="$2"
    
    # Simple version comparison using sort -V
    if printf '%s\n%s\n' "$required" "$current" | sort -V -C; then
        return 0  # current >= required
    else
        return 1  # current < required
    fi
}

get_tool_version() {
    local tool="$1"
    local current_version=""
    
    case "$tool" in
        "git")
            current_version=$(git --version 2>/dev/null | cut -d' ' -f3 || echo "")
            ;;
        "jq")
            current_version=$(jq --version 2>/dev/null | cut -d' ' -f1 | sed 's/jq-//' || echo "")
            ;;
        "git-filter-repo")
            current_version=$(git-filter-repo --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "")
            ;;
        "gh")
            current_version=$(gh version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "")
            ;;
        "find")
            current_version=$(find --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "")
            ;;
        "sed")
            current_version=$(sed --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "")
            ;;
        "awk")
            current_version=$(awk --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "")
            ;;
        *)
            current_version=$("$tool" --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1 || echo "")
            ;;
    esac
    
    echo "$current_version"
}

verify_tool() {
    local tool="$1"
    local min_version="$2"
    local is_optional="${3:-false}"
    
    log_info "Checking $tool..."
    
    if ! command -v "$tool" >/dev/null 2>&1; then
        if [[ "$is_optional" == "true" ]]; then
            log_warn "$tool is not installed (optional but recommended)"
            return 0
        else
            log_error "$tool is not installed"
            return 1
        fi
    fi
    
    local current_version
    current_version=$(get_tool_version "$tool")
    
    if [[ -z "$current_version" ]]; then
        if [[ "$is_optional" == "true" ]]; then
            log_warn "$tool version could not be determined (optional)"
            return 0
        else
            log_error "$tool version could not be determined"
            return 1
        fi
    fi
    
    if ! version_compare "$min_version" "$current_version"; then
        if [[ "$is_optional" == "true" ]]; then
            log_warn "$tool version $current_version is below recommended $min_version"
            return 0
        else
            log_error "$tool version $current_version is below minimum $min_version"
            return 1
        fi
    fi
    
    log_info "✓ $tool $current_version"
    return 0
}

verify_git_config() {
    log_info "Checking git configuration..."
    
    if ! git config --global user.name >/dev/null 2>&1; then
        log_error "git user.name is not configured"
        return 1
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        log_error "git user.email is not configured"
        return 1
    fi
    
    log_info "✓ git configuration is valid"
}

verify_permissions() {
    log_info "Checking filesystem permissions..."
    
    # Test write permissions in current directory
    if ! touch .test-permission 2>/dev/null; then
        log_error "No write permission in current directory"
        return 1
    fi
    rm -f .test-permission
    
    # Test git operations
    if ! git init test-repo --quiet 2>/dev/null; then
        log_error "Cannot create git repositories"
        return 1
    fi
    rm -rf test-repo
    
    log_info "✓ filesystem permissions are adequate"
}

main() {
    echo "=== Monorepo Extraction Tool Verification ==="
    echo
    
    local failed_tools=0
    
    # Verify required tools
    echo "Checking required tools..."
    for tool in "${!REQUIRED_TOOLS[@]}"; do
        if ! verify_tool "$tool" "${REQUIRED_TOOLS[$tool]}" false; then
            ((failed_tools++))
        fi
    done
    
    echo
    echo "Checking recommended tools..."
    for tool in "${!RECOMMENDED_TOOLS[@]}"; do
        verify_tool "$tool" "${RECOMMENDED_TOOLS[$tool]}" true
    done
    
    echo
    # Verify git configuration
    if ! verify_git_config; then
        ((failed_tools++))
    fi
    
    echo
    # Verify permissions
    if ! verify_permissions; then
        ((failed_tools++))
    fi
    
    echo
    if [[ $failed_tools -gt 0 ]]; then
        log_error "Verification failed with $failed_tools issues"
        echo
        echo "To install missing tools:"
        echo "  Ubuntu/Debian: sudo apt-get install git jq"
        echo "  macOS: brew install git jq"
        echo "  git-filter-repo: pip install git-filter-repo"
        echo "  GitHub CLI: brew install gh  # or visit github.com/cli"
        exit 1
    fi
    
    log_info "All tools verified successfully ✓"
    echo "Environment is ready for monorepo extraction"
}

# Run verification if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
