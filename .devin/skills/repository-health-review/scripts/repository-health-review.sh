#!/bin/bash
# Repository Health Review Script
# Comprehensive analysis for outdated info, conflicting rules, undocumented standards, failures, missing docs, and security patterns

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Default values
VERBOSE=false
REPORT_FILE=""
QUICK_MODE=false
PRE_EXTRACTION=false
POST_EXTRACTION=false
CATEGORIES=""
EXCLUDE_DIRS=""
REPO_PATH=""
PROJECT_NAME=""

# Analysis categories
AVAILABLE_CATEGORIES="outdated,conflicts,undocumented,failures,missing_docs,security"

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
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}DEBUG:${NC} $1"
    fi
}

log_critical() {
    echo -e "${MAGENTA}CRITICAL:${NC} $1"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] REPOSITORY_PATH [PROJECT_NAME]

Arguments:
    REPOSITORY_PATH    Path to the repository to analyze
    PROJECT_NAME       Name of the project (optional, for pre/post-extraction modes)

Options:
    -v, --verbose              Show detailed analysis output
    -q, --quick               Quick analysis (high-priority files only)
    -r, --report FILE          Generate JSON report to FILE
    -c, --categories LIST     Comma-separated categories: $AVAILABLE_CATEGORIES
    -e, --exclude LIST        Comma-separated directories to exclude
    --pre-extraction          Pre-extraction analysis mode
    --post-extraction         Post-extraction analysis mode
    -h, --help                Show this help message

Examples:
    $0 /opt/my-project
    $0 --verbose --report health.json /opt/my-project
    $0 --categories security,outdated /opt/my-project
    $0 --pre-extraction /opt/monorepo webapp
    $0 --post-extraction /opt/extracted-repo

Categories:
    outdated        - Outdated information and deprecated tools
    conflicts       - Conflicting rules and configurations
    undocumented    - Undocumented standards and conventions
    failures        - Lessons from failures and temporary code
    missing_docs   - Missing tool documentation
    security        - Security and access patterns
EOF
}

# Severity scoring
declare -A SEVERITY_SCORES=(
    ["critical"]=10
    ["high"]=7
    ["medium"]=5
    ["low"]=2
    ["info"]=1
)

