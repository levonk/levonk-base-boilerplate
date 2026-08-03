#!/usr/bin/env bats
# Test copier template settings for common misconfigurations.
# Run: bats tests/test-copier-settings.bats

# Setup: find the boilerplate root
setup() {
    BATS_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

# Test 1: All copier.yml/yaml files use _subdirectory: files (not dynamic paths)
@test "all copier configs use _subdirectory: files (no dynamic paths)" {
    local copier_files
    copier_files=$(find "$BATS_ROOT" -name "copier.y*ml" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*")

    [ -n "$copier_files" ] || skip "no copier files found"

    local failed=0
    for f in $copier_files; do
        local subdir
        subdir=$(grep -E '^_subdirectory:' "$f" | head -1 | sed 's/^_subdirectory:[[:space:]]*//' | tr -d '"'"'"'')
        if [[ "$subdir" != "files" ]]; then
            echo "FAIL: $f has _subdirectory: '$subdir' (expected 'files')" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}

# Test 2: All copier configs use _templates_suffix: .jinja
@test "all copier configs use _templates_suffix: .jinja" {
    local copier_files
    copier_files=$(find "$BATS_ROOT" -name "copier.y*ml" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*")

    [ -n "$copier_files" ] || skip "no copier files found"

    local failed=0
    for f in $copier_files; do
        local suffix
        suffix=$(grep -E '^_templates_suffix:' "$f" | head -1 | sed 's/^_templates_suffix:[[:space:]]*//' | tr -d '"'"'"'')
        if [[ "$suffix" != ".jinja" ]]; then
            echo "FAIL: $f has _templates_suffix: '$suffix' (expected '.jinja')" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}

# Test 3: No duplicate _subdirectory or _templates_suffix in any copier file
@test "no copier file has duplicate _subdirectory or _templates_suffix" {
    local copier_files
    copier_files=$(find "$BATS_ROOT" -name "copier.y*ml" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*")

    [ -n "$copier_files" ] || skip "no copier files found"

    local failed=0
    for f in $copier_files; do
        local count_subdir count_suffix
        count_subdir=$(grep -cE '^_subdirectory:' "$f")
        count_suffix=$(grep -cE '^_templates_suffix:' "$f")
        if [ "$count_subdir" -gt 1 ]; then
            echo "FAIL: $f has $count_subdir _subdirectory entries (expected 1)" >&3
            failed=1
        fi
        if [ "$count_suffix" -gt 1 ]; then
            echo "FAIL: $f has $count_suffix _templates_suffix entries (expected 1)" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}

# Test 4: No .tmpl files contain unrendered Jinja syntax (should be .jinja)
@test "no .tmpl files contain Jinja syntax (should be renamed to .jinja)" {
    local tmpl_files
    tmpl_files=$(find "$BATS_ROOT" -name "*.tmpl" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*" \
        -not -path "*/internal-docs/*")

    [ -n "$tmpl_files" ] || skip "no .tmpl files found"

    local failed=0
    for f in $tmpl_files; do
        if grep -qE '\{\{.*\}\}' "$f" 2>/dev/null; then
            echo "FAIL: $f contains Jinja syntax but has .tmpl suffix (should be .jinja)" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}

# Test 5: No package.json template uses "*" as a dependency version specifier
@test "no package.json template uses '*' as a dependency version specifier" {
    local pkg_files
    pkg_files=$(find "$BATS_ROOT" -name "package.json.jinja" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*")

    [ -n "$pkg_files" ] || skip "no package.json.jinja files found"

    local failed=0
    for f in $pkg_files; do
        # Only check lines inside dependencies/devDependencies blocks
        # Extract dependency blocks and check for "*" versions
        # Allow "workspace:*" and "catalog:" — only flag bare "*"
        local dep_lines
        dep_lines=$(python3 -c "
import json, sys, re
with open('$f') as fh:
    content = fh.read()
# Find all dependency entries: \"pkg-name\": \"version\"
# Match inside dependencies/devDependencies/peerDependencies/optionalDependencies
# Skip engines, devEngines, packageManager, version fields
for m in re.finditer(r'\"((?:dependencies|devDependencies|peerDependencies|optionalDependencies)\"\s*:\s*\{)([^}]*)\}', content):
    block = m.group(2)
    for dep_match in re.finditer(r'\"([^\"]+)\"\s*:\s*\"([^\"]+)\"', block):
        pkg, ver = dep_match.group(1), dep_match.group(2)
        if ver == '*' and pkg != 'workspace':
            print(f'{pkg}: {ver}')
" 2>/dev/null)
        if [ -n "$dep_lines" ]; then
            echo "FAIL: $f has dependency entries with '\"*\"' version:" >&3
            echo "$dep_lines" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}

# Test 6: No duplicate copier.yml and copier.yaml in the same directory
@test "no directory has both copier.yml and copier.yaml" {
    local copier_files dirs_with_both
    copier_files=$(find "$BATS_ROOT" -name "copier.y*ml" \
        -not -path "*/node_modules/*" \
        -not -path "*/experiments/*" \
        -not -path "*/.git/*")

    [ -n "$copier_files" ] || skip "no copier files found"

    local failed=0
    for f in $copier_files; do
        local dir
        dir=$(dirname "$f")
        if [ -f "$dir/copier.yml" ] && [ -f "$dir/copier.yaml" ]; then
            echo "FAIL: $dir has both copier.yml and copier.yaml" >&3
            failed=1
        fi
    done
    [ "$failed" -eq 0 ]
}
