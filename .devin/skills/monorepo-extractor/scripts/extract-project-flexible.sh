#!/bin/bash
# Improved monorepo extraction with branch support and flexible validation

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DRY_RUN=false
BRANCH=""
FORCE_VALIDATION=false
SKIP_RESTRUCTURE=false

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
    -b, --branch BRANCH    Clone specific branch (default: current branch)
    -f, --force           Skip validation warnings
    -d, --dry-run         Show what would be done without executing
    -r, --skip-restructure Skip moving files to root directory
    -h, --help            Show this help message

Examples:
    $0 /opt/company-monorepo webapp /opt/webapp-repo
    $0 --branch main ~/projects/company-monorepo libs/shared-utils ~/shared-utils
    $0 --force --branch develop /opt/monorepo apps/api /opt/api-repo
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
            FORCE_VALIDATION=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -r|--skip-restructure)
            SKIP_RESTRUCTURE=true
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

# Flexible validation (less strict than original)
validate_monorepo_state() {
    local monorepo_path="$1"
    
    log_step "Validating monorepo state (flexible mode)"
    
    cd "$monorepo_path"
    
    # Check if it's a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not a git repository: $monorepo_path"
        return 1
    fi
    
    # Check for uncommitted changes (warn, don't fail)
    if git status --porcelain | grep -q .; then
        if [[ "$FORCE_VALIDATION" == "true" ]]; then
            log_warn "Uncommitted changes detected, proceeding with --force"
        else
            log_error "Uncommitted changes detected. Use --force to proceed or commit changes first."
            return 1
        fi
    fi
    
    # Check if project directory exists
    if [[ ! -d "$PROJECT_NAME" ]]; then
        log_error "Project directory not found: $PROJECT_NAME"
        return 1
    fi
    
    log_info "Monorepo validation passed"
}

extract_project_with_branch() {
    local monorepo_path="$1"
    local project_name="$2"
    local new_repo_path="$3"
    local branch="${4:-}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would clone monorepo with branch: ${branch:-current}"
        log_step "[DRY RUN] Would filter history to include only $project_name/"
        log_step "[DRY RUN] Would move to: $new_repo_path"
        return 0
    fi
    
    log_step "Creating repository from branch: ${branch:-current}"
    
    # Clone with specific branch if provided
    if [[ -n "$branch" ]]; then
        git clone -b "$branch" "$monorepo_path" "$new_repo_path"
    else
        git clone "$monorepo_path" "$new_repo_path"
    fi
    
    cd "$new_repo_path"
    
    log_step "Filtering git history for $project_name"
    
    # Use git-filter-repo for clean history extraction
    if command -v git-filter-repo >/dev/null 2>&1; then
        git-filter-repo --path "$project_name/" --force
    else
        log_warn "git-filter-repo not available, using git filter-branch"
        git filter-branch --subdirectory-filter "$project_name" --prune-empty
    fi
    
    log_info "History extraction completed"
}

restructure_project() {
    local new_repo_path="$1"
    local project_name="$2"
    
    if [[ "$SKIP_RESTRUCTURE" == "true" ]]; then
        log_info "Skipping restructuring ( --skip-restructure )"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would move files from $project_name/ to root"
        return 0
    fi
    
    cd "$new_repo_path"
    
    # Check if files are in subdirectory
    if [[ -d "$project_name" ]]; then
        log_step "Moving files from $project_name/ to root directory"
        
        # Move all files to root
        mv "$project_name"/* . 2>/dev/null || true
        mv "$project_name"/.* . 2>/dev/null || true
        
        # Remove empty directory
        rmdir "$project_name" 2>/dev/null || true
        
        # Commit the restructuring
        git add .
        git commit -m "Restructure: Move project files to root directory
        
Extracted from monorepo using git-filter-repo
Original path: $project_name/
Extraction date: $(date +%Y-%m-%d)" || log_warn "No changes to commit"
        
        log_info "Project restructuring completed"
    else
        log_info "Files already at root level"
    fi
}

# Main execution
main() {
    log_info "Starting monorepo extraction (improved version)"
    log_info "Monorepo: $MONOREPO_PATH"
    log_info "Project: $PROJECT_NAME"
    log_info "Destination: $NEW_REPO_PATH"
    log_info "Branch: ${BRANCH:-current}"
    
    # Validate monorepo state (flexible)
    validate_monorepo_state "$MONOREPO_PATH"
    
    # Extract project with branch support
    extract_project_with_branch "$MONOREPO_PATH" "$PROJECT_NAME" "$NEW_REPO_PATH" "$BRANCH"
    
    # Restructure if needed
    restructure_project "$NEW_REPO_PATH" "$PROJECT_NAME"
    
    log_info "Extraction completed successfully!"
    log_info "Repository ready at: $NEW_REPO_PATH"
}

# Run main function
main "$@"
