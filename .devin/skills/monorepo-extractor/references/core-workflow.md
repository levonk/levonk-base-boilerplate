# Core Workflow

## Workflow Steps

1. **Tool Verification**: Ensure all required tools are available with minimum versions
2. **Monorepo State Validation**: Verify repository is fully committed, pushed, and validated remotely
3. **System Detection**: Detect build systems, package managers, and CI/CD platforms
4. **Workspace Analysis**: Analyze workspace configurations and shared resources
5. **Repository Duplication**: Duplicate entire monorepo to preserve structure and shared content
6. **Intelligent Pruning**: Remove unrelated projects and history while preserving shared resources
7. **Workspace Updates**: Update workspace configurations to reflect single-project structure
8. **Target Validation**: Verify project-specific targets (bootstrap, build, lint, test, etc.) work properly
9. **Final Validation**: Verify repository integrity and history completeness
10. **Cleanup**: Safely remove project from original monorepo with reference to new location

## Deterministic Tool Verification

Before any extraction begins, verify all required tools:

```bash
#!/bin/bash
# scripts/verify-tools.sh

set -euo pipefail

# Required tools and minimum versions
declare -A REQUIRED_TOOLS=(
    ["git"]="2.25.0"
    ["jq"]="1.6"
    ["find"]="4.7.0"
    ["sed"]="4.8"
    ["awk"]="5.0"
)

verify_tool() {
    local tool="$1"
    local min_version="$2"

    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool is not installed"
        return 1
    fi

    local current_version
    case "$tool" in
        "git")
            current_version=$(git --version | cut -d' ' -f3)
            ;;
        "jq")
            current_version=$(jq --version | cut -d' ' -f1 | sed 's/jq-//')
            ;;
        *)
            current_version=$("$tool" --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
            ;;
    esac

    if ! printf '%s\n%s\n' "$min_version" "$current_version" | sort -V -C; then
        echo "ERROR: $tool version $current_version is below minimum $min_version"
        return 1
    fi

    echo "✓ $tool $current_version"
}

echo "Verifying required tools..."
for tool in "${!REQUIRED_TOOLS[@]}"; do
    verify_tool "$tool" "${REQUIRED_TOOLS[$tool]}"
done

echo "All tools verified successfully"
```

## Safe Git History Extraction

Use `git filter-repo` or `git filter-branch` to extract only relevant history:

```bash
#!/bin/bash
# scripts/extract-project.sh

set -euo pipefail

MONOREPO_PATH="$1"
PROJECT_NAME="$2"
NEW_REPO_PATH="$3"

# Verify inputs
if [[ ! -d "$MONOREPO_PATH" ]]; then
    echo "ERROR: Monorepo path does not exist: $MONOREPO_PATH"
    exit 1
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: Project name is required"
    exit 1
fi

if [[ -z "$NEW_REPO_PATH" ]]; then
    echo "ERROR: New repo path is required"
    exit 1
fi

# Check for active work in project directory
cd "$MONOREPO_PATH"
if git status --porcelain "$PROJECT_NAME" | grep -q .; then
    echo "ERROR: Project has uncommitted changes. Please commit or stash before extraction."
    exit 1
fi

# Create temporary clone for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

git clone "$MONOREPO_PATH" "$TEMP_DIR/monorepo-temp"
cd "$TEMP_DIR/monorepo-temp"

# Extract only the project directory and its history
git filter-repo --path "$PROJECT_NAME/" --force

# Create new repository
mkdir -p "$NEW_REPO_PATH"
cd "$NEW_REPO_PATH"
git init

# Push filtered history to new repository
git remote add origin "$TEMP_DIR/monorepo-temp"
git pull origin main

echo "Project extracted to: $NEW_REPO_PATH"
```

## Validation and Verification

Comprehensive validation of the extracted repository:

```bash
#!/bin/bash
# scripts/validate-extraction.sh

set -euo pipefail

NEW_REPO_PATH="$1"

cd "$NEW_REPO_PATH"

# 1. Verify repository integrity
echo "Checking repository integrity..."
git fsck --full

# 2. Verify history completeness
echo "Checking history completeness..."
if ! git log --oneline | head -n 1 >/dev/null; then
    echo "ERROR: No commits found in extracted repository"
    exit 1
fi

# 3. Verify all files are present
echo "Verifying file presence..."
if [[ ! -f ".gitignore" ]] || [[ ! -d "src" ]]; then
    echo "WARNING: Expected project structure may be incomplete"
fi

# 4. Verify no monorepo artifacts remain
echo "Checking for monorepo artifacts..."
if find . -name "*.lock" -o -name "*.tmp" | grep -q .; then
    echo "WARNING: Found potential monorepo artifacts"
fi

# 5. Verify remote connectivity
echo "Checking remote connectivity..."
if git remote get-url origin >/dev/null 2>&1; then
    git fetch origin
    echo "✓ Remote connectivity verified"
else
    echo "INFO: No remote configured - local repository only"
fi

echo "Validation completed successfully"
```

## Team Safety Procedures

Before removing the project from the monorepo:

1. **Announcement**: Notify team of upcoming migration
2. **Backup**: Create tagged backup in monorepo
3. **Reference**: Add reference comment pointing to new repository
4. **Grace Period**: Wait for team confirmation

```bash
#!/bin/bash
# scripts/safe-cleanup.sh

set -euo pipefail

MONOREPO_PATH="$1"
PROJECT_NAME="$2"
NEW_REPO_URL="$3"

cd "$MONOREPO_PATH"

# Create backup tag
BACKUP_TAG="pre-extraction-$(date +%Y%m%d-%H%M%S)"
git tag -a "$BACKUP_TAG" -m "Pre-extraction backup of $PROJECT_NAME"

# Create reference comment
cat > "$PROJECT_NAME/README.md" << EOF
# Project Moved

This project has been extracted to its own repository.

**New Location**: $NEW_REPO_URL

**Extraction Date**: $(date +%Y-%m-%d)

**Backup Tag**: $BACKUP_TAG in this repository

Please update your remotes and workflows to point to the new location.
EOF

git add "$PROJECT_NAME/README.md"
git commit -m "docs: Add migration reference for $PROJECT_NAME"

echo "Project reference updated. Safe to remove directory after team confirmation."
```
