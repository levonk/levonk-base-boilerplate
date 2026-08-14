#!/bin/bash
# Analyze AI/IDE configuration files and project documentation for intelligent extraction
# Evaluates relevance of configs for migration to standalone repository

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] MONOREPO_PATH PROJECT_NAME

Arguments:
    MONOREPO_PATH    Path to the monorepo to analyze
    PROJECT_NAME     Name of the project to extract

Options:
    -v, --verbose    Show detailed analysis output
    -o, --output     Output analysis to JSON file
    -f, --filter     Show only relevant/high-priority files
    -h, --help       Show this help message

Examples:
    $0 /opt/company-monorepo webapp
    $0 --verbose --filter --output analysis.json ~/projects/company-monorepo shared-utils
EOF
}

# AI/IDE configuration patterns and their analysis functions
declare -A AI_IDE_CONFIGS=(
    # AI Assistant Configs
    [".agents"]="analyze_agents_dir"
    [".windsurf"]="analyze_windsurf_dir"
    [".claud"]="analyze_claud_dir"
    [".cursor"]="analyze_cursor_dir"
    [".gemini"]="analyze_gemini_dir"
    [".qwen"]="analyze_qwen_dir"
    [".crush"]="analyze_crush_dir"
    [".clienrules"]="analyze_clienrules_dir"

    # Development Environment Configs
    [".devbox"]="analyze_devbox_dir"
    [".iflow"]="analyze_iflow_dir"
    [".specify"]="analyze_specify_dir"
    [".tickets"]="analyze_tickets_dir"
    [".trae"]="analyze_trae_dir"
    [".vscode"]="analyze_vscode_dir"

    # Project Documentation
    ["README.md"]="analyze_readme"
    ["AGENTS.md"]="analyze_agents_md"
    ["MEMORY.md"]="analyze_memory_md"
    ["TOOLS.md"]="analyze_tools_md"
    ["SOUL.md"]="analyze_soul_md"
    ["IDENTITY.md"]="analyze_identity_md"
    ["USER.md"]="analyze_user_md"
    ["HEARTBEAT.md"]="analyze_heartbeat_md"

    # AI Workflow Files
    ["WORKFLOW.md"]="analyze_workflow_md"
    ["PROMPTS.md"]="analyze_prompts_md"
    ["SKILLS.md"]="analyze_skills_md"
    ["AGENT.md"]="analyze_agent_md"
)

# Relevance scoring (1-10, higher = more relevant for migration)
declare -A RELEVANCE_SCORES=(
    # Core project docs - highest relevance
    ["README.md"]=10
    ["AGENTS.md"]=9
    ["MEMORY.md"]=8
    ["TOOLS.md"]=7

    # AI identity docs - high relevance for AI projects
    ["IDENTITY.md"]=8
    ["SOUL.md"]=7
    ["USER.md"]=7
    ["HEARTBEAT.md"]=6

    # Workflow/skill docs - medium relevance
    ["WORKFLOW.md"]=7
    ["PROMPTS.md"]=6
    ["SKILLS.md"]=6
    ["AGENT.md"]=6

    # IDE configs - variable relevance based on content
    [".vscode"]=5
    [".cursor"]=6
    [".windsurf"]=7
    [".claud"]=6
    [".gemini"]=6
    [".qwen"]=5
    [".crush"]=5
    [".clienrules"]=5

    # Development environment - lower relevance (often regenerated)
    [".devbox"]=4
    [".iflow"]=4
    [".specify"]=4
    [".tickets"]=5
    [".trae"]=4
    [".agents"]=6
)

# Repository health analysis functions
analyze_outdated_information() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Checking for outdated information in: $file"

    local outdated_count=0
    local issues=()

    # Check for outdated version references
    if grep -q -E "(version [0-9]\.[0-9]|v[0-9]\.[0-9]|[0-9]{4}-[0-9]{2}-[0-9]{2})" "$file"; then
        local date_refs
        date_refs=$(grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$file" | head -3)
        for date_ref in $date_refs; do
            local days_old
            days_old=$(( ($(date +%s) - $(date -d "$date_ref" +%s 2>/dev/null || echo 0)) / 86400 ))
            if [[ $days_old -gt 365 ]]; then
                issues+=("Outdated date reference: $date_ref ($days_old days old)")
                outdated_count=$((outdated_count + 1))
            fi
        done
    fi

    # Check for deprecated tool references
    local deprecated_tools=("bower" "gulp 3" "webpack 3" "babel 6" "nodejs < 14" "python 2" "npm < 6")
    for tool in "${deprecated_tools[@]}"; do
        if grep -q -i "$tool" "$file"; then
            issues+=("Deprecated tool reference: $tool")
            outdated_count=$((outdated_count + 1))
        fi
    done

    # Check for outdated URLs/domains
    if grep -q -E "http://[^s]|gist.github.com/[0-9]{6,}" "$file"; then
        issues+=("Potentially outdated URLs or gist references")
        outdated_count=$((outdated_count + 1))
    fi

    if [[ $outdated_count -gt 0 ]]; then
        echo "  ⚠️  Outdated information detected: $outdated_count issues"
        for issue in "${issues[@]}"; do
            echo "    - $issue"
        done
    fi

    return $outdated_count
}

