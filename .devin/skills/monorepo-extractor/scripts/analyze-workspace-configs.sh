#!/bin/bash
# Analyze workspace configurations and monorepo structures
# Handles pnpm, npm, yarn, cargo, maven, gradle, bazel, pants, etc.

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

# Workspace configuration analyzers
analyze_pnpm_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing pnpm workspace: $file"
    
    # Extract workspace packages
    local workspace_packages
    workspace_packages=$(grep -A 10 "packages:" "$file" | grep -E "^\s*-" | sed 's/.*"\(.*\)".*/\1/' || true)
    
    if [[ -n "$workspace_packages" ]]; then
        echo "  Workspace packages:"
        echo "$workspace_packages" | while read -r pkg; do
            if [[ "$pkg" == *"$target_project"* ]]; then
                echo "    ✓ Target project: $pkg"
            else
                echo "    - Other project: $pkg"
            fi
        done
    fi
    
    # Check for catalog configuration
    if grep -q "catalog:" "$file"; then
        echo "  ✓ Found pnpm catalog configuration"
    fi
    
    return 0
}

analyze_npm_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing npm workspace: $file"
    
    # Check for workspace configuration
    if jq -e '.workspaces' "$file" >/dev/null 2>&1; then
        echo "  Found npm/yarn workspace configuration"
        
        local workspaces
        workspaces=$(jq -r '.workspaces[]? // empty' "$file" 2>/dev/null || true)
        
        if [[ -n "$workspaces" ]]; then
            echo "  Workspace directories:"
            echo "$workspaces" | while read -r ws; do
                if [[ "$ws" == *"$target_project"* ]]; then
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
}

analyze_yarn_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing yarn workspace: $file"
    
    # Yarn workspaces can be defined in package.json
    if jq -e '.workspaces' "$file" >/dev/null 2>&1; then
        echo "  Found yarn workspace configuration"
        
        local workspaces
        workspaces=$(jq -r '.workspaces[]? // empty' "$file" 2>/dev/null || true)
        
        if [[ -n "$workspaces" ]]; then
            echo "  Workspace directories:"
            echo "$workspaces" | while read -r ws; do
                if [[ "$ws" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $ws"
                else
                    echo "    - Other workspace: $ws"
                fi
            done
        fi
    fi
    
    return 0
}

analyze_cargo_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Cargo workspace: $file"
    
    if grep -q "\[workspace\]" "$file"; then
        echo "  Found Cargo workspace"
        
        local members
        members=$(grep -A 10 "members" "$file" | grep '"' | sed 's/.*"\(.*\)".*/\1/' || true)
        
        if [[ -n "$members" ]]; then
            echo "  Workspace members:"
            echo "$members" | while read -r member; do
                if [[ "$member" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $member"
                else
                    echo "    - Other member: $member"
                fi
            done
        fi
        
        # Check for exclude patterns
        local excludes
        excludes=$(grep -A 10 "exclude" "$file" | grep '"' | sed 's/.*"\(.*\)".*/\1/' || true)
        
        if [[ -n "$excludes" ]]; then
            echo "  Excluded members:"
            echo "$excludes" | while read -r exclude; do
                echo "    - $exclude"
            done
        fi
    fi
    
    return 0
}

analyze_maven_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Maven workspace: $file"
    
    # Check for modules
    if grep -q "<modules>" "$file"; then
        echo "  Maven multi-module project detected"
        
        local modules
        modules=$(grep -A 20 "<modules>" "$file" | grep "<module>" | sed 's/.*<module>\(.*\)<\/module>.*/\1/' || true)
        
        if [[ -n "$modules" ]]; then
            echo "  Maven modules:"
            echo "$modules" | while read -r module; do
                if [[ "$module" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $module"
                else
                    echo "    - Other module: $module"
                fi
            done
        fi
    fi
    
    # Check for parent POM references
    if grep -q "<parent>" "$file"; then
        echo "  ✓ Found parent POM configuration"
    fi
    
    return 0
}

analyze_gradle_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Gradle workspace: $file"
    
    # Check for settings.gradle
    if [[ -f "settings.gradle" ]] || [[ -f "settings.gradle.kts" ]]; then
        echo "  ✓ Found Gradle settings file"
        
        local settings_file="settings.gradle"
        if [[ -f "settings.gradle.kts" ]]; then
            settings_file="settings.gradle.kts"
        fi
        
        # Extract included modules
        local modules
        modules=$(grep -E "include\s*['\"]" "$settings_file" | sed "s/.*include\s*['\"]\([^'\"]*\)['\"].*/\1/" || true)
        
        if [[ -n "$modules" ]]; then
            echo "  Included modules:"
            echo "$modules" | while read -r module; do
                if [[ "$module" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $module"
                else
                    echo "    - Other module: $module"
                fi
            done
        fi
    fi
    
    return 0
}

analyze_bazel_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Bazel workspace: $file"
    
    echo "  ✓ Found Bazel WORKSPACE file"
    
    # Check for workspace name
    if grep -q "workspace(" "$file"; then
        local workspace_name
        workspace_name=$(grep "workspace(" "$file" | sed 's/.*workspace(\s*name\s*=\s*"\([^"]*\)".*/\1/' || true)
        if [[ -n "$workspace_name" ]]; then
            echo "  Workspace name: $workspace_name"
        fi
    fi
    
    # Check for load statements
    if grep -q "load(" "$file"; then
        echo "  ✓ Found Bazel load statements"
    fi
    
    return 0
}

analyze_pants_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Pants workspace: $file"
    
    echo "  ✓ Found Pants configuration"
    
    # Check for source roots
    if grep -q "source_root" "$file"; then
        echo "  ✓ Found source root configuration"
    fi
    
    return 0
}

analyze_nx_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Nx workspace: $file"
    
    echo "  ✓ Found Nx configuration"
    
    # Check for projects
    if jq -e '.projects' "$file" >/dev/null 2>&1; then
        local projects
        projects=$(jq -r '.projects | keys[]' "$file" 2>/dev/null || true)
        
        if [[ -n "$projects" ]]; then
            echo "  Nx projects:"
            echo "$projects" | while read -r project; do
                if [[ "$project" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $project"
                else
                    echo "    - Other project: $project"
                fi
            done
        fi
    fi
    
    return 0
}

analyze_turbo_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Turbo workspace: $file (legacy - superseded by NX per ADR 20260419001)"
    
    echo "  ⚠ Found Turbo configuration (legacy - consider migrating to NX)"
    
    # Check for pipeline configuration
    if jq -e '.pipeline' "$file" >/dev/null 2>&1; then
        echo "  Turbo pipelines found:"
        jq -r '.pipeline | keys[]' "$file" 2>/dev/null | while read -r pipeline; do
            echo "    - $pipeline"
        done
    fi
    
    return 0
}

analyze_lerna_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Lerna workspace: $file"
    
    echo "  ✓ Found Lerna configuration"
    
    # Check for packages
    if jq -e '.packages' "$file" >/dev/null 2>&1; then
        local packages
        packages=$(jq -r '.packages[]? // empty' "$file" 2>/dev/null || true)
        
        if [[ -n "$packages" ]]; then
            echo "  Lerna packages:"
            echo "$packages" | while read -r package; do
                if [[ "$package" == *"$target_project"* ]]; then
                    echo "    ✓ Target project: $package"
                else
                    echo "    - Other package: $package"
                fi
            done
        fi
    fi
    
    return 0
}

analyze_rush_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Rush workspace: $file"
    
    echo "  ✓ Found Rush configuration"
    
    return 0
}

analyze_python_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Python workspace: $file"
    
    echo "  ✓ Found Python project configuration"
    
    # Check for Poetry workspace
    if grep -q "\[tool.poetry\]" "$file"; then
        echo "  ✓ Found Poetry configuration"
    fi
    
    # Check for setuptools workspace
    if grep -q "\[tool.setuptools\]" "$file"; then
        echo "  ✓ Found setuptools configuration"
    fi
    
    return 0
}

