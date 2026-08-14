#!/usr/bin/env bash
# post-adoption-check.sh
# Verifies the adoption produced the expected progressive-disclosure structure.
# Run after all adoption steps are complete (step 20 in SKILL.md Quick Start).
#
# Usage:
#   ./post-adoption-check.sh /path/to/project
#   ./post-adoption-check.sh .  # current directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the post_adoption_check function from adopt-project.sh
# shellcheck source=adopt-project.sh
if [[ -f "$SCRIPT_DIR/adopt-project.sh" ]]; then
    # Extract just the function definition
    eval "$(sed -n '/^post_adoption_check() {/,/^}/p' "$SCRIPT_DIR/adopt-project.sh")"
else
    echo "ERROR: adopt-project.sh not found at $SCRIPT_DIR/adopt-project.sh" >&2
    exit 1
fi

project_path="${1:-.}"
post_adoption_check "$project_path"