analyze_conflicting_rules() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Checking for conflicting rules in: $file"

    local conflicts=0

    # Check for conflicting ESLint rules
    if [[ "$file" == *".json"* ]] || [[ "$file" == *".js"* ]]; then
        if grep -q '"quotes":.*"single"' "$file" && grep -q '"quotes":.*"double"' "$file"; then
            echo "  ❌ Conflicting quote rules in ESLint config"
            conflicts=$((conflicts + 1))
        fi

        if grep -q '"semi":.*"always"' "$file" && grep -q '"semi":.*"never"' "$file"; then
            echo "  ❌ Conflicting semicolon rules in ESLint config"
            conflicts=$((conflicts + 1))
        fi
    fi

    # Check for conflicting gitignore patterns
    if [[ "$file" == *".gitignore"* ]]; then
        if grep -q "!\*.log" "$file" && grep -q "\*.log" "$file"; then
            echo "  ❌ Conflicting gitignore patterns for *.log files"
            conflicts=$((conflicts + 1))
        fi
    fi

    # Check for contradictory documentation statements
    if grep -q -i "never.*commit.*keys" "$file" && grep -q -i "api.*key.*example" "$file"; then
        echo "  ❌ Potential conflict: API keys in documentation"
        conflicts=$((conflicts + 1))
    fi

    return $conflicts
}

analyze_undocumented_standards() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Checking for undocumented standards in: $file"

    local undocumented=0

    # Check for custom scripts without documentation
    if [[ "$file" == *"package.json" ]]; then
        local custom_scripts
        custom_scripts=$(jq -r '.scripts | keys[]' "$file" 2>/dev/null | grep -v -E "^(build|test|lint|start|dev|install|clean|prepare)" || true)
        if [[ -n "$custom_scripts" ]]; then
            echo "  ℹ️  Custom scripts found that may need documentation:"
            echo "$custom_scripts" | while read -r script; do
                echo "    - $script"
            done
            undocumented=$((undocumented + 1))
        fi
    fi

    # Check for environment variables without documentation
    if grep -q -E "process\.env\.|\.env\." "$file"; then
        local env_vars
        env_vars=$(grep -o -E 'process\.env\.[A-Z_]+|\.env\.[A-Z_]+' "$file" | sort -u | head -5)
        if [[ -n "$env_vars" ]]; then
            echo "  ℹ️  Environment variables that may need documentation:"
            echo "$env_vars" | while read -r var; do
                echo "    - $var"
            done
            undocumented=$((undocumented + 1))
        fi
    fi

    # Check for custom file extensions without explanation
    if [[ "$file" == *"README"* ]]; then
        local custom_files
        custom_files=$(find . -type f -name "*.custom" -o -name "*.spec" -o -name "*.test" 2>/dev/null | head -3 | wc -l)
        if [[ $custom_files -gt 0 ]]; then
            echo "  ℹ️  Custom file formats found that may need explanation"
            undocumented=$((undocumented + 1))
        fi
    fi

    return $undocumented
}

analyze_failure_lessons() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Analyzing lessons from failures in: $file"

    local lessons=0

    # Check for known failure patterns
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
    )

    for pattern in "${failure_patterns[@]}"; do
        if grep -q -i "$pattern" "$file"; then
            echo "  ⚠️  Failure pattern detected: $pattern"
            lessons=$((lessons + 1))
        fi
    done

    # Check for security-related TODOs
    if grep -q -i -E "(security|auth|permission|access).*(todo|fix|hack|temporary)" "$file"; then
        echo "  🔴 Security-related temporary code detected"
        lessons=$((lessons + 1))
    fi

    # Check for performance warnings
    if grep -q -i -E "(slow|inefficient|optimize|performance).*(todo|fix|improve)" "$file"; then
        echo "  ⚡ Performance-related issues noted"
        lessons=$((lessons + 1))
    fi

    return $lessons
}

