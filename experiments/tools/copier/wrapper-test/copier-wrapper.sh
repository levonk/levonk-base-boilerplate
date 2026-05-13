#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PARTIALS="$SCRIPT_DIR/_shared-partials"

echo "🔗 Copier Wrapper: Setting up shared partials..."

# Function to copy shared partials
copy_partials() {
    local template_dir="$1"
    local target_dir="$template_dir/files/partials.bak"

    echo "  Copying partials for: $template_dir"

    # Remove existing copies
    rm -rf "$target_dir" 2>/dev/null || true

    # Create fresh directory
    mkdir -p "$target_dir"

    # Copy shared partials (always fresh)
    for file in "$SHARED_PARTIALS"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$target_dir/$filename"
            echo "    Copied: $filename"
        fi
    done
}

# Copy partials for each template before running copier
for template in template-a template-b; do
    if [ -d "$SCRIPT_DIR/$template" ]; then
        copy_partials "$SCRIPT_DIR/$template"
    fi
done

echo "✅ Shared partials copied successfully"
echo "🚀 Running copier with arguments: $*"

# Now run the actual copier command with all arguments
exec copier "$@"

# vim: set ft=sh:
