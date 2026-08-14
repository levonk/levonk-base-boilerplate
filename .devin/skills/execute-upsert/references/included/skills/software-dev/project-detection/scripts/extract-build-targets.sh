#!/bin/bash

# Extract build targets from existing configuration files
# Returns justfile-compatible targets based on discovered configurations

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Extract targets from package.json scripts
extract_package_json_targets() {
    local package_json="$1"

    if [[ ! -f "$package_json" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $package_json"

    # Use jq to extract scripts, fallback to grep if jq not available
    if command -v jq &> /dev/null; then
        jq -r '.scripts // {} | to_entries[] | "\(.key):\n\t\(.value)"' "$package_json" 2>/dev/null || true
    else
        # Fallback to grep/sed
        grep -A 100 '"scripts"' "$package_json" | grep -E '^\s*"[^"]+":\s*"' | sed 's/^[[:space:]]*"\([^"]*\)":[[:space:]]*"\(.*\)".*/\1:\n\t\2/' || true
    fi
}

# Extract targets from Cargo.toml
extract_cargo_targets() {
    local cargo_toml="$1"

    if [[ ! -f "$cargo_toml" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $cargo_toml"

    echo "build:"
    echo "	cargo build --release"
    echo ""
    echo "build-dev:"
    echo "	cargo build"
    echo ""
    echo "test:"
    echo "	cargo test"
    echo ""
    echo "run:"
    echo "	cargo run"
    echo ""
    echo "check:"
    echo "	cargo check"
    echo ""
    echo "clean:"
    echo "	cargo clean"
    echo ""
    echo "fmt:"
    echo "	cargo fmt"
    echo ""
    echo "clippy:"
    echo "	cargo clippy -- -D warnings"
}

# Extract targets from Makefile
extract_makefile_targets() {
    local makefile="$1"

    if [[ ! -f "$makefile" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $makefile"

    # Extract targets that don't start with . and contain :
    grep -E '^[a-zA-Z][^:]*:' "$makefile" | grep -v -E '^\.' | sed 's/:.*$//' | while read -r target; do
        if [[ -n "$target" ]]; then
            echo "$target:"
            echo "	make $target"
            echo ""
        fi
    done
}

# Extract targets from pyproject.toml
extract_pyproject_targets() {
    local pyproject_toml="$1"

    if [[ ! -f "$pyproject_toml" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $pyproject_toml"

    # Check for poetry scripts
    if grep -q '\[tool.poetry.scripts\]' "$pyproject_toml"; then
        echo "install:"
        echo "	poetry install"
        echo ""
        echo "build:"
        echo "	poetry build"
        echo ""
        echo "publish:"
        echo "	poetry publish"
        echo ""
    fi

    # Check for standard tool configurations
    echo "test:"
    echo "	python -m pytest"
    echo ""
    echo "lint:"
    echo "	python -m ruff check ."
    echo ""
    echo "format:"
    echo "	python -m black ."
    echo ""
    echo "typecheck:"
    echo "	python -m mypy ."
    echo ""
}

# Extract targets from go.mod
extract_go_targets() {
    local go_mod="$1"

    if [[ ! -f "$go_mod" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $go_mod"

    echo "build:"
    echo "	go build ./..."
    echo ""
    echo "test:"
    echo "	go test ./..."
    echo ""
    echo "run:"
    echo "	go run ./..."
    echo ""
    echo "mod-tidy:"
    echo "	go mod tidy"
    echo ""
    echo "mod-download:"
    echo "	go mod download"
    echo ""
    echo "vet:"
    echo "	go vet ./..."
    echo ""
    echo "fmt:"
    echo "	go fmt ./..."
    echo ""
}

# Extract targets from pom.xml (Maven)
extract_maven_targets() {
    local pom_xml="$1"

    if [[ ! -f "$pom_xml" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $pom_xml"

    echo "compile:"
    echo "	mvn compile"
    echo ""
    echo "test:"
    echo "	mvn test"
    echo ""
    echo "package:"
    echo "	mvn package"
    echo ""
    echo "install:"
    echo "	mvn install"
    echo ""
    echo "clean:"
    echo "	mvn clean"
    echo ""
    echo "verify:"
    echo "	mvn verify"
    echo ""
}

# Extract targets from build.gradle or build.gradle.kts
extract_gradle_targets() {
    local build_gradle="$1"

    if [[ ! -f "$build_gradle" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $build_gradle"

    echo "build:"
    echo "	./gradlew build"
    echo ""
    echo "test:"
    echo "	./gradlew test"
    echo ""
    echo "compile:"
    echo "	./gradlew compileJava"
    echo ""
    echo "jar:"
    echo "	./gradlew jar"
    echo ""
    echo "clean:"
    echo "	./gradlew clean"
    echo ""
    echo "bootRun:"
    echo "	./gradlew bootRun"
    echo ""
}

# Extract targets from Package.swift (Swift Package Manager)
extract_swift_targets() {
    local package_swift="$1"

    if [[ ! -f "$package_swift" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $package_swift"

    echo "build:"
    echo "	swift build"
    echo ""
    echo "build-release:"
    echo "	swift build -c release"
    echo ""
    echo "test:"
    echo "	swift test"
    echo ""
    echo "run:"
    echo "	swift run"
    echo ""
    echo "clean:"
    echo "	swift package clean"
    echo ""
    echo "update:"
    echo "	swift package update"
    echo ""
}

# Extract targets from devbox.json
extract_devbox_targets() {
    local devbox_json="$1"

    if [[ ! -f "$devbox_json" ]]; then
        return 0
    fi

    log_debug "Extracting targets from $devbox_json"

    # Generate standard devbox targets according to adopt-project standards
    echo "# Standard devbox targets (ADR 20260131001 compliant)"
    echo ""
    echo "clean:"
    echo "	devbox shell clean"
    echo ""
    echo "dev:"
    echo "	devbox shell dev"
    echo ""
    echo "build:"
    echo "	devbox shell build"
    echo ""
    echo "test:"
    echo "	devbox shell test"
    echo ""
    echo "lint:"
    echo "	devbox shell lint"
    echo ""
    echo "typecheck:"
    echo "	devbox shell typecheck"
    echo ""
    echo "# Bootstrap recipes (REQUIRED)"
    echo "bootstrap:"
    echo "	devbox shell bootstrap"
    echo ""
    echo "bootstrap_impl:"
    echo "	# Language-specific setup handled by devbox"
    echo "	echo \"Development environment ready!\""
    echo ""

    # Extract custom scripts from devbox.json if they exist
    if command -v jq &> /dev/null; then
        local custom_scripts
        custom_scripts=$(jq -r '.scripts // {} | to_entries[] | select(.key != "bootstrap" and .key != "bootstrap_impl") | "\(.key):\n\tdevbox shell \(.key)"' "$devbox_json" 2>/dev/null || echo "")

        if [[ -n "$custom_scripts" ]]; then
            echo "# Custom scripts from devbox.json"
            echo "$custom_scripts"
            echo ""
        fi

        # Also extract packages for informational purposes
        local packages
        packages=$(jq -r '.packages // {} | keys[]' "$devbox_json" 2>/dev/null || echo "")

        if [[ -n "$packages" ]]; then
            echo "# Package management"
            echo "install:"
            echo "	devbox install"
            echo ""
            echo "shell:"
            echo "	devbox shell"
            echo ""
        fi
    fi

    # Add common devbox targets
    echo "# Common devbox commands"
    echo "devbox-shell:"
    echo "	devbox shell"
    echo ""
    echo "devbox-install:"
    echo "	devbox install"
    echo ""
    echo "devbox-update:"
    echo "	devbox update"
    echo ""
}

# Generate justfile from all detected configurations
generate_justfile_from_configs() {
    local project_path="${1:-.}"
    local output_file="${2:-justfile}"

    log_info "Generating justfile from existing configurations in $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Start justfile with header
    cat > "$output_file" << 'EOF'
# Generated justfile based on existing project configurations
# Auto-generated by extract-build-targets.sh

default:
    @just --list

EOF

    local found_configs=false

    # Check each configuration file and extract targets
    if [[ -f "package.json" ]]; then
        log_info "Found package.json - extracting npm/pnpm/yarn scripts"
        echo "# npm/pnpm/yarn scripts from package.json" >> "$output_file"
        extract_package_json_targets "package.json" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "Cargo.toml" ]]; then
        log_info "Found Cargo.toml - adding Cargo targets"
        echo "# Cargo targets" >> "$output_file"
        extract_cargo_targets "Cargo.toml" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "Makefile" ]]; then
        log_info "Found Makefile - extracting targets"
        echo "# Targets from Makefile" >> "$output_file"
        extract_makefile_targets "Makefile" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "pyproject.toml" ]]; then
        log_info "Found pyproject.toml - adding Python targets"
        echo "# Python targets from pyproject.toml" >> "$output_file"
        extract_pyproject_targets "pyproject.toml" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "go.mod" ]]; then
        log_info "Found go.mod - adding Go targets"
        echo "# Go targets" >> "$output_file"
        extract_go_targets "go.mod" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "pom.xml" ]]; then
        log_info "Found pom.xml - adding Maven targets"
        echo "# Maven targets" >> "$output_file"
        extract_maven_targets "pom.xml" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        local gradle_file="build.gradle"
        [[ -f "build.gradle.kts" ]] && gradle_file="build.gradle.kts"

        log_info "Found $gradle_file - adding Gradle targets"
        echo "# Gradle targets" >> "$output_file"
        extract_gradle_targets "$gradle_file" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "devbox.json" ]]; then
        log_info "Found devbox.json - adding Devbox targets"
        echo "# Devbox targets" >> "$output_file"
        extract_devbox_targets "devbox.json" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ -f "Package.swift" ]]; then
        log_info "Found Package.swift - adding Swift targets"
        echo "# Swift Package Manager targets" >> "$output_file"
        extract_swift_targets "Package.swift" >> "$output_file"
        echo "" >> "$output_file"
        found_configs=true
    fi

    if [[ "$found_configs" == "true" ]]; then
        # Add common loop targets
        echo "# Common development targets" >> "$output_file"
        echo "loop: || (install build test)" >> "$output_file"
        echo "ci: || (install lint test build)" >> "$output_file"
        echo "" >> "$output_file"

        log_info "✓ Generated justfile from existing configurations"
        log_info "Output file: $output_file"

        # Show preview
        echo ""
        echo "Generated justfile preview:"
        echo "=========================="
        head -20 "$output_file"
        echo "..."
    else
        log_warn "No supported configuration files found"
        return 1
    fi
}

# Show available targets in existing configurations
show_available_targets() {
    local project_path="${1:-.}"

    log_info "Scanning for build targets in $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    local found_any=false

    if [[ -f "package.json" ]]; then
        log_info "=== package.json scripts ==="
        extract_package_json_targets "package.json"
        found_any=true
    fi

    if [[ -f "Makefile" ]]; then
        log_info "=== Makefile targets ==="
        grep -E '^[a-zA-Z][^:]*:' "Makefile" | grep -v -E '^\.' | sed 's/:.*$//' | head -10
        found_any=true
    fi

    if [[ -f "Cargo.toml" ]]; then
        log_info "=== Cargo.toml (standard targets) ==="
        echo "build, test, run, check, clean, fmt, clippy"
        found_any=true
    fi

    if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        log_info "=== Python (standard targets) ==="
        echo "install, test, lint, fmt, typecheck"
        found_any=true
    fi

    if [[ -f "go.mod" ]]; then
        log_info "=== Go (standard targets) ==="
        echo "build, test, vet, fmt, run"
        found_any=true
    fi

    if [[ -f "pom.xml" ]]; then
        log_info "=== Maven (standard targets) ==="
        echo "compile, test, package, install, clean, verify"
        found_any=true
    fi

    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        log_info "=== Gradle (standard targets) ==="
        echo "build, test, compile, jar, clean, bootRun"
        found_any=true
    fi

    if [[ -f "devbox.json" ]]; then
        log_info "=== Devbox (custom scripts) ==="
        jq -r '.scripts // {} | keys[]' "devbox.json" 2>/dev/null || echo "(no custom scripts)"
        found_any=true
    fi

    if [[ -f "Package.swift" ]]; then
        log_info "=== Swift Package Manager (standard targets) ==="
        echo "build, build-release, test, run, clean, update"
        found_any=true
    fi

    if [[ "$found_any" == "false" ]]; then
        log_warn "No supported configuration files found"
        return 1
    fi
}

# Main function
main() {
    local command="${1:-help}"
    local project_path="${2:-.}"
    local output_file="${3:-justfile}"

    case "$command" in
        "generate")
            generate_justfile_from_configs "$project_path" "$output_file"
            ;;
        "show")
            show_available_targets "$project_path"
            ;;
        "help"|"-h"|"--help")
            cat << EOF
Extract Build Targets Script

Usage: $0 <command> [project_path] [output_file]

Commands:
    generate [path] [file]  Generate justfile from existing configs
    show [path]             Show available targets in configs
    help                    Show this help message

Examples:
    $0 generate . justfile
    $0 show .
    $0 generate /path/to/project custom-justfile

Supported configuration files:
    - package.json (npm/pnpm/yarn scripts)
    - Cargo.toml (Cargo commands)
    - Makefile (make targets)
    - pyproject.toml (Python/poetry)
    - go.mod (Go modules)
    - pom.xml (Maven)
    - build.gradle / build.gradle.kts (Gradle)
    - devbox.json (Devbox)
    - Package.swift (Swift Package Manager)

EOF
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            main "help"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
