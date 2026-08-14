#!/bin/bash

# AI Development Loop Orchestrator
# Delegates to language-specific helper scripts based on project type detection

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

# Detect project type
detect_project_type() {
    if [[ -f "package.json" ]] && [[ -f "package.json" ]]; then
        echo "node"
    elif [[ -f "pyproject.toml" ]] && [[ -f "pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "Cargo.toml" ]] && [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "go.mod" ]] && [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "CMakeLists.txt" ]] && [[ -f "CMakeLists.txt" ]]; then
        echo "cmake"
    elif [[ -f "Makefile" ]] && [[ -f "Makefile" ]]; then
        echo "make"
    elif [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        echo "docker-compose"
    elif [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        echo "docker-compose"
    else
        echo "unknown"
    fi
}

# Get the appropriate helper script path
get_helper_script() {
    local project_type="$1"
    case "$project_type" in
        "node")
            echo "${0%}/scripts/node-loop-helper.sh"
            ;;
        "python")
            echo "${0%}/scripts/python-loop-helper.sh"
            ;;
        "rust")
            echo "${0%}/scripts/rust-loop-helper.sh"
            ;;
        "go")
            echo "${0%}/scripts/go-loop-helper.sh"
            ;;
        "cmake")
            echo "${0%}/scripts/cmake-loop-helper.sh"
            ;;
        "make")
            echo "${0%}/scripts/make-loop-helper.sh"
            ;;
        "docker-compose")
            echo "${0%}/scripts/docker-compose-helper.sh"
            ;;
        *)
            echo "${0%}/scripts/dev-loop-helper.sh"
            ;;
    esac
}

# Run the appropriate helper script
run_helper() {
    local project_type
    project_type=$(detect_project_type)
    local helper_script
    helper_script=$(get_helper_script "$project_type")
    
    if [[ ! -f "$helper_script" ]]; then
        log_error "Helper script not found: $helper_script"
        exit 1
    fi
    
    log_step "Detected $project_type project, using $helper_script"
    
    # Execute the helper script with all arguments passed through
    "$helper_script" "$@"
}
