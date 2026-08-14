#!/bin/bash

# AI Development Loop Helper Script
# Provides convenience functions for the AI Development Loop workflow

# Validate running with bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be run with bash, not sh or other shells." >&2
    exit 1
fi

set -euo pipefail

# Global variables
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${GREEN}[STEP]${NC} $1"
    fi
}

# Check if ticketr is available
check_ticketr() {
    if ! command -v tkr &> /dev/null; then
        print_error "ticketr (tkr) command not found. Please install ticketr CLI."
        exit 1
    fi
    
    # Check if tkr is the updated version with misplaced ticket fixing
    if ! tkr list &> /dev/null; then
        print_error "tkr command failed. Please ensure tkr is properly installed and updated."
        exit 1
    fi
}

# Detect the environment management system in use
detect_environment() {
    # Priority order: direnv > devbox > mise > nix > nvm > poetry > pipenv > uv > asdf > docker-compose > native
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
        "nvm")
            echo "NVM (.nvmrc detected)"
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
            echo "Asdf (.asdf-version/.tool-versions detected)"
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

# Check if using preferred environment (devbox) and warn if not
check_preferred_environment() {
    local env=$(detect_environment)
    if [[ "$env" != "devbox" ]]; then
        print_warning "⚠️  Preferred environment is Devbox, but detected: $env"
        print_warning "Consider using Devbox for optimal experience:"
        case "$env" in
            "direnv")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add rust cargo just"
                echo "  - Run commands: devbox run -- <command>"
                ;;
            "mise")
                echo "  - Create devbox.json: devbox init"
                echo "  - Add packages: devbox add rust cargo just"
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

# Security scanning and caching system
get_cache_dir() {
    echo "${XDG_CACHE_HOME:-$HOME/.cache}/levonk/ai-dev-loop"
}

# Initialize cache directory
init_cache() {
    local cache_dir
    cache_dir=$(get_cache_dir)
    mkdir -p "$cache_dir"
}

# Calculate hash of environment configuration
calc_env_hash() {
    local env="$1"
    local config_file=""
    local hash_input=""

    case "$env" in
        "direnv")
            config_file=".envrc"
            if [[ -f "$config_file" ]]; then
                hash_input="$env:$(sha256sum "$config_file" | cut -d' ' -f1)"
            else
                config_file=".env"
                if [[ -f "$config_file" ]]; then
                    hash_input="$env:$(sha256sum "$config_file" | cut -d' ' -f1)"
                fi
            fi
            ;;
        "devbox")
            config_file="devbox.json"
            ;;
        "mise")
            config_file="mise.toml"
            if [[ ! -f "$config_file" ]]; then
                config_file=".mise.toml"
            fi
            ;;
        "nix")
            config_file="flake.nix"
            ;;
        "nvm")
            config_file=".nvmrc"
            ;;
        "poetry")
            config_file="pyproject.toml"
            ;;
        "pipenv")
            config_file="Pipfile"
            ;;
        "uv")
            config_file="uv.lock"
            ;;
        "pip")
            config_file="requirements.txt"
            ;;
        "pyenv")
            config_file=".python-version"
            ;;
        "asdf")
            config_file=".tool-versions"
            ;;
        "docker-compose")
            config_file="docker-compose.yml"
            if [[ ! -f "$config_file" ]]; then
                config_file="docker-compose.yaml"
            fi
            ;;
        "devcontainer")
            config_file=".devcontainer/devcontainer.json"
            ;;
        *)
            return 1
            ;;
    esac

    if [[ -f "$config_file" ]]; then
        hash_input="$env:$(sha256sum "$config_file" | cut -d' ' -f1)"
        echo "$hash_input"
    else
        return 1
    fi
}

# Check if environment has been scanned and approved
is_env_scanned() {
    local env="$1"
    local cache_dir
    cache_dir=$(get_cache_dir)
    local env_hash
    env_hash=$(calc_env_hash "$env")

    if [[ -n "$env_hash" && -f "$cache_dir/scanned/$env_hash" ]]; then
        return 0
    else
        return 1
    fi
}

# Mark environment as scanned and approved
mark_env_scanned() {
    local env="$1"
    local cache_dir
    cache_dir=$(get_cache_dir)
    local env_hash
    env_hash=$(calc_env_hash "$env")

    if [[ -n "$env_hash" ]]; then
        mkdir -p "$cache_dir/scanned"
        echo "$(date +%Y-%m-%d_%H:%M:%S): $env environment scanned and approved" > "$cache_dir/scanned/$env_hash"
        print_success "✓ Environment $env marked as safe"
    fi
}

# Perform security scan on environment configuration
scan_environment_security() {
    local env="$1"
    local config_file=""
    local warnings=()
    local errors=()

    print_status "Performing security scan on $env environment..."

    case "$env" in
        "direnv")
            if [[ -f ".envrc" ]]; then
                config_file=".envrc"
                # Scan .envrc for dangerous patterns
                if grep -q "rm -rf" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: 'rm -rf' found in .envrc")
                fi
                if grep -q "eval.*\$(" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: 'eval \$(' found in .envrc - potential command injection")
                fi
                if grep -q "curl.*|" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: 'curl |' found in .envrc - potential pipe injection")
                fi
            elif [[ -f ".env" ]]; then
                config_file=".env"
                # Scan .env for dangerous patterns
                if grep -q "rm -rf" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: 'rm -rf' found in .env")
                fi
            fi
            ;;
        "devbox")
            config_file="devbox.json"
            # Scan devbox.json for suspicious packages
            if grep -q "curl.*http" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in devbox.json packages")
            fi
            ;;
        "mise")
            if [[ -f "mise.toml" ]]; then
                config_file="mise.toml"
            elif [[ -f ".mise.toml" ]]; then
                config_file=".mise.toml"
            fi
            # Scan mise config for suspicious packages
            if [[ -n "$config_file" ]] && grep -q "curl.*http" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in mise config")
            fi
            ;;
        "nix")
            config_file="flake.nix"
            # Scan flake.nix for suspicious inputs
            if grep -q "url.*http://" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in flake.nix")
            fi
            ;;
        "nvm")
            config_file=".nvmrc"
            # Scan .nvmrc for dangerous patterns
            if [[ -f "$config_file" ]]; then
                if grep -q "rm -rf" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: 'rm -rf' found in .nvmrc")
                fi
                if grep -q "eval.*\$(" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: 'eval \$(' found in .nvmrc - potential command injection")
                fi
                if grep -q "curl.*|" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: 'curl |' found in .nvmrc - potential pipe injection")
                fi
                if grep -q "nvm install" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: 'nvm install' found in .nvmrc - consider using specific versions")
                fi
            fi
            ;;
        "poetry")
            config_file="pyproject.toml"
            # Scan pyproject.toml for suspicious packages
            if grep -q "http://" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in pyproject.toml dependencies")
            fi
            ;;
        "pipenv")
            config_file="Pipfile"
            # Scan Pipfile for suspicious packages
            if grep -q "http://" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in Pipfile dependencies")
            fi
            ;;
        "uv")
            config_file="uv.lock"
            # Scan uv.lock for suspicious packages
            if [[ -f "$config_file" ]]; then
                if grep -q "http://" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: HTTP URLs found in uv.lock dependencies")
                fi
                if grep -q "git+http://" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: Insecure Git URLs found in uv.lock")
                fi
            fi
            ;;
        "pip")
            config_file="requirements.txt"
            # Scan requirements.txt for suspicious packages
            if [[ -f "$config_file" ]]; then
                if grep -q "http://" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: HTTP URLs found in requirements.txt dependencies")
                fi
                if grep -q "git+http://" "$config_file" 2>/dev/null; then
                    warnings+=("⚠️  WARNING: Insecure Git URLs found in requirements.txt")
                fi
                if grep -q "rm -rf" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: 'rm -rf' found in requirements.txt")
                fi
            fi
            ;;
        "pyenv")
            config_file=".python-version"
            # Scan .python-version for suspicious versions
            if [[ -f "$config_file" ]]; then
                local version
                version=$(cat "$config_file" 2>/dev/null)
                if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    warnings+=("⚠️  WARNING: Old Python version detected: $version - consider upgrading")
                fi
            fi
            ;;
        "asdf")
            config_file=".tool-versions"
            # Scan .tool-versions for suspicious packages
            if grep -q "nodejs.*http" "$config_file" 2>/dev/null; then
                warnings+=("⚠️  WARNING: HTTP URLs found in .tool-versions")
            fi
            ;;
        "docker-compose")
            if [[ -f "docker-compose.yml" ]]; then
                config_file="docker-compose.yml"
            elif [[ -f "docker-compose.yaml" ]]; then
                config_file="docker-compose.yaml"
            fi
            # Scan docker-compose for security issues
            if [[ -n "$config_file" ]]; then
                if grep -q "privileged.*true" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: privileged containers found")
                fi
                if grep -q "volume.*:/var/run/docker.sock" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: Docker socket mounted in container")
                fi
            fi
            ;;
        "devcontainer")
            config_file=".devcontainer/devcontainer.json"
            # Scan devcontainer.json for security issues
            if [[ -f "$config_file" ]]; then
                if grep -q "privileged.*true" "$config_file" 2>/dev/null; then
                    errors+=("⚠️  DANGEROUS: privileged containers found in devcontainer.json")
                fi
            fi
            ;;
        *)
            print_status "No security scan available for $env environment"
            return 0
            ;;
    esac

    # Report findings
    if [[ ${#errors[@]} -gt 0 ]]; then
        print_error "🚨 SECURITY ERRORS FOUND:"
        for error in "${errors[@]}"; do
            print_error "  $error"
        done
        print_error "Environment scan FAILED. Please fix security issues before proceeding."
        return 1
    fi

    if [[ ${#warnings[@]} -gt 0 ]]; then
        print_warning "⚠️  Security warnings found:"
        for warning in "${warnings[@]}"; do
            print_warning "  $warning"
        done
        print_warning "Proceeding with caution..."
    fi

    print_success "✓ Security scan completed for $env environment"
    return 0
}

# Wrap command with appropriate environment manager
run_command() {
    local env=$(detect_environment)

    # Initialize cache
    init_cache

    # Check if environment has been scanned before
    if ! is_env_scanned "$env"; then
        # Perform security scan
        if ! scan_environment_security "$env"; then
            print_error "Security scan failed. Command execution blocked."
            return 1
        fi

        # Mark as scanned
        mark_env_scanned "$env"
    else
        print_status "✓ Environment $env already scanned and approved"
    fi

    case "$env" in
        "direnv")
            print_status "Running with direnv: $*"
            direnv exec "$@"
            ;;
        "devbox")
            print_status "Running with devbox: $*"
            devbox run -- "$@"
            ;;
        "mise")
            print_status "Running with mise: $*"
            mise exec -- "$@"
            ;;
        "nix")
            print_status "Running with nix: $*"
            nix develop --command "$@"
            ;;
        "nvm")
            print_status "Running with NVM: $*"
            nvm exec "$@"
            ;;
        "poetry")
            print_status "Running with poetry: $*"
            poetry "$@"
            ;;
        "pipenv")
            print_status "Running with pipenv: $*"
            pipenv "$@"
            ;;
        "uv")
            print_status "Running with uv: $*"
            uv "$@"
            ;;
        "pip")
            print_status "Running with pip: $*"
            pip "$@"
            ;;
        "pyenv")
            print_status "Running with pyenv: $*"
            pyenv exec "$@"
            ;;
        "asdf")
            print_status "Running with asdf: $*"
            asdf exec "$@"
            ;;
        "docker-compose")
            print_status "Running with docker-compose: $*"
            docker compose "$@"
            ;;
        "devcontainer")
            print_status "Running with devcontainer: $*"
            code --new-window --folder . "$@"
            ;;
        *)
            print_status "Running natively: $*"
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
        "nvm")
            nvm exec -- command -v "$cmd" &> /dev/null
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
            pyenv exec -- command -v "$cmd" &> /dev/null
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

# Foundation check
foundation_check() {
    print_status "Running foundation checks..."

    # Display environment info and check for preferred environment
    local env_info=$(get_environment_info)
    print_status "Environment: $env_info"
    check_preferred_environment

    # Check git status
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        print_warning "Working directory is not clean"
        git status --short
        echo
    else
        print_success "Working directory is clean"
    fi

    # Check if on main branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        print_warning "You are on $current_branch branch. Consider creating a feature branch."
    else
        print_success "On feature branch: $current_branch"
    fi

    # Check for common quality commands using environment-aware detection
    if command_exists_in_env just; then
        print_status "Running quality checks with just..."
        if run_command just test 2>/dev/null; then
            print_success "Tests passed"
        else
            print_warning "Some tests failed"
        fi

        if run_command just lint 2>/dev/null; then
            print_success "Linting passed"
        else
            print_warning "Linting issues found"
        fi

        if run_command just typecheck 2>/dev/null; then
            print_success "Type checking passed"
        else
            print_warning "Type checking issues found"
        fi
    else
        print_warning "Just command not found in current environment. Skipping quality checks."
    fi

    echo
}

# Get next ready ticket
get_next_ticket() {
    print_step "Step 1: Ticket Selection - Grab next actionable ticket"
    print_status "Getting next ready ticket..."
    local next_ticket=$(tkr ready 2>/dev/null | head -1)
    if [[ -n "$next_ticket" ]]; then
        print_success "Next ticket: $next_ticket"
        echo "$next_ticket"
    else
        print_warning "No ready tickets found"
        echo "No ready tickets"

        # Suggest alternative actions
        echo
        print_status "Suggested actions when no tickets are available:"
        echo "1. Run foundation checks: dev-loop foundation"
        echo "2. Create new tickets for identified work"
        echo "3. Look for improvement opportunities"
        echo "4. Update documentation or create templates"
        echo "5. Address technical debt or refactoring"
        echo
        print_status "Current ticket status:"
        tkr list --status=open 2>/dev/null || echo "  No open tickets"
        echo
        print_status "Consider running 'dev-loop foundation' to ensure system readiness."
        print_status "For detailed investigation, run 'dev-loop --verbose status'"
    fi
}

# Start work on ticket
start_work() {
    local ticket_id="$1"
    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        print_error "Usage: $0 start <ticket-id>"
        exit 1
    fi

    print_step "Step 2: Start Work - Mark ticket as in_progress"
    print_status "Starting work on ticket: $ticket_id"
    tkr start "$ticket_id"
    print_success "Ticket marked as in_progress"

    # Prompt for note
    echo "Add a note about what you're working on (press Enter to skip):"
    read -r note
    if [[ -n "$note" ]]; then
        tkr add-note "$ticket_id" "$note"
        print_success "Note added"
    fi
    
    print_status "Next: Proceed with High Quality, Strategy, Implementation, Verification steps"
    print_status "Use 'dev-loop --verbose validate' when ready to check work quality"
}

