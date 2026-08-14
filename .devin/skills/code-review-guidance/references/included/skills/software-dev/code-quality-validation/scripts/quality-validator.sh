#!/usr/bin/env bash

# Code Quality Validation Script
# Comprehensive code quality validation for multiple languages

set -euo pipefail

# Script configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"

# Colors for output (only if supported)
SUPPORTS_COLOR=false

# Check if color output is supported
check_color_support() {
    # Check if we're in a terminal that supports color
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        local colors
        colors=$(tput colors 2>/dev/null || echo "0")
        if [[ "$colors" -gt 0 ]]; then
            SUPPORTS_COLOR=true
        fi
    fi
    
    # Also check for common color support indicators
    if [[ -n "${FORCE_COLOR:-}" || "${CLICOLOR:-}" == "1" || "${CLICOLOR_FORCE:-}" == "1" ]]; then
        SUPPORTS_COLOR=true
    fi
}

# Initialize color variables (only set if color is supported)
init_colors() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        CYAN='\033[0;36m'
        NC='\033[0m' # No Color
    else
        # Set to empty strings when color not supported
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        PURPLE=''
        CYAN=''
        NC=''
    fi
}

# Logging functions (safe for all environments)
log_info() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    else
        echo "[INFO] $1"
    fi
}

log_success() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    else
        echo "[SUCCESS] $1"
    fi
}

log_warning() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    else
        echo "[WARNING] $1"
    fi
}

log_error() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${RED}[ERROR]${NC} $1"
    else
        echo "[ERROR] $1"
    fi
}

log_phase() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${PURPLE}[PHASE]${NC} $1"
    else
        echo "[PHASE] $1"
    fi
}

log_tool() {
    if [[ "$SUPPORTS_COLOR" == "true" ]]; then
        echo -e "${CYAN}[TOOL]${NC} $1"
    else
        echo "[TOOL] $1"
    fi
}

# Global variables
DEBUG=false
CI_MODE=false
REPORT_FORMAT="text"
AUTO_FIX=false
INCREMENTAL=false
FAILED_PHASES=0
TOTAL_ISSUES=0

# Configuration
CONFIG_FILE="$PROJECT_ROOT/.quality-validator.json"
DEFAULT_CONFIG='{
  "languages": [],
  "phases": {
    "lint": {"enabled": true, "fail_on_error": true},
    "format": {"enabled": true, "auto_fix": false},
    "test": {"enabled": true, "coverage": false},
    "security": {"enabled": true, "audit_dependencies": true}
  },
  "custom": {
    "pre_commands": [],
    "post_commands": []
  }
}'

# Environment detection
detect_environment() {
    if [[ -f "devbox.json" ]]; then
        echo "devbox"
    elif [[ -f "mise.toml" || -f ".mise.toml" || -f ".tool-versions" ]]; then
        echo "mise"
    elif [[ -f "flake.nix" ]]; then
        echo "nix"
    else
        echo "native"
    fi
}

# Command wrapper for environment-aware execution
run_command() {
    local env_type
    env_type=$(detect_environment)
    
    if [[ "$DEBUG" == "true" ]]; then
        log_info "Environment: $env_type"
        log_info "Command: $*"
    fi
    
    case "$env_type" in
        "devbox")
            devbox run -- "$@"
            ;;
        "mise")
            mise exec -- "$@"
            ;;
        "nix")
            nix develop --command "$@"
            ;;
        "native")
            "$@"
            ;;
    esac
}

# Project type detection
detect_project_type() {
    local detected_languages=()
    
    # JavaScript/TypeScript
    if [[ -f "package.json" ]]; then
        detected_languages+=("javascript")
    fi
    
    # Rust
    if [[ -f "Cargo.toml" ]]; then
        detected_languages+=("rust")
    fi
    
    # Python
    if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
        detected_languages+=("python")
    fi
    
    # Go
    if [[ -f "go.mod" ]]; then
        detected_languages+=("go")
    fi
    
    # Java/Kotlin
    if [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
        detected_languages+=("java")
    fi
    
    # C/C++
    if [[ -f "Makefile" || -f "CMakeLists.txt" || -f "configure.ac" ]]; then
        detected_languages+=("cpp")
    fi
    
    printf '%s\n' "${detected_languages[@]}"
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_info "Loading configuration from $CONFIG_FILE"
        jq . "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_CONFIG"
    else
        log_info "Using default configuration"
        echo "$DEFAULT_CONFIG"
    fi
}

# Check if tool is available
tool_available() {
    command -v "$1" >/dev/null 2>&1
}

# JavaScript/TypeScript validation
validate_javascript() {
    log_phase "Validating JavaScript/TypeScript"
    
    local issues=0
    
    # ESLint
    if tool_available eslint; then
        log_tool "Running ESLint"
        if run_command eslint .; then
            log_success "ESLint passed"
        else
            log_error "ESLint failed"
            ((issues++))
        fi
    else
        log_warning "ESLint not available"
    fi
    
    # Prettier
    if tool_available prettier; then
        log_tool "Checking formatting with Prettier"
        if run_command prettier --check .; then
            log_success "Prettier check passed"
        else
            log_error "Prettier check failed"
            if [[ "$AUTO_FIX" == "true" ]]; then
                log_tool "Auto-fixing with Prettier"
                run_command prettier --write .
            fi
            ((issues++))
        fi
    else
        log_warning "Prettier not available"
    fi
    
    # npm audit
    if tool_available npm && [[ -f "package.json" ]]; then
        log_tool "Running npm audit"
        if run_command npm audit --audit-level moderate; then
            log_success "npm audit passed"
        else
            log_warning "npm audit found vulnerabilities"
            ((issues++))
        fi
    fi
    
    # Tests
    if [[ -f "package.json" ]]; then
        local test_script
        test_script=$(jq -r '.scripts.test // empty' package.json 2>/dev/null || echo "")
        if [[ -n "$test_script" ]]; then
            log_tool "Running npm test"
            if run_command npm test; then
                log_success "Tests passed"
            else
                log_error "Tests failed"
                ((issues++))
            fi
        fi
    fi
    
    return $issues
}

# Rust validation
validate_rust() {
    log_phase "Validating Rust"
    
    local issues=0
    
    # Clippy
    if tool_available cargo; then
        log_tool "Running Clippy"
        if run_command cargo clippy -- -D warnings; then
            log_success "Clippy passed"
        else
            log_error "Clippy failed"
            ((issues++))
        fi
    fi
    
    # rustfmt
    if tool_available rustfmt; then
        log_tool "Checking formatting with rustfmt"
        if run_command cargo fmt -- --check; then
            log_success "rustfmt check passed"
        else
            log_error "rustfmt check failed"
            if [[ "$AUTO_FIX" == "true" ]]; then
                log_tool "Auto-fixing with rustfmt"
                run_command cargo fmt
            fi
            ((issues++))
        fi
    else
        log_warning "rustfmt not available"
    fi
    
    # Tests
    if tool_available cargo; then
        log_tool "Running cargo test"
        if run_command cargo test; then
            log_success "Tests passed"
        else
            log_error "Tests failed"
            ((issues++))
        fi
    fi
    
    # Cargo audit
    if tool_available cargo-audit || run_command cargo install cargo-audit --quiet; then
        log_tool "Running cargo audit"
        if run_command cargo audit; then
            log_success "cargo audit passed"
        else
            log_warning "cargo audit found vulnerabilities"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Python validation
validate_python() {
    log_phase "Validating Python"
    
    local issues=0
    
    # Flake8 or Ruff
    if tool_available ruff; then
        log_tool "Running Ruff"
        if run_command ruff check .; then
            log_success "Ruff passed"
        else
            log_error "Ruff failed"
            if [[ "$AUTO_FIX" == "true" ]]; then
                log_tool "Auto-fixing with Ruff"
                run_command ruff check --fix .
            fi
            ((issues++))
        fi
    elif tool_available flake8; then
        log_tool "Running Flake8"
        if run_command flake8 .; then
            log_success "Flake8 passed"
        else
            log_error "Flake8 failed"
            ((issues++))
        fi
    else
        log_warning "Neither Ruff nor Flake8 available"
    fi
    
    # Black formatting
    if tool_available black; then
        log_tool "Checking formatting with Black"
        if run_command black --check .; then
            log_success "Black check passed"
        else
            log_error "Black check failed"
            if [[ "$AUTO_FIX" == "true" ]]; then
                log_tool "Auto-fixing with Black"
                run_command black .
            fi
            ((issues++))
        fi
    else
        log_warning "Black not available"
    fi
    
    # Tests
    if tool_available pytest; then
        log_tool "Running pytest"
        if run_command pytest; then
            log_success "pytest passed"
        else
            log_error "pytest failed"
            ((issues++))
        fi
    elif tool_available python && [[ -f "test" ]]; then
        log_tool "Running python -m unittest"
        if run_command python -m unittest discover; then
            log_success "unittest passed"
        else
            log_error "unittest failed"
            ((issues++))
        fi
    fi
    
    # Security with bandit
    if tool_available bandit; then
        log_tool "Running bandit security scan"
        if run_command bandit -r .; then
            log_success "bandit passed"
        else
            log_warning "bandit found security issues"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Go validation
validate_go() {
    log_phase "Validating Go"
    
    local issues=0
    
    # go vet
    if tool_available go; then
        log_tool "Running go vet"
        if run_command go vet ./...; then
            log_success "go vet passed"
        else
            log_error "go vet failed"
            ((issues++))
        fi
    fi
    
    # golangci-lint
    if tool_available golangci-lint; then
        log_tool "Running golangci-lint"
        if run_command golangci-lint run; then
            log_success "golangci-lint passed"
        else
            log_error "golangci-lint failed"
            ((issues++))
        fi
    fi
    
    # gofmt
    if tool_available gofmt; then
        log_tool "Checking formatting with gofmt"
        if ! gofmt -l . | grep -q .; then
            log_success "gofmt check passed"
        else
            log_error "gofmt check failed"
            if [[ "$AUTO_FIX" == "true" ]]; then
                log_tool "Auto-fixing with gofmt"
                run_command gofmt -w .
            fi
            ((issues++))
        fi
    fi
    
    # Tests
    if tool_available go; then
        log_tool "Running go test"
        if run_command go test ./...; then
            log_success "Tests passed"
        else
            log_error "Tests failed"
            ((issues++))
        fi
    fi
    
    # gosec
    if tool_available gosec; then
        log_tool "Running gosec security scan"
        if run_command gosec ./...; then
            log_success "gosec passed"
        else
            log_warning "gosec found security issues"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Security scanning
security_scan() {
    log_phase "Security Scanning"
    
    local issues=0
    
    # Secret scanning
    log_tool "Scanning for secrets"
    local secret_patterns=(
        "AKIA[0-9A-Z]{16}"
        "ghp_[a-zA-Z0-9]{36}"
        "sk_live_[a-zA-Z0-9]{24}"
        "-----BEGIN [A-Z]+ KEY-----"
        "API[_-]?KEY[_-]?[=:_][\"']?[a-zA-Z0-9]{20,}"
    )
    
    for pattern in "${secret_patterns[@]}"; do
        if git grep --cached -E "$pattern" 2>/dev/null || git grep -E "$pattern" 2>/dev/null; then
            log_error "Potential secret found: $pattern"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "No secrets detected"
    fi
    
    return $issues
}

# Main validation function
run_validation() {
    local phase="${1:-complete}"
    local config
    config=$(load_config)
    
    # Get detected languages
    local languages
    readarray -t languages < <(detect_project_type)
    
    if [[ ${#languages[@]} -eq 0 ]]; then
        log_warning "No supported project types detected"
        return 0
    fi
    
    log_info "Detected languages: ${languages[*]}"
    
    # Run pre-commands
    local pre_commands
    pre_commands=$(echo "$config" | jq -r '.custom.pre_commands[]? // empty' 2>/dev/null || true)
    while IFS= read -r cmd; do
        if [[ -n "$cmd" ]]; then
            log_info "Running pre-command: $cmd"
            run_command eval "$cmd"
        fi
    done <<< "$pre_commands"
    
    # Run validation phases
    case "$phase" in
        "lint")
            for lang in "${languages[@]}"; do
                case "$lang" in
                    "javascript") validate_javascript ;;
                    "rust") validate_rust ;;
                    "python") validate_python ;;
                    "go") validate_go ;;
                esac
                ((TOTAL_ISSUES += $?))
            done
            ;;
        "format")
            for lang in "${languages[@]}"; do
                case "$lang" in
                    "javascript") 
                        if tool_available prettier; then
                            if [[ "$AUTO_FIX" == "true" ]]; then
                                run_command prettier --write .
                            else
                                run_command prettier --check .
                            fi
                        fi
                        ;;
                    "rust")
                        if tool_available rustfmt; then
                            if [[ "$AUTO_FIX" == "true" ]]; then
                                run_command cargo fmt
                            else
                                run_command cargo fmt -- --check
                            fi
                        fi
                        ;;
                    "python")
                        if tool_available black; then
                            if [[ "$AUTO_FIX" == "true" ]]; then
                                run_command black .
                            else
                                run_command black --check .
                            fi
                        fi
                        ;;
                    "go")
                        if [[ "$AUTO_FIX" == "true" ]]; then
                            run_command gofmt -w .
                        else
                            ! gofmt -l . | grep -q .
                        fi
                        ;;
                esac
                ((TOTAL_ISSUES += $?))
            done
            ;;
        "test")
            for lang in "${languages[@]}"; do
                case "$lang" in
                    "javascript")
                        if [[ -f "package.json" ]] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
                            run_command npm test || ((TOTAL_ISSUES++))
                        fi
                        ;;
                    "rust") run_command cargo test || ((TOTAL_ISSUES++)) ;;
                    "python")
                        if tool_available pytest; then
                            run_command pytest || ((TOTAL_ISSUES++))
                        elif tool_available python; then
                            run_command python -m unittest discover || ((TOTAL_ISSUES++))
                        fi
                        ;;
                    "go") run_command go test ./... || ((TOTAL_ISSUES++)) ;;
                esac
            done
            ;;
        "security")
            security_scan || ((TOTAL_ISSUES++))
            ;;
        "complete")
            # Run all phases
            for lang in "${languages[@]}"; do
                case "$lang" in
                    "javascript") validate_javascript ;;
                    "rust") validate_rust ;;
                    "python") validate_python ;;
                    "go") validate_go ;;
                esac
                ((TOTAL_ISSUES += $?))
            done
            security_scan || ((TOTAL_ISSUES++))
            ;;
    esac
    
    # Run post-commands
    local post_commands
    post_commands=$(echo "$config" | jq -r '.custom.post_commands[]? // empty' 2>/dev/null || true)
    while IFS= read -r cmd; do
        if [[ -n "$cmd" ]]; then
            log_info "Running post-command: $cmd"
            run_command eval "$cmd"
        fi
    done <<< "$post_commands"
    
    return $TOTAL_ISSUES
}

# Generate report
generate_report() {
    local format="${1:-text}"
    
    case "$format" in
        "json")
            jq -n \
                --arg total "$TOTAL_ISSUES" \
                --arg status "$([ $TOTAL_ISSUES -eq 0 ] && echo "passed" || echo "failed")" \
                '{
                    summary: {
                        total_issues: ($total | tonumber),
                        status: $status
                    }
                }'
            ;;
        "junit")
            echo "<testsuite name=\"quality-validation\" tests=\"1\">"
            echo "  <testcase name=\"quality-validation\" classname=\"quality\">"
            if [[ $TOTAL_ISSUES -gt 0 ]]; then
                echo "    <failure message=\"Found $TOTAL_ISSUES issues\">"
                echo "    </failure>"
            fi
            echo "  </testcase>"
            echo "</testsuite>"
            ;;
        "text")
            if [[ $TOTAL_ISSUES -eq 0 ]]; then
                log_success "All quality checks passed!"
            else
                log_error "Found $TOTAL_ISSUES issues"
            fi
            ;;
    esac
}

# Health check
health_check() {
    log_info "Health Check - Tool Availability"
    
    local tools=(
        "eslint:JavaScript linting"
        "prettier:Code formatting"
        "cargo:Rust package manager"
        "rustfmt:Rust formatting"
        "python:Python interpreter"
        "pytest:Python testing"
        "black:Python formatting"
        "ruff:Python linting"
        "go:Go compiler"
        "golangci-lint:Go linting"
        "bandit:Python security"
        "gosec:Go security"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if tool_available "$tool"; then
            log_success "✓ $tool - $description"
        else
            log_warning "✗ $tool - $description (not available)"
        fi
    done
}

# Install pre-commit hook
install_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/pre-commit"
    
    if [[ ! -d "$hook_dir" ]]; then
        log_error "Not a git repository or .git/hooks not found"
        return 1
    fi
    
    log_info "Installing pre-commit hook"
    
    cat > "$hook_file" << 'EOF'
#!/bin/sh
# Pre-commit hook for code quality validation

SCRIPT_DIR="$(git rev-parse --show-toplevel)/scripts/quality-validator.sh"
if [[ -f "$SCRIPT_DIR" ]]; then
    "$SCRIPT_DIR" pre-commit || exit 1
fi
EOF
    
    chmod +x "$hook_file"
    log_success "Pre-commit hook installed"
}

# Main function
main() {
    local command="${1:-complete}"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                DEBUG=true
                shift
                ;;
            --ci)
                CI_MODE=true
                shift
                ;;
            --format)
                REPORT_FORMAT="$2"
                shift 2
                ;;
            --fix)
                AUTO_FIX=true
                shift
                ;;
            --incremental)
                INCREMENTAL=true
                shift
                ;;
            *)
                command="$1"
                shift
                ;;
        esac
    done
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Initialize color support detection
    check_color_support
    init_colors
    
    log_info "Starting Code Quality Validation"
    log_info "Project root: $PROJECT_ROOT"
    log_info "Environment: $(detect_environment)"
    log_info "Command: $command"
    log_info "Color support: $SUPPORTS_COLOR"
    
    case "$command" in
        "lint"|"format"|"test"|"security"|"complete")
            run_validation "$command"
            generate_report "$REPORT_FORMAT"
            ;;
        "fix")
            AUTO_FIX=true
            run_validation "format"
            ;;
        "health-check")
            health_check
            ;;
        "install-hook")
            install_hook
            ;;
        "pre-commit")
            # In pre-commit mode, only check staged changes
            run_validation "complete"
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $SCRIPT_NAME [command] [options]"
            echo ""
            echo "Commands:"
            echo "  lint        - Run linting validation"
            echo "  format      - Check code formatting"
            echo "  test        - Run tests"
            echo "  security    - Run security scanning"
            echo "  complete    - Run all validation phases"
            echo "  fix         - Auto-fix formatting issues"
            echo "  health-check - Show tool availability"
            echo "  install-hook - Install git pre-commit hook"
            echo "  pre-commit   - Run pre-commit validation"
            echo "  help        - Show this help"
            echo ""
            echo "Options:"
            echo "  --debug     - Enable debug logging"
            echo "  --ci        - CI mode (no interactive prompts)"
            echo "  --format    - Report format (text|json|junit)"
            echo "  --fix       - Auto-fix formatting issues"
            echo "  --incremental - Only validate changed files"
            ;;
        *)
            log_error "Unknown command: $command"
            exit 1
            ;;
    esac
    
    # Exit with appropriate code
    if [[ $TOTAL_ISSUES -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function with all arguments
main "$@"