analyze_missing_tool_documentation() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Checking for missing tool documentation in: $file"

    local missing_docs=0

    # Check for tools mentioned without setup instructions
    local tools=("docker" "kubernetes" "terraform" "ansible" "jenkins" "github actions" "gitlab ci" "circleci")
    for tool in "${tools[@]}"; do
        if grep -q -i "$tool" "$file" && ! grep -q -i -E "(setup|install|configure|getting started).*$tool" "$file"; then
            echo "  📚 Tool mentioned without setup docs: $tool"
            missing_docs=$((missing_docs + 1))
        fi
    done

    # Check for configuration files without explanation
    local config_files=(".env.example" "docker-compose.yml" "k8s/" "terraform/" ".github/workflows/")
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]] && ! grep -q -i "$config" "$file"; then
            echo "  📄 Configuration file not documented: $config"
            missing_docs=$((missing_docs + 1))
        fi
    done

    return $missing_docs
}

analyze_security_access_patterns() {
    local file="$1"
    local project="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_debug "Analyzing security/access patterns in: $file"

    local security_issues=0

    # Check for hardcoded secrets patterns
    local secret_patterns=(
        "password.*=.*['\"][^'\"]{8,}['\"]"
        "api_key.*=.*['\"][^'\"]{16,}['\"]"
        "secret.*=.*['\"][^'\"]{16,}['\"]"
        "token.*=.*['\"][^'\"]{16,}['\"]"
        "auth.*=.*['\"][^'\"]{16,}['\"]"
    )

    for pattern in "${secret_patterns[@]}"; do
        if grep -q -E "$pattern" "$file"; then
            echo "  🔴 Potential hardcoded secret detected"
            security_issues=$((security_issues + 1))
        fi
    done

    # Check for insecure configurations
    if grep -q -i -E "(debug.*true|ssl.*false|tls.*false|verify.*false)" "$file"; then
        echo "  🔴 Insecure configuration detected"
        security_issues=$((security_issues + 1))
    fi

    # Check for overly permissive access patterns
    if grep -q -E "chmod.*777|permission.*all|access.*everyone|public.*true" "$file"; then
        echo "  🔴 Overly permissive access pattern detected"
        security_issues=$((security_issues + 1))
    fi

    # Check for missing security headers
    if [[ "$file" == *"package.json"* ]] || [[ "$file" == *"server"* ]]; then
        if ! grep -q -i -E "(helmet|cors|csrf|xss|security)" "$file"; then
            echo "  ⚠️  Security middleware not mentioned"
            security_issues=$((security_issues + 1))
        fi
    fi

    # Check for authentication patterns
    if grep -q -i -E "(login|auth|session|jwt|oauth)" "$file"; then
        if ! grep -q -i -E "(secure|encrypt|hash|salt|protect)" "$file"; then
            echo "  ⚠️  Authentication mentioned without security details"
            security_issues=$((security_issues + 1))
        fi
    fi

    return $security_issues
}

# Enhanced analysis function with repository health checks
analyze_repository_health() {
    local file="$1"
    local project="$2"
    local analysis_type="$3"

    case "$analysis_type" in
        "outdated")
            analyze_outdated_information "$file" "$project"
            ;;
        "conflicts")
            analyze_conflicting_rules "$file" "$project"
            ;;
        "undocumented")
            analyze_undocumented_standards "$file" "$project"
            ;;
        "failures")
            analyze_failure_lessons "$file" "$project"
            ;;
        "missing_docs")
            analyze_missing_tool_documentation "$file" "$project"
            ;;
        "security")
            analyze_security_access_patterns "$file" "$project"
            ;;
        *)
            # Run all analyses
            local total_issues=0
            analyze_outdated_information "$file" "$project" && total_issues=$((total_issues + $?))
            analyze_conflicting_rules "$file" "$project" && total_issues=$((total_issues + $?))
            analyze_undocumented_standards "$file" "$project" && total_issues=$((total_issues + $?))
            analyze_failure_lessons "$file" "$project" && total_issues=$((total_issues + $?))
            analyze_missing_tool_documentation "$file" "$project" && total_issues=$((total_issues + $?))
            analyze_security_access_patterns "$file" "$project" && total_issues=$((total_issues + $?))

            if [[ $total_issues -gt 0 ]]; then
                echo "  📊 Total repository health issues: $total_issues"
            fi
            return $total_issues
            ;;
    esac
}

