#!/bin/bash

# Rust Development Loop Helper
# Language-specific helper for Rust projects

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Detect if this is a Rust project
detect_rust_project() {
    [[ -f "Cargo.toml" ]] && [[ -f "Cargo.toml" ]]
}

# Detect the environment management system in use (Rust specific)
detect_environment() {
    # Priority order: direnv > devbox > mise > nix > native
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
        "mise")
            mise exec -- command -v "$cmd" &> /dev/null
            ;;
        "nix")
            nix develop --command command -v "$cmd" &> /dev/null
            ;;
        *)
            command -v "$cmd" &> /dev/null
            ;;
    esac
}

# Foundation check
foundation_check() {
    print_status "Running foundation checks..."

    # Check if rustc is available
    if ! command_exists_in_env rustc; then
        print_error "rustc command not found. Please install Rust toolchain."
        exit 1
    fi

    # Check if just is available
    if ! command_exists_in_env just; then
        print_error "just command not found. Please install just."
        exit 1
    fi

    # Check if cargo is available
    if ! command_exists_in_env cargo; then
        print_error "cargo command not found. Please install Rust toolchain."
        exit 1
    fi

    print_success "✓ Foundation checks passed"
}

# Run iterative development loop using justfile targets
iterative_development_loop() {
    print_status "Starting iterative development loop..."

    # Check for preferred environment
    check_preferred_environment

    local steps=(
        "test"
        "build"
        "clippy"
        "check"
    )

    for step in "${steps[@]}"; do
        log_step "Running: just $step"

        if run_command just "$step"; then
            print_success "✓ $step completed successfully"
        else
            print_error "✗ $step failed"
            print_warn "Restarting development loop from test step..."
            return 1
        fi
    done

    print_success "🎉 Iterative development loop completed!"
}

# Show help
show_help() {
    echo "Rust Development Loop Helper"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  foundation     Run foundation checks"
    echo "  next           Get next ready ticket"
    echo "  start <id>     Start work on ticket"
    echo "  complete <id>  Mark ticket as ready"
    echo "  close <id>     Mark ticket as closed"
    echo "  show <id>      Show ticket details"
    echo "  loop           Run iterative development loop"
    echo "  generate-justfile  Generate justfile for project type"
    echo "  env            Show detected environment information"
    echo "  validate       Validate work and run checks"
    echo "  reflect <id>   Reflection helper"
    echo "  status         Show status overview"
    echo "  no-tickets     Handle no tickets scenario"
    echo "  help           Show this help"
    echo
    echo "Examples:"
    echo "  $0 foundation"
    echo "  $0 next"
    echo "  $0 start ja-1234"
    echo "  $0 complete ja-1234"
    echo "  $0 loop"
    echo "  $0 generate-justfile"
    echo "  $0 env"
    echo "  $0 reflect ja-1234"
    echo "  $0 no-tickets"
}
