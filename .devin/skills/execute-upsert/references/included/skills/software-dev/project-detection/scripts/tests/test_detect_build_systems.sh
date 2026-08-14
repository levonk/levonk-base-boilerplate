#!/usr/bin/env bash
# test_detect_build_systems.sh — unit tests for detect-build-systems.sh
# Tests build system detection (npm, cargo, maven, swift, etc.) and
# environment wrapper detection (devbox, nix, mise) via cli-tool-discovery.sh.
#
# Run directly:
#   bash scripts/tests/test_detect_build_systems.sh
#
# Creates temp scenarios under /tmp/skill-test/project-detection/{scenario}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/../detect-build-systems.sh"
EXTRACT_SCRIPT="$SCRIPT_DIR/../extract-build-targets.sh"
TEST_BASE="/tmp/skill-test/project-detection"

FAILED=0
PASSED=0
SKIPPED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }
skip() { echo "  SKIP: $1 (tool not installed)"; SKIPPED=$((SKIPPED + 1)); }

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — expected '$needle' in '$haystack'"
    fi
}
assert_not_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — did not expect '$needle' in '$haystack'"
    fi
}

# Create a scenario dir with specific files. Echoes the dir path.
setup_scenario() {
    local scenario="$1"; shift
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        touch "$dir/$f"
    done
    echo "$dir"
}

# Run detect-build-systems.sh from a given dir. Echoes detected systems.
run_detect() {
    local dir="$1"
    (cd "$dir" && bash "$DETECT_SCRIPT" "$dir") 2>/dev/null || true
}

# Run extract-build-targets.sh show from a given dir.
run_show_targets() {
    local dir="$1"
    (cd "$dir" && bash "$EXTRACT_SCRIPT" show "$dir") 2>/dev/null || true
}

# --- build system detection tests ---

test_npm_detection() {
    local dir; dir="$(setup_scenario npm package.json)"
    local out; out="$(run_detect "$dir")"
    assert_contains "npm: detects package.json" "npm" "$out"
}

test_cargo_detection() {
    local dir; dir="$(setup_scenario cargo Cargo.toml)"
    local out; out="$(run_detect "$dir")"
    assert_contains "cargo: detects Cargo.toml" "cargo" "$out"
}

test_go_detection() {
    local dir; dir="$(setup_scenario go go.mod)"
    local out; out="$(run_detect "$dir")"
    assert_contains "go: detects go.mod" "go" "$out"
}

test_maven_detection() {
    local dir; dir="$(setup_scenario maven pom.xml)"
    local out; out="$(run_detect "$dir")"
    assert_contains "maven: detects pom.xml" "maven" "$out"
}

test_gradle_detection() {
    local dir; dir="$(setup_scenario gradle build.gradle)"
    local out; out="$(run_detect "$dir")"
    assert_contains "gradle: detects build.gradle" "gradle" "$out"
}

test_python_detection() {
    local dir; dir="$(setup_scenario python pyproject.toml)"
    local out; out="$(run_detect "$dir")"
    assert_contains "python: detects pyproject.toml" "python" "$out"
}

test_swift_detection() {
    local dir; dir="$(setup_scenario swift Package.swift)"
    local out; out="$(run_detect "$dir")"
    assert_contains "swift: detects Package.swift" "swift" "$out"
}

test_make_detection() {
    local dir; dir="$(setup_scenario make Makefile)"
    local out; out="$(run_detect "$dir")"
    assert_contains "make: detects Makefile" "make" "$out"
}

test_just_detection() {
    local dir; dir="$(setup_scenario just Justfile)"
    local out; out="$(run_detect "$dir")"
    assert_contains "just: detects Justfile" "just" "$out"
}

test_dotnet_detection() {
    local dir; dir="$(setup_scenario dotnet MyProject.csproj)"
    local out; out="$(run_detect "$dir")"
    assert_contains "dotnet: detects *.csproj" "dotnet" "$out"
}

test_ruby_detection() {
    local dir; dir="$(setup_scenario ruby Gemfile)"
    local out; out="$(run_detect "$dir")"
    assert_contains "ruby: detects Gemfile" "ruby" "$out"
}

test_elixir_detection() {
    local dir; dir="$(setup_scenario elixir mix.exs)"
    local out; out="$(run_detect "$dir")"
    assert_contains "elixir: detects mix.exs" "elixir" "$out"
}

test_docker_detection() {
    local dir; dir="$(setup_scenario docker Dockerfile)"
    local out; out="$(run_detect "$dir")"
    assert_contains "docker: detects Dockerfile" "docker" "$out"
}

test_multiple_systems() {
    local dir; dir="$(setup_scenario multi package.json Cargo.toml Makefile)"
    local out; out="$(run_detect "$dir")"
    assert_contains "multi: detects npm" "npm" "$out"
    assert_contains "multi: detects cargo" "cargo" "$out"
    assert_contains "multi: detects make" "make" "$out"
}

