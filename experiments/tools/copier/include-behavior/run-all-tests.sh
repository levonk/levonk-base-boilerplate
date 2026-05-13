#!/bin/bash

# Test all Copier include permutations
set -e

echo "=== Testing All Copier Include Permutations ==="
echo

# Test 0: Parent _partials
echo "Test 0: Parent _partials"
echo "--------------------"
cd /tmp/copier-permutations/parent-root-partials
copier copy . /tmp/output-parent --data project_name=parent 2>&1 | tee /tmp/parent.log
if [ -f /tmp/output-parent/template ]; then
    echo "✅ SUCCESS: Parent _partials works"
    echo "Output:"
    cat /tmp/output-parent/template
    echo
    echo "Files created:"
    find /tmp/output-parent -type f | sort
else
    echo "❌ FAILED: Parent _partials failed"
fi
echo

# Test 1: Root _partials
echo "Test 1: Root _partials"
echo "--------------------"
cd /tmp/copier-permutations/shared-root-partials
copier copy . /tmp/output-shared --data project_name=shared 2>&1 | tee /tmp/shared.log
if [ -f /tmp/output-shared/template ]; then
    echo "✅ SUCCESS: Root _partials works"
    echo "Output:"
    cat /tmp/output-shared/template
    echo
    echo "Files created:"
    find /tmp/output-shared -type f | sort
else
    echo "❌ FAILED: Root _partials failed"
fi
echo

# Test 2: copier/_partials
echo "Test 2: copier/_partials"
echo "-----------------------"
cd /tmp/copier-permutations/samedir-copier-partials
mkdir -p copier/_partials
echo "Partial from copier/_partials" > copier/_partials/test-partial.jinja
echo "# Test 2: copier/_partials

Project: {{ project_name }}

Including from copier/_partials:
{% include \"copier/_partials/test-partial.jinja\" %}" > template.jinja

copier copy . /tmp/output-samedir --data project_name=samedir 2>&1 | tee /tmp/samedir.log
if [ -f /tmp/output-samedir/template ]; then
    echo "✅ SUCCESS: copier/_partials works"
    echo "Output:"
    cat /tmp/output-samedir/template
    echo
    echo "Files created:"
    find /tmp/output-samedir -type f | sort
else
    echo "❌ FAILED: copier/_partials failed"
fi
echo

# Test 3: files/_partials
echo "Test 3: files/_partials"
echo "----------------------"
cd /tmp/copier-permutations/filesdir-files-partials
mkdir -p files/_partials
echo "Partial from files/_partials" > files/_partials/test-partial.jinja
echo "# Test 3: files/_partials

project_name: {{ project_name }}

_templates_suffix: .jinja
_subdirectory: files" > copier.yml

echo "# Test 3: files/_partials

Project: {{ project_name }}

Including from files/_partials:
{% include \"_partials/test-partial.jinja\" %}" > files/template.jinja

copier copy . /tmp/output-filesdir --data project_name=filesdir 2>&1 | tee /tmp/filesdir.log
if [ -f /tmp/output-filesdir/template ]; then
    echo "✅ SUCCESS: files/_partials works"
    echo "Output:"
    cat /tmp/output-filesdir/template
    echo
    echo "Files created:"
    find /tmp/output-filesdir -type f | sort
else
    echo "❌ FAILED: files/_partials failed"
fi
echo

echo "=== Summary ==="
echo "Check individual logs:"
echo "  /tmp/shared.log"
echo "  /tmp/samedir.log"
echo "  /tmp/filesdir.log"

# vim: set ft=sh:
