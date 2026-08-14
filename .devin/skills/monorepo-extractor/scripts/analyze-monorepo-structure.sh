#!/bin/bash
# Analyze monorepo structure and identify shared resources and dependencies
# Intelligently detects shared configuration and build system files

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

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME

Arguments:
    MONOREPO_PATH    Path to the monorepo to analyze
    PROJECT_NAME     Name of the project to extract

Options:
    -v, --verbose    Show detailed analysis output
    -o, --output     Output analysis to JSON file
    -h, --help       Show this help message

Examples:
    $0 /opt/company-monorepo webapp
    $0 --verbose --output analysis.json ~/projects/company-monorepo shared-utils
EOF
}

# Shared resource patterns and their analysis functions
declare -A SHARED_RESOURCES=(
    [".envrc"]="analyze_direnv"
    ["pnpm-workspace.yaml"]="analyze_pnpm_workspace"
    ["pnpm-workspaces.yml"]="analyze_pnpm_workspace"
    ["package.json"]="analyze_package_json"
    ["flake.nix"]="analyze_nix_flake"
    ["devbox.json"]="analyze_devbox"
    ["pom.xml"]="analyze_maven"
    ["WORKSPACE"]="analyze_bazel"
    ["pants.toml"]="analyze_pants"
    ["nx.json"]="analyze_nx"  # Preferred per ADR 20260419001
    ["turbo.json"]="analyze_turbo"  # Legacy - superseded by NX
    ["lerna.json"]="analyze_lerna"
    ["rush.json"]="analyze_rush"
    ["Cargo.toml"]="analyze_cargo_workspace"
    ["pyproject.toml"]="analyze_python_workspace"
    ["go.mod"]="analyze_go_workspace"
    ["Makefile"]="analyze_makefile"
    ["Justfile"]="analyze_justfile"
)

analyze_direnv() {
    local file="$1"
    local project="$2"

    log_info "Analyzing .envrc configuration"

    if [[ -f "$file" ]]; then
        echo "  Found .envrc with direnv configuration"

        # Check for project-specific paths
        if grep -q "$project" "$file"; then
            echo "  ⚠️  .envrc contains project-specific references"
            echo "    Project references: $(grep "$project" "$file" | cut -d: -f2 | tr -d ' ')"
        fi

        # Check for shared environment setup
        if grep -q "use nix\|export PATH\|watch_file" "$file"; then
            echo "  ✓ Contains shared environment setup"
        fi

        return 0
    fi
}

analyze_pnpm_workspace() {
    local file="$1"
    local project="$2"

    log_info "Analyzing pnpm workspace configuration"

    if [[ -f "$file" ]]; then
        echo "  Found pnpm workspace configuration"

        # Extract workspace packages
        local workspace_packages
        workspace_packages=$(grep -A 10 "packages:" "$file" | grep -E "^\s*-" | sed 's/.*"\(.*\)".*/\1/' || true)

        if [[ -n "$workspace_packages" ]]; then
            echo "  Workspace packages:"
            echo "$workspace_packages" | while read -r pkg; do
                if [[ "$pkg" == *"$project"* ]]; then
                    echo "    ✓ Target project: $pkg"
                else
                    echo "    - Other project: $pkg"
                fi
            done
        fi

        return 0
    fi
}

analyze_package_json() {
    local file="$1"
    local project="$2"

    log_info "Analyzing package.json for workspace configuration"

    if [[ -f "$file" ]]; then
        # Check for workspace configuration
        if jq -e '.workspaces' "$file" >/dev/null 2>&1; then
            echo "  Found npm/yarn workspace configuration"

            local workspaces
            workspaces=$(jq -r '.workspaces[]? // empty' "$file" 2>/dev/null || true)

            if [[ -n "$workspaces" ]]; then
                echo "  Workspace directories:"
                echo "$workspaces" | while read -r ws; do
                    if [[ "$ws" == *"$project"* ]]; then
                        echo "    ✓ Target project: $ws"
                    else
                        echo "    - Other workspace: $ws"
                    fi
                done
            fi
        fi

        # Check for shared scripts
        local shared_scripts
        shared_scripts=$(jq -r '.scripts | keys[]' "$file" 2>/dev/null | grep -E "^(bootstrap|build|lint|test|deploy|doctor|typecheck|install|run)" || true)

        if [[ -n "$shared_scripts" ]]; then
            echo "  Shared scripts found:"
            echo "$shared_scripts" | while read -r script; do
                echo "    - $script"
            done
        fi

        return 0
    fi
}

analyze_nix_flake() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Nix flake configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Nix flake"

        # Check for project references
        if grep -q "$project" "$file"; then
            echo "  ⚠️  Flake contains project-specific references"
        fi

        # Check for shared outputs
        if grep -q "devShells\|packages\|apps" "$file"; then
            echo "  ✓ Contains shared development environment"
        fi

        return 0
    fi
}

analyze_devbox() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Devbox configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Devbox configuration"

        # Check for shared packages
        local shared_packages
        shared_packages=$(jq -r '.packages | keys[]' "$file" 2>/dev/null || true)

        if [[ -n "$shared_packages" ]]; then
            echo "  Shared Devbox packages found"
        fi

        return 0
    fi
}

analyze_maven() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Maven multi-module configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Maven POM"

        # Check for modules
        if grep -q "<modules>" "$file"; then
            echo "  Maven multi-module project detected"

            local modules
            modules=$(grep -A 20 "<modules>" "$file" | grep "<module>" | sed 's/.*<module>\(.*\)<\/module>.*/\1/' || true)

            if [[ -n "$modules" ]]; then
                echo "  Maven modules:"
                echo "$modules" | while read -r module; do
                    if [[ "$module" == *"$project"* ]]; then
                        echo "    ✓ Target project: $module"
                    else
                        echo "    - Other module: $module"
                    fi
                done
            fi
        fi

        return 0
    fi
}

analyze_bazel() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Bazel workspace configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Bazel WORKSPACE file"

        return 0
    fi
}

analyze_pants() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Pants build system configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Pants configuration"

        return 0
    fi
}

analyze_turbo() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Turbo monorepo configuration (legacy - superseded by NX per ADR 20260419001)"

    if [[ -f "$file" ]]; then
        echo "  ⚠ Found Turbo configuration (legacy - consider migrating to NX)"

        # Check for pipeline configuration
        if jq -e '.pipeline' "$file" >/dev/null 2>&1; then
            echo "  Turbo pipelines found:"
            jq -r '.pipeline | keys[]' "$file" 2>/dev/null | while read -r pipeline; do
                echo "    - $pipeline"
            done
        fi

        return 0
    fi
}

analyze_nx() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Nx monorepo configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Nx configuration"

        return 0
    fi
}

analyze_lerna() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Lerna monorepo configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Lerna configuration"

        return 0
    fi
}

analyze_rush() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Rush monorepo configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Rush configuration"

        return 0
    fi
}

analyze_cargo_workspace() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Cargo workspace configuration"

    if [[ -f "$file" ]]; then
        if grep -q "\[workspace\]" "$file"; then
            echo "  Found Cargo workspace"

            local members
            members=$(grep -A 10 "members" "$file" | grep '"' | sed 's/.*"\(.*\)".*/\1/' || true)

            if [[ -n "$members" ]]; then
                echo "  Workspace members:"
                echo "$members" | while read -r member; do
                    if [[ "$member" == *"$project"* ]]; then
                        echo "    ✓ Target project: $member"
                    else
                        echo "    - Other member: $member"
                    fi
                done
            fi
        fi

        return 0
    fi
}

analyze_python_workspace() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Python workspace configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Python project configuration"

        return 0
    fi
}

analyze_go_workspace() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Go workspace configuration"

    if [[ -f "$file" ]]; then
        echo "  Found Go module"

        return 0
    fi
}

analyze_makefile() {
    local file="$1"
    local project="$2"

    log_info "Analyzing Makefile for shared targets"

    if [[ -f "$file" ]]; then
        echo "  Found Makefile with shared targets"

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

    if [[ -f "$detection_path/scripts/detect-build-systems.sh" ]]; then
        source "$detection_path/scripts/detect-build-systems.sh"
    else
        log_error "detect-build-systems.sh not found in project-detection skill"
        return 1
    fi

    if [[ -f "$detection_path/scripts/detect-ci-cd-systems.sh" ]]; then
        source "$detection_path/scripts/detect-ci-cd-systems.sh"
    else
        log_error "detect-ci-cd-systems.sh not found in project-detection skill"
        return 1
    fi

    if [[ -f "$detection_path/scripts/analyze-workspace-configs.sh" ]]; then
        source "$detection_path/scripts/analyze-workspace-configs.sh"
    else
        log_error "analyze-workspace-configs.sh not found in project-detection skill"
        return 1
    fi
}

analyze_monorepo_structure() {
    local repo_path="$1"
    local project_name="$2"
    local verbose="${3:-false}"

    cd "$repo_path"

    log_step "Analyzing monorepo structure"

    # Source project detection scripts
    source_project_detection

    # Detect all systems
    log_info "Detecting build systems and tooling..."
    local build_systems
    build_systems=$(detect_systems "$repo_path" "$verbose")

    log_info "Detecting CI/CD systems..."
    local ci_cd_systems
    ci_cd_systems=$(detect_ci_cd_systems "$repo_path" "$verbose")

    log_info "Analyzing workspace configurations..."
    local workspace_analysis
    workspace_analysis=$(analyze_workspace_configs "$repo_path" "$project_name" "$verbose")

    # Analyze project structure
    log_info "Analyzing project directory structure..."
    local project_dirs
    project_dirs=$(find . -maxdepth 3 -type d -name "$project_name" 2>/dev/null || true)

    # Find shared resources
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
            echo "  $system"
        done
    else
        echo "  No build systems detected"
    fi
    echo

    echo "CI/CD Systems Detected:"
    if [[ -n "$ci_cd_systems" ]]; then
        for system in $ci_cd_systems; do
            echo "  $system"
        done
    else
        echo "  No CI/CD systems detected"
    fi
    echo

    if [[ -n "$workspace_analysis" ]]; then
        echo "Workspace Analysis:"
        echo "$workspace_analysis"
        echo
    fi

    echo "Project Directories Found:"
    if [[ -n "$project_dirs" ]]; then
        echo "$project_dirs" | while read -r dir; do
            echo "  $dir"
        done
    else
        echo "  No project directories found matching '$project_name'"
    fi
    echo

    echo "Shared Resources (${#shared_resources[@]}):"
    if [[ ${#shared_resources[@]} -gt 0 ]]; then
        for resource in "${shared_resources[@]}"; do
            echo "  $resource"
        done
    else
        echo "  No shared resources found"
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
                echo "Analyze monorepo structure and shared resources"
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
    if [[ -n "$output_file" ]]; then
        generate_analysis_report "$monorepo_path" "$project_name" "$output_file"
    fi

    echo
    log_info "Analysis completed successfully"
}

# Run analysis if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
