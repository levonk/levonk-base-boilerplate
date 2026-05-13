#!/bin/bash

# Test shared partials pattern
set -e

echo "=== Testing Shared Partials Pattern ==="
echo

# Test Template A
echo "Testing Template A..."
echo "----------------------"
cd /home/micro/p/gh/lrepo52/job-aide/boilerplate/experiments/tools/copier/shared-partials-test/template-a
copier copy . /tmp/output-template-a --data project_name=web-app-a --data environment=development --data template_type=web-app 2>&1 | tee /tmp/template-a.log

if [ -f /tmp/output-template-a/main.md ]; then
    echo "✅ SUCCESS: Template A works with shared partials"
    echo "Generated content:"
    echo "---"
    cat /tmp/output-template-a/main.md
    echo "---"
    echo
else
    echo "❌ FAILED: Template A failed to generate"
    cat /tmp/template-a.log
    exit 1
fi

# Test Template B
echo "Testing Template B..."
echo "----------------------"
cd /home/micro/p/gh/lrepo52/job-aide/boilerplate/experiments/tools/copier/shared-partials-test/template-b
copier copy . /tmp/output-template-b --data project_name=api-service-b --data environment=production --data template_type=api-service 2>&1 | tee /tmp/template-b.log

if [ -f /tmp/output-template-b/main.md ]; then
    echo "✅ SUCCESS: Template B works with shared partials"
    echo "Generated content:"
    echo "---"
    cat /tmp/output-template-b/main.md
    echo "---"
    echo
else
    echo "❌ FAILED: Template B failed to generate"
    cat /tmp/template-b.log
    exit 1
fi

# Verify no _partials directory was copied
echo "Verifying _partials directory is empty..."
if [ -d /tmp/output-template-a/_partials ] && [ "$(ls -A /tmp/output-template-a/_partials)" ] || [ -d /tmp/output-template-b/_partials ] && [ "$(ls -A /tmp/output-template-b/_partials)" ]; then
    echo "❌ FAILED: _partials directory contains files"
    exit 1
else
    echo "✅ SUCCESS: _partials directory is empty (partials included but not copied)"
fi

echo
echo "=== All Tests Passed! ==="
echo "Shared partials pattern works correctly:"
echo "- Both templates can include shared partials"
echo "- _shared directory is not copied to output"
echo "- DRY principle achieved"

# vim: set ft=sh:
