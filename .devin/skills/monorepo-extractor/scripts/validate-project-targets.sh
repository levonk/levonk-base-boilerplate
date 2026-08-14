#!/bin/bash
# Validate project-specific targets and commands
# Modular validation for different build systems and languages

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Common targets to validate
COMMON_TARGETS=("bootstrap" "doctor" "build" "lint" "typecheck" "test" "deploy" "run" "install")

# Import detection functions
source "$(dirname "${BASH_SOURCE[0]}")/detect-build-systems.sh"

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

validate_yarn_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v yarn >/dev/null 2>&1; then
        log_warn "  yarn not available, skipping"
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
    
    log_info "  Testing yarn run $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                yarn run bootstrap --if-present
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            yarn run doctor --if-present
            ;;
        "build")
            yarn run build --if-present
            ;;
        "lint")
            yarn run lint --if-present
            ;;
        "typecheck")
            yarn run typecheck --if-present
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                yarn run test --if-present
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
                yarn install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            yarn run "$target" --if-present
            ;;
    esac
}

validate_bun_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v bun >/dev/null 2>&1; then
        log_warn "  bun not available, skipping"
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
    
    log_info "  Testing bun run $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                bun run bootstrap --if-present
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            bun run doctor --if-present
            ;;
        "build")
            bun run build --if-present
            ;;
        "lint")
            bun run lint --if-present
            ;;
        "typecheck")
            bun run typecheck --if-present
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                bun run test --if-present
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
                bun install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            bun run "$target" --if-present
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

validate_go_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v go >/dev/null 2>&1; then
        log_warn "  go not available, skipping"
        return 1
    fi
    
    if [[ ! -f "go.mod" ]]; then
        return 1
    fi
    
    log_info "  Testing go $target"
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                go mod download
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            go mod verify
            ;;
        "build")
            go build ./...
            ;;
        "lint")
            if command -v golangci-lint >/dev/null 2>&1; then
                golangci-lint run
            elif command -v golint >/dev/null 2>&1; then
                golint ./...
            fi
            ;;
        "typecheck")
            # Go doesn't have a separate typecheck, build includes it
            go build ./...
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                go test ./...
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
                go install ./...
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            log_warn "  Unknown go target: $target"
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

validate_gradle_targets() {
    local target="$1"
    local fast_mode="${2:-false}"
    
    if ! command -v gradle >/dev/null 2>&1 && ! command -v ./gradlew >/dev/null 2>&1; then
        log_warn "  gradle not available, skipping"
        return 1
    fi
    
    if [[ ! -f "build.gradle" ]] && [[ ! -f "build.gradle.kts" ]]; then
        return 1
    fi
    
    log_info "  Testing gradle $target"
    
    # Use gradlew if available, otherwise gradle
    local gradle_cmd="gradle"
    if [[ -f "./gradlew" ]]; then
        gradle_cmd="./gradlew"
    fi
    
    case "$target" in
        "bootstrap")
            if [[ "$fast_mode" != "true" ]]; then
                $gradle_cmd dependencies
            else
                log_info "  [FAST MODE] Skipping bootstrap"
            fi
            ;;
        "doctor")
            $gradle_cmd validate
            ;;
        "build")
            $gradle_cmd build
            ;;
        "lint")
            $gradle_cmd checkstyleMain
            ;;
        "typecheck")
            $gradle_cmd compileJava
            ;;
        "test")
            if [[ "$fast_mode" != "true" ]]; then
                $gradle_cmd test
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
                $gradle_cmd install
            else
                log_info "  [FAST MODE] Skipping install"
            fi
            ;;
        *)
            log_warn "  Unknown gradle target: $target"
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
                if [[ "$system" == "npm" ]]; then
                    if validate_npm_targets "$target" "$fast_mode"; then
                        target_passed=true
                    fi
                elif [[ "$system" == "pnpm" ]]; then
                    if validate_pnpm_targets "$target" "$fast_mode"; then
                        target_passed=true
                    fi
                elif [[ "$system" == "yarn" ]]; then
                    if validate_yarn_targets "$target" "$fast_mode"; then
                        target_passed=true
                    fi
                elif [[ "$system" == "bun" ]]; then
                    if validate_bun_targets "$target" "$fast_mode"; then
                        target_passed=true
                    fi
                fi
                ;;
            "cargo"|"rust")
                if validate_cargo_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "python"|"poetry"|"pip")
                if validate_python_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "go"|"golang")
                if validate_go_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "maven")
                if validate_maven_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "gradle")
                if validate_gradle_targets "$target" "$fast_mode"; then
                    target_passed=true
                fi
                ;;
            "make")
                if validate_make_targets "$target" "$fast_mode"; then
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
                echo "Usage: $0 [OPTIONS] REPO_PATH"
                echo "Validate project-specific targets and commands"
                echo
                echo "Options:"
                echo "  -v, --verbose    Show detailed validation output"
                echo "  -t, --targets     Comma-separated list of targets to test"
                echo "  -f, --fast        Skip time-consuming tests"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                if [[ -z "$repo_path" ]]; then
                    repo_path="$1"
                else
                    log_error "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$repo_path" ]]; then
        log_error "Repository path is required"
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
    
    echo "=== Project Targets Validation ==="
    echo "Repository: $repo_path"
    echo "Targets: $targets_to_test"
    echo "Verbose: $verbose"
    echo "Fast mode: $fast_mode"
    echo
    
    cd "$repo_path"
    
    # Detect build systems
    local build_systems
    if ! build_systems=$(detect-systems "$repo_path" "$verbose"); then
        log_error "Could not detect build system"
        exit 1
    fi
    
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