# Enhanced content analysis functions
analyze_readme() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["README.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing README.md"

    # Check for project-specific content
    local project_mentions=0
    project_mentions=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    # Check for monorepo-specific content that should be cleaned
    local monorepo_indicators=0
    monorepo_indicators=$(grep -c -E "(monorepo|this repository contains|part of larger|shared with)" "$file" 2>/dev/null || echo 0)

    # Check for standalone project indicators
    local standalone_indicators=0
    standalone_indicators=$(grep -c -E "(standalone|independent|separate package|individual project)" "$file" 2>/dev/null || echo 0)

    # Adjust relevance based on content
    if [[ $project_mentions -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific content ($project_mentions mentions)"
    fi

    if [[ $monorepo_indicators -gt 0 ]]; then
        log_warn "  ⚠️  Contains monorepo-specific references ($monorepo_indicators found)"
        log_debug "    Consider updating for standalone repository"
    fi

    if [[ $standalone_indicators -gt 0 ]]; then
        log_debug "  ✓ Already describes as standalone project"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Project mentions: $project_mentions"
    echo "  Monorepo references: $monorepo_indicators"
    echo "  Standalone indicators: $standalone_indicators"

    return 0
}

analyze_agents_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["AGENTS.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing AGENTS.md"

    # Check for project-specific agent configurations
    local project_agents=0
    project_agents=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    # Check for shared agent configurations
    local shared_agents=0
    shared_agents=$(grep -c -E "(shared|common|global|all projects)" "$file" 2>/dev/null || echo 0)

    # Count agent definitions
    local agent_count=0
    agent_count=$(grep -c "^## " "$file" 2>/dev/null || echo 0)

    if [[ $project_agents -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific agents ($project_agents references)"
    fi

    if [[ $shared_agents -gt 0 ]]; then
        log_debug "  ℹ️  Contains shared agent configurations"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Agent definitions: $agent_count"
    echo "  Project-specific: $project_agents"
    echo "  Shared configurations: $shared_agents"

    return 0
}

analyze_memory_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["MEMORY.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing MEMORY.md"

    # Check for project-specific memories
    local project_memories=0
    project_memories=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    # Check for monorepo-wide memories
    local monorepo_memories=0
    monorepo_memories=$(grep -c -E "(monorepo|repository-wide|global|all projects)" "$file" 2>/dev/null || echo 0)

    # Count memory entries
    local memory_count=0
    memory_count=$(grep -c "^# " "$file" 2>/dev/null || echo 0)

    if [[ $project_memories -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific memories ($project_memories references)"
    fi

    if [[ $monorepo_memories -gt 0 ]]; then
        log_debug "  ℹ️  Contains monorepo-wide memories"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Memory entries: $memory_count"
    echo "  Project-specific: $project_memories"
    echo "  Monorepo-wide: $monorepo_memories"

    return 0
}

analyze_tools_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["TOOLS.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing TOOLS.md"

    # Check for project-specific tools
    local project_tools=0
    project_tools=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    # Check for shared tool configurations
    local shared_tools=0
    shared_tools=$(grep -c -E "(shared|common|global|all projects)" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific tools: $project_tools"
    echo "  Shared tools: $shared_tools"

    return 0
}

analyze_identity_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["IDENTITY.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing IDENTITY.md"

    # Check for project-specific identity
    local project_identity=0
    project_identity=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific identity: $project_identity"

    return 0
}

analyze_soul_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["SOUL.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing SOUL.md"
    echo "  Relevance Score: $relevance/10"

    return 0
}

analyze_user_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["USER.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing USER.md"
    echo "  Relevance Score: $relevance/10"

    return 0
}

analyze_heartbeat_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["HEARTBEAT.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing HEARTBEAT.md"
    echo "  Relevance Score: $relevance/10"

    return 0
}

# IDE configuration analysis functions
analyze_windsurf_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".windsurf"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .windsurf directory"

    # Check for project-specific configurations
    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    # Check for project references
    local project_refs=0
    project_refs=$(find "$dir" -type f -exec grep -l -i "$project" {} \; 2>/dev/null | wc -l || echo 0)

    if [[ $project_refs -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific configurations"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"
    echo "  Project references: $project_refs"

    return 0
}

analyze_cursor_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".cursor"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .cursor directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_vscode_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".vscode"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .vscode directory"

    # Check for project-specific settings
    local settings_files=0
    settings_files=$(find "$dir" -name "settings.json" | wc -l)

    # Check for project-specific tasks
    local tasks_files=0
    tasks_files=$(find "$dir" -name "tasks.json" | wc -l)

    # Check for project-specific launch configurations
    local launch_files=0
    launch_files=$(find "$dir" -name "launch.json" | wc -l)

    # Check for project references
    local project_refs=0
    project_refs=$(find "$dir" -type f -exec grep -l -i "$project" {} \; 2>/dev/null | wc -l || echo 0)

    if [[ $project_refs -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific configurations"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Settings files: $settings_files"
    echo "  Tasks files: $tasks_files"
    echo "  Launch files: $launch_files"
    echo "  Project references: $project_refs"

    return 0
}

analyze_claud_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".claud"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .claud directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_gemini_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".gemini"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .gemini directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_qwen_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".qwen"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .qwen directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_crush_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".crush"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .crush directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_clienrules_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".clienrules"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .clienrules directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_agents_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".agents"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .agents directory"

    local agent_files=0
    agent_files=$(find "$dir" -name "*.md" -o -name "*.json" | wc -l)

    # Check for project-specific agents
    local project_agents=0
    project_agents=$(find "$dir" -type f -exec grep -l -i "$project" {} \; 2>/dev/null | wc -l || echo 0)

    if [[ $project_agents -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific agents"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Agent files: $agent_files"
    echo "  Project-specific: $project_agents"

    return 0
}

# Development environment analysis functions
analyze_devbox_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".devbox"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .devbox directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"
    echo "  ℹ️  Usually regenerated, lower migration priority"

    return 0
}

analyze_tickets_dir() {
    local dir="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES[".tickets"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing .tickets directory"

    local ticket_files=0
    ticket_files=$(find "$dir" -name "*.md" | wc -l)

    # Check for project-specific tickets
    local project_tickets=0
    project_tickets=$(find "$dir" -type f -exec grep -l -i "$project" {} \; 2>/dev/null | wc -l || echo 0)

    if [[ $project_tickets -gt 0 ]]; then
        relevance=$((relevance + 1))
        log_debug "  ✓ Contains project-specific tickets"
    fi

    echo "  Relevance Score: $relevance/10"
    echo "  Ticket files: $ticket_files"
    echo "  Project-specific: $project_tickets"

    return 0
}

# Generic directory analysis for other AI/IDE configs
analyze_generic_ai_dir() {
    local dir="$1"
    local project="$2"
    local config_name="$3"
    local relevance=${RELEVANCE_SCORES["$config_name"]}

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    log_info "Analyzing $config_name directory"

    local config_files=0
    config_files=$(find "$dir" -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" | wc -l)

    echo "  Relevance Score: $relevance/10"
    echo "  Configuration files: $config_files"

    return 0
}

analyze_iflow_dir() {
    analyze_generic_ai_dir "$1" "$2" ".iflow"
}

analyze_specify_dir() {
    analyze_generic_ai_dir "$1" "$2" ".specify"
}

analyze_trae_dir() {
    analyze_generic_ai_dir "$1" "$2" ".trae"
}

# Workflow documentation analysis
analyze_workflow_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["WORKFLOW.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing WORKFLOW.md"

    local project_workflows=0
    project_workflows=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific workflows: $project_workflows"

    return 0
}

analyze_prompts_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["PROMPTS.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing PROMPTS.md"

    local project_prompts=0
    project_prompts=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific prompts: $project_prompts"

    return 0
}

analyze_skills_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["SKILLS.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing SKILLS.md"

    local project_skills=0
    project_skills=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific skills: $project_skills"

    return 0
}

analyze_agent_md() {
    local file="$1"
    local project="$2"
    local relevance=${RELEVANCE_SCORES["AGENT.md"]}

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    log_info "Analyzing AGENT.md"

    local project_agent=0
    project_agent=$(grep -c -i "$project" "$file" 2>/dev/null || echo 0)

    echo "  Relevance Score: $relevance/10"
    echo "  Project-specific agent config: $project_agent"

    return 0
}

# Main analysis function
analyze_ai_ide_configs() {
    local monorepo_path="$1"
    local project_name="$2"
    local verbose="${3:-false}"
    local filter_only="${4:-false}"
    local output_file="${5:-}"

    local total_relevance=0
    local analyzed_count=0
    local high_priority_files=()

    log_step "Analyzing AI/IDE configurations and documentation"

    # Change to monorepo directory
    cd "$monorepo_path" || {
        log_error "Failed to change directory: $monorepo_path"
        return 1
    }

    # Analyze each configuration file/directory
    for config in "${!AI_IDE_CONFIGS[@]}"; do
        local analyzer="${AI_IDE_CONFIGS[$config]}"
        local relevance=${RELEVANCE_SCORES[$config]:-5}

        if [[ "$config" == *".md" ]]; then
            # It's a markdown file
            if [[ -f "$config" ]]; then
                echo ""
                if [[ "$filter_only" == "true" && $relevance -ge 7 ]]; then
                    echo "🔥 HIGH PRIORITY: $config"
                elif [[ "$filter_only" != "true" ]]; then
                    echo "📄 $config"
                fi

                if [[ "$filter_only" != "true" || $relevance -ge 7 ]]; then
                    $analyzer "$config" "$project_name"

                    # Run repository health analysis on markdown files
                    if [[ "$verbose" == "true" ]]; then
                        echo ""
                        log_debug "Running repository health analysis on $config"
                        analyze_repository_health "$config" "$project_name"
                    fi

                    total_relevance=$((total_relevance + relevance))
                    analyzed_count=$((analyzed_count + 1))

                    if [[ $relevance -ge 7 ]]; then
                        high_priority_files+=("$config")
                    fi
                fi
            fi
        else
            # It's a directory
            if [[ -d "$config" ]]; then
                echo ""
                if [[ "$filter_only" == "true" && $relevance -ge 7 ]]; then
                    echo "🔥 HIGH PRIORITY: $config/"
                elif [[ "$filter_only" != "true" ]]; then
                    echo "📁 $config/"
                fi

                if [[ "$filter_only" != "true" || $relevance -ge 7 ]]; then
                    $analyzer "$config" "$project_name"
                    total_relevance=$((total_relevance + relevance))
                    analyzed_count=$((analyzed_count + 1))

                    if [[ $relevance -ge 7 ]]; then
                        high_priority_files+=("$config/")
                    fi
                fi
            fi
        fi
    done

    # Summary
    echo ""
    log_step "Analysis Summary"
    echo "  Total files/directories analyzed: $analyzed_count"
    echo "  Total relevance score: $total_relevance"
    echo "  Average relevance: $(( total_relevance / (analyzed_count > 0 ? analyzed_count : 1) ))/10"

    if [[ ${#high_priority_files[@]} -gt 0 ]]; then
        echo ""
        echo "🔥 High Priority Files for Migration:"
        for file in "${high_priority_files[@]}"; do
            echo "    - $file"
        done
    fi

    # Recommendations
    echo ""
    log_step "Migration Recommendations"

    if [[ ${#high_priority_files[@]} -gt 0 ]]; then
        echo "  ✓ Prioritize migrating high-priority files first"
        echo "  ✓ Review and update monorepo-specific references"
        echo "  ✓ Clean up shared configurations for standalone use"
    else
        echo "  ℹ️  No high-priority AI/IDE configurations found"
        echo "  ℹ️  Consider if AI/IDE setup is needed for this project"
    fi

    # Output to JSON if requested
    if [[ -n "$output_file" ]]; then
        log_info "Generating JSON report: $output_file"

        cat > "$output_file" << EOF
{
  "analysis": {
    "monorepo_path": "$monorepo_path",
    "project_name": "$project_name",
    "analyzed_count": $analyzed_count,
    "total_relevance": $total_relevance,
    "average_relevance": $(( total_relevance / (analyzed_count > 0 ? analyzed_count : 1) ))
  },
  "high_priority_files": [
$(printf '    "%s"\n' "${high_priority_files[@]}")
  ],
  "recommendations": [
    "Review and update monorepo-specific references in documentation",
    "Clean up shared configurations for standalone use",
    "Test AI/IDE configurations in new repository environment"
  ]
}
EOF
        log_info "JSON report generated"
    fi
}

# Main execution
main() {
    local verbose=false
    local filter_only=false
    local output_file=""
    local monorepo_path=""
    local project_name=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -f|--filter)
                filter_only=true
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
    if [[ -z "$monorepo_path" || -z "$project_name" ]]; then
        log_error "Missing required arguments"
        show_usage
        exit 1
    fi

    if [[ ! -d "$monorepo_path" ]]; then
        log_error "Monorepo path does not exist: $monorepo_path"
        exit 1
    fi

    # Run analysis
    analyze_ai_ide_configs "$monorepo_path" "$project_name" "$verbose" "$filter_only" "$output_file"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
