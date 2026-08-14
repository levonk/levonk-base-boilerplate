#!/bin/bash

# Python Development Loop Helper
# Language-specific helper for Python projects

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

# Detect if this is a Python project
detect_python_project() {
    [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] || [[ -f "setup.cfg" ]]
}

# Detect the environment management system in use (Python specific)
detect_environment() {
    # Priority order: direnv > devbox > mise > nix > poetry > pipenv > uv > asdf > docker-compose > native
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
    elif [[ -f "pyproject.toml" ]] && command -v poetry &> /dev/null; then
        echo "poetry"
    elif [[ -f "Pipfile" ]] && command -v pipenv &> /dev/null; then
        echo "pipenv"
    elif [[ -f "uv.lock" ]] && command -v uv &> /dev/null; then
        echo "uv"
    elif [[ -f "requirements.txt" ]] && command -v pip &> /dev/null; then
        echo "pip"
    elif [[ -f ".python-version" ]] && command -v pyenv &> /dev/null; then
        echo "pyenv"
    elif [[ -f ".tool-versions" ]] && command -v mise &> /dev/null; then
        echo "mise"
    elif [[ -f ".asdf-version" ]] && command -v asdf &> /dev/null; then
        echo "asdf"
    elif [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]] && command -v docker &> /dev/null; then
        echo "docker-compose"
    elif [[ -f ".devcontainer/devcontainer.json" ]] && command -v code &> /dev/null; then
        echo "devcontainer"
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
        "poetry")
            echo "Poetry (pyproject.toml detected)"
            ;;
        "pipenv")
            echo "Pipenv (Pipfile detected)"
            ;;
        "uv")
            echo "UV (uv.lock detected)"
            ;;
        "pip")
            echo "Pip (requirements.txt detected)"
            ;;
        "pyenv")
            echo "Pyenv (.python-version detected)"
            ;;
        "asdf")
            echo "Asdf (.tool-versions/.asdf-version detected)"
            ;;
        "docker-compose")
            echo "Docker Compose (docker-compose.yml detected)"
            ;;
        "devcontainer")
            echo "Dev Container (.devcontainer/devcontainer.json detected)"
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
        "poetry")
            log_info "Running with poetry: $*"
            poetry "$@"
            ;;
        "pipenv")
            log_info "Running with pipenv: $*"
            pipenv "$@"
            ;;
        "uv")
            log_info "Running with UV: $*"
            uv "$@"
            ;;
        "pip")
            log_info "Running with pip: $*"
            pip "$@"
            ;;
        "pyenv")
            log_info "Running with pyenv: $*"
            pyenv exec "$@"
            ;;
        "asdf")
            log_info "Running with asdf: $*"
            asdf exec "$@"
            ;;
        "docker-compose")
            log_info "Running with docker-compose: $*"
            docker compose "$@"
            ;;
        "devcontainer")
            log_info "Running with devcontainer: $*"
            code --new-window --folder . "$@"
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
        "poetry")
            poetry run command -v "$cmd" &> /dev/null
            ;;
        "pipenv")
            pipenv run command -v "$cmd" &> /dev/null
            ;;
        "uv")
            uv "$cmd" --version &> /dev/null
            ;;
        "pip")
            pip "$cmd" --version &> /dev/null
            ;;
        "pyenv")
            pyenv exec command -v "$cmd" &> /dev/null
            ;;
        "asdf")
            asdf exec -- command -v "$cmd" &> /dev/null
            ;;
        "docker-compose")
            docker compose exec -- command -v "$cmd" &> /dev/null
            ;;
        "devcontainer")
            command -v "$cmd" &> /dev/null
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
                echo "  - Add packages: devbox add python uv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "mise")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python uv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "nix")
                echo "  - Create flake.nix: nix flake"
                echo "  - Run commands: nix develop --command <command>"
                ;;
            "poetry")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python poetry"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "pipenv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python pipenv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "uv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python uv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "pip")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python pip"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "pyenv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python pyenv"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "asdf")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add python asdf"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "docker-compose")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add docker docker-compose"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "devcontainer")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add docker"
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

# Generate Python-specific justfile content
generate_python_justfile() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    cat << EOF
# Python development targets
# Generated by python-loop-helper.sh

# Install dependencies
install:
    $pkg_manager install

# Build project
build:
    $pkg_manager build

# Run tests
test:
    $pkg_manager test

# Development server
dev:
    $pkg_manager run dev

# Lint code
lint:
    $pkg_manager run lint

# Type checking
typecheck:
    $pkg_manager run typecheck

# Clean build artifacts
clean:
    rm -rf build/ dist/ *.egg-info/
EOF
}

# Detect package manager
detect_package_manager() {
    if [[ -f "pyproject.toml" ]] && command -v poetry &> /dev/null; then
        echo "poetry"
    elif [[ -f "Pipfile" ]] && command -v pipenv &> /dev/null; then
        echo "pipenv"
    elif [[ -f "uv.lock" ]] && command -v uv &> /dev/null; then
        echo "uv"
    elif [[ -f "requirements.txt" ]] && command -v pip &> /dev/null; then
        echo "pip"
    else
        echo "pip"  # Default fallback
    fi
}

# Run Python-specific development loop
run_python_development_loop() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    local env
    env=$(detect_environment)

    log_step "Starting Python development loop with $pkg_manager..."
    log_info "Environment: $(detect_environment)"
    check_preferred_environment

    local steps=(
        "install:$pkg_manager install"
        "build:$pkg_manager build"
        "lint:$pkg_manager lint"
        "test:$pkg_manager test"
        "dev:$pkg_manager dev"
    )

    for step in "${steps[@]}"; do
        local step_name="${step%%:*}"
        local step_command="${step#*}"

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
                "direnv")
                    echo "  Retry with: direnv exec $step_command"
                    ;;
                *)
                    echo "  Retry with: $step_command"
                    ;;
            esac
            return 1
        fi
    done

    log_info "🎉 Python development loop completed successfully!"
}

# Show help
show_help() {
    echo "Python Development Loop Helper"
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
