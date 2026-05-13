#!/bin/bash
set -e

echo "🧪 Testing Copier Wrapper with Shared Partials"
echo "============================================="

# Clean up any previous test outputs
rm -rf /tmp/output-wrapper-test-a /tmp/output-wrapper-test-b

# Test the wrapper script with template-a
echo ""
echo "📋 Testing Template A with wrapper..."
./copier-wrapper.sh copy template-a /tmp/output-wrapper-test-a --defaults

echo ""
echo "📋 Testing Template B with wrapper..."
./copier-wrapper.sh copy template-b /tmp/output-wrapper-test-b --defaults

echo ""
echo "🔍 Verifying outputs..."
echo ""

# Check Template A output
echo "Template A Output:"
echo "-----------------"
if [ -f /tmp/output-wrapper-test-a/main.md ]; then
    echo "✅ main.md generated"
    echo "Content preview:"
    head -10 /tmp/output-wrapper-test-a/main.md
    echo ""
else
    echo "❌ main.md not found"
fi

# Check Template B output
echo "Template B Output:"
echo "-----------------"
if [ -f /tmp/output-wrapper-test-b/main.md ]; then
    echo "✅ main.md generated"
    echo "Content preview:"
    head -10 /tmp/output-wrapper-test-b/main.md
    echo ""
else
    echo "❌ main.md not found"
fi

# Verify shared partials are included but not copied
echo "Verifying _partials-tmp directories:"
echo "------------------------------------"

if [ -d /tmp/output-wrapper-test-a/_partials-tmp ]; then
    if [ "$(ls -A /tmp/output-wrapper-test-a/_partials-tmp)" ]; then
        echo "❌ Template A: _partials-tmp contains files (should be empty)"
    else
        echo "✅ Template A: _partials-tmp is empty"
    fi
else
    echo "✅ Template A: _partials-tmp not copied"
fi

if [ -d /tmp/output-wrapper-test-b/_partials-tmp ]; then
    if [ "$(ls -A /tmp/output-wrapper-test-b/_partials-tmp)" ]; then
        echo "❌ Template B: _partials-tmp contains files (should be empty)"
    else
        echo "✅ Template B: _partials-tmp is empty"
    fi
else
    echo "✅ Template B: _partials-tmp not copied"
fi

echo ""
echo "🎉 Test completed!"

# vim: set ft=sh:
