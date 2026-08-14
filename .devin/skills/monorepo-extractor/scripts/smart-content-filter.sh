#!/bin/bash
# Smart content filtering for monorepo extraction
# Intelligently filters and adapts content for standalone repository migration

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

log_debug() {
    echo -e "${CYAN}DEBUG:${NC} $1"
}

log_action() {
    echo -e "${MAGENTA}ACTION:${NC} $1"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME DEST_PATH

Arguments:
    MONOREPO_PATH    Path to the monorepo
    PROJECT_NAME     Name of the project to extract
    DEST_PATH        Destination path for the filtered content

Options:
    -v, --verbose    Show detailed filtering output
    -d, --dry-run    Show what would be filtered without making changes
    -f, --force      Force overwrite existing files in destination
    -k, --keep       Keep low-relevance files (default: filter out)
    -h, --help       Show this help message

Examples:
    $0 /opt/company-monorepo webapp /opt/filtered-webapp
    $0 --dry-run --verbose /opt/company-monorepo webapp /opt/filtered-webapp
    $0 --keep /opt/company-monorepo shared-utils /opt/filtered-shared-utils
EOF
}

# Content filtering patterns
declare -A MONOREPO_PATTERNS=(
    # Monorepo-specific phrases to clean
    ["monorepo"]="standalone repository"
    ["this repository contains"]="this project provides"
    ["part of larger"]="independent project"
    ["shared with"]="self-contained"
    ["in the monorepo"]="in this project"
    ["across the repository"]="within this project"
    ["repository-wide"]="project-specific"
    ["monorepo root"]="project root"
    ["top-level"]="project-level"
    ["shared dependencies"]="project dependencies"
    ["common configuration"]="project configuration"
)

# Project-specific patterns to preserve/enhance
declare -A PROJECT_PATTERNS=(
    ["$PROJECT_NAME"]="[PROJECT_NAME]"
    ["the project"]="this standalone project"
    ["this project"]="this independent project"
)

# File patterns to filter based on relevance
declare -A FILTER_PATTERNS=(
    # High relevance (7-10) - always keep
    ["README.md"]="keep"
    ["AGENTS.md"]="keep"
    ["MEMORY.md"]="keep"
    ["TOOLS.md"]="keep"
    ["IDENTITY.md"]="keep"
    ["WORKFLOW.md"]="keep"
    [".windsurf/"]="keep"
    [".cursor/"]="keep"
    [".agents/"]="keep"
    [".tickets/"]="keep"
    
    # Medium relevance (5-6) - keep if project-specific
    ["SOUL.md"]="conditional"
    ["USER.md"]="conditional"
    ["HEARTBEAT.md"]="conditional"
    ["PROMPTS.md"]="conditional"
    ["SKILLS.md"]="conditional"
    ["AGENT.md"]="conditional"
    [".claud/"]="conditional"
    [".gemini/"]="conditional"
    [".qwen/"]="conditional"
    [".crush/"]="conditional"
    [".clienrules/"]="conditional"
    [".vscode/"]="conditional"
    
    # Low relevance (1-4) - filter unless explicitly requested
    [".devbox/"]="filter"
    [".iflow/"]="filter"
    [".specify/"]="filter"
    [".trae/"]="filter"
)

# Filter content within files
filter_file_content() {
    local src_file="$1"
    local dest_file="$2"
    local project_name="$3"
    local verbose="${4:-false}"
    
    if [[ ! -f "$src_file" ]]; then
        return 1
    fi
    
    log_debug "Filtering content: $src_file -> $dest_file"
    
    # Create destination directory if needed
    mkdir -p "$(dirname "$dest_file")"
    
    # Start with original content
    local content
    content=$(cat "$src_file")
    
    # Apply monorepo pattern replacements
    for pattern in "${!MONOREPO_PATTERNS[@]}"; do
        replacement="${MONOREPO_PATTERNS[$pattern]}"
        if echo "$content" | grep -qi "$pattern"; then
            content=$(echo "$content" | sed -E "s/$pattern/$replacement/gi")
            if [[ "$verbose" == "true" ]]; then
                log_debug "  Replaced '$pattern' with '$replacement'"
            fi
        fi
    done
    
    # Apply project-specific enhancements
    content=$(echo "$content" | sed "s/\[PROJECT_NAME\]/$project_name/g")
    
    # Remove monorepo-specific sections
    content=$(echo "$content" | sed '/## Monorepo Specific/,/^$/d')
    content=$(echo "$content" | sed '/# Monorepo/,/^$/d')
    content=$(echo "$content" | sed '/<!-- monorepo-only -->/,/<!-- \/monorepo-only -->/d')
    
    # Clean up extra whitespace
    content=$(echo "$content" | sed '/^$/N;/^\n$/d')
    
    # Write filtered content
    echo "$content" > "$dest_file"
    
    if [[ "$verbose" == "true" ]]; then
        local original_size
        local filtered_size
        original_size=$(wc -c < "$src_file")
        filtered_size=$(wc -c < "$dest_file")
        log_debug "  Size: $original_size -> $filtered_size bytes"
    fi
    
    return 0
}

# Determine if file should be kept based on relevance and project-specific content
should_keep_file() {
    local file_path="$1"
    local project_name="$2"
    local keep_low_relevance="${3:-false}"
    
    # Check file pattern relevance
    local action="filter"
    for pattern in "${!FILTER_PATTERNS[@]}"; do
        if [[ "$file_path" == "$pattern" ]] || [[ "$file_path" == "$pattern"* ]]; then
            action="${FILTER_PATTERNS[$pattern]}"
            break
        fi
    done
    
    case "$action" in
        "keep")
            return 0
            ;;
        "filter")
            if [[ "$keep_low_relevance" == "true" ]]; then
                return 0
            else
                return 1
            fi
            ;;
        "conditional")
            # Check if file contains project-specific content
            if [[ -f "$file_path" ]] && grep -q -i "$project_name" "$file_path" 2>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# Filter directory recursively
filter_directory() {
    local src_dir="$1"
    local dest_dir="$2"
    local project_name="$3"
    local keep_low_relevance="${4:-false}"
    local verbose="${5:-false}"
    local dry_run="${6:-false}"
    
    if [[ ! -d "$src_dir" ]]; then
        return 1
    fi
    
    log_debug "Filtering directory: $src_dir -> $dest_dir"
    
    # Create destination directory
    if [[ "$dry_run" != "true" ]]; then
        mkdir -p "$dest_dir"
    fi
    
    # Process all items in directory
    while IFS= read -r -d '' item; do
        local relative_path
        relative_path="${item#$src_dir/}"
        local dest_item="$dest_dir/$relative_path"
        
        if [[ -d "$item" ]]; then
            # Recursively filter subdirectory
            filter_directory "$item" "$dest_item" "$project_name" "$keep_low_relevance" "$verbose" "$dry_run"
        elif [[ -f "$item" ]]; then
            # Check if file should be kept
            if should_keep_file "$relative_path" "$project_name" "$keep_low_relevance"; then
                if [[ "$dry_run" == "true" ]]; then
                    log_action "WOULD KEEP: $relative_path"
                else
                    if [[ "$relative_path" == *.md ]]; then
                        filter_file_content "$item" "$dest_item" "$project_name" "$verbose"
                        log_action "FILTERED: $relative_path"
                    else
                        # Copy non-markdown files as-is
                        cp "$item" "$dest_item"
                        log_action "COPIED: $relative_path"
                    fi
                fi
            else
                if [[ "$verbose" == "true" || "$dry_run" == "true" ]]; then
                    log_debug "FILTERED OUT: $relative_path (low relevance)"
                fi
            fi
        fi
    done < <(find "$src_dir" -print0)
    
    return 0
}

# Generate filtering report
generate_filtering_report() {
    local src_path="$1"
    local dest_path="$2"
    local project_name="$3"
    local report_file="$4"
    
    log_info "Generating filtering report: $report_file"
    
    # Count files in source and destination
    local src_files
    local dest_files
    src_files=$(find "$src_path" -type f | wc -l)
    dest_files=$(find "$dest_path" -type f 2>/dev/null | wc -l || echo 0)
    
    # Calculate sizes
    local src_size
    local dest_size
    src_size=$(du -sb "$src_path" | cut -f1)
    dest_size=$(du -sb "$dest_path" 2>/dev/null | cut -f1 || echo 0)
    
    # List high priority files
    local high_priority_files=()
    for pattern in "${!FILTER_PATTERNS[@]}"; do
        if [[ "${FILTER_PATTERNS[$pattern]}" == "keep" ]]; then
            if [[ -e "$dest_path/$pattern" ]]; then
                high_priority_files+=("$pattern")
            fi
        fi
    done
    
    cat > "$report_file" << EOF
# Monorepo Extraction Filtering Report

## Summary
- **Source Path**: $src_path
- **Destination Path**: $dest_path
- **Project Name**: $project_name
- **Files Processed**: $src_files -> $dest_files
- **Size Reduction**: $src_size -> $dest_size bytes
- **Compression Ratio**: $(echo "scale=2; $dest_size * 100 / $src_size" | bc -l)%

## High Priority Files Migrated
$(printf '- %s\n' "${high_priority_files[@]}")

## Filtering Actions Taken
- Replaced monorepo-specific terminology
- Removed monorepo-only sections
- Enhanced project-specific references
- Filtered low-relevance configuration files

## Recommendations
1. Review filtered content for accuracy
2. Test AI/IDE configurations in new environment
3. Update any remaining monorepo references
4. Consider adding project-specific setup instructions

## Next Steps
1. Commit filtered content to new repository
2. Set up CI/CD for standalone project
3. Update documentation and README
4. Notify team of new repository location
EOF

    log_info "Filtering report generated"
}

# Main filtering function
smart_content_filter() {
    local monorepo_path="$1"
    local project_name="$2"
    local dest_path="$3"
    local verbose="${4:-false}"
    local dry_run="${5:-false}"
    local force="${6:-false}"
    local keep_low_relevance="${7:-false}"
    
    log_step "Starting smart content filtering"
    
    # Validate inputs
    if [[ ! -d "$monorepo_path" ]]; then
        log_error "Monorepo path does not exist: $monorepo_path"
        return 1
    fi
    
    if [[ -d "$dest_path" && "$force" != "true" ]]; then
        log_error "Destination path exists and --force not specified: $dest_path"
        return 1
    fi
    
    # Create destination directory
    if [[ "$dry_run" != "true" ]]; then
        if [[ -d "$dest_path" ]]; then
            rm -rf "$dest_path"
        fi
        mkdir -p "$dest_path"
    fi
    
    # Change to monorepo directory
    cd "$monorepo_path" || {
        log_error "Failed to change directory: $monorepo_path"
        return 1
    }
    
    local filtered_count=0
    local total_count=0
    
    # Process AI/IDE configurations and documentation
    log_step "Processing AI/IDE configurations and documentation"
    
    for config in "${!AI_IDE_CONFIGS[@]}"; do
        total_count=$((total_count + 1))
        
        if [[ "$config" == *".md" ]]; then
            # Process markdown file
            if [[ -f "$config" ]]; then
                if should_keep_file "$config" "$project_name" "$keep_low_relevance"; then
                    if [[ "$dry_run" == "true" ]]; then
                        log_action "WOULD FILTER: $config"
                    else
                        filter_file_content "$config" "$dest_path/$config" "$project_name" "$verbose"
                        log_action "FILTERED: $config"
                    fi
                    filtered_count=$((filtered_count + 1))
                else
                    if [[ "$verbose" == "true" ]]; then
                        log_debug "SKIPPED: $config (low relevance)"
                    fi
                fi
            fi
        else
            # Process directory
            if [[ -d "$config" ]]; then
                if should_keep_file "$config/" "$project_name" "$keep_low_relevance"; then
                    filter_directory "$config" "$dest_path/$config" "$project_name" "$keep_low_relevance" "$verbose" "$dry_run"
                    filtered_count=$((filtered_count + 1))
                else
                    if [[ "$verbose" == "true" ]]; then
                        log_debug "SKIPPED: $config/ (low relevance)"
                    fi
                fi
            fi
        fi
    done
    
    # Summary
    echo ""
    log_step "Filtering Summary"
    echo "  Total items processed: $total_count"
    echo "  Items filtered/migrated: $filtered_count"
    echo "  Items skipped: $((total_count - filtered_count))"
    
    if [[ "$dry_run" != "true" ]]; then
        # Generate report
        local report_file="$dest_path/filtering-report.md"
        generate_filtering_report "$monorepo_path" "$dest_path" "$project_name" "$report_file"
        
        log_info "Smart content filtering completed successfully"
        log_info "Filtered content available at: $dest_path"
        log_info "Filtering report: $report_file"
    else
        log_info "Dry run completed. Use --force to apply changes."
    fi
}

# Main execution
main() {
    local verbose=false
    local dry_run=false
    local force=false
    local keep_low_relevance=false
    local monorepo_path=""
    local project_name=""
    local dest_path=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -k|--keep)
                keep_low_relevance=true
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
                elif [[ -z "$dest_path" ]]; then
                    dest_path="$1"
                else
                    log_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate arguments
    if [[ -z "$monorepo_path" || -z "$project_name" || -z "$dest_path" ]]; then
        log_error "Missing required arguments"
        show_usage
        exit 1
    fi
    
    # Run smart content filtering
    smart_content_filter "$monorepo_path" "$project_name" "$dest_path" "$verbose" "$dry_run" "$force" "$keep_low_relevance"
}

# Source AI/IDE configs from the analysis script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/analyze-ai-ide-configs.sh"

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