# Complete work on ticket
complete_work() {
    local ticket_id="$1"
    local action="${2:-ready}"

    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        print_error "Usage: $0 complete <ticket-id> [ready|close]"
        exit 1
    fi

    print_step "Step 8: Completion - Mark ticket ready/closed"
    print_status "Completing work on ticket: $ticket_id"

    # Run quality checks before completion
    if command -v just &> /dev/null; then
        print_step "Running quality checks before completion"
        local all_passed=true

        print_status "Running tests..."
        if ! just test; then
            print_error "Tests failed - cannot complete ticket"
            print_error "To fix test failures:"
            print_error "1. Review test output above for specific failure details"
            print_error "2. Fix failing tests or update them for new functionality"
            print_error "3. Ensure implementation matches ticket requirements"
            print_error "4. Run 'just test --verbose' for more details"
            print_error "5. Once fixed, retry: dev-loop complete $ticket_id"
            all_passed=false
        fi

        print_status "Running linting..."
        if ! just lint; then
            print_error "Linting failed - cannot complete ticket"
            print_error "To fix linting errors:"
            print_error "1. Review linting output above for specific issues"
            print_error "2. Run 'just lint --fix' if auto-fix is available"
            print_error "3. Manually fix remaining linting issues"
            print_error "4. Consider updating linting rules if needed"
            print_error "5. Once fixed, retry: dev-loop complete $ticket_id"
            all_passed=false
        fi

        print_status "Running type checking..."
        if ! just typecheck; then
            print_error "Type checking failed - cannot complete ticket"
            print_error "To fix type checking errors:"
            print_error "1. Review type error output above for specific issues"
            print_error "2. Add proper type annotations where missing"
            print_error "3. Fix type mismatches or incorrect usage"
            print_error "4. Update type definitions if needed"
            print_error "5. Once fixed, retry: dev-loop complete $ticket_id"
            all_passed=false
        fi

        if [[ "$all_passed" != "true" ]]; then
            print_error "Quality checks failed. Fix issues before completing ticket."
            print_error "Run 'dev-loop --verbose validate' for detailed diagnostics"
            exit 1
        fi

        print_success " All quality checks passed"
    else
        print_warning "Just command not found in current environment. Skipping quality checks."
        print_warning "Manual verification required before completing ticket."
    fi

    echo "Add a completion note (press Enter to skip):"
    read -r note
    if [[ -n "$note" ]]; then
        tkr add-note "$ticket_id" "$note"
        print_success "Note added"
    fi
    
    print_status "Next: Proceed with Steps 10-13 (Assess, Codify, Commit, Loop)"
    if [[ "$action" == "close" ]]; then
        tkr close "$ticket_id"
        print_success "Ticket marked as closed"
    else
        tkr ready "$ticket_id"
        print_success "Ticket marked as ready for review"
    fi
}

# Show ticket status
show_ticket() {
    local ticket_id="$1"
    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        echo "Usage: $0 show <ticket-id>"
        exit 1
    fi

    print_status "Showing ticket details: $ticket_id"
    tkr show "$ticket_id"
}

# List tickets by status
list_tickets() {
    local status="${1:-open}"
    print_status "Listing tickets with status: $status"
    tkr list --status="$status"
}

# Reflection helper
reflection_helper() {
    local ticket_id="$1"
    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        echo "Usage: $0 reflect <ticket-id>"
        exit 1
    fi

    print_status "Reflection helper for ticket: $ticket_id"
    echo
    echo "=== Process Reflection ==="
    echo "What went well in this cycle?"
    echo "What obstacles were encountered?"
    echo "How could the process be improved?"
    echo
    echo "=== Technical Reflection ==="
    echo "What patterns emerged in the code?"
    echo "Are there opportunities for refactoring?"
    echo "What technical debt was discovered?"
    echo
    echo "=== Documentation Reflection ==="
    echo "What documentation needs updating?"
    echo "Are there patterns that should be codified?"
    echo "What decisions need to be recorded?"
    echo
    echo "=== Tooling Reflection ==="
    echo "Were the right tools available?"
    echo "Are there missing commands or workflows?"
    echo "Could automation improve the process?"
    echo
    echo "=== Opportunity Identification ==="
    echo "Boilerplate opportunities (repeated patterns)?"
    echo "Workflow opportunities (automation potential)?"
    echo "Skill opportunities (expertise to codify)?"
    echo "Template opportunities (reusable structures)?"
    echo
    echo "Enter your reflection (press Ctrl+D when done):"

    local reflection=""
    while IFS= read -r line; do
        reflection="$reflection$line\n"
    done

    if [[ -n "$reflection" ]]; then
        tkr add-note "$ticket_id" "Reflection: $reflection"
        print_success "Reflection added to ticket"
    fi
}

# Quick status overview
status_overview() {
    print_status "Development Loop Status Overview"
    echo

    # Current ticket info
    local current_ticket=$(tkr list --status=in_progress --format=short 2>/dev/null | head -1)
    if [[ -n "$current_ticket" ]]; then
        print_success "Currently working on: $current_ticket"
    else
        print_warning "No ticket currently in progress"
    fi

    # Queue status
    local open_count=$(tkr list --status=open --format=count 2>/dev/null || echo "0")
    local ready_count=$(tkr list --status=ready --format=count 2>/dev/null || echo "0")

    echo "Open tickets: $open_count"
    echo "Ready for review: $ready_count"

    # If no tickets, suggest foundation checks
    if [[ "$open_count" == "0" && "$ready_count" == "0" && -z "$current_ticket" ]]; then
        echo
        print_status "No tickets found. Suggested actions:"
        echo "1. Run foundation checks: dev-loop foundation"
        echo "2. Create new tickets for identified work"
        echo "3. Look for improvement opportunities"
        echo "4. Update documentation or create templates"
        echo "5. Address technical debt or refactoring"
    fi

    # Git status
    echo
    print_status "Git Status:"
    git status --short --branch 2>/dev/null || print_warning "Not in a git repository"

    echo
    print_status "Current Workflow Step:"
    if [[ -n "$current_ticket" ]]; then
        echo "  Working on: $current_ticket"
        echo "  Next: Continue with High Quality, Strategy, Implementation, Verification steps"
    else
        echo "  Ready to start: Run 'dev-loop next' to get a ticket"
        echo "  Or run 'dev-loop no-tickets' for foundation-first workflow"
    fi
}

# Handle no tickets scenario
no_tickets_workflow() {
    print_status "No tickets available - running foundation-first workflow"
    echo


    # Step 1: Foundation checks
    foundation_check

    echo
    print_status "Foundation checks complete. Next steps:"
    echo "1. Create new tickets for any work identified"
    echo "2. Look for improvement opportunities in codebase"
    echo "3. Update documentation or create templates"
    echo "4. Address technical debt or refactoring"
    echo "5. Run 'dev-loop status' to check for new tickets"
    echo

    # Show current system status
    print_status "Current system status:"
    echo "  Repository: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'Unknown')"
    echo "  Last commit: $(git log -1 --format='%h %s' 2>/dev/null || echo 'Unknown')"
    echo "  Working directory: $([ -n "$(git status --porcelain 2>/dev/null)" ] && echo 'Dirty' || echo 'Clean')"
}

# Show help
show_help() {
    echo "AI Development Loop Orchestrator"
    echo
    echo "Usage: $0 [--verbose|-v] <command> [options]"
    echo
    echo "Options:"
    echo "  --verbose, -v    Enable verbose output with step-by-step logging"
    echo
    echo "Commands:"
    echo "  foundation     Run foundation checks (Step 0)"
    echo "  next           Get next ready ticket (Step 1)"
    echo "  start <id>     Start work on ticket (Step 2)"
    echo "  verify <id>    Run verification checks (Step 6)"
    echo "  audit <id>     Run ticket audit with coverage validation (Step 7)"
    echo "  complete <id>  Mark ticket as ready (Step 8)"
    echo "  close <id>     Mark ticket as closed (Step 8)"
    echo "  show <id>      Show ticket details"
    echo "  loop           Run iterative development loop"
    echo "  smart-loop     Language-aware development loop"
    echo "  generate-justfile  Generate justfile for project type"
    echo "  env            Show detected environment information"
    echo "  cache-clear    Clear security scan cache"
    echo "  cache-info     Show cache information"
    echo "  validate       Validate work and run checks (alias for verify)"
    echo "  reflect <id>   Reflection helper"
    echo "  status         Show status overview"
    echo "  no-tickets     Handle no tickets scenario"
    echo "  help           Show this help"
    echo
    echo "Examples:"
    echo "  $0 foundation                    # Run foundation checks"
    echo "  $0 --verbose foundation           # Run with detailed step logging"
    echo "  $0 next                          # Get next ticket"
    echo "  $0 start ja-1234                 # Start working on ticket"
    echo "  $0 verify ja-1234                # Run verification checks (Step 6)"
    echo "  $0 audit ja-1234                 # Run ticket audit (Step 7)"
    echo "  $0 --verbose audit ja-1234       # Audit with detailed logging"
    echo "  $0 complete ja-1234               # Mark ticket as ready"
    echo "  $0 --verbose complete ja-1234    # Complete with detailed logging"
    echo "  $0 loop                          # Run development loop"
    echo "  $0 smart-loop                     # Run language-aware loop"
    echo "  $0 generate-justfile              # Generate project justfile"
    echo "  $0 env                           # Show environment info"
    echo "  $0 cache-clear                   # Clear cache"
    echo "  $0 cache-info                    # Show cache info"
    echo "  $0 reflect ja-1234                # Add reflection notes"
    echo "  $0 no-tickets                    # Handle no tickets scenario"
    echo
    echo "For detailed step-by-step execution, add --verbose to any command."
    echo "The script will provide in-situ instructions for any errors encountered."
}

