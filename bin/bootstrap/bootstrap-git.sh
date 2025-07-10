#!/bin/bash

## Also create tags/ feature/ both globally and inside of u/{username}/

# --- Configuration ---
REMOTE="origin"          # Remote repository name (usually 'origin')
BASE_BRANCH="main"    # Base branch to branch from (usually main, master, or develop)
USER_ID=$(id -u)       # get user ID for checks
BRANCHES=(
  "env/prod"
  "env/stage"
  "env/dev"
)

USER_BRANCHES=(
  "u/levonk/env/dev"
)

# --- Functions ---

function create_and_push_branch() {
  local branch_name="$1"

  # Check if the branch already exists
  git show-ref --quiet "refs/heads/$branch_name" && {
    echo "Branch '$branch_name' already exists. Skipping."
    return 0  # Exit function successfully
  }

  # Create the branch
  echo "Creating branch: $branch_name"
  git checkout -b "$branch_name" "$BASE_BRANCH" || {
    echo "Failed to create branch '$branch_name'."
    return 1
  }

  # Push the branch
  echo "Pushing branch: $branch_name"
  git push -u "$REMOTE" "$branch_name" || {
    echo "Failed to push branch '$branch_name'."
    git checkout "$BASE_BRANCH"  # Return to the base branch
    git branch -D "$branch_name"  # Remove the broken branch
    echo "Returning to '$BASE_BRANCH' and deleting broken local branch"
    return 1
  }

  return 0
}

# --- Main Script ---

# Sanity Check for a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Not in a Git repository! exiting."
  exit 1
fi

# Verify there is a remote called ORIGIN
git remote show "$REMOTE" > /dev/null 2>&1 || {
  echo "Remote '$REMOTE' does not exist! exiting."
  exit 1
}

#Check if our user ID is zero (root)
if [ "$USER_ID" -eq 0 ]; then
    echo "It is NOT recommend to run this script as root, and will now exit. Please run as a normal user."
    exit 1
fi

# Create base branches:
echo "creating base branches:"
for BRANCH in "${BRANCHES[@]}"; do
  create_and_push_branch "$BRANCH"
done

echo "creating user branches:"
for BRANCH in "${USER_BRANCHES[@]}"; do
  create_and_push_branch "$BRANCH"
done

echo "Finished creating and pushing branches."
git branch

exit 0
