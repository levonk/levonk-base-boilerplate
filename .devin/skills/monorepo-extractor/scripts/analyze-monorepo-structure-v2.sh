#!/bin/bash
# Analyze monorepo structure using project-detection skill
# Uses modular detection for comprehensive analysis

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

# Find project-detection skill
find_project_detection_skill() {
    local possible_paths=(
        "$SCRIPT_DIR/../project-detection"
        "$SCRIPT_DIR/../../project-detection"
        "$HOME/.local/share/ai/skills/software-dev/project-detection"
    )

    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done

    log_error "Project detection skill not found"
    return 1
}

# Source project detection scripts
source_project_detection() {
    local detection_path
    detection_path=$(find_project_detection_skill)

    if [[ -f "$detection_path/scripts/detect-all-systems.sh" ]]; then
        source "$detection_path/scripts/detect-all-systems.sh"
    else
        log_error "detect-all-systems.sh not found in project-detection skill"
        return 1
    fi
}

analyze_monorepo_structure() {
    local repo_path="$1"
    local project_name="$2"
    local verbose="${3:-false}"

    cd "$repo_path"

    log_step "Analyzing monorepo structure using project-detection skill"

    # Source project detection scripts
    source_project_detection

    # Detect all systems using the unified function
    log_info "Running comprehensive detection..."
    local detection_output
    detection_output=$(detect_all_systems "$repo_path" "$verbose" "json" "$project_name" 2>/dev/null | grep -A 10 "^{")

    # Parse JSON output (simple parsing for demonstration)
    local build_systems
    local ci_cd_systems

    build_systems=$(echo "$detection_output" | grep '"build_systems"' | sed 's/.*"build_systems": \[\([^]]*\)\].*/\1/' | sed 's/"//g' | sed 's/,/ /g')
    ci_cd_systems=$(echo "$detection_output" | grep '"ci_cd_systems"' | sed 's/.*"ci_cd_systems": \[\([^]]*\)\].*/\1/' | sed 's/"//g' | sed 's/,/ /g')

    # Find project directories
    log_info "Finding project directories..."
    local project_dirs
    project_dirs=$(find . -maxdepth 3 -type d -name "$project_name" 2>/dev/null || true)

    # Find shared resources (additional analysis)
    log_info "Identifying shared resources..."
    local shared_resources=()

    # Environment configurations
    if [[ -f ".envrc" ]]; then
        shared_resources+=(".envrc (direnv configuration)")
    fi

    if [[ -f ".env" ]]; then
        shared_resources+=(".env (environment variables)")
    fi

    if [[ -f "devbox.json" ]]; then
        shared_resources+=("devbox.json (development environment)")
    fi

    if [[ -f "flake.nix" ]]; then
        shared_resources+=("flake.nix (Nix flakes)")
    fi

    if [[ -f "shell.nix" ]]; then
        shared_resources+=("shell.nix (Nix shell)")
    fi

    # Workspace configurations
    if [[ -f "pnpm-workspace.yaml" ]]; then
        shared_resources+=("pnpm-workspace.yaml (pnpm workspace)")
    fi

    if [[ -f "lerna.json" ]]; then
        shared_resources+=("lerna.json (Lerna monorepo)")
    fi

    if [[ -f "nx.json" ]]; then
        shared_resources+=("nx.json (Nx monorepo - preferred per ADR 20260419001)")
    fi

    if [[ -f "turbo.json" ]]; then
        shared_resources+=("turbo.json (Turborepo - legacy, superseded by NX)")
    fi

    if [[ -f "rush.json" ]]; then
        shared_resources+=("rush.json (Rush monorepo)")
    fi

    # Build configurations
    if [[ -f "package.json" ]]; then
        shared_resources+=("package.json (Node.js configuration)")
    fi

    if [[ -f "Cargo.toml" ]]; then
        shared_resources+=("Cargo.toml (Rust workspace)")
    fi

    if [[ -f "pom.xml" ]]; then
        shared_resources+=("pom.xml (Maven configuration)")
    fi

    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        shared_resources+=("build.gradle (Gradle configuration)")
    fi

    if [[ -f "Makefile" ]]; then
        shared_resources+=("Makefile (Make build system)")
    fi

    if [[ -f "Justfile" ]]; then
        shared_resources+=("Justfile (Just command runner)")
    fi

    # CI/CD configurations
    if [[ -d ".github" ]]; then
        shared_resources+=(".github/ (GitHub Actions)")
    fi

    if [[ -f ".gitlab-ci.yml" ]]; then
        shared_resources+=(".gitlab-ci.yml (GitLab CI)")
    fi

    if [[ -f ".travis.yml" ]]; then
        shared_resources+=(".travis.yml (Travis CI)")
    fi

    if [[ -f "Jenkinsfile" ]]; then
        shared_resources+=("Jenkinsfile (Jenkins)")
    fi

    # Documentation
    if [[ -d "docs" ]]; then
        shared_resources+=("docs/ (documentation)")
    fi

    if [[ -f "README.md" ]]; then
        shared_resources+=("README.md (project documentation)")
    fi

    # Output analysis
    echo "=== Monorepo Structure Analysis ==="
    echo "Repository: $repo_path"
    echo "Target Project: $project_name"
    echo

    echo "Build Systems Detected:"
    if [[ -n "$build_systems" ]]; then
        for system in $build_systems; do
            if [[ -n "$system" ]]; then
                echo "  ✓ $system"
            fi
        done
    else
        echo "  ✗ No build systems detected"
    fi
    echo

    echo "CI/CD Systems Detected:"
    if [[ -n "$ci_cd_systems" ]]; then
        for system in $ci_cd_systems; do
            if [[ -n "$system" ]]; then
                echo "  ✓ $system"
            fi
        done
    else
        echo "  ✗ No CI/CD systems detected"
    fi
    echo

    echo "Project Directories Found:"
    if [[ -n "$project_dirs" ]]; then
        echo "$project_dirs" | while read -r dir; do
            echo "  📁 $dir"
        done
    else
        echo "  ✗ No project directories found matching '$project_name'"
    fi
    echo

    echo "Shared Resources (${#shared_resources[@]}):"
    if [[ ${#shared_resources[@]} -gt 0 ]]; then
        for resource in "${shared_resources[@]}"; do
            echo "  📄 $resource"
        done
    else
        echo "  ✗ No shared resources found"
    fi
    echo

    # Recommendations
    echo "=== Recommendations ==="

    if [[ ${#shared_resources[@]} -eq 0 ]]; then
        log_warn "No shared resources detected - project may be standalone"
    fi

    if [[ -n "$build_systems" ]]; then
        log_info "Build systems detected - ensure compatibility in extracted repository"
    fi

    if [[ -n "$ci_cd_systems" ]]; then
        log_info "CI/CD systems detected - update workflows for single-project structure"
    fi

    if [[ -z "$project_dirs" ]]; then
        log_warn "Target project directory not found - verify project name"
    fi

    # Export results for other scripts
    export MONOREPO_BUILD_SYSTEMS="$build_systems"
    export MONOREPO_CI_CD_SYSTEMS="$ci_cd_systems"
    export MONOREPO_SHARED_RESOURCES="${shared_resources[*]}"
    export MONOREPO_PROJECT_DIRS="$project_dirs"
}

main() {
    local repo_path=""
    local project_name=""
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME"
                echo "Analyze monorepo structure using project-detection skill"
                echo
                echo "Options:"
                echo "  -v, --verbose    Show detailed analysis output"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                if [[ -z "$repo_path" ]]; then
                    repo_path="$1"
                elif [[ -z "$project_name" ]]; then
                    project_name="$1"
                else
                    log_error "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$repo_path" ]] || [[ -z "$project_name" ]]; then
        log_error "Monorepo path and project name are required"
        exit 1
    fi

    if [[ ! -d "$repo_path" ]]; then
        log_error "Monorepo path does not exist: $repo_path"
        exit 1
    fi

    analyze_monorepo_structure "$repo_path" "$project_name" "$verbose"

    log_info "Monorepo structure analysis completed"
}

# Run analysis if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