# Foundation check
foundation_check() {
    print_step "Step 0: Foundation Check - Ensuring clean starting state"
    print_status "Running foundation checks..."

    # Check if ticketr is available
    print_step "Checking ticketr CLI availability"
    check_ticketr

    # Initialize cache
    print_step "Initializing security cache"
    init_cache

    # Check if environment has been scanned before
    if ! is_env_scanned "native"; then
        print_step "Performing security scan on environment"
        # Perform security scan
        if ! scan_environment_security "native"; then
            print_error "Security scan failed. Command execution blocked."
            print_error "Detailed instructions:"
            print_error "1. Review the security scan output above"
            print_error "2. Fix identified security issues in configuration files"
            print_error "3. Remove dangerous commands or patterns"
            print_error "4. Use HTTPS URLs for package dependencies"
            print_error "5. Run 'dev-loop cache-clear' and retry"
            return 1
        fi

        # Mark as scanned
        mark_env_scanned "native"
        print_success "✓ Environment security scan passed"
    else
        print_status "✓ Environment native already scanned and approved"
    fi

    # Check if required commands exist
    print_step "Checking required toolchain commands"
    if ! command_exists_in_env rustc; then
        print_error "rustc command not found. Please install Rust toolchain."
        print_error "Installation instructions:"
        print_error "1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        print_error "2. Restart your shell or source ~/.cargo/env"
        print_error "3. Verify installation: rustc --version"
        exit 1
    fi

    if ! command_exists_in_env just; then
        print_error "just command not found. Please install just."
        print_error "Installation instructions:"
        print_error "1. Install just: cargo install just"
        print_error "2. Verify installation: just --version"
        exit 1
    fi

    if ! command_exists_in_env cargo; then
        print_error "cargo command not found. Please install Rust toolchain."
        print_error "Installation instructions:"
        print_error "1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        print_error "2. Restart your shell or source ~/.cargo/env"
        print_error "3. Verify installation: cargo --version"
        exit 1
    fi

    print_success "✓ Foundation checks completed"
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

# Language-aware development loop
language_aware_loop() {
    local project_type
    project_type=$(detect_project_type)

    if [[ "$project_type" == "unknown" ]]; then
        print_error "Unknown project type detected. Falling back to generic loop."
        iterative_development_loop
        return 1
    fi

    log_step "Detected $project_type project, using language-specific helper"

    # Get the appropriate helper script path
    local helper_script
    helper_script=$(get_helper_script "$project_type")

    if [[ ! -f "$helper_script" ]]; then
        print_error "Helper script not found for $project_type projects"
        exit 1
    fi

    log_step "Running $project_type development loop"

    # Execute the language-specific helper script with all arguments passed through
    "$helper_script" "$@"
}

# Iterative development loop using justfile targets
iterative_development_loop() {
    print_status "Starting iterative development loop..."

    # Check for preferred environment
    check_preferred_environment

    # Define standard targets in order
    local targets=("install" "build" "lint" "test" "dev" "e2e")
    local failed_target=""

    # Check if justfile exists
    if [[ ! -f "justfile" ]]; then
        print_error "No justfile found. Create one first or use project-adopter skill."
        return 1
    fi

    # Get available targets from justfile using environment-aware execution
    local available_targets
    if command_exists_in_env just; then
        available_targets=$(run_command just --list 2>/dev/null | grep -E '^\s+\w+' | awk '{print $1}' || true)
    else
        print_error "Just command not available in current environment"
        return 1
    fi

    for target in "${targets[@]}"; do
        # Check if target exists in justfile
        if echo "$available_targets" | grep -q "^$target$"; then
            print_status "Running: just $target"

            if run_command just "$target"; then
                print_success "✓ $target completed successfully"
            else
                print_error "✗ $target failed"
                failed_target="$target"
                break
            fi
        else
            print_warning "Target '$target' not found in justfile, skipping..."
        fi
    done

    if [[ -n "$failed_target" ]]; then
        local env=$(detect_environment)
        print_warning "Loop failed at '$failed_target'. Restarting from install..."
        print_status "You can manually retry with: run_command just $failed_target"
        case "$env" in
            "devbox")
                echo "  Or: just $failed_target (auto-detects devbox via _devbox helper)"
                ;;
            "mise")
                echo "  Or: mise exec -- just $failed_target"
                ;;
            "nix")
                echo "  Or: nix develop --command just $failed_target"
                ;;
        esac
        return 1
    fi

    print_success "🎉 Development loop completed successfully!"
}

# Language-aware loop helper
language_aware_loop() {
    print_status "Detecting project type and running appropriate loop..."

    # Try to detect project type and use language-specific helper
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check for Node.js project
    if [[ -f "package.json" ]] || [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]]; then
        if [[ -f "$script_dir/node-loop-helper.sh" ]]; then
            print_status "Node.js project detected, using node-loop-helper..."
            "$script_dir/node-loop-helper.sh" run-loop
            return $?
        fi
    fi

    # Fall back to generic justfile loop
    print_status "Using generic justfile loop..."
    iterative_development_loop
}

# Generate justfile based on project detection
generate_project_justfile() {
    print_status "Generating justfile based on project detection..."

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check for Node.js project first (use node-loop-helper for Node.js-specific logic)
    if [[ -f "package.json" ]] || [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]]; then
        if [[ -f "$script_dir/node-loop-helper.sh" ]]; then
            print_status "Node.js project detected, using node-loop-helper..."
            "$script_dir/node-loop-helper.sh" update-justfile
            return $?
        fi
    fi

    # Try to use project-adopter for comprehensive project detection
    local adopter_script="../project-adopter/scripts/adopt-project.sh"
    if [[ -f "$adopter_script" ]]; then
        print_status "Using project-adopter for comprehensive project detection..."
        "$adopter_script" --justfile-only "$(pwd)"
        return $?
    fi

    print_error "Could not detect project type or find appropriate generator"
    return 1
}

# Step 6: Verification - Add/update/run tests and validate implementation
run_verification() {
    local ticket_id="$1"
    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        print_error "Usage: $0 verify <ticket-id>"
        exit 1
    fi

    print_step "Step 6: Verification - Add/update/run tests and validate implementation"
    print_status "Running comprehensive verification for ticket: $ticket_id"

    # Run test suite
    print_step "Running test suite"
    if command -v just &> /dev/null; then
        if just test; then
            print_success "✓ Tests passed"
        else
            print_error "Tests failed"
            print_error "To fix test failures:"
            print_error "1. Review test output above for specific failure details"
            print_error "2. Fix failing tests or update them for new functionality"
            print_error "3. Ensure implementation matches ticket requirements"
            print_error "4. Run 'just test --verbose' for more details"
            return 1
        fi
    else
        print_warning "Just command not found. Manual testing required."
    fi

    # Run linting
    print_step "Running linting checks"
    if command -v just &> /dev/null; then
        if just lint; then
            print_success "✓ Linting passed"
        else
            print_error "Linting failed"
            print_error "To fix linting errors:"
            print_error "1. Review linting output above for specific issues"
            print_error "2. Run 'just lint --fix' if auto-fix is available"
            print_error "3. Manually fix remaining linting issues"
            return 1
        fi
    else
        print_warning "Just command not found. Manual linting required."
    fi

    # Run type checking
    print_step "Running type checking"
    if command -v just &> /dev/null; then
        if just typecheck; then
            print_success "✓ Type checking passed"
        else
            print_error "Type checking failed"
            print_error "To fix type checking errors:"
            print_error "1. Review type error output above for specific issues"
            print_error "2. Add proper type annotations where missing"
            print_error "3. Fix type mismatches or incorrect usage"
            return 1
        fi
    else
        print_warning "Just command not found. Manual type checking required."
    fi

    print_success "✓ Verification completed successfully"
    print_status "Ready for ticket audit (Step 7)"
}

# Step 7: Ticket Audit - Coverage validation against ticket requirements
run_ticket_audit() {
    local ticket_id="$1"
    if [[ -z "$ticket_id" ]]; then
        print_error "Ticket ID required"
        print_error "Usage: $0 audit <ticket-id>"
        exit 1
    fi

    print_step "Step 7: Ticket Audit - Coverage validation (90%+ threshold)"
    print_status "Running ticket audit for: $ticket_id"

    # Get ticket details
    local ticket_details
    ticket_details=$(tkr show "$ticket_id" 2>/dev/null)
    if [[ -z "$ticket_details" ]]; then
        print_error "Could not retrieve ticket details for: $ticket_id"
        print_error "Please verify the ticket ID exists and try again"
        return 1
    fi

    # Validate ticket has required fields
    if ! echo "$ticket_details" | grep -q "^title:"; then
        print_error "Ticket $ticket_id appears to be malformed (missing title)"
        return 1
    fi

    print_status "Analyzing ticket requirements..."
    
    # Extract key information from ticket
    local title
    local description
    title=$(echo "$ticket_details" | grep -E "^title:" | cut -d: -f2- | sed 's/^ *//' || echo "Unknown")
    description=$(echo "$ticket_details" | grep -A 20 "^description:" | grep -v "^description:" | grep -v "^#" | head -10 | sed '/^$/d' || echo "No description")

    print_status "Ticket: $title"
    print_status "Requirements analysis:"

    # Automated coverage checks
    local coverage_score=0
    local max_score=100
    local issues_found=()

    # Check 1: Tests exist and pass
    print_step "Checking test coverage"
    if command -v just &> /dev/null && just test &>/dev/null; then
        print_success "✓ Tests exist and pass (+30 points)"
        ((coverage_score+=30))
    else
        print_error "✗ Tests missing or failing (-30 points)"
        issues_found+=("Tests missing or failing")
    fi

    # Check 2: Code quality (linting)
    print_step "Checking code quality"
    if command -v just &> /dev/null && just lint &>/dev/null; then
        print_success "✓ Code quality checks pass (+20 points)"
        ((coverage_score+=20))
    else
        print_error "✗ Code quality issues detected (-20 points)"
        issues_found+=("Code quality issues")
    fi

    # Check 3: Type safety
    print_step "Checking type safety"
    if command -v just &> /dev/null && just typecheck &>/dev/null; then
        print_success "✓ Type checking passes (+20 points)"
        ((coverage_score+=20))
    else
        print_error "✗ Type safety issues detected (-20 points)"
        issues_found+=("Type safety issues")
    fi

    # Check 4: Documentation
    print_step "Checking documentation"
    local doc_files=0
    if [[ -f "README.md" ]] || [[ -f "docs/"* ]]; then
        doc_files=$(find . -name "*.md" -type f | wc -l)
        if [[ $doc_files -gt 0 ]]; then
            print_success "✓ Documentation exists ($doc_files markdown files) (+15 points)"
            ((coverage_score+=15))
        fi
    else
        print_warning "⚠ Limited documentation found (-15 points)"
        ((coverage_score-=15))
        issues_found+=("Limited documentation")
    fi

    # Check 5: Git status (clean working directory)
    print_step "Checking git status"
    if git rev-parse --git-dir &>/dev/null; then
        local git_status
        git_status=$(git status --porcelain 2>/dev/null)
        if [[ -z "$git_status" ]]; then
            print_success "✓ Clean git working directory (+15 points)"
            ((coverage_score+=15))
        else
            print_warning "⚠ Uncommitted changes detected (-15 points)"
            ((coverage_score-=15))
            issues_found+=("Uncommitted changes")
        fi
    else
        print_warning "⚠ Not in a git repository (-15 points)"
        ((coverage_score-=15))
        issues_found+=("Not in git repository")
    fi

    # Calculate final score and provide results
    echo
    print_status "=== AUDIT RESULTS ==="
    print_status "Coverage Score: $coverage_score/$max_score"
    
    if [[ $coverage_score -ge 90 ]]; then
        print_success "✓ PASSED: Coverage meets 90%+ threshold"
        print_status "Ticket is ready for completion"
    elif [[ $coverage_score -ge 70 ]]; then
        print_warning "⚠ PARTIAL: Coverage $coverage_score% (needs 90%+)"
        print_status "Some improvements needed before completion"
    else
        print_error "✗ FAILED: Coverage $coverage_score% (below 70%)"
        print_status "Significant improvements required"
    fi

    # Report issues found
    if [[ ${#issues_found[@]} -gt 0 ]]; then
        echo
        print_status "Issues to address:"
        for issue in "${issues_found[@]}"; do
            print_error "  • $issue"
        done
    fi

    # Add audit note to ticket
    local audit_note="Audit completed: $coverage_score% coverage"
    if [[ ${#issues_found[@]} -gt 0 ]]; then
        audit_note="$audit_note. Issues: $(IFS=', '; echo "${issues_found[*]}")"
    fi
    
    echo
    print_status "Adding audit results to ticket..."
    tkr add-note "$ticket_id" "$audit_note"
    print_success "Audit note added to ticket"

    # Return appropriate exit code
    if [[ $coverage_score -ge 90 ]]; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    local command="${1:-help}"
    
    # Check for verbose flag
    if [[ "$command" == "--verbose" ]] || [[ "$command" == "-v" ]]; then
        VERBOSE=true
        print_status "Verbose mode enabled"
        shift
        command="${1:-help}"
    fi

    case "$command" in
        "foundation")
            foundation_check
            ;;
        "next")
            check_ticketr
            get_next_ticket
            ;;
        "start")
            check_ticketr
            start_work "$2"
            ;;
        "complete"|"ready")
            check_ticketr
            complete_work "$2" "ready"
            ;;
        "close")
            check_ticketr
            complete_work "$2" "close"
            ;;
        "show")
            check_ticketr
            show_ticket "$2"
            ;;
        "list")
            check_ticketr
            list_tickets "$2"
            ;;
        "loop")
            iterative_development_loop
            ;;
        "smart-loop")
            language_aware_loop
            ;;
        "generate-justfile")
            generate_project_justfile
            ;;
        "validate")
            check_ticketr
            run_verification "$2"
            ;;
        "audit")
            check_ticketr
            run_ticket_audit "$2"
            ;;
        "verify")
            check_ticketr
            run_verification "$2"
            ;;
        "env"|"environment")
            local env_info=$(get_environment_info)
            print_status "Detected environment: $env_info"
            local env=$(detect_environment)
            print_status "Command wrapper: $env"
            local cache_dir
            cache_dir=$(get_cache_dir)
            print_status "Cache directory: $cache_dir"
            if is_env_scanned "$env"; then
                print_success "✓ Environment already scanned and approved"
            else
                print_warning "⚠️  Environment not yet scanned - will scan on first command"
            fi
            ;;
        "cache-clear")
            local cache_dir
            cache_dir=$(get_cache_dir)
            if [[ -d "$cache_dir" ]]; then
                rm -rf "$cache_dir"
                print_success "✓ Cache cleared: $cache_dir"
            else
                print_warning "Cache directory not found: $cache_dir"
            fi
            ;;
        "cache-info")
            local cache_dir
            cache_dir=$(get_cache_dir)
            print_status "Cache directory: $cache_dir"
            if [[ -d "$cache_dir" ]]; then
                local scanned_count
                scanned_count=$(find "$cache_dir/scanned" -type f 2>/dev/null | wc -l)
                print_status "Scanned environments: $scanned_count"
                print_status "Cache size: $(du -sh "$cache_dir" 2>/dev/null | cut -f1)"
            else
                print_warning "Cache directory not found"
            fi
            ;;
        "reflect")
            check_ticketr
            reflection_helper "$2"
            ;;
        "status")
            check_ticketr
            status_overview
            ;;
        "no-tickets")
            no_tickets_workflow
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
