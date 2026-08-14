#!/bin/bash
# Validate that common monorepo targets work in the extracted repository
# Tests bootstrap, doctor, build, lint, typecheck, test, deploy, run, install

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Common targets to validate
COMMON_TARGETS=("bootstrap" "doctor" "build" "lint" "typecheck" "test" "deploy" "run" "install")

# Build system detection patterns
declare -A BUILD_SYSTEMS=(
    ["npm"]="package.json"
    ["pnpm"]="pnpm-lock.yaml"
    ["yarn"]="yarn.lock"
    ["bun"]="bun.lockb"
    ["make"]="Makefile"
    ["just"]="Justfile"
    ["cargo"]="Cargo.toml"
    ["maven"]="pom.xml"
    ["gradle"]="build.gradle"
    ["bazel"]="WORKSPACE"
    ["pants"]="pants.toml"
    ["nx"]="nx.json"  # Preferred per ADR 20260419001
    ["turbo"]="turbo.json"  # Legacy - superseded by NX
    ["python"]="pyproject.toml"
    ["go"]="go.mod"
    ["nix"]="flake.nix"
)

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
Usage: $0 [OPTIONS] REPO_PATH

Arguments:
    REPO_PATH    Path to the repository to validate

Options:
    -v, --verbose    Show detailed validation output
    -t, --targets     Comma-separated list of targets to test
    -f, --fast        Skip time-consuming tests
    -h, --help       Show this help message

Examples:
    $0 /opt/webapp-repo
    $0 --verbose --targets "build,test" ~/extracted-projects/shared-utils
    $0 --fast /opt/webapp-repo
EOF
}

detect_build_system() {
    local repo_path="$1"
    
    cd "$repo_path"
    
    log_step "Detecting build system"
    
    local detected_systems=()
    
    for system in "${!BUILD_SYSTEMS[@]}"; do
        local indicator="${BUILD_SYSTEMS[$system]}"
        if [[ -f "$indicator" ]] || [[ -d "$indicator" ]]; then
            detected_systems+=("$system")
            log_info "  ✓ $system detected (via $indicator)"
        fi
    done
    
    if [[ ${#detected_systems[@]} -eq 0 ]]; then
        log_warn "No recognized build system detected"
        return 1
    fi
    
    echo "Detected build systems: ${detected_systems[*]}"
    return 0
}

validate_npm_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if [[ ! -f "package.json" ]]; then
        return 1
    fi
    
    # Check if target exists in package.json scripts
    if ! jq -e ".scripts.\"$target\"" package.json >/dev/null 2>&1; then
        log_warn "  Script '$target' not found in package.json"
        return 1
    fi
    
    log_info "  Testing npm run $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                npm run bootstrap --if-present
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            npm run doctor --if-present
            ;;
        "build")
            npm run build --if-present
            ;;
        "lint")
            npm run lint --if-present
            ;;
        "typecheck")
            npm run typecheck --if-present
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                npm run test --if-present
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                npm install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            npm run "$target" --if-present
            ;;
    esac
}

validate_pnpm_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v pnpm >/dev/null 2>&1; then
        log_warn "  pnpm not available, skipping"
        return 1
    fi
    
    if [[ ! -f "package.json" ]]; then
        return 1
    fi
    
    # Check if target exists in package.json scripts
    if ! jq -e ".scripts.\"$target\"" package.json >/dev/null 2>&1; then
        log_warn "  Script '$target' not found in package.json"
        return 1
    fi
    
    log_info "  Testing pnpm run $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                pnpm run bootstrap --if-present
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            pnpm run doctor --if-present
            ;;
        "build")
            pnpm run build --if-present
            ;;
        "lint")
            pnpm run lint --if-present
            ;;
        "typecheck")
            pnpm run typecheck --if-present
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                pnpm run test --if-present
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                pnpm install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            pnpm run "$target" --if-present
            ;;
    esac
}

validate_make_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if [[ ! -f "Makefile" ]]; then
        return 1
    fi
    
    # Check if target exists in Makefile
    if ! grep -q "^$target:" Makefile; then
        log_warn "  Target '$target' not found in Makefile"
        return 1
    fi
    
    log_info "  Testing make $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                make bootstrap
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            make doctor
            ;;
        "build")
            make build
            ;;
        "lint")
            make lint
            ;;
        "typecheck")
            make typecheck
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                make test
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                make install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            make "$target"
            ;;
    esac
}

validate_cargo_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v cargo >/dev/null 2>&1; then
        log_warn "  cargo not available, skipping"
        return 1
    fi
    
    if [[ ! -f "Cargo.toml" ]]; then
        return 1
    fi
    
    log_info "  Testing cargo $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                cargo build
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            cargo check
            ;;
        "build")
            cargo build
            ;;
        "lint")
            cargo clippy
            ;;
        "typecheck")
            cargo check
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                cargo test
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                cargo install --path .
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            log_warn "  Unknown cargo target: $target"
            ;;
    esac
}

validate_maven_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v mvn >/dev/null 2>&1; then
        log_warn "  mvn not available, skipping"
        return 1
    fi
    
    if [[ ! -f "pom.xml" ]]; then
        return 1
    fi
    
    log_info "  Testing maven $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                mvn dependency:resolve
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            mvn validate
            ;;
        "build")
            mvn compile
            ;;
        "lint")
            mvn checkstyle:check
            ;;
        "typecheck")
            mvn compile
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                mvn test
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                mvn install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            log_warn "  Unknown maven target: $target"
            ;;
    esac
}

validate_python_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if [[ ! -f "pyproject.toml" ]]; then
        return 1
    fi
    
    log_info "  Testing python $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                if command -v pip >/dev/null 2>&1; then
                    pip install -e .
                elif command -v poetry >/dev/null 2>&1; then
                    poetry install
                fi
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            python -m py_compile **/*.py
            ;;
        "build")
            if command -v poetry >/dev/null 2>&1; then
                poetry build
            elif command -v setuptools >/dev/null 2>&1; then
                python setup.py build
            fi
            ;;
        "lint")
            if command -v ruff >/dev/null 2>&1; then
                ruff check .
            elif command -v flake8 >/dev/null 2>&1; then
                flake8 .
            fi
            ;;
        "typecheck")
            if command -v mypy >/dev/null 2>&1; then
                mypy .
            fi
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                if command -v pytest >/dev/null 2>&1; then
                    pytest
                elif command -v python >/dev/null 2>&1; then
                    python -m unittest discover
                fi
            else
                log_info "  [FAST MODE] Skipping test"
            fi
            ;;
        "deploy")
            log_warn "  Skipping deploy (production operation)"
            ;;
        "run")
            log_warn "  Skipping run (requires specific parameters)"
            ;;
        "install")
            if [[ "$fast_mode" != "true" ]]; then
                if command -v pip >/dev/null 2>&1; then
                    pip install -e .
                elif command -v poetry >/dev/null 2>&1; then
                    poetry install
                fi
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            log_warn "  Unknown python target: $target"
            ;;
    esac
}

validate_target() {
    local target="$1"
    local build_systems="$2"
    local fast_mode="${3:-false}"
    local verbose="${4:-false}"
    
    log_step "Validating target: $target"
    
    local target_passed=false
    
    for system in $build_systems; do
        case "$system" in
            "npm"|"yarn"|"bun")
                if validate_npm_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "pnpm")
                if validate_pnpm_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "make")
                if validate_make_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "cargo")
                if validate_cargo_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "maven")
                if validate_maven_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "python")
                if validate_python_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            *)
                log_warn "  Build system $system not supported for target validation"
                ;;
        esac
    done
    
    if [[ "$target_passed" == "true" ]]; then
        log_info "  ✓ Target '$target' validation passed"
        return 0
    else
        log_error "  ✗ Target '$target' validation failed"
        return 1
    fi
}

generate_validation_report() {
    local repo_path="$1"
    local report_file="$2"
    local results="$3"
    
    cd "$repo_path"
    
    {
        echo "# Monorepo Targets Validation Report"
        echo "Generated: $(date)"
        echo "Repository: $repo_path"
        echo
        
        echo "## Validation Results"
        echo "$results"
        echo
        
        echo "## Repository Information"
        echo "- Build systems: $(detect_build_system . | grep "Detected" | cut -d: -f2 | tr -d ' ')"
        echo "- Repository size: $(du -sh . | cut -f1)"
        echo "- Last commit: $(git log -1 --format='%h %s')"
        echo
        
        echo "## Environment"
        echo "- Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
        echo "- Python: $(python --version 2>/dev/null || echo 'Not installed')"
        echo "- Rust: $(rustc --version 2>/dev/null | cut -d' ' -f2 || echo 'Not installed')"
        echo "- Java: $(java -version 2>&1 | head -n1 | cut -d'"' -f2 || echo 'Not installed')"
        echo "- Go: $(go version 2>/dev/null | cut -d' ' -f3 || echo 'Not installed')"
    } > "$report_file"
    
    log_info "Validation report generated: $report_file"
}

main() {
    local repo_path=""
    local targets_to_test=""
    local verbose=false
    local fast_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -t|--targets)
                targets_to_test="$2"
                shift 2
                ;;
            -f|--fast)
                fast_mode=true
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
    
    # Set default targets if not specified
    if [[ -z "$targets_to_test" ]]; then
        targets_to_test=$(IFS=,; echo "${COMMON_TARGETS[*]}")
    fi
    
    echo "=== Monorepo Targets Validation ==="
    echo "Repository: $repo_path"
    echo "Targets: $targets_to_test"
    echo "Verbose: $verbose"
    echo "Fast mode: $fast_mode"
    echo
    
    cd "$repo_path"
    
    # Detect build systems
    local build_systems
    if ! build_systems=$(detect_build_system "."); then
        log_error "Could not detect build system"
        exit 1
    fi
    
    # Extract build system names
    build_systems=$(echo "$build_systems" | grep "✓" | sed 's/.*✓ \([^ ]*\).*/\1/' | tr '\n' ' ')
    
    # Validate each target
    local results=""
    local failed_targets=()
    local passed_targets=()
    
    IFS=',' read -ra targets <<< "$targets_to_test"
    for target in "${targets[@]}"; do
        target=$(echo "$target" | xargs) # trim whitespace
        
        if validate_target "$target" "$build_systems" "$fast_mode" "$verbose"; then
            passed_targets+=("$target")
            results+="✓ $target: PASSED\n"
        else
            failed_targets+=("$target")
            results+="✗ $target: FAILED\n"
        fi
        echo
    done
    
    # Generate report
    local report_file="${repo_path}/targets-validation-$(date +%Y%m%d-%H%M%S).md"
    generate_validation_report "$repo_path" "$report_file" "$results"
    
    echo "=== Validation Summary ==="
    echo "Passed targets: ${#passed_targets[@]}"
    echo "Failed targets: ${#failed_targets[@]}"
    
    if [[ ${#passed_targets[@]} -gt 0 ]]; then
        echo "✓ ${passed_targets[*]}"
    fi
    
    if [[ ${#failed_targets[@]} -gt 0 ]]; then
        echo "✗ ${failed_targets[*]}"
    fi
    
    if [[ ${#failed_targets[@]} -eq 0 ]]; then
        log_info "✓ All targets validated successfully"
        exit 0
    else
        log_error "✗ Some targets failed validation"
        exit 1
    fi
}

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