# Analysis functions
analyze_outdated_information() {
    local file="$1"
    local issues=0
    
    log_debug "Checking for outdated information in: $file"
    
    # Check for old dates
    local old_dates
    old_dates=$(grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$file" 2>/dev/null | head -5 || true)
    for date in $old_dates; do
        if date -d "$date" >/dev/null 2>&1; then
            local days_old
            days_old=$(( ($(date +%s) - $(date -d "$date" +%s 2>/dev/null || echo 0)) / 86400 ))
            if [[ $days_old -gt 365 ]]; then
                echo "  🟡 Outdated date reference: $date ($days_old days old)"
                issues=$((issues + 1))
            fi
        fi
    done
    
    # Check for deprecated tools
    local deprecated_tools=("bower" "gulp 3" "webpack 3" "babel 6" "nodejs < 14" "python 2" "npm < 6" "angularjs" "backbone.js")
    for tool in "${deprecated_tools[@]}"; do
        if grep -q -i "$tool" "$file" 2>/dev/null; then
            echo "  🟡 Deprecated tool reference: $tool"
            issues=$((issues + 1))
        fi
    done
    
    # Check for outdated URLs
    if grep -q -E "http://[^s]|gist.github.com/[0-9]{6,}" "$file" 2>/dev/null; then
        echo "  🟡 Potentially outdated URLs or gist references"
        issues=$((issues + 1))
    fi
    
    return $issues
}

analyze_conflicting_rules() {
    local file="$1"
    local issues=0
    
    log_debug "Checking for conflicting rules in: $file"
    
    # ESLint conflicts
    if [[ "$file" == *".json"* ]] || [[ "$file" == *".js"* ]] || [[ "$file" == *".eslintrc"* ]]; then
        if grep -q '"quotes":.*"single"' "$file" 2>/dev/null && grep -q '"quotes":.*"double"' "$file" 2>/dev/null; then
            echo "  🔴 Conflicting ESLint quote rules"
            issues=$((issues + 3))
        fi
        
        if grep -q '"semi":.*"always"' "$file" 2>/dev/null && grep -q '"semi":.*"never"' "$file" 2>/dev/null; then
            echo "  🔴 Conflicting ESLint semicolon rules"
            issues=$((issues + 3))
        fi
    fi
    
    # Gitignore conflicts
    if [[ "$file" == *".gitignore"* ]]; then
        if grep -q "!\*.log" "$file" 2>/dev/null && grep -q "\*.log" "$file" 2>/dev/null; then
            echo "  🟡 Conflicting gitignore patterns for *.log files"
            issues=$((issues + 1))
        fi
    fi
    
    # Package.json script conflicts
    if [[ "$file" == *"package.json"* ]]; then
        local duplicate_scripts
        duplicate_scripts=$(jq -r '.scripts | keys[]' "$file" 2>/dev/null | sort | uniq -d || true)
        if [[ -n "$duplicate_scripts" ]]; then
            echo "  🔴 Duplicate script names in package.json"
            issues=$((issues + 2))
        fi
    fi
    
    return $issues
}

analyze_undocumented_standards() {
    local file="$1"
    local issues=0
    
    log_debug "Checking for undocumented standards in: $file"
    
    # Custom scripts without documentation
    if [[ "$file" == *"package.json"* ]]; then
        local custom_scripts
        custom_scripts=$(jq -r '.scripts | keys[]' "$file" 2>/dev/null | grep -v -E "^(build|test|lint|start|dev|install|clean|prepare|format)" || true)
        if [[ -n "$custom_scripts" ]]; then
            echo "  🔵 Custom scripts that may need documentation:"
            echo "$custom_scripts" | head -3 | while read -r script; do
                echo "    - $script"
            done
            issues=$((issues + 1))
        fi
    fi
    
    # Environment variables without documentation
    if grep -q -E "process\.env\.|\.env\." "$file" 2>/dev/null; then
        local env_vars
        env_vars=$(grep -o -E 'process\.env\.[A-Z_]+|\.env\.[A-Z_]+' "$file" 2>/dev/null | sort -u | head -3 || true)
        if [[ -n "$env_vars" ]]; then
            echo "  🔵 Environment variables that may need documentation:"
            echo "$env_vars" | while read -r var; do
                echo "    - $var"
            done
            issues=$((issues + 1))
        fi
    fi
    
    # Check for undocumented file formats
    if [[ "$file" == *"README"* ]]; then
        local undocumented_formats
        undocumented_formats=$(find . -name "*.custom" -o -name "*.spec" -o -name "*.test" 2>/dev/null | head -3 | wc -l)
        if [[ $undocumented_formats -gt 0 ]]; then
            echo "  🔵 Custom file formats found that may need explanation"
            issues=$((issues + 1))
        fi
    fi
    
    return $issues
}

analyze_failure_lessons() {
    local file="$1"
    local issues=0
    
    log_debug "Analyzing lessons from failures in: $file"
    
    # Known failure patterns
    local failure_patterns=(
        "TODO.*fix.*later"
        "FIXME.*urgent"
        "HACK.*temporary"
        "BUG.*critical"
        "known.*issue"
        "workaround.*for"
        "temporary.*solution"
        "don't.*commit.*this"
        "remove.*before.*production"
        "XXX.*fix"
    )
    
    for pattern in "${failure_patterns[@]}"; do
        if grep -q -i "$pattern" "$file" 2>/dev/null; then
            echo "  🟡 Failure pattern detected: $pattern"
            issues=$((issues + 1))
        fi
    done
    
    # Security-related TODOs (higher severity)
    if grep -q -i -E "(security|auth|permission|access).*(todo|fix|hack|temporary)" "$file" 2>/dev/null; then
        echo "  🔴 Security-related temporary code detected"
        issues=$((issues + 3))
    fi
    
    # Performance warnings
    if grep -q -i -E "(slow|inefficient|optimize|performance).*(todo|fix|improve)" "$file" 2>/dev/null; then
        echo "  🟡 Performance-related issues noted"
        issues=$((issues + 1))
    fi
    
    return $issues
}

analyze_missing_tool_documentation() {
    local file="$1"
    local issues=0
    
    log_debug "Checking for missing tool documentation in: $file"
    
    # Tools mentioned without setup instructions
    local tools=("docker" "kubernetes" "terraform" "ansible" "jenkins" "github actions" "gitlab ci" "circleci" "travis ci" "azure pipelines")
    for tool in "${tools[@]}"; do
        if grep -q -i "$tool" "$file" 2>/dev/null && ! grep -q -i -E "(setup|install|configure|getting started).*$tool" "$file" 2>/dev/null; then
            echo "  🔵 Tool mentioned without setup docs: $tool"
            issues=$((issues + 1))
        fi
    done
    
    # Check for configuration files without explanation
    local config_files=(".env.example" "docker-compose.yml" "docker-compose.yaml" "k8s/" "terraform/" ".github/workflows/")
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]] && ! grep -q -i "$config" "$file" 2>/dev/null; then
            echo "  🔵 Configuration file not documented: $config"
            issues=$((issues + 1))
        fi
    done
    
    return $issues
}

analyze_security_patterns() {
    local file="$1"
    local issues=0
    
    log_debug "Analyzing security/access patterns in: $file"
    
    # Hardcoded secrets patterns
    local secret_patterns=(
        "password.*=.*['\"][^'\"]{8,}['\"]"
        "api_key.*=.*['\"][^'\"]{16,}['\"]"
        "secret.*=.*['\"][^'\"]{16,}['\"]"
        "token.*=.*['\"][^'\"]{16,}['\"]"
        "auth.*=.*['\"][^'\"]{16,}['\"]"
        "private_key.*=.*['\"]"
        "access_token.*=.*['\"]"
    )
    
    for pattern in "${secret_patterns[@]}"; do
        if grep -q -E "$pattern" "$file" 2>/dev/null; then
            echo "  🔴 Potential hardcoded secret detected"
            issues=$((issues + 5))
        fi
    done
    
    # Insecure configurations
    if grep -q -i -E "(debug.*true|ssl.*false|tls.*false|verify.*false)" "$file" 2>/dev/null; then
        echo "  🔴 Insecure configuration detected"
        issues=$((issues + 3))
    fi
    
    # Overly permissive access patterns
    if grep -q -E "chmod.*777|permission.*all|access.*everyone|public.*true" "$file" 2>/dev/null; then
        echo "  🔴 Overly permissive access pattern detected"
        issues=$((issues + 2))
    fi
    
    # Missing security headers (for web applications)
    if [[ "$file" == *"package.json"* ]] || [[ "$file" == *"server"* ]] || [[ "$file" == *"app"* ]]; then
        if ! grep -q -i -E "(helmet|cors|csrf|xss|security)" "$file" 2>/dev/null; then
            echo "  🟡 Security middleware not mentioned"
            issues=$((issues + 1))
        fi
    fi
    
    # Authentication patterns
    if grep -q -i -E "(login|auth|session|jwt|oauth)" "$file" 2>/dev/null; then
        if ! grep -q -i -E "(secure|encrypt|hash|salt|protect|verify)" "$file" 2>/dev/null; then
            echo "  🟡 Authentication mentioned without security details"
            issues=$((issues + 1))
        fi
    fi
    
    return $issues
}

# Run specific analysis category
run_analysis_category() {
    local category="$1"
    local file="$2"
    
    case "$category" in
        "outdated")
            analyze_outdated_information "$file"
            ;;
        "conflicts")
            analyze_conflicting_rules "$file"
            ;;
        "undocumented")
            analyze_undocumented_standards "$file"
            ;;
        "failures")
            analyze_failure_lessons "$file"
            ;;
        "missing_docs")
            analyze_missing_tool_documentation "$file"
            ;;
        "security")
            analyze_security_patterns "$file"
            ;;
        *)
            log_error "Unknown analysis category: $category"
            return 1
            ;;
    esac
}

# Calculate health score
calculate_health_score() {
    local critical_issues=$1
    local high_issues=$2
    local medium_issues=$3
    local low_issues=$4
    local info_issues=$5
    
    local score=100
    
    # Deduct points based on severity
    score=$((score - (critical_issues * 10)))
    score=$((score - (high_issues * 7)))
    score=$((score - (medium_issues * 5)))
    score=$((score - (low_issues * 2)))
    score=$((score - (info_issues * 1)))
    
    # Ensure score doesn't go below 0
    [[ $score -lt 0 ]] && score=0
    
    echo $score
}

# Generate JSON report
generate_json_report() {
    local repo_path="$1"
    local project_name="$2"
    local critical_issues="$3"
    local high_issues="$4"
    local medium_issues="$5"
    local low_issues="$6"
    local info_issues="$7"
    local total_issues="$8"
    local health_score="$9"
    local report_file="${10}"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    cat > "$report_file" << EOF
{
  "repository": {
    "path": "$repo_path",
    "name": "${project_name:-$(basename "$repo_path")}",
    "last_analyzed": "$timestamp"
  },
  "health_score": $health_score,
  "issues": {
    "critical": $critical_issues,
    "high": $high_issues,
    "medium": $medium_issues,
    "low": $low_issues,
    "info": $info_issues,
    "total": $total_issues
  },
  "analysis_mode": "${ANALYSIS_MODE:-standard}",
  "categories_analyzed": "${CATEGORIES:-all}",
  "recommendations": [
    {
      "priority": "high",
      "action": "Address critical security issues immediately",
      "description": "Fix hardcoded secrets and insecure configurations"
    },
    {
      "priority": "medium", 
      "action": "Update outdated documentation and tools",
      "description": "Remove deprecated tool references and update old dates"
    },
    {
      "priority": "low",
      "action": "Document undocumented standards and tools",
      "description": "Add setup instructions and explain custom conventions"
    }
  ]
}
EOF
    
    log_info "JSON report generated: $report_file"
}

# Main repository health analysis
analyze_repository_health() {
    local repo_path="$1"
    local project_name="$2"
    
    local total_critical=0
    local total_high=0
    local total_medium=0
    local total_low=0
    local total_info=0
    local files_analyzed=0
    
    log_step "Starting repository health analysis"
    log_info "Repository: $repo_path"
    [[ -n "$project_name" ]] && log_info "Project: $project_name"
    
    # Change to repository directory
    cd "$repo_path" || {
        log_error "Failed to change directory: $repo_path"
        return 1
    }
    
    # Determine which files to analyze
    local files_to_analyze=()
    
    if [[ "$QUICK_MODE" == "true" ]]; then
        # High-priority files only
        files_to_analyze=("README.md" "package.json" ".gitignore" ".eslintrc*" "docker-compose.yml" "Dockerfile" "*.config.js" "*.config.ts")
    else
        # Comprehensive analysis
        files_to_analyze=("README.md" "AGENTS.md" "MEMORY.md" "TOOLS.md" "package.json" "*.json" "*.yml" "*.yaml" "*.js" "*.ts" "*.md" ".gitignore" ".env*" "Dockerfile" "docker-compose.*" ".eslintrc*" "*.config.*")
    fi
    
    # Build find command with exclusions
    local find_cmd="find . -maxdepth 3"
    for pattern in "${files_to_analyze[@]}"; do
        find_cmd="$find_cmd -name '$pattern' -o"
    done
    find_cmd="${find_cmd%-o}"  # Remove trailing -o
    
    # Add exclusions
    if [[ -n "$EXCLUDE_DIRS" ]]; then
        IFS=',' read -ra EXCLUDE_ARRAY <<< "$EXCLUDE_DIRS"
        for exclude in "${EXCLUDE_ARRAY[@]}"; do
            find_cmd="$find_cmd -not -path './$exclude/*'"
        done
    fi
    
    # Find files
    local found_files
    found_files=$(eval "$find_cmd" 2>/dev/null || true)
    
    if [[ -z "$found_files" ]]; then
        log_warn "No files found for analysis"
        return 0
    fi
    
    # Analyze each file
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            echo ""
            log_info "Analyzing: $file"
            files_analyzed=$((files_analyzed + 1))
            
            local file_critical=0
            local file_high=0
            local file_medium=0
            local file_low=0
            local file_info=0
            
            # Run selected analysis categories
            if [[ -z "$CATEGORIES" ]]; then
                # Run all categories
                analyze_outdated_information "$file"
                local issues=$?
                file_low=$((file_low + issues))
                
                analyze_conflicting_rules "$file"
                issues=$?
                file_critical=$((file_critical + issues))
                
                analyze_undocumented_standards "$file"
                issues=$?
                file_info=$((file_info + issues))
                
                analyze_failure_lessons "$file"
                issues=$?
                file_medium=$((file_medium + issues))
                
                analyze_missing_tool_documentation "$file"
                issues=$?
                file_info=$((file_info + issues))
                
                analyze_security_patterns "$file"
                issues=$?
                file_critical=$((file_critical + issues))
            else
                # Run specific categories
                IFS=',' read -ra CAT_ARRAY <<< "$CATEGORIES"
                for category in "${CAT_ARRAY[@]}"; do
                    category=$(echo "$category" | xargs)  # Trim whitespace
                    run_analysis_category "$category" "$file"
                    local issues=$?
                    case $category in
                        "security") file_critical=$((file_critical + issues)) ;;
                        "conflicts") file_critical=$((file_critical + issues)) ;;
                        "failures") file_medium=$((file_medium + issues)) ;;
                        "outdated") file_low=$((file_low + issues)) ;;
                        "undocumented"|"missing_docs") file_info=$((file_info + issues)) ;;
                    esac
                done
            fi
            
            # Update totals
            total_critical=$((total_critical + file_critical))
            total_high=$((total_high + file_high))
            total_medium=$((total_medium + file_medium))
            total_low=$((total_low + file_low))
            total_info=$((total_info + file_info))
        fi
    done <<< "$found_files"
    
    # Calculate totals and score
    local total_issues=$((total_critical + total_high + total_medium + total_low + total_info))
    local health_score
    health_score=$(calculate_health_score $total_critical $total_high $total_medium $total_low $total_info)
    
    # Summary
    echo ""
    log_step "Repository Health Summary"
    echo "  Files analyzed: $files_analyzed"
    echo "  Health Score: $health_score/100"
    echo "  Critical Issues: $total_critical"
    echo "  High Issues: $total_high"
    echo "  Medium Issues: $total_medium"
    echo "  Low Issues: $total_low"
    echo "  Info Issues: $total_info"
    echo "  Total Issues: $total_issues"
    
    # Generate report if requested
    if [[ -n "$REPORT_FILE" ]]; then
        generate_json_report "$repo_path" "$project_name" $total_critical $total_high $total_medium $total_low $total_info $total_issues $health_score "$REPORT_FILE"
    fi
    
    # Recommendations based on score
    echo ""
    log_step "Recommendations"
    if [[ $health_score -ge 90 ]]; then
        echo "  ✅ Excellent repository health! Minor improvements suggested."
    elif [[ $health_score -ge 80 ]]; then
        echo "  ✅ Good repository health. Address medium and low priority issues."
    elif [[ $health_score -ge 70 ]]; then
        echo "  ⚠️  Fair repository health. Focus on critical and high priority issues."
    elif [[ $health_score -ge 50 ]]; then
        echo "  🔴 Poor repository health. Immediate attention required for critical issues."
    else
        echo "  🔴 Critical repository health. Major remediation needed."
    fi
    
    # Mode-specific recommendations
    if [[ "$PRE_EXTRACTION" == "true" ]]; then
        echo ""
        echo "  🚀 Pre-Extraction Recommendations:"
        echo "    - Address all critical issues before extraction"
        echo "    - Document project-specific dependencies"
        echo "    - Clean up monorepo-specific references"
    fi
    
    if [[ "$POST_EXTRACTION" == "true" ]]; then
        echo ""
        echo "  🎯 Post-Extraction Validation:"
        echo "    - Verify all configurations work in standalone mode"
        echo "    - Update documentation for new repository structure"
        echo "    - Test all build and deployment processes"
    fi
    
    return $total_critical
}

# Main execution
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quick)
                QUICK_MODE=true
                shift
                ;;
            -r|--report)
                REPORT_FILE="$2"
                shift 2
                ;;
            -c|--categories)
                CATEGORIES="$2"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_DIRS="$2"
                shift 2
                ;;
            --pre-extraction)
                PRE_EXTRACTION=true
                ANALYSIS_MODE="pre-extraction"
                shift
                ;;
            --post-extraction)
                POST_EXTRACTION=true
                ANALYSIS_MODE="post-extraction"
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
                if [[ -z "$REPO_PATH" ]]; then
                    REPO_PATH="$1"
                elif [[ -z "$PROJECT_NAME" ]]; then
                    PROJECT_NAME="$1"
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
    if [[ -z "$REPO_PATH" ]]; then
        log_error "Repository path is required"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$REPO_PATH" ]]; then
        log_error "Repository path does not exist: $REPO_PATH"
        exit 1
    fi
    
    # Validate categories
    if [[ -n "$CATEGORIES" ]]; then
        IFS=',' read -ra CAT_ARRAY <<< "$CATEGORIES"
        for category in "${CAT_ARRAY[@]}"; do
            category=$(echo "$category" | xargs)  # Trim whitespace
            if [[ ! " $AVAILABLE_CATEGORIES " =~ *" $category "* ]]; then
                log_error "Invalid category: $category"
                log_error "Available categories: $AVAILABLE_CATEGORIES"
                exit 1
            fi
        done
    fi
    
    # Run analysis
    local critical_issues
    analyze_repository_health "$REPO_PATH" "$PROJECT_NAME"
    critical_issues=$?
    
    # Exit with appropriate code
    if [[ $critical_issues -gt 0 ]]; then
        log_warn "Repository has $critical_issues critical issues"
        exit 1
    else
        log_info "Repository health check completed successfully"
        exit 0
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
