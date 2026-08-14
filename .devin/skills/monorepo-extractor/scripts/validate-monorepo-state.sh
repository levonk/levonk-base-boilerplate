#!/bin/bash
# Comprehensive monorepo state validation before extraction
# Ensures all changes are committed, pushed, and validated remotely

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validation thresholds
MAX_UNPUSHED_COMMITS=5
MAX_STASH_ENTRIES=3
REMOTE_TIMEOUT=30

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
Usage: $0 [OPTIONS] MONOREPO_PATH

Arguments:
    MONOREPO_PATH    Path to the monorepo to validate

Options:
    -v, --verbose    Show detailed validation output
    -q, --quiet      Suppress non-error output
    -f, --force      Continue despite warnings
    -h, --help       Show this help message

Examples:
    $0 /opt/company-monorepo
    $0 --verbose ~/projects/company-monorepo
EOF
}

validate_git_repository() {
    local repo_path="$1"
    
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path does not exist: $repo_path"
        return 1
    fi
    
    if [[ ! -d "$repo_path/.git" ]]; then
        log_error "Not a git repository: $repo_path"
        return 1
    fi
    
    cd "$repo_path"
    
    # Check if repository is in a valid state
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Repository is corrupted or invalid"
        return 1
    fi
    
    log_info "Repository structure is valid"
}

validate_working_directory_clean() {
    local verbose="${1:-false}"
    
    log_step "Checking working directory cleanliness"
    
    # Check for uncommitted changes
    local uncommitted_files
    uncommitted_files=$(git status --porcelain 2>/dev/null || true)
    
    if [[ -n "$uncommitted_files" ]]; then
        log_error "Found uncommitted changes:"
        echo "$uncommitted_files"
        
        if [[ "$verbose" == "true" ]]; then
            echo
            echo "Detailed status:"
            git status --long
        fi
        
        return 1
    fi
    
    # Check for stashed changes
    local stash_count
    stash_count=$(git stash list 2>/dev/null | wc -l)
    
    if [[ $stash_count -gt 0 ]]; then
        log_warn "Found $stash_count stashed entries"
        
        if [[ $stash_count -gt $MAX_STASH_ENTRIES ]]; then
            log_error "Too many stashed entries ($stash_count > $MAX_STASH_ENTRIES)"
            if [[ "$verbose" == "true" ]]; then
                echo "Stash entries:"
                git stash list
            fi
            return 1
        fi
        
        if [[ "$verbose" == "true" ]]; then
            echo "Stash entries:"
            git stash list
        fi
    fi
    
    log_info "Working directory is clean"
}

validate_remote_connectivity() {
    local verbose="${1:-false}"
    
    log_step "Validating remote connectivity"
    
    # Check if remote is configured
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_warn "No remote 'origin' configured - local repository only"
        return 0
    fi
    
    local remote_url
    remote_url=$(git remote get-url origin)
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Remote URL: $remote_url"
    fi
    
    # Test remote connectivity with timeout
    if timeout $REMOTE_TIMEOUT git ls-remote origin >/dev/null 2>&1; then
        log_info "Remote connectivity verified"
    else
        log_error "Remote connectivity test failed"
        if [[ "$verbose" == "true" ]]; then
            echo "This could indicate:"
            echo "- Network connectivity issues"
            echo "- Authentication problems"
            echo "- Repository does not exist remotely"
            echo "- Insufficient permissions"
        fi
        return 1
    fi
}

validate_branch_sync() {
    local verbose="${1:-false}"
    
    log_step "Validating branch synchronization"
    
    # Get current branch
    local current_branch
    current_branch=$(git branch --show-current)
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Current branch: $current_branch"
    fi
    
    # Check if branch exists remotely
    if ! git ls-remote --exit-code origin "refs/heads/$current_branch" >/dev/null 2>&1; then
        log_warn "Branch '$current_branch' does not exist remotely"
        log_warn "This is normal for new branches"
        return 0
    fi
    
    # Check for unpushed commits
    local unpushed_commits
    unpushed_commits=$(git log --oneline "origin/$current_branch..HEAD" 2>/dev/null | wc -l)
    
    if [[ $unpushed_commits -gt 0 ]]; then
        log_error "Found $unpushed_commits unpushed commits"
        
        if [[ $unpushed_commits -gt $MAX_UNPUSHED_COMMITS ]]; then
            log_error "Too many unpushed commits ($unpushed_commits > $MAX_UNPUSHED_COMMITS)"
        fi
        
        if [[ "$verbose" == "true" ]]; then
            echo "Unpushed commits:"
            git log --oneline "origin/$current_branch..HEAD"
        fi
        
        return 1
    fi
    
    # Check for unpulled commits
    local unpulled_commits
    unpulled_commits=$(git log --oneline "HEAD..origin/$current_branch" 2>/dev/null | wc -l)
    
    if [[ $unpulled_commits -gt 0 ]]; then
        log_warn "Found $unpulled_commits unpulled commits from remote"
        
        if [[ "$verbose" == "true" ]]; then
            echo "Unpulled commits:"
            git log --oneline "HEAD..origin/$current_branch"
        fi
    fi
    
    log_info "Branch is synchronized with remote"
}

validate_repository_integrity() {
    local verbose="${1:-false}"
    
    log_step "Validating repository integrity"
    
    # Run git fsck to check for corruption
    local fsck_output
    fsck_output=$(git fsck --full 2>&1 || true)
    
    if [[ -n "$fsck_output" ]]; then
        log_error "Repository integrity issues found:"
        echo "$fsck_output"
        return 1
    fi
    
    # Check for proper HEAD reference
    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        log_warn "Repository is in detached HEAD state"
        if [[ "$verbose" == "true" ]]; then
            echo "Current commit: $(git rev-parse HEAD)"
        fi
    fi
    
    # Verify object database
    local object_count
    object_count=$(git count-objects -v | grep 'count' | cut -d: -f2 | tr -d ' ')
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Objects in database: $object_count"
    fi
    
    log_info "Repository integrity is valid"
}

validate_recent_activity() {
    local project_name="$1"
    local verbose="${2:-false}"
    
    log_step "Checking recent activity in project"
    
    # Check for recent commits in the project (last hour)
    local recent_commits
    recent_commits=$(git log --since="1 hour ago" --oneline -- "$project_name" 2>/dev/null | wc -l)
    
    if [[ $recent_commits -gt 0 ]]; then
        log_warn "Found $recent_commits recent commits in $project_name (last hour)"
        
        if [[ "$verbose" == "true" ]]; then
            echo "Recent commits:"
            git log --since="1 hour ago" --oneline -- "$project_name"
        fi
        
        return 1
    fi
    
    # Check for ongoing operations
    if [[ -f ".git/index.lock" ]]; then
        log_error "Git operation appears to be in progress (index.lock exists)"
        return 1
    fi
    
    log_info "No blocking recent activity detected"
}

generate_validation_report() {
    local repo_path="$1"
    local report_file="$2"
    
    cd "$repo_path"
    
    {
        echo "# Monorepo State Validation Report"
        echo "Generated: $(date)"
        echo "Repository: $repo_path"
        echo
        
        echo "## Repository Information"
        echo "- Current branch: $(git branch --show-current)"
        echo "- Total commits: $(git rev-list --count HEAD)"
        echo "- Repository size: $(du -sh . | cut -f1)"
        echo "- Last commit: $(git log -1 --format='%h %s')"
        echo
        
        echo "## Remote Status"
        if git remote get-url origin >/dev/null 2>&1; then
            echo "- Remote URL: $(git remote get-url origin)"
            echo "- Remote connectivity: $(timeout 10 git ls-remote origin >/dev/null 2>&1 && echo "✓ OK" || echo "✗ Failed")"
        else
            echo "- Remote: Not configured"
        fi
        echo
        
        echo "## Working Directory Status"
        echo "- Uncommitted changes: $(git status --porcelain | wc -l)"
        echo "- Stashed entries: $(git stash list | wc -l)"
        echo "- Unpushed commits: $(git log --oneline origin/$(git branch --show-current)..HEAD 2>/dev/null | wc -l)"
        echo
        
        echo "## Repository Health"
        echo "- Git fsck: $(git fsck --full 2>&1 | wc -l) issues found"
        echo "- Object count: $(git count-objects -v | grep 'count' | cut -d: -f2 | tr -d ' ')"
        echo
    } > "$report_file"
    
    log_info "Validation report generated: $report_file"
}

main() {
    local repo_path=""
    local verbose=false
    local quiet=false
    local force=false
    local project_name=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -f|--force)
                force=true
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
                if [[ -z "$repo_path" ]]; then
                    repo_path="$1"
                elif [[ -z "$project_name" ]]; then
                    project_name="$1"
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
    if [[ -z "$repo_path" ]]; then
        log_error "Repository path is required"
        show_usage
        exit 1
    fi
    
    if [[ "$quiet" != "true" ]]; then
        echo "=== Monorepo State Validation ==="
        echo "Repository: $repo_path"
        echo "Verbose: $verbose"
        echo "Force: $force"
        if [[ -n "$project_name" ]]; then
            echo "Project: $project_name"
        fi
        echo
    fi
    
    # Run validations
    local validation_passed=true
    
    if ! validate_git_repository "$repo_path"; then
        validation_passed=false
    fi
    
    if ! validate_working_directory_clean "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_remote_connectivity "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_branch_sync "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_repository_integrity "$verbose"; then
        validation_passed=false
    fi
    
    # Check recent activity only if project name is provided
    if [[ -n "$project_name" ]]; then
        if ! validate_recent_activity "$project_name" "$verbose"; then
            if [[ "$force" != "true" ]]; then
                validation_passed=false
            else
                log_warn "Recent activity detected but continuing due to --force flag"
            fi
        fi
    fi
    
    # Generate report
    local report_file="${repo_path}/monorepo-validation-$(date +%Y%m%d-%H%M%S).md"
    generate_validation_report "$repo_path" "$report_file"
    
    echo
    if [[ "$validation_passed" == "true" ]]; then
        log_info "✓ All validations passed successfully"
        log_info "Monorepo is ready for extraction"
        exit 0
    else
        log_error "✗ Some validations failed"
        log_error "Please address issues before proceeding with extraction"
        
        if [[ "$force" != "true" ]]; then
            echo
            echo "To bypass these warnings, use --force flag"
            exit 1
        else
            log_warn "Continuing despite validation failures due to --force flag"
            exit 0
        fi
    fi
}

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
