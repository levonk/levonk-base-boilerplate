# Git Status Digest Script Reference

This document describes the `git-status-digest.sh` script used by the Git Repository Management skill for intelligent repository analysis.

## Script Purpose

The `git-status-digest.sh` script provides intelligent analysis of git repository status, going beyond simple `git status` output to provide detailed insights about changes, file modifications, and repository state.

## Script Locations

The skill searches for the script in this order:
1. `scripts/git-status-digest.sh` (project-local)
2. `bin/git-status-digest.sh` (project-local)
3. `~/.local/bin/executable_git-status-digest.sh` (user-global)

## Usage Modes

### Identify Mode
```bash
git-status-digest.sh identify
```

**Purpose**: First-run analysis to identify all changes and plan commit groupings.

**Output**:
- Detailed analysis of staged files
- Detailed analysis of unstaged files  
- Complete enumeration of untracked files
- Porcelain snapshot for correlation
- File counts and change statistics

**When to use**: At the beginning of repository management workflow to understand current state.

### Assert-Clean Mode
```bash
git-status-digest.sh assert-clean
```

**Purpose**: Final verification to ensure repository is in clean state.

**Output**:
- Simple pass/fail indication
- Detailed error report if repository is not clean
- Specific files and changes preventing clean state

**When to use**: After committing all changes to verify repository is clean.

## Output Format

### Staged Files Analysis
- **File count**: Total number of staged changes
- **Change types**: Added (A), Modified (M), Deleted (D), Renamed (R), Copied (C)
- **Detailed diffs**: For <5 files, shows unified diffs with context
- **Summary listing**: For >=5 files, shows concise listing with line counts

### Unstaged Files Analysis
- **Modified files**: Files with changes in working directory
- **Change context**: Unified diffs for modified files
- **Line statistics**: Added/deleted lines per file
- **Threshold handling**: Detailed vs summary based on file count

### Untracked Files Analysis
- **Complete enumeration**: All untracked files and directories
- **File metadata**: Line counts for regular files, type indicators for others
- **Directory structure**: Hierarchical view of untracked content

## Integration with Skill

### Automatic Detection
The skill automatically detects and uses `git-status-digest.sh` when available:
```bash
if git_status_script=$(find_git_status_digest); then
    run_command "$git_status_script" identify
else
    manual_git_analysis "identify"
fi
```

### Environment Awareness
The script is executed through the environment manager wrapper:
```bash
# Devbox
devbox run -- scripts/git-status-digest.sh identify

# Mise  
mise exec -- scripts/git-status-digest.sh identify

# Native
scripts/git-status-digest.sh identify
```

### Verification Loop
The skill uses both modes in a verification loop:
1. **Initial**: `identify` mode to understand current state
2. **Final**: `assert-clean` mode to verify successful cleanup

## Manual Fallback

When `git-status-digest.sh` is not available, the skill provides a manual fallback with equivalent functionality:

### Porcelain Analysis
```bash
git status --untracked-files=all --porcelain
```

### Detailed File Analysis
```bash
# Staged files
git diff --cached --name-status
git diff --cached --unified=5 -- <path>

# Unstaged files  
git diff --name-status
git diff --unified=5 -- <path>

# Untracked files
git ls-files --others --exclude-standard
```

### Change Categorization
The manual fallback categorizes changes:
- **Pure renames** (R100): Show as `old -> new`
- **Pure copies** (C100): Show as `source -> dest`
- **Modified renames** (R<100): Show diff on new path
- **Modified copies** (C<100): Show diff on new path
- **Type changes** (T*): Show with counts
- **Permission changes**: Show with line counts

## Error Handling

### Script Not Found
- **Detection**: Skill searches multiple locations
- **Fallback**: Automatic switch to manual analysis
- **Warning**: Logs fallback usage for awareness

### Script Execution Failures
- **Graceful degradation**: Continue with manual analysis
- **Error reporting**: Clear indication of failure reason
- **Recovery**: Manual analysis provides equivalent results

### Permission Issues
- **Detection**: Check script executability
- **Resolution**: Attempt to make executable
- **Fallback**: Manual analysis if permissions cannot be fixed

## Best Practices

### Script Maintenance
- Keep script updated with latest git features
- Test with various repository states
- Ensure compatibility across git versions
- Handle edge cases (empty repos, corrupted states)

### Integration Testing
- Test with different environment managers
- Verify fallback behavior when script unavailable
- Validate output parsing in skill
- Test with large and small change sets

### Performance Considerations
- Optimize for large repositories
- Limit diff output for many files
- Use efficient git commands
- Cache results where appropriate

## Troubleshooting

### Common Issues

**Script not found**:
- Verify installation in expected locations
- Check file permissions
- Ensure script is executable

**Unexpected output format**:
- Verify script version compatibility
- Check for custom modifications
- Validate git version compatibility

**Performance issues**:
- Limit analysis scope for large repos
- Use appropriate thresholds for detailed output
- Consider repository size and complexity

### Debug Mode
Enable debug logging to troubleshoot issues:
```bash
./scripts/git-repo-manager.sh analyze --debug
```

This shows:
- Script search paths
- Execution commands
- Output parsing details
- Fallback activation reasons
