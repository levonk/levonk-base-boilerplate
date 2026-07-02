#!/bin/bash
set -e

# Universal Copier Wrapper for Shared Partials System
#
# This script works around Copier's limitations with template includes:
# - Symlinks don't work: Copier's Jinja2 sandbox cannot resolve symlinks to templates
# - Relative parent/sibling paths don't work: Copier only searches within the template subdirectory
# - External paths don't work: Copier's template rendering is sandboxed to the template directory
#
# Solution: Copy shared partials into each template's subdirectory before running Copier
# This ensures partials are accessible via normal Jinja2 include statements
#
# Why hard links instead of soft links:
# - Soft links (symlinks) fail because Copier's Jinja2 sandbox cannot resolve them
# - Hard links work because they appear as regular files to Copier's template engine
# - Hard links provide performance benefits while maintaining compatibility
#
# Uses mirrored directory structure: boilerplate/_shared/ mirrors boilerplate/ structure
#
# Usage:
#   ./copier-wrapper.sh copy <template-path> <output-path> [copier-options]
#   devbox run -- ./boilerplate/copier-wrapper.sh copy apps/plugins/browser-extension ./my-extension --defaults
#
# IMPORTANT: Run via devbox to ensure copier is available:
#   devbox run -- ./boilerplate/copier-wrapper.sh copy <template> <output>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_ROOT="$SCRIPT_DIR/_shared"

echo "📋 Universal Copier Wrapper: Setting up shared partials..."

# Function to ensure copier is available via devbox
ensure_copier() {
    # Check if we're already in a devbox environment
    if [ -n "$DEVBOX_SHELL_ENABLED" ]; then
        if ! command -v copier >/dev/null 2>&1; then
            echo "❌ copier not found in devbox environment"
            echo "   Please ensure copier is added to devbox.json packages"
            exit 1
        fi
        return 0
    fi

    # Check if devbox is available
    if ! command -v devbox >/dev/null 2>&1; then
        echo "❌ Neither devbox nor copier found"
        echo ""
        echo "Please run via devbox:"
        echo "   devbox run -- ./boilerplate/copier-wrapper.sh copy <template> <output>"
        echo ""
        echo "Or ensure copier is installed:"
        echo "   pip install --user copier"
        exit 1
    fi

    # Devbox is available but we're not in a shell
    echo "🔄 Devbox detected but not in shell. Restarting with devbox..."
    echo ""
    echo "Run this command instead:"
    echo "   devbox run -- $0 $*"
    echo ""
    exec devbox run -- "$0" "$@"
}

# Function to copy entire shared directory to a template
copy_shared_partials() {
    local template_dir="$1"
    local target_dir="$template_dir/partials.bak"

    echo "  Processing template: $template_dir"
    echo "    Shared source: $SHARED_ROOT"

    # Remove existing copies to ensure fresh copy
    rm -rf "$target_dir" 2>/dev/null || true

    # Copy entire _shared directory if it exists
    if [ -d "$SHARED_ROOT" ]; then
        # Create fresh directory
        mkdir -p "$target_dir"

        # Enable dotglob to include hidden files in the copy
        # This ensures files like .envrc.jinja are copied properly
        shopt -s dotglob 2>/dev/null || true

        # Use hard links on Linux with compatible file systems for efficiency
        # Fall back to regular copy if hard links fail (cross-filesystem, etc.)
        #
        # Note: We use hard links instead of soft links (symlinks) because:
        # - Copier's Jinja2 sandbox cannot resolve symlinks to template files
        # - Hard links appear as regular files, which Copier can process normally
        # - This maintains compatibility while providing performance benefits
        #
        # CRITICAL: We now copy ALL files including hidden ones (dotfiles)
        # by using dotglob and copying the directory contents with /.
        if command -v cp >/dev/null 2>&1 && cp --help 2>/dev/null | grep -q "\-\-link\|--link"; then
            # Try hard links first (more efficient, saves disk space)
            if cp -rL --link "$SHARED_ROOT"/. "$target_dir/" 2>/dev/null; then
                echo "    ✅ Linked entire shared directory including hidden files (hard links)"
            else
                # Fall back to regular copy if hard links fail
                if cp -r "$SHARED_ROOT"/. "$target_dir/" 2>/dev/null; then
                    echo "    ✅ Copied entire shared directory including hidden files (fallback)"
                else
                    echo "    ⚠️  No files found in $SHARED_ROOT"
                    rmdir "$target_dir" 2>/dev/null || true
                fi
            fi
        else
            # Regular copy if cp doesn't support --link
            if cp -r "$SHARED_ROOT"/. "$target_dir/" 2>/dev/null; then
                echo "    ✅ Copied entire shared directory including hidden files"
            else
                echo "    ⚠️  No files found in $SHARED_ROOT"
                rmdir "$target_dir" 2>/dev/null || true
            fi
        fi

        # Disable dotglob after we're done
        shopt -u dotglob 2>/dev/null || true
    else
        echo "    ⚠️  Shared directory not found at $SHARED_ROOT"
    fi
}

# Function to find all template directories (those with copier.yml or copier.yaml)
find_all_templates() {
    find "$SCRIPT_DIR" -name "copier.yml" -o -name "copier.yaml" | while read -r config; do
        dirname "$config"
    done
}

# Function to find specific template directory
find_template() {
    local template_name="$1"
    local template_path="$SCRIPT_DIR/$template_name"

    if [ -d "$template_path" ] && ([ -f "$template_path/copier.yml" ] || [ -f "$template_path/copier.yaml" ]); then
        echo "$template_path"
    else
        echo ""
    fi
}

# Main logic
if [ "$1" = "copy" ] && [ -n "$2" ]; then
    # Specific template requested
    template_path="$(find_template "$2")"
    if [ -n "$template_path" ]; then
        copy_shared_partials "$template_path"
        echo "✅ Shared partials setup complete for: $2"
    else
        echo "❌ Template not found: $2"
        echo "Available templates:"
        find_all_templates | sed 's|.*/||' | sort
        exit 1
    fi
else
    # Copy for all templates (default behavior)
    echo "🔍 Scanning for all templates..."
    template_count=0
    for template in $(find_all_templates); do
        copy_shared_partials "$template"
        template_count=$((template_count + 1))
    done
    echo "✅ Shared partials copied for $template_count templates"
fi

echo ""
echo "🚀 Running copier with arguments: $*"
echo ""

# Ensure copier is available before running
ensure_copier

# Clean up every generated partials.bak/ directory so it doesn't linger in the
# template tree. The source of truth is _shared/; a leftover partials.bak/ is a
# footgun that invites people to edit generated copies instead of the source.
# Runs on EXIT (covers success, failure, and signals) — see the `copier "$@"`
# call below which intentionally does NOT use `exec` so this trap can fire.
cleanup_partials_bak() {
    find "$SCRIPT_DIR" -type d -name "partials.bak" -prune -exec rm -rf {} + 2>/dev/null || true
}
trap cleanup_partials_bak EXIT

# Run the actual copier command (no exec — we need the trap to fire afterward)
copier "$@"
exit $?

# vim: set ft=sh:
