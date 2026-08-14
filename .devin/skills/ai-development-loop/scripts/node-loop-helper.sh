#!/bin/bash

# Node.js Loop Helper Script
# Provides Node.js-specific logic for development loops and justfile generation

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

# Detect if this is a Node.js project
detect_node_project() {
    [[ -f "package.json" ]] || [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]] || [[ -f "uv.lock" ]]
}

# Detect the environment management system in use (Node.js specific)
detect_environment() {
    # Priority order: direnv > devbox > mise > nix > nvm > uv > native
    if [[ -f ".envrc" ]] && command -v direnv &> /dev/null; then
        echo "direnv"
    elif [[ -f ".env" ]] && command -v direnv &> /dev/null; then
        echo "direnv"
    elif [[ -f "devbox.json" ]] && command -v devbox &> /dev/null; then
        echo "devbox"
    elif [[ -f "mise.toml" ]] || [[ -f ".mise.toml" ]] && command -v mise &> /dev/null; then
        echo "mise"
    elif [[ -f "flake.nix" ]] && command -v nix &> /dev/null; then
        echo "nix"
    elif [[ -f ".nvmrc" ]] && command -v nvm &> /dev/null; then
        echo "nvm"
    elif [[ -f "uv.lock" ]] && command -v uv &> /dev/null; then
        echo "uv"
    else
        echo "native"
    fi
}

# Get environment info for display
get_environment_info() {
    local env=$(detect_environment)
    case "$env" in
        "direnv")
            echo "Direnv (.envrc/.env detected)"
            ;;
        "devbox")
            echo "Devbox (devbox.json detected)"
            ;;
        "mise")
            echo "Mise (mise.toml/.tool-versions detected)"
            ;;
        "nix")
            echo "Nix (flake.nix detected)"
            ;;
        "nvm")
            echo "NVM (.nvmrc detected)"
            ;;
        "uv")
            echo "UV (uv.lock detected)"
            ;;
        *)
            echo "Native (no environment manager detected)"
            ;;
    esac
}

# Wrap command with appropriate environment manager
run_command() {
    local env=$(detect_environment)
    case "$env" in
        "direnv")
            log_info "Running with direnv: $*"
            direnv exec "$@"
            ;;
        "devbox")
            log_info "Running with devbox: $*"
            devbox run -- "$@"
            ;;
        "mise")
            log_info "Running with mise: $*"
            mise exec -- "$@"
            ;;
        "nix")
            log_info "Running with nix: $*"
            nix develop --command "$@"
            ;;
        "nvm")
            log_info "Running with NVM: $*"
            nvm exec "$@"
            ;;
        "uv")
            log_info "Running with UV: $*"
            uv "$@"
            ;;
        *)
            log_info "Running natively: $*"
            "$@"
            ;;
    esac
}

# Check if a command exists in the current environment
command_exists_in_env() {
    local cmd="$1"
    local env=$(detect_environment)

    case "$env" in
        "direnv")
            direnv exec -- command -v "$cmd" &> /dev/null
            ;;
        "devbox")
            devbox run -- command -v "$cmd" &> /dev/null
            ;;
        "nix")
            nix develop --command command -v "$cmd" &> /dev/null
            ;;
        "nvm")
            nvm exec -- command -v "$cmd" &> /dev/null
            ;;
        "uv")
            uv "$cmd" --version &> /dev/null
            ;;
        *)
            command -v "$cmd" &> /dev/null
            ;;
    esac
}

# Check if using preferred environment (devbox) and warn if not
check_preferred_environment() {
    local env=$(detect_environment)
    if [[ "$env" != "devbox" ]]; then
        log_warn "⚠️  Preferred environment is Devbox, but detected: $env"
        log_warn "Consider using Devbox for optimal experience:"
        case "$env" in
            "direnv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add nodejs pnpm"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "mise")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add nodejs pnpm"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "nix")
                echo "  - Create flake.nix: nix flake"
                echo "  - Run commands: nix develop --command <command>"
                ;;
            "nvm")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add nodejs rust just"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "uv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python uv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            *)
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add <package>"
                echo "  - Run commands: devbox run -- <command>"
                ;;
        esac
        echo
    fi
}

# Detect package manager
detect_package_manager() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "package-lock.json" ]]; then
        echo "npm"
    else
        echo "npm"  # Default fallback
    fi
}

# Generate Node.js-specific justfile content
generate_node_justfile() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)

    cat << EOF
# Node.js development targets
# Generated by node-loop-helper.sh

# Install dependencies
install:
    $pkg_manager install

# Build the project
build:
    $pkg_manager run build

# Run linting
lint:
    $pkg_manager run lint

# Run unit tests
test:
    $pkg_manager test

# Start development server
dev:
    $pkg_manager run dev

# Run E2E tests (if Playwright is available)
e2e:
    pnpm exec playwright test

# Complete development loop - fails fast if any step fails
loop: || (install build lint test dev e2e)

# Individual targets for debugging
loop-build: || (install build)
loop-test: || (install build lint test)
loop-dev: || (install build lint test dev)

# Clean dependencies and artifacts
clean:
    rm -rf node_modules/
    rm -rf dist/
    rm -rf .nuxt/
    rm -rf .next/
    rm -rf .vite/
    $pkg_manager install

# Type checking (if TypeScript)
typecheck:
    $pkg_manager run typecheck || true

# Security audit
audit:
    $pkg_manager audit || $pkg_manager audit --audit-level moderate

# Update dependencies
update:
    $pkg_manager update
    $pkg_manager install
EOF
}

# Update existing justfile with Node.js targets
update_justfile_with_node_targets() {
    local justfile="justfile"

    if [[ ! -f "$justfile" ]]; then
        log_info "Creating new justfile with Node.js targets..."
        generate_node_justfile > "$justfile"
        return 0
    fi

    # Check if Node.js targets already exist
    if grep -q "install:" "$justfile" && grep -q "$pkg_manager install" "$justfile"; then
        log_info "Node.js targets already exist in justfile"
        return 0
    fi

    log_info "Adding Node.js targets to existing justfile..."

    # Create temporary file with new content
    local temp_file
    temp_file=$(mktemp)

    # Add Node.js targets to the end
    cat "$justfile" > "$temp_file"
    echo "" >> "$temp_file"
    echo "# Node.js development targets (added by node-loop-helper.sh)" >> "$temp_file"
    generate_node_justfile >> "$temp_file"

    # Replace original
    mv "$temp_file" "$justfile"
    log_info "✓ Updated justfile with Node.js targets"
}

# Run Node.js-specific development loop
run_node_development_loop() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    local env
    env=$(detect_environment)

    log_step "Starting Node.js development loop with $pkg_manager..."
    log_info "Environment: $(detect_environment)"
    check_preferred_environment

    local steps=(
        "install:$pkg_manager install"
        "build:$pkg_manager run build"
        "lint:$pkg_manager run lint"
        "test:$pkg_manager test"
        "dev:$pkg_manager run dev"
        "e2e:pnpm exec playwright test"
    )

    for step in "${steps[@]}"; do
        local step_name="${step%%:*}"
        local step_command="${step#*:}"

        log_step "Running: $step_name"

        if run_command eval "$step_command"; then
            log_info "✓ $step_name completed successfully"
        else
            log_error "✗ $step_name failed"
            log_warn "Restarting development loop from install step..."
            case "$env" in
                "devbox")
                    echo "  Retry with: devbox run -- $step_command"
                    ;;
                "mise")
                    echo "  Retry with: mise exec -- $step_command"
                    ;;
                "nix")
                    echo "  Retry with: nix develop --command $step_command"
                    ;;
            esac
            return 1
        fi
    done

    log_info "🎉 Node.js development loop completed successfully!"
}

# Validate Node.js project setup
validate_node_project() {
    local issues=()

    if ! detect_node_project; then
        issues+=("No Node.js project files found (package.json, lock files)")
    fi

    if [[ ! -f "package.json" ]]; then
        issues+=("Missing package.json")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_error "Node.js project validation failed:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    fi

    log_info "✓ Node.js project validation passed"
    return 0
}

# Main execution
main() {
    local command="${1:-help}"

    case "$command" in
        "detect")
            detect_node_project && echo "Node.js project detected" || echo "Not a Node.js project"
            ;;
        "package-manager")
            detect_package_manager
            ;;
        "generate-justfile")
            generate_node_justfile
            ;;
        "update-justfile")
            update_justfile_with_node_targets
            ;;
        "run-loop")
            if ! validate_node_project; then
                exit 1
            fi
            run_node_development_loop
            ;;
        "validate")
            validate_node_project
            ;;
        "help"|*)
            cat << EOF
Node.js Loop Helper

Usage: $0 <command>

Commands:
    detect           Detect if current directory is a Node.js project
    package-manager  Detect which package manager is being used
    generate-justfile  Generate Node.js justfile content to stdout
    update-justfile    Add Node.js targets to existing justfile
    run-loop         Run the complete Node.js development loop
    validate         Validate Node.js project setup
    help             Show this help message

Examples:
    $0 detect
    $0 generate-justfile > justfile
    $0 update-justfile
    $0 run-loop
EOF
            ;;
    esac
}

# Run main function with all arguments
main "$@"
