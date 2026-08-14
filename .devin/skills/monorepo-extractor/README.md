# Monorepo Extractor Skill

A comprehensive skill for safely extracting projects from monorepos while preserving git history and ensuring team coordination.

## Overview

The Monorepo Extractor skill provides enterprise-grade tools for splitting monorepo projects into standalone repositories. It enforces strict validation to ensure safe, reproducible extractions that preserve complete git history and maintain team coordination.

## Why This Skill Exists

### The Problem

Extracting projects from monorepos is risky business:

- **History Loss**: Poor extraction can lose commit history
- **Team Disruption**: Extraction during active work can cause conflicts
- **Data Loss**: Local-only changes can be lost during extraction
- **Inconsistent State**: Unclean repositories produce unpredictable results
- **Compliance Issues**: Enterprise environments require strict procedures

### Our Solution

The Monorepo Extractor skill implements **strict validation** and **precise git history preservation**:

- **Clean State Requirement**: Only extracts from clean, pushed repositories
- **History Preservation**: Uses `git-filter-repo` for accurate history filtering
- **Team Safety**: Ensures all changes are remotely available before extraction
- **Enterprise Compliance**: Meets strict requirements for repository splitting

## Quick Start

### For Production Use (Recommended)

```bash
# Basic extraction - auto-detects single branch
./scripts/extract-project-strict.sh /path/to/monorepo project-name /path/to/new-repo

# Specify branch explicitly
./scripts/extract-project-strict.sh --branch main /path/to/monorepo project-name /path/to/new-repo

# Test without making changes
./scripts/extract-project-strict.sh --dry-run --verbose /path/to/monorepo project-name /path/to/new-repo
```

### For Development/Testing

```bash
# More flexible validation (allows uncommitted changes with --force)
./scripts/extract-project-flexible.sh --force /path/to/monorepo project-name /path/to/new-repo
```

## Understanding the Scripts

### `extract-project-strict.sh` - Production Grade

**Purpose**: Enterprise-safe extraction with comprehensive validation

**When to Use**:
- ✅ Production repository splits
- ✅ Compliance-required extractions
- ✅ Team coordination scenarios
- ✅ When history preservation is critical

**Key Features**:
- **Strict Validation**: Fails fast on any repository issues
- **Remote Verification**: Requires all commits to be pushed
- **Branch Auto-Detection**: Handles single-branch repos automatically
- **Git Identity Rewrite**: Optional committer/author rewriting
- **Comprehensive Help**: Built-in `--help` and `--usage`

**Validation Requirements**:
1. No uncommitted changes
2. No stashed entries
3. Remote `origin` configured
4. Remote connectivity verified
5. Current branch exists on remote
6. **No unpushed commits** (critical)
7. Repository integrity (git fsck)
8. Branch clarity (auto-detect or explicit)

### `extract-project-flexible.sh` - Development Grade

**Purpose**: Flexible extraction for development and testing scenarios

**When to Use**:
- ✅ Development experiments
- ✅ Testing extraction workflows
- ✅ Learning the extraction process
- ⚠️ NOT for production use

**Key Differences**:
- **Flexible Validation**: `--force` bypasses warnings
- **Less Strict**: Allows some repository issues
- **Simpler Workflow**: Fewer validation steps

## Design Philosophy

### Strict Validation Rationale

We enforce strict validation because:

1. **History Preservation**: Clean state ensures accurate git history extraction
2. **Reproducibility**: Predictable results across different environments
3. **Safety**: Prevents extraction of incomplete or corrupted state
4. **Remote Backup**: Ensures all commits exist remotely before extraction
5. **Team Coordination**: Guarantees team access to all changes
6. **Compliance**: Meets enterprise requirements for repository operations

### The "Copy and Filter" Approach

We use the **copy-branch-then-filter** approach instead of complex in-place operations:

```bash
# 1. Clone the specific branch
git clone --branch main --single-branch /path/to/monorepo /tmp/extraction

# 2. Filter history to keep only desired files
cd /tmp/extraction
git-filter-repo --path apps/project/ --force

# 3. Restructure if needed
mv apps/project/* .
rm -rf apps
git add .
git commit -m "Restructure: Move to root"
```

**Why This Approach**:
- **Preserves Commit SHAs**: Original commits remain intact
- **Clean History**: No artificial commits or rewrites
- **Safe Operations**: Works on temporary copy, never touches original
- **Branch Specific**: Extracts exact branch state

## Advanced Usage

### Git Identity Rewrite

For compliance or privacy requirements:

```bash
./scripts/extract-project-strict.sh \
  --committer-name "Service Account" \
  --committer-email "service@company.com" \
  --author-name "Service Account" \
  --author-email "service@company.com" \
  /path/to/monorepo project-name /path/to/new-repo
```

### Branch Management

**Auto-Detection (Single Branch)**:
```bash
# Automatically detects and uses the only branch
./scripts/extract-project-strict.sh /path/to/monorepo project-name /path/to/new-repo
```

**Explicit Branch (Multi-Branch)**:
```bash
# Specify which branch to extract
./scripts/extract-project-strict.sh --branch develop /path/to/monorepo project-name /path/to/new-repo
```

### Dry Run Testing

Always test before production extraction:

```bash
./scripts/extract-project-strict.sh \
  --dry-run \
  --verbose \
  --branch main \
  /path/to/monorepo project-name /path/to/new-repo
```

## Common Workflows

### Workflow 1: Standard Project Extraction

```bash
# 1. Ensure monorepo is clean and pushed
cd /path/to/monorepo
git status  # Should be clean
git push    # Should be up to date

# 2. Test extraction
./scripts/extract-project-strict.sh \
  --dry-run \
  --verbose \
  /path/to/monorepo apps/my-project /path/to/my-project

# 3. Perform extraction
./scripts/extract-project-strict.sh \
  /path/to/monorepo apps/my-project /path/to/my-project

# 4. Verify result
cd /path/to/my-project
git log --oneline  # Check history
git status        # Should be clean
```

### Workflow 2: Compliance Extraction with Identity Rewrite

```bash
./scripts/extract-project-strict.sh \
  --branch main \
  --committer-name "Bot User" \
  --committer-email "bot@company.com" \
  --author-name "Bot User" \
  --author-email "bot@company.com" \
  /path/to/monorepo project-name /path/to/new-repo
```

### Workflow 3: Emergency Recovery

⚠️ **DANGER**: Use only when you understand the risks

```bash
./scripts/extract-project-strict.sh \
  --force \
  /path/to/monorepo project-name /path/to/new-repo
```

## Error Handling and Troubleshooting

### Common Validation Failures

**Uncommitted Changes**:
```bash
ERROR: Repository has uncommitted changes. Commit or stash before extraction.
```
**Solution**: Commit or stash all changes

**No Remote**:
```bash
ERROR: No remote 'origin' configured. Repository must be pushed before extraction.
```
**Solution**: Add remote and push: `git remote add origin <url> && git push -u origin <branch>`

**Unpushed Commits**:
```bash
ERROR: Found 3 unpushed commits. Push all commits before extraction.
```
**Solution**: Push commits: `git push origin <branch>`

**Branch Not Remote**:
```bash
ERROR: Branch 'feature-branch' does not exist on remote. Push branch before extraction.
```
**Solution**: Push branch: `git push -u origin feature-branch`

### Recovery Procedures

If extraction fails:

1. **Check Validation**: Read error messages carefully
2. **Fix Repository**: Address the validation issues
3. **Retry Extraction**: Run extraction again
4. **Use --force**: Only if you understand the risks

## Best Practices

### Before Extraction

1. **Commit Everything**: Ensure working directory is clean
2. **Push to Remote**: All commits must be on remote
3. **Notify Team**: Let team members know about extraction
4. **Test First**: Always use `--dry-run` before production
5. **Backup**: Consider creating a backup tag

### During Extraction

1. **Use Strict Script**: Prefer `extract-project-strict.sh` for production
2. **Monitor Output**: Watch for any warning or error messages
3. **Verify Results**: Check the extracted repository immediately

### After Extraction

1. **Validate History**: Ensure git history is preserved
2. **Test Functionality**: Verify the extracted project works
3. **Update Documentation**: Update any references to old location
4. **Notify Team**: Inform team of new repository location
5. **Clean Up**: Optionally remove project from monorepo

## Technical Details

### Git Filter Repo

This skill uses `git-filter-repo` for history preservation:

**Installation**:
```bash
pip install git-filter-repo
```

**Why git-filter-repo**:
- **Fast**: Much faster than git filter-branch
- **Accurate**: Preserves exact commit history
- **Safe**: Works on temporary copies
- **Feature-Rich**: Supports identity rewriting and path filtering

### Repository Structure

```
monorepo-extractor/
├── scripts/
│   ├── extract-project-strict.sh      # Production extraction
│   ├── extract-project-flexible.sh    # Development extraction
│   ├── extract-project.sh              # Legacy extraction
│   ├── validate-monorepo-state.sh     # Validation utilities
│   ├── verify-tools.sh                 # Tool verification
│   └── ...                             # Other utility scripts
├── SKILL.md                           # Skill documentation
└── README.md                          # This file
```

### Validation Sequence

The strict script validates in this order:

1. Git repository structure
2. Working directory cleanliness
3. Stashed entries check
4. Project directory existence
5. Remote configuration
6. Remote connectivity
7. Branch remote existence
8. Unpushed commits check
9. Repository integrity
10. Branch clarity

## Contributing

### Adding New Features

1. **Maintain Strictness**: Don't compromise validation for convenience
2. **Add Tests**: Include validation for new features
3. **Update Documentation**: Keep this README and SKILL.md current
4. **Preserve Backwards**: Don't break existing workflows

### Reporting Issues

When reporting issues, include:

1. **Repository State**: Git status, branch, remote info
2. **Command Used**: Exact command with all arguments
3. **Error Messages**: Complete error output
4. **Environment**: OS, git version, tool versions

## License

This skill is part of the AI skills ecosystem and follows the same licensing terms.

## Related Skills

- **Project Detection Skill**: Analyzes project structure and tooling
- **Project Configuration Skill**: Configures projects with standard tooling
- **Environment Setup Skill**: Sets up development environments

---

**Remember**: Repository extraction is a significant operation. Always test thoroughly, communicate with your team, and ensure you have backups before proceeding with production extractions.
