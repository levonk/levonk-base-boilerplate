#!/bin/bash
# Safe git history extraction for monorepo projects
# Extracts a project while preserving its complete git history

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DRY_RUN=false
BACKUP_TAG_PREFIX="pre-extraction"
TEMP_DIR_BASE="/tmp/monorepo-extraction"

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
    MONOREPO_PATH    Path to the monorepo directory
    PROJECT_NAME     Name of the project/directory to extract
    NEW_REPO_PATH    Path where the new repository will be created

Options:
    -d, --dry-run    Show what would be done without executing
    -b, --backup     Create backup tag before extraction (default: true)
    -h, --help       Show this help message

Examples:
    $0 /opt/company-monorepo webapp /opt/webapp-repo
    $0 --dry-run ~/projects/company-monorepo libs/shared-utils ~/shared-utils
EOF
}

validate_inputs() {
    local monorepo_path="$1"
    local project_name="$2"
    local new_repo_path="$3"

    # Validate monorepo path
    if [[ ! -d "$monorepo_path" ]]; then
        log_error "Monorepo path does not exist: $monorepo_path"
        return 1
    fi

    if [[ ! -d "$monorepo_path/.git" ]]; then
        log_error "Monorepo path is not a git repository: $monorepo_path"
        return 1
    fi

    # Validate project name
    if [[ -z "$project_name" ]]; then
        log_error "Project name cannot be empty"
        return 1
    fi

    if [[ ! -d "$monorepo_path/$project_name" ]]; then
        log_error "Project directory does not exist: $monorepo_path/$project_name"
        return 1
    fi

    # Validate new repo path
    if [[ -z "$new_repo_path" ]]; then
        log_error "New repository path cannot be empty"
        return 1
    fi

    if [[ -e "$new_repo_path" ]] && [[ "$DRY_RUN" != "true" ]]; then
        log_error "New repository path already exists: $new_repo_path"
        return 1
    fi

    # Check for uncommitted changes in project
    cd "$monorepo_path"
    if git status --porcelain "$project_name" | grep -q .; then
        log_error "Project has uncommitted changes. Please commit or stash before extraction."
        echo "Uncommitted files:"
        git status --porcelain "$project_name"
        return 1
    fi

    log_info "Input validation passed"
}

check_active_work() {
    local monorepo_path="$1"
    local project_name="$2"

    cd "$monorepo_path"

    # Check for recent commits in project (last 24 hours)
    local recent_commits
    recent_commits=$(git log --since="24 hours ago" --oneline -- "$project_name" | wc -l)

    if [[ $recent_commits -gt 0 ]]; then
        log_warn "Found $recent_commits recent commits in $project_name"
        log_warn "Please ensure no active work is in progress"

        if [[ "$DRY_RUN" != "true" ]]; then
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Extraction cancelled"
                exit 0
            fi
        fi
    fi
}

create_backup_tag() {
    local monorepo_path="$1"
    local project_name="$2"

    cd "$monorepo_path"

    local backup_tag="${BACKUP_TAG_PREFIX}-${project_name}-$(date +%Y%m%d-%H%M%S)"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would create backup tag: $backup_tag"
        echo "$backup_tag"
        return 0
    fi

    log_step "Creating backup tag: $backup_tag"
    git tag -a "$backup_tag" -m "Pre-extraction backup of $project_name"

    log_info "Backup tag created: $backup_tag"
    echo "$backup_tag"
}

extract_project_history() {
    local monorepo_path="$1"
    local project_name="$2"
    local temp_dir="$3"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would clone monorepo to temporary directory"
        log_step "[DRY RUN] Would filter history to include only $project_name/"
        return 0
    fi

    log_step "Creating temporary clone for extraction"
    git clone "$monorepo_path" "$temp_dir/monorepo-temp"

    cd "$temp_dir/monorepo-temp"

    log_step "Filtering git history for $project_name"

    # Check if git-filter-repo is available
    if command -v git-filter-repo >/dev/null 2>&1; then
        git-filter-repo --path "$project_name/" --force
    else
        log_warn "git-filter-repo not available, falling back to git filter-branch"
        git filter-branch --subdirectory-filter "$project_name" --prune-empty
    fi

    log_info "History extraction completed"
}

create_new_repository() {
    local new_repo_path="$1"
    local temp_dir="$2"
    local project_name="$3"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would create new repository at: $new_repo_path"
        log_step "[DRY RUN] Would initialize git repository"
        log_step "[DRY RUN] Would copy filtered history"
        return 0
    fi

    log_step "Creating new repository"
    mkdir -p "$new_repo_path"
    cd "$new_repo_path"

    # Initialize new repository
    git init

    # Add remote to temporary repository
    git remote add origin "$temp_dir/monorepo-temp"

    # Pull all branches from filtered history
    git fetch origin
    for branch in $(git branch -r | grep -v HEAD); do
        git checkout -B "${branch#origin/}" "origin/$branch" 2>/dev/null || true
    done

    # Set main branch as default
    if git rev-parse main >/dev/null 2>&1; then
        git checkout main
    elif git rev-parse master >/dev/null 2>&1; then
        git checkout master
    else
        git checkout -b main
    fi

    # Remove origin remote
    git remote remove origin

    log_info "New repository created at: $new_repo_path"
}

cleanup_temp_files() {
    local temp_dir="$1"

    if [[ "$DRY_RUN" != "true" ]] && [[ -d "$temp_dir" ]]; then
        log_step "Cleaning up temporary files"
        rm -rf "$temp_dir"
    fi
}

main() {
    local monorepo_path=""
    local project_name=""
    local new_repo_path=""
    local create_backup=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -b|--backup)
                create_backup=true
                shift
                ;;
            --no-backup)
                create_backup=false
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
        log_error "Missing required arguments"
        show_usage
        exit 1
    fi

    echo "=== Monorepo Project Extraction ==="
    echo "Monorepo: $monorepo_path"
    echo "Project: $project_name"
    echo "Target: $new_repo_path"
    echo "Dry run: $DRY_RUN"
    echo

    # Step 1: Validate monorepo state before any changes
    log_step "Validating monorepo state before extraction"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ "$DRY_RUN" != "true" ]]; then
        if ! "$script_dir/validate-monorepo-state.sh" --verbose "$monorepo_path" "$project_name"; then
            log_error "Monorepo state validation failed"
            log_error "Please address issues before proceeding with extraction"
            exit 1
        fi
        log_info "✓ Monorepo state validation passed"
    else
        log_step "[DRY RUN] Would validate monorepo state"
    fi

    # Validate inputs
    validate_inputs "$monorepo_path" "$project_name" "$new_repo_path"

    # Check for active work
    check_active_work "$monorepo_path" "$project_name"

    # Create backup tag
    local backup_tag=""
    if [[ "$create_backup" == "true" ]]; then
        backup_tag=$(create_backup_tag "$monorepo_path" "$project_name")
    fi

    # Setup temporary directory
    local temp_dir="${TEMP_DIR_BASE}/$(date +%s)-$$"
    mkdir -p "$temp_dir"

    # Ensure cleanup on exit
    trap "cleanup_temp_files '$temp_dir'" EXIT

    # Extract project history
    extract_project_history "$monorepo_path" "$project_name" "$temp_dir"

    # Create new repository
    create_new_repository "$new_repo_path" "$temp_dir" "$project_name"

    echo
    log_info "Extraction completed successfully!"
    if [[ -n "$backup_tag" ]]; then
        log_info "Backup tag: $backup_tag"
    fi
    log_info "New repository: $new_repo_path"

    if [[ "$DRY_RUN" != "true" ]]; then
        echo
        log_info "Next steps:"
        echo "1. Validate the new repository: ./scripts/validate-extraction.sh $new_repo_path"
        echo "2. Set up remote: cd $new_repo_path && git remote add origin <URL>"
        echo "3. Push to remote: git push -u origin main"
        echo "4. Update team and CI/CD configurations"
        echo "5. Run safe cleanup: ./scripts/safe-cleanup.sh $monorepo_path $project_name <NEW_REPO_URL>"
    fi
}

# Run extraction if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