test_no_systems() {
    local dir; dir="$(setup_scenario empty)"
    local out; out="$(run_detect "$dir")"
    # Should be empty or just whitespace
    assert_not_contains "empty: no false positives" "npm" "$out"
    assert_not_contains "empty: no false positives" "cargo" "$out"
}

# --- environment wrapper detection tests (via cli-tool-discovery.sh) ---

test_devbox_detection() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox detection"; return; }
    local dir; dir="$(setup_scenario devbox devbox.json)"
    local out; out="$(run_detect "$dir")"
    assert_contains "devbox: detects devbox.json" "devbox" "$out"
}

test_nix_detection() {
    command -v nix >/dev/null 2>&1 || { skip "nix detection"; return; }
    local dir; dir="$(setup_scenario nix flake.nix)"
    local out; out="$(run_detect "$dir")"
    assert_contains "nix: detects flake.nix" "nix" "$out"
}

test_mise_detection() {
    command -v mise >/dev/null 2>&1 || { skip "mise detection"; return; }
    local dir; dir="$(setup_scenario mise mise.toml)"
    local out; out="$(run_detect "$dir")"
    assert_contains "mise: detects mise.toml" "mise" "$out"
}

test_no_wrapper_when_tool_missing() {
    # If devbox isn't installed, devbox.json should not trigger detection
    local dir; dir="$(setup_scenario no-devbox-tool devbox.json)"
    local out; out="$(run_detect "$dir")"
    if command -v devbox >/dev/null 2>&1; then
        assert_contains "devbox installed: detects devbox" "devbox" "$out"
    else
        assert_not_contains "devbox not installed: no false positive" "devbox" "$out"
    fi
}

# --- extract-build-targets tests ---

test_swift_targets() {
    local dir; dir="$(setup_scenario swift-targets Package.swift)"
    local out; out="$(run_show_targets "$dir")"
    assert_contains "swift targets: shows build" "build" "$out"
    assert_contains "swift targets: shows test" "test" "$out"
}

test_cargo_targets() {
    local dir; dir="$(setup_scenario cargo-targets Cargo.toml)"
    local out; out="$(run_show_targets "$dir")"
    assert_contains "cargo targets: shows build" "build" "$out"
    assert_contains "cargo targets: shows test" "test" "$out"
}

test_makefile_targets() {
    local dir
    dir="$TEST_BASE/makefile-targets"
    rm -rf "$dir"; mkdir -p "$dir"
    cat > "$dir/Makefile" <<'EOF'
build:
	echo build
test:
	echo test
lint:
	echo lint
EOF
    local out; out="$(run_show_targets "$dir")"
    assert_contains "makefile targets: shows build" "build" "$out"
    assert_contains "makefile targets: shows test" "test" "$out"
    assert_contains "makefile targets: shows lint" "lint" "$out"
}

test_maven_targets() {
    local dir; dir="$(setup_scenario maven-targets pom.xml)"
    local out; out="$(run_show_targets "$dir")"
    assert_contains "maven targets: shows compile/test" "test" "$out"
}

test_gradle_targets() {
    local dir; dir="$(setup_scenario gradle-targets build.gradle)"
    local out; out="$(run_show_targets "$dir")"
    assert_contains "gradle targets: shows build/test" "test" "$out"
}

test_devbox_targets() {
    local dir
    dir="$TEST_BASE/devbox-targets"
    rm -rf "$dir"; mkdir -p "$dir"
    cat > "$dir/devbox.json" <<'EOF'
{
  "packages": ["python3@latest"],
  "scripts": {
    "build": "echo build",
    "test": "echo test"
  }
}
EOF
    local out; out="$(run_show_targets "$dir")"
    assert_contains "devbox targets: shows build" "build" "$out"
    assert_contains "devbox targets: shows test" "test" "$out"
}

# --- main ---

main() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"

    echo "=== project-detection: detect-build-systems.sh tests ==="
    echo ""

    echo "--- build system detection ---"
    test_npm_detection
    test_cargo_detection
    test_go_detection
    test_maven_detection
    test_gradle_detection
    test_python_detection
    test_swift_detection
    test_make_detection
    test_just_detection
    test_dotnet_detection
    test_ruby_detection
    test_elixir_detection
    test_docker_detection
    test_multiple_systems
    test_no_systems

    echo ""
    echo "--- environment wrapper detection ---"
    test_devbox_detection
    test_nix_detection
    test_mise_detection
    test_no_wrapper_when_tool_missing

    echo ""
    echo "--- extract-build-targets ---"
    test_swift_targets
    test_cargo_targets
    test_makefile_targets
    test_maven_targets
    test_gradle_targets
    test_devbox_targets

    echo ""
    echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

    rm -rf "$TEST_BASE"
    exit "$FAILED"
}

main "$@"
