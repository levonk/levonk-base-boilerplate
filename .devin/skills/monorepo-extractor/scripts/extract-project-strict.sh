#!/bin/bash
# Strict monorepo extraction with branch detection and git history preservation
# Requires clean repository state and provides precise extraction control

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DRY_RUN=false
FORCE_MODE=false
VERBOSE=false
BRANCH=""
COMMITTER_NAME=""
COMMITTER_EMAIL=""
AUTHOR_NAME=""
AUTHOR_EMAIL=""
ANALYZE_AI_IDE=true
FILTER_AI_CONTENT=true

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

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}VERBOSE:${NC} $1"
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME NEW_REPO_PATH

Arguments:
    MONOREPO_PATH    Path to the monorepo directory
    PROJECT_NAME     Name of the project/directory to extract
    NEW_REPO_PATH    Path where the new repository will be created

Options:
    -b, --branch BRANCH        Clone specific branch (auto-detects if not specified)
    -f, --force               Force extraction despite warnings (DANGEROUS)
    -v, --verbose             Show detailed output
    -d, --dry-run             Show what would be done without executing
    -u, --usage               Show usage examples
    -h, --help                Show this help message
    --no-ai-analysis         Skip AI/IDE configuration analysis
    --no-ai-filtering         Skip AI content filtering and migration

Git Identity Options:
    --committer-name NAME     Rewrite committer name
    --committer-email EMAIL   Rewrite committer email
    --author-name NAME        Rewrite author name
    --author-email EMAIL      Rewrite author email

Examples:
    $0 /opt/company-monorepo webapp /opt/webapp-repo
    $0 --branch main ~/projects/monorepo libs/shared-utils ~/shared-utils
    $0 --verbose --branch develop /opt/monorepo apps/api /opt/api-repo
    $0 --dry-run --committer-name "Bot User" --committer-email "bot@company.com" \\
        /opt/monorepo project /opt/project-repo

Usage Examples:
    # Auto-detect single branch
    $0 /path/to/monorepo project-name /path/to/new-repo

    # Specify branch explicitly
    $0 --branch main /path/to/monorepo project-name /path/to/new-repo

    # Rewrite git history
    $0 --committer-name "John Doe" --committer-email "john@company.com" \\
        --author-name "Jane Smith" --author-email "jane@company.com" \\
        /path/to/monorepo project-name /path/to/new-repo

    # Test extraction without making changes
    $0 --dry-run --verbose /path/to/monorepo project-name /path/to/new-repo
EOF
}

show_usage_examples() {
    cat << EOF
Usage Examples:

1. Basic Extraction (Auto-detect branch):
   $0 /opt/company-monorepo webapp /opt/webapp-repo

2. Specific Branch Extraction:
   $0 --branch main ~/projects/monorepo libs/shared-utils ~/shared-utils

3. Verbose Extraction with Git Rewrite:
   $0 --verbose --committer-name "Bot User" --committer-email "bot@company.com" \\
      /opt/monorepo apps/api /opt/api-repo

4. Dry Run Testing:
   $0 --dry-run --branch develop /opt/monorepo project-name /opt/project-repo

5. Force Extraction (DANGEROUS - only if you know what you're doing):
   $0 --force /opt/monorepo project-name /opt/project-repo

6. Complete Git Identity Rewrite:
   $0 --committer-name "John Doe" --committer-email "john@company.com" \\
      --author-name "Jane Smith" --author-email "jane@company.com" \\
      --branch main /opt/monorepo project /opt/project-repo
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -u|--usage)
            show_usage_examples
            exit 0
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        --committer-name)
            COMMITTER_NAME="$2"
            shift 2
            ;;
        --committer-email)
            COMMITTER_EMAIL="$2"
            shift 2
            ;;
        --author-name)
            AUTHOR_NAME="$2"
            shift 2
            ;;
        --author-email)
            AUTHOR_EMAIL="$2"
            shift 2
            ;;
        --no-ai-analysis)
            ANALYZE_AI_IDE=false
            shift
            ;;
        --no-ai-filtering)
            FILTER_AI_CONTENT=false
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [[ -z "${MONOREPO_PATH:-}" ]]; then
                MONOREPO_PATH="$1"
            elif [[ -z "${PROJECT_NAME:-}" ]]; then
                PROJECT_NAME="$1"
            elif [[ -z "${NEW_REPO_PATH:-}" ]]; then
                NEW_REPO_PATH="$1"
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
if [[ -z "${MONOREPO_PATH:-}" || -z "${PROJECT_NAME:-}" || -z "${NEW_REPO_PATH:-}" ]]; then
    log_error "Missing required arguments"
    show_usage
    exit 1
fi

validate_monorepo_state() {
    local monorepo_path="$1"

    log_step "Validating monorepo state (strict mode)"

    cd "$monorepo_path"

    # Check if it's a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not a git repository: $monorepo_path"
        exit 1
    fi

    # Check for uncommitted changes (STRICT - no warnings, just fail)
    if git status --porcelain | grep -q .; then
        log_error "Repository has uncommitted changes. Commit or stash before extraction."
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Uncommitted changes:"
            git status --porcelain
        fi
        exit 1
    fi

    # Check for stashed changes
    local stash_count
    stash_count=$(git stash list 2>/dev/null | wc -l)
    if [[ $stash_count -gt 0 ]]; then
        log_error "Repository has $stash_count stashed entries. Clear stash before extraction."
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Stash entries:"
            git stash list
        fi
        exit 1
    fi

    # Check if project directory exists
    if [[ ! -d "$PROJECT_NAME" ]]; then
        log_error "Project directory not found: $PROJECT_NAME"
        exit 1
    fi

    # CRITICAL: Check if repository is pushed to remote
    log_step "Validating remote synchronization"

    # Check if remote is configured
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_error "No remote 'origin' configured. Repository must be pushed before extraction."
        exit 1
    fi

    local remote_url
    remote_url=$(git remote get-url origin)
    log_verbose "Remote URL: $remote_url"

    # Test remote connectivity
    if ! timeout 30 git ls-remote origin >/dev/null 2>&1; then
        log_error "Cannot connect to remote repository. Check network and authentication."
        exit 1
    fi

    # Get current branch
    local current_branch
    current_branch=$(git branch --show-current)
    log_verbose "Current branch: $current_branch"

    # Check if branch exists remotely
    if ! git ls-remote --exit-code origin "refs/heads/$current_branch" >/dev/null 2>&1; then
        log_error "Branch '$current_branch' does not exist on remote. Push branch before extraction."
        if [[ "$VERBOSE" == "true" ]]; then
            echo "To push: git push -u origin $current_branch"
        fi
        exit 1
    fi

    # Check for unpushed commits (CRITICAL)
    local unpushed_commits
    unpushed_commits=$(git log --oneline "origin/$current_branch..HEAD" 2>/dev/null | wc -l)

    if [[ $unpushed_commits -gt 0 ]]; then
        log_error "Found $unpushed_commits unpushed commits. Push all commits before extraction."
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Unpushed commits:"
            git log --oneline "origin/$current_branch..HEAD"
            echo "To push: git push origin $current_branch"
        fi
        exit 1
    fi

    # Check for unpulled commits (warning only)
    local unpulled_commits
    unpulled_commits=$(git log --oneline "HEAD..origin/$current_branch" 2>/dev/null | wc -l)

    if [[ $unpulled_commits -gt 0 ]]; then
        log_warn "Found $unpulled commits on remote. Consider pulling before extraction."
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Unpulled commits:"
            git log --oneline "HEAD..origin/$current_branch"
            echo "To pull: git pull origin $current_branch"
        fi
    fi

    # Check repository integrity
    if ! git fsck --no-dangling >/dev/null 2>&1; then
        log_error "Repository integrity check failed. Run 'git fsck' to fix issues."
        if [[ "$FORCE_MODE" != "true" ]]; then
            exit 1
        else
            log_warn "Proceeding despite integrity issues (--force mode)"
        fi
    fi

    log_info "Monorepo validation passed - repository is clean and synchronized"
}

detect_or_validate_branch() {
    local monorepo_path="$1"

    cd "$monorepo_path"

    if [[ -n "$BRANCH" ]]; then
        log_step "Validating specified branch: $BRANCH"

        # Check if branch exists
        if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
            log_error "Branch '$BRANCH' does not exist"
            exit 1
        fi

        # Check if branch is current branch
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [[ "$current_branch" != "$BRANCH" ]]; then
            log_error "Current branch is '$current_branch', but you specified '$BRANCH'"
            log_error "Switch to branch '$BRANCH' or omit --branch to auto-detect"
            exit 1
        fi

        log_info "Branch validation passed: $BRANCH"
    else
        log_step "Auto-detecting branch"

        # Get current branch
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        # Check if there are multiple branches
        local branch_count
        branch_count=$(git branch | wc -l)

        if [[ $branch_count -eq 1 ]]; then
            BRANCH="$current_branch"
            log_info "Auto-detected single branch: $BRANCH"
        elif [[ $branch_count -gt 1 ]]; then
            log_error "Repository has multiple branches:"
            git branch
            log_error "Specify --branch to choose which branch to extract"
            exit 1
        else
            log_error "No branches found in repository"
            exit 1
        fi
    fi
}

extract_project_strict() {
    local monorepo_path="$1"
    local project_name="$2"
    local new_repo_path="$3"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would extract with strict validation"
        log_verbose "[DRY RUN] Monorepo: $monorepo_path"
        log_verbose "[DRY RUN] Project: $project_name"
        log_verbose "[DRY RUN] Branch: $BRANCH"
        log_verbose "[DRY RUN] Destination: $new_repo_path"

        if [[ -n "$COMMITTER_NAME" || -n "$COMMITTER_EMAIL" || -n "$AUTHOR_NAME" || -n "$AUTHOR_EMAIL" ]]; then
            log_verbose "[DRY RUN] Git identity rewrite enabled"
        fi

        return 0
    fi

    log_step "Starting strict extraction"

    # Create destination directory
    mkdir -p "$new_repo_path"

    # Clone the specific branch
    log_verbose "Cloning branch: $BRANCH"
    git clone --branch "$BRANCH" --single-branch "$monorepo_path" "$new_repo_path"

    cd "$new_repo_path"

    # Remove origin remote to avoid accidental pushes
    git remote remove origin

    # Clean up multi-line git config entries that break git-filter-repo
    # git-filter-repo parses `git config --list` output and fails on multi-line values
    # because continuation lines lack the key=value format
    log_verbose "Cleaning up multi-line git config entries"
    local config_output
    config_output=$(git config --list 2>/dev/null)
    if echo "$config_output" | grep -q "^[[:space:]]"; then
        log_warn "Found multi-line git config entries, removing problematic sections"
        # Find sections with multi-line values and remove them
        local current_key=""
        local in_multiline=false
        while IFS= read -r line; do
            if echo "$line" | grep -q "^[[:space:]]"; then
                if [[ "$in_multiline" == "true" ]]; then
                    local section="${current_key%%.*}"
                    git config --remove-section "$section" 2>/dev/null || true
                    log_verbose "Removed config section: $section (multi-line value)"
                fi
            else
                current_key="${line%%=*}"
                in_multiline=true
            fi
        done <<< "$config_output"
    fi

    # Analyze AI/IDE configurations if enabled
    if [[ "$ANALYZE_AI_IDE" == "true" ]]; then
        log_step "Analyzing AI/IDE configurations and documentation"

        # Get script directory
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

        # Run AI/IDE analysis
        if [[ -f "$script_dir/analyze-ai-ide-configs.sh" ]]; then
            local analysis_output="$new_repo_path/ai-ide-analysis.json"
            if "$script_dir/analyze-ai-ide-configs.sh" --output "$analysis_output" "$monorepo_path" "$project_name"; then
                log_info "AI/IDE analysis completed: $analysis_output"

                # Show high priority files if verbose
                if [[ "$VERBOSE" == "true" && -f "$analysis_output" ]]; then
                    log_verbose "High priority files identified:"
                    # Extract high priority files from JSON (simplified)
                    if command -v jq >/dev/null 2>&1; then
                        jq -r '.high_priority_files[]' "$analysis_output" 2>/dev/null | while read -r file; do
                            log_verbose "  - $file"
                        done
                    fi
                fi
            else
                log_warn "AI/IDE analysis failed, continuing without it"
            fi
        else
            log_warn "AI/IDE analysis script not found, continuing without it"
        fi

        # Run repository health review if available
        if [[ -f "$script_dir/../repository-health-review/scripts/repository-health-review.sh" ]]; then
            log_step "Running repository health review"
            local health_output="$new_repo_path/health-review.json"
            if "$script_dir/../repository-health-review/scripts/repository-health-review.sh" --report "$health_output" "$monorepo_path" "$project_name"; then
                log_info "Repository health review completed: $health_output"

                # Show health score if verbose
                if [[ "$VERBOSE" == "true" && -f "$health_output" ]]; then
                    if command -v jq >/dev/null 2>&1; then
                        local health_score
                        health_score=$(jq -r '.health_score' "$health_output" 2>/dev/null || echo "unknown")
                        local critical_issues
                        critical_issues=$(jq -r '.issues.critical' "$health_output" 2>/dev/null || echo "0")
                        log_verbose "  Health Score: $health_score/100"
                        log_verbose "  Critical Issues: $critical_issues"

                        if [[ $critical_issues -gt 0 ]]; then
                            log_warn "  ⚠️  Critical issues detected - review health report"
                        fi
                    fi
                fi
            else
                log_warn "Repository health review failed, continuing without it"
            fi
        else
            log_warn "Repository health review skill not found at ../repository-health-review/scripts/, continuing without it"
        fi
    fi

    # Use git-filter-repo for clean history extraction
    log_step "Filtering git history for $project_name"

    local filter_args=("--path" "$project_name/" "--force")

    # Add git identity rewrite options if specified
    if [[ -n "$COMMITTER_NAME" ]]; then
        filter_args+=("--committer-name" "$COMMITTER_NAME")
    fi
    if [[ -n "$COMMITTER_EMAIL" ]]; then
        filter_args+=("--committer-email" "$COMMITTER_EMAIL")
    fi
    if [[ -n "$AUTHOR_NAME" ]]; then
        filter_args+=("--author-name" "$AUTHOR_NAME")
    fi
    if [[ -n "$AUTHOR_EMAIL" ]]; then
        filter_args+=("--author-email" "$AUTHOR_EMAIL")
    fi

    log_verbose "Filter arguments: ${filter_args[*]}"

    if command -v git-filter-repo >/dev/null 2>&1; then
        # Bypass global and system git config to avoid multi-line config values
        # that break git-filter-repo's config parser (e.g. merge.railschema.driver)
        GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 git-filter-repo "${filter_args[@]}"
    else
        log_error "git-filter-repo is required for extraction"
        log_error "Install with: pip install git-filter-repo"
        exit 1
    fi

    log_info "History extraction completed"

    # Restructure if files are in subdirectory
    if [[ -d "$project_name" ]]; then
        log_step "Moving files from $project_name/ to root directory"

        # Move all files to root
        mv "$project_name"/* . 2>/dev/null || true
        mv "$project_name"/.* . 2>/dev/null || true

        # Remove empty directory
        rmdir "$project_name" 2>/dev/null || true

        # Add .gitignore if not present
        if [[ ! -f .gitignore ]]; then
            cat > .gitignore << 'EOF'
# Build artifacts
target/
dist/
build/

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
logs/
EOF
            git add .gitignore
        fi

        # Commit the restructuring
        git add .
        git commit -m "Restructure: Move project files to root directory

Extracted from monorepo: $(basename "$monorepo_path")
Original path: $project_name/
Branch: $BRANCH
Extraction date: $(date +%Y-%m-%d)
Extraction tool: monorepo-extractor" || log_warn "No changes to commit"

            log_info "Files restructured to root directory"
        fi

        # Apply smart content filtering if enabled
        if [[ "$FILTER_AI_CONTENT" == "true" ]]; then
            log_step "Applying smart content filtering for AI/IDE configurations"

            # Get script directory
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

            # Run smart content filtering
            if [[ -f "$script_dir/smart-content-filter.sh" ]]; then
                local temp_filtered_dir="${new_repo_path}_filtered"
                if "$script_dir/smart-content-filter.sh" --verbose --force "$new_repo_path" "$project_name" "$temp_filtered_dir"; then
                    # Backup original and replace with filtered content
                    local backup_dir="${new_repo_path}_backup"
                    mv "$new_repo_path" "$backup_dir"
                    mv "$temp_filtered_dir" "$new_repo_path"

                    log_info "Smart content filtering completed"
                    log_info "Original content backed up to: $backup_dir"

                    # Commit the filtered content
                    cd "$new_repo_path"
                    git add .
                    if git diff --staged --quiet; then
                        log_info "No content changes detected during filtering"
                    else
                        git commit -m "AI/IDE: Apply smart content filtering for standalone repository"
                    fi
                else
                    log_warn "Smart content filtering failed, continuing with original content"
                fi
            else
                log_warn "Smart content filter script not found, skipping content filtering"
            fi
        fi

        # Show final repository state
        if [[ "$VERBOSE" == "true" ]]; then
            log_step "Final repository state:"
            echo "Commits: $(git rev-list --count HEAD)"
            echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
            echo "Files: $(git ls-files | wc -l)"
        fi
}

# Main execution
main() {
    log_info "Starting strict monorepo extraction"
    log_verbose "Monorepo: $MONOREPO_PATH"
    log_verbose "Project: $PROJECT_NAME"
    log_verbose "Destination: $NEW_REPO_PATH"
    log_verbose "Force mode: $FORCE_MODE"
    log_verbose "Dry run: $DRY_RUN"
    log_verbose "AI/IDE analysis: $ANALYZE_AI_IDE"
    log_verbose "AI content filtering: $FILTER_AI_CONTENT"

    # Validate monorepo state (strict)
    validate_monorepo_state "$MONOREPO_PATH"

    # Detect or validate branch
    detect_or_validate_branch "$MONOREPO_PATH"

    # Extract project with strict validation
    extract_project_strict "$MONOREPO_PATH" "$PROJECT_NAME" "$NEW_REPO_PATH"

    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Extraction completed successfully!"
        log_info "Repository ready at: $NEW_REPO_PATH"
        log_info "Branch: $BRANCH"
        log_info "Commits preserved: $(cd "$NEW_REPO_PATH" && git rev-list --count HEAD)"
    else
        log_info "Dry run completed - no changes made"
    fi
}

# Run main function with all arguments
main "$@"
