#!/bin/bash
set -e

# Copier Wrapper for Shared Partials
#
# This script works around Copier's limitations with template includes:
# - Symlinks don't work: Copier's Jinja2 sandbox cannot resolve symlinks to templates
# - Relative parent/sibling paths don't work: Copier only searches within the template subdirectory
# - External paths don't work: Copier's template rendering is sandboxed to the template directory
#
# Solution: Copy shared partials into each template's subdirectory before running Copier
# This ensures partials are accessible via normal Jinja2 include statements
#
# Usage: ./copier-wrapper.sh copy <template-name> <output-path> [copier-options]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PARTIALS="$SCRIPT_DIR/_shared-partials"

echo "📋 Copier Wrapper: Setting up shared partials..."

# Function to copy shared partials to a template
copy_partials() {
    local template_dir="$1"
    local target_dir="$template_dir/partials.bak"

    echo "  Copying partials for: $template_dir"

    # Remove existing copies to ensure fresh copy
    rm -rf "$target_dir" 2>/dev/null || true

    # Create fresh directory
    mkdir -p "$target_dir"

    # Copy shared partials recursively (files and directories, including hidden files)
    cp -r "$SHARED_PARTIALS"/. "$target_dir/" 2>/dev/null || true
    cp -r "$SHARED_PARTIALS"/* "$target_dir/" 2>/dev/null || true
    
    # List what was copied
    for item in "$target_dir"/*; do
        if [ -e "$item" ]; then
            echo "    Copied: $(basename "$item")"
        fi
    done
}

# Find all template directories (those with copier.yml)
find_templates() {
    for dir in "$SCRIPT_DIR"/*/; do
        if [ -f "$dir/copier.yml" ] || [ -f "$dir/copier.yaml" ]; then
            echo "${dir%/}"
        fi
    done
}

# Copy partials for each template before running copier
if [ "$1" = "copy" ] && [ -n "$2" ] && [ -d "$SCRIPT_DIR/$2" ]; then
    # Specific template requested
    copy_partials "$SCRIPT_DIR/$2"
else
    # Copy for all templates (default behavior)
    for template in $(find_templates); do
        copy_partials "$template"
    done
fi

echo "✅ Shared partials copied successfully"
echo "🚀 Running copier with arguments: $*"

# Now run the actual copier command with all arguments
exec copier "$@"

# vim: set ft=sh:
