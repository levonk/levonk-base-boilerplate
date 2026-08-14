#!/bin/bash
# Detect all systems in a project (build systems, CI/CD, workspace configs)
# Main entry point for project detection

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

log_step() {
    echo -e "${BLUE}STEP:${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source detection scripts
source "$SCRIPT_DIR/detect-build-systems.sh"
source "$SCRIPT_DIR/detect-ci-cd-systems.sh"
source "$SCRIPT_DIR/analyze-workspace-configs.sh"

detect_all_systems() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"
    local format="${3:-human}"
    local project_name="${4:-}"
    
    cd "$repo_path"
    
    log_step "Detecting all systems in: $repo_path"
    
    # Detect build systems
    local build_systems
    build_systems=$(detect_systems "$repo_path" "$verbose")
    
    # Detect CI/CD systems
    local ci_cd_systems
    ci_cd_systems=$(detect_ci_cd_systems "$repo_path" "$verbose")
    
    # Analyze workspace configurations
    local workspace_analysis=""
    if [[ -n "$project_name" ]]; then
        workspace_analysis=$(analyze_workspace_configs "$repo_path" "$project_name" "$verbose")
    fi
    
    # Output results
    case "$format" in
        "json")
            echo "{"
            echo "  \"build_systems\": [$(echo "$build_systems" | sed 's/[^[:space:]]\+/"&"/g' | sed 's/ /, /g')],"
            echo "  \"ci_cd_systems\": [$(echo "$ci_cd_systems" | sed 's/[^[:space:]]\+/"&"/g' | sed 's/ /, /g')]"
            if [[ -n "$workspace_analysis" ]]; then
                echo "  \"workspace_analysis\": \"$workspace_analysis\""
            fi
            echo "}"
            ;;
        "human"|*)
            echo "=== Detection Results ==="
            echo
            echo "Build Systems:"
            if [[ -n "$build_systems" ]]; then
                for system in $build_systems; do
                    echo "  ✓ $system"
                done
            else
                echo "  ✗ No build systems detected"
            fi
            echo
            echo "CI/CD Systems:"
            if [[ -n "$ci_cd_systems" ]]; then
                for system in $ci_cd_systems; do
                    echo "  ✓ $system"
                done
            else
                echo "  ✗ No CI/CD systems detected"
            fi
            echo
            if [[ -n "$workspace_analysis" ]]; then
                echo "Workspace Analysis:"
                echo "$workspace_analysis"
            fi
            ;;
    esac
}

main() {
    local repo_path="."
    local verbose=false
    local format="human"
    local project_name=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -p|--project)
                project_name="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS] [REPO_PATH]"
                echo "Detect all systems in a project"
                echo
                echo "Options:"
                echo "  -v, --verbose    Show detailed detection output"
                echo "  -f, --format     Output format (human|json)"
                echo "  -p, --project    Project name for workspace analysis"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                if [[ "$repo_path" == "." ]]; then
                    repo_path="$1"
                else
                    echo "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path does not exist: $repo_path"
        exit 1
    fi
    
    detect_all_systems "$repo_path" "$verbose" "$format" "$project_name"
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
