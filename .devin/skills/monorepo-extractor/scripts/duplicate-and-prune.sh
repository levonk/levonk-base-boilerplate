#!/bin/bash
# Duplicate monorepo and prune to create new repository with monorepo structure
# Preserves shared resources while removing unrelated projects and history

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DRY_RUN=false
KEEP_SHARED_RESOURCES=true
PRUNE_HISTORY=true
TEMP_DIR_BASE="/tmp/monorepo-duplication"

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
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME NEW_REPO_PATH

Arguments:
    MONOREPO_PATH    Path to the source monorepo
    PROJECT_NAME     Name of the project to extract
    NEW_REPO_PATH    Path where the new repository will be created

Options:
    -d, --dry-run          Show what would be done without executing
    --no-shared-resources  Remove all shared resources (keep only project)
    --keep-history         Keep all history (don't prune unrelated commits)
    --keep-temp            Keep temporary directory for debugging
    -h, --help             Show this help message

Examples:
    $0 /opt/company-monorepo webapp /opt/webapp-repo
    $0 --dry-run --no-shared-resources ~/projects/company-monorepo libs/shared-utils
EOF
}

# Shared resource patterns to preserve
declare -A SHARED_RESOURCES=(
    # Environment and development
    [".envrc"]="keep"
    ["direnv.toml"]="keep"
    ["devbox.json"]="keep"
    ["devbox.lock"]="keep"
    ["flake.nix"]="keep"
    ["flake.lock"]="keep"
    ["shell.nix"]="keep"
    ["Dockerfile"]="keep"
    ["docker-compose.yml"]="keep"
    ["docker-compose.override.yml"]="keep"
    
    # Package management
    ["package.json"]="analyze"
    ["package-lock.json"]="analyze"
    ["pnpm-lock.yaml"]="analyze"
    ["pnpm-workspace.yaml"]="analyze"
    ["pnpm-workspaces.yml"]="analyze"
    ["yarn.lock"]="analyze"
    ["bun.lockb"]="analyze"
    
    # Build systems
    ["Makefile"]="keep"
    ["Justfile"]="keep"
    ["nx.json"]="keep"  # Preferred per ADR 20260419001
    ["turbo.json"]="keep"  # Legacy - superseded by NX
    ["lerna.json"]="keep"
    ["rush.json"]="keep"
    
    # Language specific
    ["Cargo.toml"]="analyze"
    ["Cargo.lock"]="analyze"
    ["pyproject.toml"]="analyze"
    ["poetry.lock"]="analyze"
    ["go.mod"]="analyze"
    ["go.sum"]="analyze"
    ["pom.xml"]="analyze"
    ["build.gradle"]="analyze"
    ["gradle.lockfile"]="analyze"
    ["WORKSPACE"]="keep"
    ["BUILD.bazel"]="keep"
    ["pants.toml"]="keep"
    
    # Configuration
    [".gitignore"]="keep"
    [".editorconfig"]="keep"
    [".prettierrc"]="keep"
    [".prettierrc.json"]="keep"
    [".eslintrc.js"]="keep"
    [".eslintrc.json"]="keep"
    [".eslintrc.yml"]="keep"
    [".eslintrc.yaml"]="keep"
    ["tsconfig.json"]="keep"
    ["tsconfig.base.json"]="keep"
    ["jest.config.js"]="keep"
    ["jest.config.json"]="keep"
    ["vitest.config.ts"]="keep"
    ["vitest.config.js"]="keep"
    
    # CI/CD
    [".github"]="keep"
    [".gitlab-ci.yml"]="keep"
    [".circleci"]="keep"
    ["Jenkinsfile"]="keep"
    ["azure-pipelines.yml"]="keep"
    
    # Documentation
    ["README.md"]="analyze"
    ["CHANGELOG.md"]="keep"
    ["CONTRIBUTING.md"]="keep"
    ["LICENSE"]="keep"
    ["docs"]="keep"
    [".vscode"]="keep"
    [".idea"]="keep"
)

# Projects to remove (everything except the target project)
declare -a PROJECTS_TO_REMOVE=()

analyze_workspace_config() {
    local workspace_file="$1"
    local target_project="$2"
    
    log_info "Analyzing workspace configuration: $workspace_file"
    
    if [[ ! -f "$workspace_file" ]]; then
        return 0
    fi
    
    case "$workspace_file" in
        "pnpm-workspace.yaml"|"pnpm-workspaces.yml")
            local workspace_packages
            workspace_packages=$(grep -A 10 "packages:" "$workspace_file" | grep -E "^\s*-" | sed 's/.*"\(.*\)".*/\1/' || true)
            
            while IFS= read -r pkg; do
                if [[ -n "$pkg" ]] && [[ "$pkg" != *"$target_project"* ]]; then
                    PROJECTS_TO_REMOVE+=("$pkg")
                fi
            done <<< "$workspace_packages"
            ;;
        "package.json")
            if jq -e '.workspaces' "$workspace_file" >/dev/null 2>&1; then
                local workspaces
                workspaces=$(jq -r '.workspaces[]? // empty' "$workspace_file" 2>/dev/null || true)
                
                while IFS= read -r ws; do
                    if [[ -n "$ws" ]] && [[ "$ws" != *"$target_project"* ]]; then
                        PROJECTS_TO_REMOVE+=("$ws")
                    fi
                done <<< "$workspaces"
            fi
            ;;
        "Cargo.toml")
            if grep -q "\[workspace\]" "$workspace_file"; then
                local members
                members=$(grep -A 10 "members" "$workspace_file" | grep '"' | sed 's/.*"\(.*\)".*/\1/' || true)
                
                while IFS= read -r member; do
                    if [[ -n "$member" ]] && [[ "$member" != *"$target_project"* ]]; then
                        PROJECTS_TO_REMOVE+=("$member")
                    fi
                done <<< "$members"
            fi
            ;;
        "pom.xml")
            if grep -q "<modules>" "$workspace_file"; then
                local modules
                modules=$(grep -A 20 "<modules>" "$workspace_file" | grep "<module>" | sed 's/.*<module>\(.*\)<\/module>.*/\1/' || true)
                
                while IFS= read -r module; do
                    if [[ -n "$module" ]] && [[ "$module" != *"$target_project"* ]]; then
                        PROJECTS_TO_REMOVE+=("$module")
                    fi
                done <<< "$modules"
            fi
            ;;
    esac
}

update_workspace_config() {
    local workspace_file="$1"
    local target_project="$2"
    local temp_repo="$3"
    
    log_info "Updating workspace configuration: $workspace_file"
    
    if [[ ! -f "$workspace_file" ]]; then
        return 0
    fi
    
    case "$workspace_file" in
        "pnpm-workspace.yaml"|"pnpm-workspaces.yml")
            # Keep only target project in workspace
            local temp_file
            temp_file=$(mktemp)
            
            grep -v "packages:" "$workspace_file" > "$temp_file" || true
            echo "packages:" >> "$temp_file"
            echo "  - '$target_project'" >> "$temp_file"
            
            mv "$temp_file" "$workspace_file"
            ;;
        "package.json")
            # Update workspaces to include only target project
            if jq -e '.workspaces' "$workspace_file" >/dev/null 2>&1; then
                jq ".workspaces = [\"$target_project\"]" "$workspace_file" > "${workspace_file}.tmp"
                mv "${workspace_file}.tmp" "$workspace_file"
            fi
            ;;
        "Cargo.toml")
            if grep -q "\[workspace\]" "$workspace_file"; then
                local temp_file
                temp_file=$(mktemp)
                
                # Keep workspace section but update members
                sed '/members:/,/]/c\
  members = ["'"$target_project"'"]' "$workspace_file" > "$temp_file"
                mv "$temp_file" "$workspace_file"
            fi
            ;;
        "pom.xml")
            if grep -q "<modules>" "$workspace_file"; then
                local temp_file
                temp_file=$(mktemp)
                
                # Update modules section
                sed '/<modules>/,/<\/modules>/c\
    <modules>\
        <module>'"$target_project"'</module>\
    </modules>' "$workspace_file" > "$temp_file"
                mv "$temp_file" "$workspace_file"
            fi
            ;;
    esac
}

duplicate_repository() {
    local source_repo="$1"
    local temp_repo="$2"
    
    log_step "Duplicating repository"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would clone repository to temporary location"
        return 0
    fi
    
    # Clone with full history
    git clone "$source_repo" "$temp_repo"
    
    cd "$temp_repo"
    
    # Remove remote to prevent accidental pushes
    git remote remove origin
    
    log_info "Repository duplicated to: $temp_repo"
}

prune_unrelated_projects() {
    local target_project="$1"
    local temp_repo="$2"
    
    cd "$temp_repo"
    
    log_step "Identifying projects to remove"
    
    # Analyze workspace configurations
    for workspace_file in "${!SHARED_RESOURCES[@]}"; do
        if [[ "${SHARED_RESOURCES[$workspace_file]}" == "analyze" ]]; then
            analyze_workspace_config "$workspace_file" "$target_project"
        fi
    done
    
    # Add common project directories that aren't the target
    for dir in */; do
        if [[ -d "$dir" ]] && [[ "$dir" != "$target_project/" ]]; then
            PROJECTS_TO_REMOVE+=("${dir%/}")
        fi
    done
    
    # Remove duplicates
    local unique_projects
    mapfile -t unique_projects < <(printf '%s\n' "${PROJECTS_TO_REMOVE[@]}" | sort -u)
    PROJECTS_TO_REMOVE=("${unique_projects[@]}")
    
    if [[ ${#PROJECTS_TO_REMOVE[@]} -gt 0 ]]; then
        log_info "Projects to remove: ${PROJECTS_TO_REMOVE[*]}"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            # Remove project directories
            for project in "${PROJECTS_TO_REMOVE[@]}"; do
                if [[ -d "$project" ]]; then
                    git rm -r "$project" 2>/dev/null || rm -rf "$project"
                    log_info "  Removed: $project"
                fi
            done
        else
            log_step "[DRY RUN] Would remove projects: ${PROJECTS_TO_REMOVE[*]}"
        fi
    else
        log_info "No unrelated projects found"
    fi
}

prune_shared_resources() {
    local temp_repo="$1"
    
    cd "$temp_repo"
    
    if [[ "$KEEP_SHARED_RESOURCES" == "true" ]]; then
        log_step "Keeping shared resources"
        return 0
    fi
    
    log_step "Removing shared resources"
    
    local resources_to_remove=()
    
    for resource in "${!SHARED_RESOURCES[@]}"; do
        if [[ -f "$resource" ]] || [[ -d "$resource" ]]; then
            resources_to_remove+=("$resource")
        fi
    done
    
    if [[ ${#resources_to_remove[@]} -gt 0 ]]; then
        log_info "Shared resources to remove: ${resources_to_remove[*]}"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            for resource in "${resources_to_remove[@]}"; do
                git rm -r "$resource" 2>/dev/null || rm -rf "$resource"
                log_info "  Removed: $resource"
            done
        else
            log_step "[DRY RUN] Would remove shared resources: ${resources_to_remove[*]}"
        fi
    fi
}

update_workspace_configurations() {
    local target_project="$1"
    local temp_repo="$2"
    
    cd "$temp_repo"
    
    log_step "Updating workspace configurations"
    
    # Update each workspace configuration file
    for workspace_file in "${!SHARED_RESOURCES[@]}"; do
        if [[ "${SHARED_RESOURCES[$workspace_file]}" == "analyze" ]] && [[ -f "$workspace_file" ]]; then
            update_workspace_config "$workspace_file" "$target_project" "$temp_repo"
        fi
    done
}

prune_git_history() {
    local target_project="$1"
    local temp_repo="$2"
    
    cd "$temp_repo"
    
    if [[ "$PRUNE_HISTORY" != "true" ]]; then
        log_step "Keeping full git history"
        return 0
    fi
    
    log_step "Pruning unrelated git history"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would prune git history to include only $target_project"
        return 0
    fi
    
    # Use git-filter-repo to keep only relevant history
    local paths_to_keep=("$target_project")
    
    # Add shared resources to keep
    if [[ "$KEEP_SHARED_RESOURCES" == "true" ]]; then
        for resource in "${!SHARED_RESOURCES[@]}"; do
            if [[ -f "$resource" ]] || [[ -d "$resource" ]]; then
                paths_to_keep+=("$resource")
            fi
        done
    fi
    
    # Build path filter
    local path_filter=""
    for path in "${paths_to_keep[@]}"; do
        if [[ -n "$path_filter" ]]; then
            path_filter="$path_filter|$path"
        else
            path_filter="$path"
        fi
    done
    
    # Filter history
    if command -v git-filter-repo >/dev/null 2>&1; then
        git-filter-repo --path-glob "$path_filter" --force
    else
        log_warn "git-filter-repo not available, using git filter-branch"
        git filter-branch --index-filter "git ls-files -s | grep -E '$path_filter' | GIT_INDEX_FILE=\$GIT_INDEX_FILE.new git update-index --index-info && mv \$GIT_INDEX_FILE.new \$GIT_INDEX_FILE" --prune-empty
    fi
    
    log_info "Git history pruned to relevant paths"
}

create_final_repository() {
    local temp_repo="$1"
    local final_repo="$2"
    
    log_step "Creating final repository"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would create final repository at: $final_repo"
        return 0
    fi
    
    # Create final repository
    mkdir -p "$final_repo"
    cd "$final_repo"
    
    # Initialize new repository
    git init
    
    # Import from temporary repository
    git remote add temp "$temp_repo"
    git fetch temp
    
    # Create main branch and import history
    git checkout -b main
    git merge temp/main --allow-unrelated-histories
    
    # Remove temporary remote
    git remote remove temp
    
    log_info "Final repository created at: $final_repo"
}

commit_changes() {
    local temp_repo="$1"
    local target_project="$2"
    
    cd "$temp_repo"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would commit changes"
        return 0
    fi
    
    # Stage all changes
    git add .
    
    # Commit the extraction
    git commit -m "feat: Extract $target_project to standalone repository

- Removed unrelated projects: ${PROJECTS_TO_REMOVE[*]:-none}
- Updated workspace configurations
- Preserved shared resources and build system
- Pruned git history to relevant changes

Generated by monorepo-extractor on $(date)
"
    
    log_info "Changes committed successfully"
}

main() {
    local monorepo_path=""
    local project_name=""
    local new_repo_path=""
    local keep_temp=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --no-shared-resources)
                KEEP_SHARED_RESOURCES=false
                shift
                ;;
            --keep-history)
                PRUNE_HISTORY=false
                shift
                ;;
            --keep-temp)
                keep_temp=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$monorepo_path" ]]; then
                    monorepo_path="$1"
                elif [[ -z "$project_name" ]]; then
                    project_name="$1"
                elif [[ -z "$new_repo_path" ]]; then
                    new_repo_path="$1"
                else
                    log_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$monorepo_path" ]] || [[ -z "$project_name" ]] || [[ -z "$new_repo_path" ]]; then
        log_error "All arguments are required: monorepo path, project name, new repo path"
        show_usage
        exit 1
    fi
    
    echo "=== Monorepo Duplication and Pruning ==="
    echo "Source: $monorepo_path"
    echo "Project: $project_name"
    echo "Target: $new_repo_path"
    echo "Keep shared resources: $KEEP_SHARED_RESOURCES"
    echo "Prune history: $PRUNE_HISTORY"
    echo "Dry run: $DRY_RUN"
    echo
    
    # Validate inputs
    if [[ ! -d "$monorepo_path" ]]; then
        log_error "Monorepo path does not exist: $monorepo_path"
        exit 1
    fi
    
    if [[ ! -d "$monorepo_path/.git" ]]; then
        log_error "Not a git repository: $monorepo_path"
        exit 1
    fi
    
    if [[ ! -d "$monorepo_path/$project_name" ]]; then
        log_error "Project directory not found: $monorepo_path/$project_name"
        exit 1
    fi
    
    if [[ -e "$new_repo_path" ]] && [[ "$DRY_RUN" != "true" ]]; then
        log_error "Target path already exists: $new_repo_path"
        exit 1
    fi
    
    # Setup temporary directory
    local temp_dir="${TEMP_DIR_BASE}/$(date +%s)-$$"
    mkdir -p "$temp_dir"
    
    # Ensure cleanup on exit
    if [[ "$keep_temp" != "true" ]]; then
        trap "rm -rf $temp_dir" EXIT
    fi
    
    # Execute duplication and pruning
    duplicate_repository "$monorepo_path" "$temp_dir/repo"
    prune_unrelated_projects "$project_name" "$temp_dir/repo"
    prune_shared_resources "$temp_dir/repo"
    update_workspace_configurations "$project_name" "$temp_dir/repo"
    prune_git_history "$project_name" "$temp_dir/repo"
    commit_changes "$temp_dir/repo" "$project_name"
    create_final_repository "$temp_dir/repo" "$new_repo_path"
    
    echo
    log_info "✓ Repository duplication and pruning completed successfully!"
    log_info "New repository: $new_repo_path"
    log_info "Project structure preserved with monorepo tooling"
    
    if [[ "$keep_temp" == "true" ]]; then
        log_info "Temporary directory kept for debugging: $temp_dir"
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo
        log_info "Next steps:"
        echo "1. Validate the new repository: ./scripts/validate-monorepo-targets.sh $new_repo_path"
        echo "2. Set up remote: cd $new_repo_path && git remote add origin <URL>"
        echo "3. Push to remote: git push -u origin main"
        echo "4. Update team and CI/CD configurations"
    fi
}

# Run duplication if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
