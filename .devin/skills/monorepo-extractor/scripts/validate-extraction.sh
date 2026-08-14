#!/bin/bash
# Comprehensive validation of extracted monorepo project
# Ensures repository integrity, history completeness, and readiness for production

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validation thresholds
MIN_COMMITS=1
MAX_SIZE_MB=1000
WARN_SIZE_MB=500

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
Usage: $0 [OPTIONS] NEW_REPO_PATH

Arguments:
    NEW_REPO_PATH    Path to the extracted repository to validate

Options:
    -v, --verbose    Show detailed validation output
    -q, --quiet      Suppress non-error output
    -h, --help       Show this help message

Examples:
    $0 /opt/webapp-repo
    $0 --verbose ~/extracted-projects/shared-utils
EOF
}

validate_repository_structure() {
    local repo_path="$1"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    log_step "Validating repository structure"
    
    # Check if it's a git repository
    if [[ ! -d ".git" ]]; then
        log_error "Not a git repository: $repo_path"
        return 1
    fi
    
    # Check for essential files
    local missing_files=()
    local expected_files=("README.md" ".gitignore")
    
    for file in "${expected_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_warn "Missing expected files: ${missing_files[*]}"
    fi
    
    # Check for project structure indicators
    local project_indicators=("src" "lib" "package.json" "Cargo.toml" "pyproject.toml" "go.mod")
    local found_indicators=()
    
    for indicator in "${project_indicators[@]}"; do
        if [[ -f "$indicator" ]] || [[ -d "$indicator" ]]; then
            found_indicators+=("$indicator")
        fi
    done
    
    if [[ ${#found_indicators[@]} -eq 0 ]]; then
        log_warn "No common project structure indicators found"
    else
        if [[ "$verbose" == "true" ]]; then
            log_info "Found project indicators: ${found_indicators[*]}"
        fi
    fi
    
    log_info "Repository structure validation passed"
}

validate_git_integrity() {
    local repo_path="$1"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    log_step "Validating git integrity"
    
    # Run git fsck to check repository integrity
    local fsck_output
    fsck_output=$(git fsck --full 2>&1 || true)
    
    if [[ -n "$fsck_output" ]]; then
        log_error "Git repository integrity issues found:"
        echo "$fsck_output"
        return 1
    fi
    
    # Check for proper HEAD reference
    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        log_warn "Repository is in detached HEAD state"
    fi
    
    # Verify all objects are accessible
    local loose_objects
    loose_objects=$(git count-objects -v | grep 'in-pack' | cut -d: -f2 | tr -d ' ')
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Loose objects: $loose_objects"
    fi
    
    log_info "Git integrity validation passed"
}

validate_history_completeness() {
    local repo_path="$1"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    log_step "Validating history completeness"
    
    # Check if repository has commits
    local commit_count
    commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    
    if [[ $commit_count -lt $MIN_COMMITS ]]; then
        log_error "Repository has only $commit_count commits (minimum: $MIN_COMMITS)"
        return 1
    fi
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Total commits: $commit_count"
        
        # Show commit history summary
        echo "Recent commits:"
        git log --oneline -10
        echo
    fi
    
    # Check for commit date range
    local first_commit_date
    local last_commit_date
    
    first_commit_date=$(git log --reverse --format="%ci" | head -n1)
    last_commit_date=$(git log --format="%ci" | head -n1)
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Commit range: $first_commit_date to $last_commit_date"
    fi
    
    # Check for reasonable commit timeline
    if [[ -n "$first_commit_date" ]] && [[ -n "$last_commit_date" ]]; then
        local first_timestamp
        local last_timestamp
        first_timestamp=$(date -d "$first_commit_date" +%s 2>/dev/null || echo "0")
        last_timestamp=$(date -d "$last_commit_date" +%s 2>/dev/null || echo "0")
        
        if [[ $first_timestamp -gt $last_timestamp ]]; then
            log_warn "Commit timeline appears inconsistent"
        fi
    fi
    
    log_info "History completeness validation passed"
}

validate_file_integrity() {
    local repo_path="$1"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    log_step "Validating file integrity"
    
    # Check repository size
    local repo_size
    repo_size=$(du -sm . | cut -f1)
    
    if [[ $repo_size -gt $MAX_SIZE_MB ]]; then
        log_error "Repository size ${repo_size}MB exceeds maximum ${MAX_SIZE_MB}MB"
        return 1
    elif [[ $repo_size -gt $WARN_SIZE_MB ]]; then
        log_warn "Repository size ${repo_size}MB is large (warning threshold: ${WARN_SIZE_MB}MB)"
    fi
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Repository size: ${repo_size}MB"
    fi
    
    # Check for potential monorepo artifacts
    local artifacts=(".gitmodules" "*.lock" "*.tmp" "node_modules/.cache" ".cache")
    local found_artifacts=()
    
    for artifact in "${artifacts[@]}"; do
        if find . -name "$artifact" | grep -q .; then
            found_artifacts+=("$artifact")
        fi
    done
    
    if [[ ${#found_artifacts[@]} -gt 0 ]]; then
        log_warn "Found potential monorepo artifacts: ${found_artifacts[*]}"
    fi
    
    # Check for empty directories that might indicate missing content
    local empty_dirs=()
    while IFS= read -r -d '' dir; do
        if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
            empty_dirs+=("$dir")
        fi
    done < <(find . -type d -print0)
    
    if [[ ${#empty_dirs[@]} -gt 0 ]] && [[ "$verbose" == "true" ]]; then
        log_info "Empty directories found: ${empty_dirs[*]}"
    fi
    
    log_info "File integrity validation passed"
}

validate_remote_connectivity() {
    local repo_path="$1"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    log_step "Validating remote connectivity"
    
    # Check if remote is configured
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_info "No remote configured - local repository only"
        return 0
    fi
    
    local remote_url
    remote_url=$(git remote get-url origin)
    
    if [[ "$verbose" == "true" ]]; then
        log_info "Remote URL: $remote_url"
    fi
    
    # Test remote connectivity (if possible)
    if [[ "$remote_url" =~ ^https?:// ]] || [[ "$remote_url" =~ ^git@ ]]; then
        if git ls-remote origin >/dev/null 2>&1; then
            log_info "Remote connectivity verified"
        else
            log_warn "Remote connectivity test failed"
        fi
    else
        log_info "Local remote URL - skipping connectivity test"
    fi
    
    # Check for unpushed commits
    local unpushed_commits
    unpushed_commits=$(git log --oneline origin/main..HEAD 2>/dev/null | wc -l)
    
    if [[ $unpushed_commits -gt 0 ]]; then
        log_warn "$unpushed_commits commits not pushed to remote"
    fi
}

generate_validation_report() {
    local repo_path="$1"
    local report_file="$2"
    
    cd "$repo_path"
    
    {
        echo "# Repository Validation Report"
        echo "Generated: $(date)"
        echo "Repository: $repo_path"
        echo
        
        echo "## Repository Information"
        echo "- Total commits: $(git rev-list --count HEAD)"
        echo "- Repository size: $(du -sh . | cut -f1)"
        echo "- Current branch: $(git branch --show-current)"
        echo "- Last commit: $(git log -1 --format='%h %s')"
        echo
        
        echo "## File Structure"
        echo "- Total files: $(find . -type f | wc -l)"
        echo "- Directories: $(find . -type d | wc -l)"
        echo "- Languages detected:"
        find . -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" | \
            sed 's/.*\.//' | sort | uniq -c | sort -nr || true
        echo
        
        echo "## Git Status"
        git status --porcelain || true
        echo
        
        echo "## Recent Activity"
        git log --oneline -5 || true
    } > "$report_file"
    
    log_info "Validation report generated: $report_file"
}

main() {
    local repo_path=""
    local verbose=false
    local quiet=false
    
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
    
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path does not exist: $repo_path"
        exit 1
    fi
    
    if [[ "$quiet" != "true" ]]; then
        echo "=== Repository Validation ==="
        echo "Repository: $repo_path"
        echo "Verbose: $verbose"
        echo
    fi
    
    # Run validations
    local validation_passed=true
    
    if ! validate_repository_structure "$repo_path" "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_git_integrity "$repo_path" "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_history_completeness "$repo_path" "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_file_integrity "$repo_path" "$verbose"; then
        validation_passed=false
    fi
    
    if ! validate_remote_connectivity "$repo_path" "$verbose"; then
        validation_passed=false
    fi
    
    # Generate report
    local report_file="${repo_path}/validation-report-$(date +%Y%m%d-%H%M%S).md"
    generate_validation_report "$repo_path" "$report_file"
    
    echo
    if [[ "$validation_passed" == "true" ]]; then
        log_info "✓ All validations passed successfully"
        log_info "Repository is ready for production use"
        exit 0
    else
        log_error "✗ Some validations failed"
        log_error "Please address issues before proceeding"
        exit 1
    fi
}

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
