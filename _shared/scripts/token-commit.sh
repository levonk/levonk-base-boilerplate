#!/usr/bin/env bash
#
# token-commit.sh
#
# Creates an initial git commit in the current directory if no commits exist yet.
#
# Behavior:
#   - Initializes git (git init) if a .git directory is not present.
#   - If no commits exist (HEAD cannot be resolved), stages all files and
#     creates an initial commit with a fixed message.
#   - Non-destructive: if commits already exist, this script does nothing.
#   - Intended to be called from copier post-copy tasks (_tasks:) to ensure
#     generated projects have a clean git baseline.
#
# Exit codes:
#   0 - success or no-op (commits already existed, or initial commit created)
#   1 - error
#
# This script is self-contained and depends only on git and bash.
# It operates on the CURRENT DIRECTORY (wherever it is invoked from), not on
# the boilerplate repository itself.

set -euo pipefail

# Initialize git if the current directory is not already a git repository.
if [ ! -d ".git" ]; then
    git init
fi

# Check whether any commits exist.
if git rev-parse --verify HEAD 2>/dev/null 1>/dev/null; then
    # Commits already exist — non-destructive no-op.
    exit 0
fi

# No commits exist: stage everything and create the initial commit.
git add -A

# Attempt a normal commit; fall back to an empty commit if staging produced
# nothing (e.g., all files are gitignored).
if ! git commit -m "Initial commit (scaffolded from boilerplate)"; then
    git commit --allow-empty -m "Initial commit (scaffolded from boilerplate)"
fi

exit 0
