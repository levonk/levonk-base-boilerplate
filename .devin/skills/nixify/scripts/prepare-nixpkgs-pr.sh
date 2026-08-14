#!/usr/bin/env bash
# Prepare a nixpkgs contribution for a project that is not yet packaged in
# nixpkgs. Scaffolds a package.nix file following the pkgs/by-name convention,
# forks NixOS/nixpkgs, creates a branch, and prepares the PR body.
#
# This script is called at Step 28b AFTER the in-repo flake has been validated
# and the main PR (Step 27) has been created. The nixpkgs PR references the
# working in-repo flake as evidence the package builds and runs.
#
# Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]
#   project-name: the nixpkgs attribute name (lowercase, hyphenated)
#   project-dir: path to the cloned project directory (with working flake.nix)
#   upstream-owner: the GitHub owner of the upstream project
#   upstream-repo: the GitHub repo name of the upstream project
#
# Output: JSON with:
#   package_nix_path   — path to the generated package.nix
#   nixpkgs_fork       — URL of the forked nixpkgs repo
#   nixpkgs_branch     — branch name in the fork
#   pr_body_path       — path to the generated PR body file
#   maintainer_entry   — suggested maintainer entry for maintainer-list.nix
#   by_name_path       — the pkgs/by-name/<prefix>/<name>/ path in nixpkgs
#
# Requires: nix (with flakes), gh, git, jq, curl
# See: https://nixos.org/manual/nixpkgs/stable/#chap-quick-start

set -euo pipefail

PROJECT="${1:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
PROJECT_DIR="${2:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
UPSTREAM_OWNER="${3:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
UPSTREAM_REPO="${4:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
MODE="${5:-}"

# Validate project name — nixpkgs attribute names are lowercase, hyphenated
if echo "$PROJECT" | grep -qE '[^a-z0-9-]'; then
  echo "ERROR: project name must be lowercase with hyphens only (nixpkgs attribute convention)" >&2
  exit 1
fi

# Compute the pkgs/by-name path — first 2 chars of the package name, lowercased
PREFIX=$(echo "$PROJECT" | cut -c1-2)
BY_NAME_PATH="pkgs/by-name/${PREFIX}/${PROJECT}"

# --- Detect project metadata for package.nix --------------------------------
# Read version and description from the project's flake.nix or manifest files
VERSION=""
DESCRIPTION=""

# Try to get version from the project's Cargo.toml, package.json, etc.
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
  VERSION=$(grep -m1 '^version' "$PROJECT_DIR/Cargo.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
  DESCRIPTION=$(grep -m1 '^description' "$PROJECT_DIR/Cargo.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
elif [ -f "$PROJECT_DIR/package.json" ]; then
  VERSION=$(jq -r '.version // empty' "$PROJECT_DIR/package.json" || echo "")
  DESCRIPTION=$(jq -r '.description // empty' "$PROJECT_DIR/package.json" || echo "")
elif [ -f "$PROJECT_DIR/pyproject.toml" ]; then
  VERSION=$(grep -m1 '^version' "$PROJECT_DIR/pyproject.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
  DESCRIPTION=$(grep -m1 '^description' "$PROJECT_DIR/pyproject.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
fi

# --- Generate package.nix ---------------------------------------------------
# The package.nix follows the pkgs/by-name convention from the nixpkgs manual.
# It is a function that takes dependencies as arguments and returns a derivation.
# The agent fills in the language-specific build framework (buildRustPackage,
# buildNpmPackage, stdenv.mkDerivation, etc.) based on the project's language.

PACKAGE_NIX_DIR=$(mktemp -d)
PACKAGE_NIX_PATH="${PACKAGE_NIX_DIR}/package.nix"

cat > "$PACKAGE_NIX_PATH" << 'PACKAGE_NIX_EOF'
# TODO: Fill in the language-specific build framework.
# See https://nixos.org/manual/nixpkgs/stable/#chap-language-support
# for the correct builder for this project's language.
#
# Common builders:
#   Rust:    rustPlatform.buildRustPackage
#   Node.js: buildNpmPackage / buildPnpmPackage
#   Python:  python3Packages.buildPythonApplication
#   Go:      buildGoModule
#   Generic: stdenv.mkDerivation
#
# The in-repo flake.nix in the upstream project already has a working build —
# use it as the reference for buildInputs, nativeBuildInputs, and build phases.
{
  lib,
  stdenv,
  # Add build-time and runtime dependencies here as arguments.
  # callPackage auto-fills them from the top-level package set.
  # Example for a Rust project:
  # rustPlatform,
  # pkg-config,
  # openssl,
}:

# TODO: Replace with the correct builder for this project's language.
# Example (Rust):
# rustPlatform.buildRustPackage {
stdenv.mkDerivation {
  pname = "PROJECT_NAME_PLACEHOLDER";
  version = "VERSION_PLACEHOLDER";

  src = fetchFromGitHub {
    owner = "UPSTREAM_OWNER_PLACEHOLDER";
    repo = "UPSTREAM_REPO_PLACEHOLDER";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    # TODO: Set the correct hash — use `nix hash to-sri --type sha256 <hash>`
    # after the first build attempt with a fake hash gives the correct one.
  };

  # TODO: Add buildInputs, nativeBuildInputs, buildPhase, installPhase
  # based on the in-repo flake.nix's #source output.

  meta = {
    description = "DESCRIPTION_PLACEHOLDER";
    homepage = "https://github.com/UPSTREAM_OWNER_PLACEHOLDER/UPSTREAM_REPO_PLACEHOLDER";
    # TODO: Set the correct license — use lib.licenses.<name>
    # See https://nixos.org/manual/nixpkgs/stable/#sec-meta-license
    license = lib.licenses.mit;
    # TODO: Set maintainers — add yourself to maintainers/maintainer-list.nix
    # in a separate commit, then reference here:
    # maintainers = [ lib.maintainers.<your-handle> ];
    maintainers = [ ];
    # TODO: Set platforms — use lib.platforms.unix or a specific subset
    mainProgram = "PROJECT_NAME_PLACEHOLDER";
    platforms = lib.platforms.unix;
  };
}
PACKAGE_NIX_EOF

# Substitute placeholders
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${PROJECT}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/VERSION_PLACEHOLDER/${VERSION}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/UPSTREAM_OWNER_PLACEHOLDER/${UPSTREAM_OWNER}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/UPSTREAM_REPO_PLACEHOLDER/${UPSTREAM_REPO}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s|DESCRIPTION_PLACEHOLDER|${DESCRIPTION:-A package for ${PROJECT}}|g" "$PACKAGE_NIX_PATH"
rm -f "${PACKAGE_NIX_PATH}.bak"

# --- Generate maintainer entry suggestion -----------------------------------
# The contributor must add themselves to maintainers/maintainer-list.nix
# in a separate commit before this PR.
CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "YOUR_GITHUB_HANDLE")
MAINTAINER_ENTRY="{ name = \"${CURRENT_USER}\"; email = \"YOUR_EMAIL\"; github = \"${CURRENT_USER}\"; githubId = YOUR_GITHUB_ID; }"

# --- Generate PR body -------------------------------------------------------
PR_BODY_PATH="${PACKAGE_NIX_DIR}/pr-body.md"

cat > "$PR_BODY_PATH" << PR_BODY_EOF
## Description

Add \`${PROJECT}\` to nixpkgs.

${DESCRIPTION:-}

## What is this?

${PROJECT} is a tool from ${UPSTREAM_OWNER}/${UPSTREAM_REPO}. The upstream
project already has a working in-repo Nix flake
(https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}) which was used as the
reference for this packaging.

## Checklist

- [ ] package.nix follows the pkgs/by-name convention
- [ ] Built locally with \`nix-build -A ${PROJECT}\`
- [ ] Ran \`nix-env -iA ${PROJECT} --option sandbox false\` and tested the binary
- [ ] Added myself as a maintainer in maintainers/maintainer-list.nix (separate commit)
- [ ] Set meta.license to the correct license
- [ ] Set meta.platforms to the tested platforms
- [ ] Ran \`nixpkgs-hammering\` and addressed findings (optional but recommended)

## Testing

The package was tested by:

1. Building: \`nix-build -A ${PROJECT}\`
2. Running: \`result/bin/${PROJECT} --version\`
3. The in-repo flake at https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}
   also validates the build via CI

## Maintainer

I have added myself to maintainers/maintainer-list.nix in a separate commit.
PR_BODY_EOF

# --- Fork nixpkgs and create branch (unless --dry-run) ---------------------
NIXPKGS_FORK=""
NIXPKGS_BRANCH="add-${PROJECT}"

if [ "$MODE" = "--dry-run" ]; then
  echo "DRY RUN — would perform:" >&2
  echo "  1. Fork NixOS/nixpkgs to ${CURRENT_USER}/nixpkgs" >&2
  echo "  2. Clone fork, create branch '${NIXPKGS_BRANCH}'" >&2
  echo "  3. Create ${BY_NAME_PATH}/package.nix" >&2
  echo "  4. Open PR to NixOS/nixpkgs with title: '${PROJECT}: init at ${VERSION}'" >&2
  echo "" >&2
  echo "Generated files:" >&2
  echo "  package.nix: ${PACKAGE_NIX_PATH}" >&2
  echo "  PR body:     ${PR_BODY_PATH}" >&2
  echo "  Maintainer entry: ${MAINTAINER_ENTRY}" >&2
else
  # Fork nixpkgs
  gh repo fork NixOS/nixpkgs --clone=false 2>/dev/null || true
  NIXPKGS_FORK="https://github.com/${CURRENT_USER}/nixpkgs"

  # Clone the fork to a temp directory
  NIXPKGS_CLONE_DIR=$(mktemp -d)
  git clone --depth=1 "$NIXPKGS_FORK" "$NIXPKGS_CLONE_DIR/nixpkgs" 2>/dev/null || {
    # If clone fails (fork may not exist yet), try cloning upstream and adding fork remote
    git clone --depth=1 "https://github.com/NixOS/nixpkgs" "$NIXPKGS_CLONE_DIR/nixpkgs"
  }
  cd "$NIXPKGS_CLONE_DIR/nixpkgs"

  # Create branch
  git checkout -b "$NIXPKGS_BRANCH"

  # Create the package directory and copy package.nix
  mkdir -p "$BY_NAME_PATH"
  cp "$PACKAGE_NIX_PATH" "$BY_NAME_PATH/package.nix"
  git add "$BY_NAME_PATH/package.nix"

  echo "nixpkgs cloned at: $(pwd)" >&2
  echo "Branch: ${NIXPKGS_BRANCH}" >&2
  echo "Package path: ${BY_NAME_PATH}/package.nix" >&2
  echo "" >&2
  echo "Next steps:" >&2
  echo "  1. Edit ${BY_NAME_PATH}/package.nix — fill in the correct builder, deps, and hash" >&2
  echo "  2. Add yourself to maintainers/maintainer-list.nix in a separate commit" >&2
  echo "  3. Build: nix-build -A ${PROJECT}" >&2
  echo "  4. Test: result/bin/${PROJECT} --version" >&2
  echo "  5. Commit and push: git push origin ${NIXPKGS_BRANCH}" >&2
  echo "  6. Open PR: gh pr create --repo NixOS/nixpkgs --body-file ${PR_BODY_PATH}" >&2
fi

# --- Output -----------------------------------------------------------------
jq -n \
  --arg package_nix_path "$PACKAGE_NIX_PATH" \
  --arg nixpkgs_fork "${NIXPKGS_FORK:-https://github.com/${CURRENT_USER}/nixpkgs}" \
  --arg nixpkgs_branch "$NIXPKGS_BRANCH" \
  --arg pr_body_path "$PR_BODY_PATH" \
  --arg maintainer_entry "$MAINTAINER_ENTRY" \
  --arg by_name_path "$BY_NAME_PATH" \
  --arg version "$VERSION" \
  '{package_nix_path: $package_nix_path,
    nixpkgs_fork: $nixpkgs_fork,
    nixpkgs_branch: $nixpkgs_branch,
    pr_body_path: $pr_body_path,
    maintainer_entry: $maintainer_entry,
    by_name_path: $by_name_path,
    version: $version}'
