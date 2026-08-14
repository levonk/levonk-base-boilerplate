#!/bin/bash
# Safe cleanup of extracted project from monorepo
# Ensures team safety and provides rollback mechanisms

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
GRACE_PERIOD_MINUTES=30
ROLLBACK_FILE=".monorepo-extraction-rollback"

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
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME NEW_REPO_URL

Arguments:
    MONOREPO_PATH    Path to the original monorepo
    PROJECT_NAME     Name of the extracted project
    NEW_REPO_URL     URL of the new repository

Options:
    -d, --dry-run      Show what would be done without executing
    -f, --force        Skip safety checks and grace period
    -g, --grace-period MINUTES  Wait time before cleanup (default: 30)
    -r, --rollback     Rollback a previous cleanup
    -h, --help         Show this help message

Examples:
    $0 /opt/company-monorepo webapp https://github.com/company/webapp.git
    $0 --dry-run ~/projects/company-monorepo libs/shared-utils git@github.com:company/shared-utils.git
    $0 --rollback /opt/company-monorepo webapp
EOF
}

create_rollback_info() {
    local monorepo_path="$1"
    local project_name="$2"
    local new_repo_url="$3"
    local backup_tag="$4"
    
    cd "$monorepo_path"
    
    local rollback_file="$project_name/$ROLLBACK_FILE"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would create rollback information file"
        return 0
    fi
    
    cat > "$rollback_file" << EOF
# Monorepo Extraction Rollback Information
# Generated: $(date)

EXTRACTION_INFO:
  Project: $project_name
  New Repository: $new_repo_url
  Backup Tag: $backup_tag
  Extraction Date: $(date +%Y-%m-%d)
  Original Path: $(pwd)/$project_name

ROLLBACK_COMMANDS:
  # Restore project from backup tag
  git checkout $backup_tag -- $project_name/
  
  # Remove rollback file
  rm $project_name/$ROLLBACK_FILE

VERIFICATION:
  # Verify restoration
  git status --porcelain $project_name/
  git log --oneline -1 -- $project_name/

TEAM_COORDINATION:
  # Notify team of rollback
  # Update any CI/CD configurations
  # Verify all dependencies are restored
EOF

    git add "$rollback_file"
    git commit -m "docs: Add rollback information for $project_name extraction"
    
    log_info "Rollback information created: $rollback_file"
}

verify_new_repository() {
    local new_repo_url="$1"
    
    log_step "Verifying new repository accessibility"
    
    # Test if we can connect to the new repository
    if [[ "$new_repo_url" =~ ^https?:// ]]; then
        if curl -fsI "$new_repo_url" >/dev/null 2>&1; then
            log_info "New repository is accessible via HTTP"
        else
            log_warn "Cannot verify new repository accessibility via HTTP"
        fi
    elif [[ "$new_repo_url" =~ ^git@ ]]; then
        # For SSH URLs, we can't easily test without authentication
        log_info "SSH repository URL detected - accessibility will be verified during push"
    else
        log_warn "Unrecognized repository URL format: $new_repo_url"
    fi
}

check_team_activity() {
    local monorepo_path="$1"
    local project_name="$2"
    
    cd "$monorepo_path"
    
    log_step "Checking for recent team activity"
    
    # Check for recent commits in the project (last grace period)
    local recent_activity
    recent_activity=$(git log --since="${GRACE_PERIOD_MINUTES} minutes ago" --oneline -- "$project_name" | wc -l)
    
    if [[ $recent_activity -gt 0 ]]; then
        log_warn "Found $recent_activity recent commits in $project_name"
        log_warn "Team may still be actively working on this project"
        
        if [[ "$DRY_RUN" != "true" ]] && [[ "${FORCE:-false}" != "true" ]]; then
            echo "Recent activity detected:"
            git log --since="${GRACE_PERIOD_MINUTES} minutes ago" --oneline -- "$project_name"
            echo
            read -p "Continue with cleanup despite recent activity? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Cleanup cancelled due to recent activity"
                exit 0
            fi
        fi
    fi
    
    # Check for uncommitted changes
    if git status --porcelain "$project_name" | grep -q .; then
        log_error "Project has uncommitted changes - cannot proceed with cleanup"
        echo "Uncommitted files:"
        git status --porcelain "$project_name"
        exit 1
    fi
    
    log_info "No blocking team activity detected"
}

create_migration_reference() {
    local monorepo_path="$1"
    local project_name="$2"
    local new_repo_url="$3"
    local backup_tag="$4"
    
    cd "$monorepo_path"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would create migration reference in project directory"
        return 0
    fi
    
    log_step "Creating migration reference"
    
    # Create a comprehensive README for the migrated project location
    cat > "$project_name/README.md" << EOF
# Project Migrated 🚀

This project has been successfully extracted to its own repository.

## 📍 New Location

**Repository:** $new_repo_url

## 📋 Migration Details

- **Extraction Date:** $(date +%Y-%m-%d)
- **Original Location:** \`$(pwd)/$project_name/\`
- **Backup Tag:** \`$backup_tag\` (in this monorepo)

## 🔄 What to Do Next

1. **Update your local repository:**
   \`\`\`bash
   cd /path/to/new/location
   git clone $new_repo_url
   \`\`\`

2. **Update any scripts or configurations:**
   - CI/CD pipelines
   - Build scripts
   - Dependency references
   - Documentation links

3. **Notify your team:**
   - Update team communication channels
   - Update project documentation
   - Update any external references

## 🛠️ Rollback Information

If you need to rollback this extraction for any reason, the original project state is preserved with the tag \`$backup_tag\`.

To restore:
\`\`\`bash
git checkout $backup_tag -- $project_name/
\`\`\`

## 📞 Support

If you encounter any issues with the migration:
1. Check the new repository for completeness
2. Verify all git history was transferred
3. Contact the migration team with the backup tag: \`$backup_tag\`

---

*This directory is preserved as a reference. The active development now occurs in the new repository.*
EOF

    git add "$project_name/README.md"
    git commit -m "docs: Add migration reference for $project_name"
    
    log_info "Migration reference created"
}

safe_remove_project() {
    local monorepo_path="$1"
    local project_name="$2"
    
    cd "$monorepo_path"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_step "[DRY RUN] Would remove project directory: $project_name"
        return 0
    fi
    
    log_step "Removing project directory from monorepo"
    
    # Create a final backup before removal
    local final_backup_tag="pre-removal-${project_name}-$(date +%Y%m%d-%H%M%S)"
    git tag -a "$final_backup_tag" -m "Final backup before removing $project_name"
    
    # Remove the project directory
    git rm -r "$project_name"
    git commit -m "feat: Remove $project_name (extracted to $new_repo_url)"
    
    log_info "Project directory removed from monorepo"
    log_info "Final backup tag: $final_backup_tag"
}

perform_rollback() {
    local monorepo_path="$1"
    local project_name="$2"
    
    cd "$monorepo_path"
    
    log_step "Performing rollback for $project_name"
    
    local rollback_file="$project_name/$ROLLBACK_FILE"
    
    if [[ ! -f "$rollback_file" ]]; then
        log_error "Rollback information not found: $rollback_file"
        exit 1
    fi
    
    # Extract backup tag from rollback file
    local backup_tag
    backup_tag=$(grep "Backup Tag:" "$rollback_file" | cut -d: -f2 | tr -d ' ')
    
    log_info "Restoring from backup tag: $backup_tag"
    
    # Restore project from backup tag
    git checkout "$backup_tag" -- "$project_name/"
    
    # Remove rollback file
    rm "$rollback_file"
    git add "$rollback_file"
    git commit -m "docs: Remove rollback information after restoration"
    
    log_info "Rollback completed successfully"
    log_info "Project $project_name has been restored to monorepo"
}

wait_for_confirmation() {
    local grace_seconds=$((GRACE_PERIOD_MINUTES * 60))
    
    if [[ "$DRY_RUN" == "true" ]] || [[ "${FORCE:-false}" == "true" ]]; then
        log_info "Skipping grace period (dry run or force mode)"
        return 0
    fi
    
    log_step "Starting grace period for team confirmation"
    log_info "Waiting $GRACE_PERIOD_MINUTES minutes for final confirmation..."
    log_info "Press Ctrl+C to cancel cleanup"
    
    for ((i=grace_seconds; i>0; i--)); do
        printf "\rTime remaining: %02d:%02d" $((i/60)) $((i%60))
        sleep 1
    done
    printf "\rGrace period completed. Proceeding with cleanup...\n"
}

main() {
    local monorepo_path=""
    local project_name=""
    local new_repo_url=""
    local rollback_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                export FORCE=true
                shift
                ;;
            -g|--grace-period)
                GRACE_PERIOD_MINUTES="$2"
                shift 2
                ;;
            -r|--rollback)
                rollback_mode=true
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
                elif [[ -z "$new_repo_url" ]]; then
                    new_repo_url="$1"
                else
                    log_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate arguments based on mode
    if [[ "$rollback_mode" == "true" ]]; then
        if [[ -z "$monorepo_path" ]] || [[ -z "$project_name" ]]; then
            log_error "Rollback mode requires monorepo path and project name"
            show_usage
            exit 1
        fi
    else
        if [[ -z "$monorepo_path" ]] || [[ -z "$project_name" ]] || [[ -z "$new_repo_url" ]]; then
            log_error "All arguments are required: monorepo path, project name, new repo URL"
            show_usage
            exit 1
        fi
    fi
    
    echo "=== Monorepo Safe Cleanup ==="
    if [[ "$rollback_mode" == "true" ]]; then
        echo "Mode: Rollback"
        echo "Monorepo: $monorepo_path"
        echo "Project: $project_name"
    else
        echo "Monorepo: $monorepo_path"
        echo "Project: $project_name"
        echo "New Repository: $new_repo_url"
        echo "Grace Period: $GRACE_PERIOD_MINUTES minutes"
        echo "Dry Run: $DRY_RUN"
    fi
    echo
    
    # Validate monorepo path
    if [[ ! -d "$monorepo_path" ]]; then
        log_error "Monorepo path does not exist: $monorepo_path"
        exit 1
    fi
    
    if [[ ! -d "$monorepo_path/.git" ]]; then
        log_error "Monorepo path is not a git repository: $monorepo_path"
        exit 1
    fi
    
    cd "$monorepo_path"
    
    # Perform rollback if requested
    if [[ "$rollback_mode" == "true" ]]; then
        perform_rollback "$monorepo_path" "$project_name"
        exit 0
    fi
    
    # Normal cleanup flow
    check_team_activity "$monorepo_path" "$project_name"
    verify_new_repository "$new_repo_url"
    
    # Create backup tag
    local backup_tag="${BACKUP_TAG_PREFIX}-${project_name}-$(date +%Y%m%d-%H%M%S)"
    if [[ "$DRY_RUN" != "true" ]]; then
        git tag -a "$backup_tag" -m "Pre-cleanup backup of $project_name"
        log_info "Backup tag created: $backup_tag"
    else
        log_step "[DRY RUN] Would create backup tag: $backup_tag"
    fi
    
    # Create rollback information
    create_rollback_info "$monorepo_path" "$project_name" "$new_repo_url" "$backup_tag"
    
    # Create migration reference
    create_migration_reference "$monorepo_path" "$project_name" "$new_repo_url" "$backup_tag"
    
    # Wait for confirmation
    wait_for_confirmation
    
    # Safe removal
    safe_remove_project "$monorepo_path" "$project_name"
    
    echo
    log_info "✓ Cleanup completed successfully!"
    log_info "Project $project_name has been safely removed from monorepo"
    log_info "New repository: $new_repo_url"
    log_info "Backup tag: $backup_tag"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo
        log_info "Final reminders:"
        echo "1. Update all CI/CD configurations to point to new repository"
        echo "2. Notify team of the migration completion"
        echo "3. Update any documentation or links"
        echo "4. Monitor new repository for any issues"
    fi
}

# Run cleanup if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