analyze_go_workspace() {
    local file="$1"
    local target_project="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_info "Analyzing Go workspace: $file"
    
    echo "  ✓ Found Go module"
    
    # Check for module name
    if grep -q "module " "$file"; then
        local module_name
        module_name=$(grep "module " "$file" | sed 's/module\s\+\(.*\)/\1/' || true)
        if [[ -n "$module_name" ]]; then
            echo "  Module name: $module_name"
        fi
    fi
    
    return 0
}

analyze_workspace_configs() {
    local repo_path="$1"
    local target_project="$2"
    local verbose="${3:-false}"
    
    cd "$repo_path"
    
    log_step "Analyzing workspace configurations"
    
    local configs_found=()
    
    # Analyze each workspace configuration
    if [[ -f "pnpm-workspace.yaml" ]] || [[ -f "pnpm-workspaces.yml" ]]; then
        for config in pnpm-workspace.yaml pnpm-workspaces.yml; do
            if [[ -f "$config" ]]; then
                analyze_pnpm_workspace "$config" "$target_project"
                configs_found+=("$config")
            fi
        done
    fi
    
    if [[ -f "package.json" ]]; then
        analyze_npm_workspace "package.json" "$target_project"
        configs_found+=("package.json")
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        analyze_cargo_workspace "Cargo.toml" "$target_project"
        configs_found+=("Cargo.toml")
    fi
    
    if [[ -f "pom.xml" ]]; then
        analyze_maven_workspace "pom.xml" "$target_project"
        configs_found+=("pom.xml")
    fi
    
    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        for config in build.gradle build.gradle.kts; do
            if [[ -f "$config" ]]; then
                analyze_gradle_workspace "$config" "$target_project"
                configs_found+=("$config")
            fi
        done
    fi
    
    if [[ -f "WORKSPACE" ]]; then
        analyze_bazel_workspace "WORKSPACE" "$target_project"
        configs_found+=("WORKSPACE")
    fi
    
    if [[ -f "pants.toml" ]]; then
        analyze_pants_workspace "pants.toml" "$target_project"
        configs_found+=("pants.toml")
    fi
    
    if [[ -f "nx.json" ]]; then
        analyze_nx_workspace "nx.json" "$target_project"
        configs_found+=("nx.json")
    fi
    
    if [[ -f "turbo.json" ]]; then
        analyze_turbo_workspace "turbo.json" "$target_project"
        configs_found+=("turbo.json")
    fi
    
    if [[ -f "lerna.json" ]]; then
        analyze_lerna_workspace "lerna.json" "$target_project"
        configs_found+=("lerna.json")
    fi
    
    if [[ -f "rush.json" ]]; then
        analyze_rush_workspace "rush.json" "$target_project"
        configs_found+=("rush.json")
    fi
    
    if [[ -f "pyproject.toml" ]]; then
        analyze_python_workspace "pyproject.toml" "$target_project"
        configs_found+=("pyproject.toml")
    fi
    
    if [[ -f "go.mod" ]]; then
        analyze_go_workspace "go.mod" "$target_project"
        configs_found+=("go.mod")
    fi
    
    if [[ ${#configs_found[@]} -eq 0 ]]; then
        log_warn "No workspace configurations found"
    else
        log_info "Found ${#configs_found[@]} workspace configuration(s)"
    fi
    
    return 0
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
                echo "Analyze workspace configurations and monorepo structures"
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
    
    echo "=== Workspace Configuration Analysis ==="
    echo "Monorepo: $repo_path"
    echo "Project: $project_name"
    echo "Verbose: $verbose"
    echo
    
    analyze_workspace_configs "$repo_path" "$project_name" "$verbose"
    
    echo
    log_info "Workspace configuration analysis completed"
}

# Run analysis if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
