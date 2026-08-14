# Monorepo Extractor - Technical Reference

## Overview

The Monorepo Extractor skill provides a comprehensive, deterministic approach to extracting projects from monorepos while preserving git history and ensuring team safety.

## Architecture

### Core Components

1. **Tool Verification** (`scripts/verify-tools.sh`)
   - Validates all required tools and minimum versions
   - Checks git configuration and permissions
   - Provides clear installation guidance

2. **Project Extraction** (`scripts/extract-project.sh`)
   - Safe git history filtering using `git-filter-repo` or `git-filter-branch`
   - Preserves complete project history
   - Creates backup tags before extraction

3. **Repository Validation** (`scripts/validate-extraction.sh`)
   - Comprehensive repository integrity checks
   - History completeness verification
   - File structure validation

4. **Safe Cleanup** (`scripts/safe-cleanup.sh`)
   - Team safety mechanisms with grace periods
   - Rollback capabilities
   - Migration reference creation

## Technical Implementation Details

### Git History Extraction

#### Primary Method: git-filter-repo
```bash
git-filter-repo --path "$PROJECT_NAME/" --force
```

**Advantages:**
- Significantly faster than git-filter-branch
- Better memory usage
- More reliable for large repositories
- Preserves commit metadata accurately

#### Fallback Method: git-filter-branch
```bash
git filter-branch --subdirectory-filter "$PROJECT_NAME" --prune-empty
```

**Used when:**
- git-filter-repo is not available
- Legacy environments with older git versions

### Backup Strategy

#### Multi-Level Backup System

1. **Pre-Extraction Tag**
   ```bash
   git tag -a "pre-extraction-$PROJECT_NAME-$(date +%Y%m%d-%H%M%S)" \
           -m "Pre-extraction backup of $PROJECT_NAME"
   ```

2. **Pre-Removal Tag**
   ```bash
   git tag -a "pre-removal-$PROJECT_NAME-$(date +%Y%m%d-%H%M%S)" \
           -m "Final backup before removing $PROJECT_NAME"
   ```

3. **Rollback Information File**
   - Contains all necessary information for restoration
   - Stored in project directory before removal
   - Includes exact commands for rollback

### Team Safety Mechanisms

#### Activity Detection
- Scans for recent commits within grace period
- Checks for uncommitted changes
- Verifies no active development in progress

#### Grace Period
- Configurable wait time (default: 30 minutes)
- Allows team to respond to migration announcement
- Can be bypassed with `--force` flag

#### Migration Reference
- Comprehensive README in original location
- Clear instructions for team members
- Links to new repository and backup information

## Error Handling and Recovery

### Common Failure Scenarios

#### 1. Tool Verification Failure
**Symptoms:** Missing or outdated tools
**Resolution:** Script provides specific installation commands
**Prevention:** Run verification before starting extraction

#### 2. Git History Corruption
**Symptoms:** `git fsck` failures, missing commits
**Resolution:** Restore from backup tag
**Prevention:** Repository validation before and after extraction

#### 3. Network Connectivity Issues
**Symptoms:** Cannot push to new repository
**Resolution:** Local repository remains functional, retry push later
**Prevention:** Test remote connectivity during validation

#### 4. Team Activity Conflicts
**Symptoms:** Recent commits detected during cleanup
**Resolution:** Cancel cleanup, coordinate with team
**Prevention:** Proper communication and grace periods

### Recovery Procedures

#### Complete Rollback
```bash
# Restore project from backup tag
git checkout pre-extraction-$PROJECT_NAME-YYYYMMDD-HHMM -- $PROJECT_NAME/

# Remove rollback information
rm $PROJECT_NAME/.monorepo-extraction-rollback
git add $PROJECT_NAME/.monorepo-extraction-rollback
git commit -m "Remove rollback information after restoration"
```

#### Partial Recovery
```bash
# Restore specific files
git checkout $BACKUP_TAG -- $PROJECT_NAME/specific/file

# Restore entire directory structure
git checkout $BACKUP_TAG -- $PROJECT_NAME/
```

## Performance Considerations

### Repository Size Impact

| Repository Size | Expected Time | Memory Usage | Recommendations |
|----------------|---------------|--------------|----------------|
| < 100MB        | < 5 minutes   | < 500MB      | Standard workflow |
| 100MB - 1GB    | 5-30 minutes  | 500MB-2GB    | Use git-filter-repo |
| > 1GB          | 30+ minutes   | > 2GB        | Consider splitting |

### Optimization Strategies

#### 1. Pre-Extraction Cleanup
```bash
# Remove unnecessary files before extraction
git filter-repo --invert-paths --path 'node_modules/' --path '*.log'
```

#### 2. Incremental Extraction
```bash
# Extract specific time ranges first
git filter-repo --since '2020-01-01' --until '2023-12-31'
```

#### 3. Parallel Processing
- Multiple projects can be extracted in parallel
- Each extraction uses isolated temporary directories

## Security Considerations

### Data Protection

#### 1. Secret Scanning
```bash
# Scan for potential secrets before extraction
git log --all --full-history -- "$PROJECT_NAME/" | \
  grep -iE '(password|token|key|secret)' || true
```

#### 2. Access Control Validation
```bash
# Verify new repository permissions
git ls-remote --exit-code origin >/dev/null 2>&1
```

#### 3. Audit Trail
- All operations are logged
- Backup tags provide immutable history
- Rollback files document all changes

### Compliance Requirements

#### 1. Data Retention
- Original history preserved in backup tags
- Complete audit trail maintained
- No data loss during extraction

#### 2. Access Management
- New repository inherits appropriate permissions
- Team access updated during migration
- Old access revoked after cleanup

## Integration Points

### CI/CD Pipeline Updates

#### 1. Build Scripts
```bash
# Update build configurations
sed -i 's|monorepo/path/project|new-repo-url|g' .github/workflows/build.yml
```

#### 2. Dependency References
```bash
# Update package.json references
jq '.repository.url = "new-repo-url"' package.json > package.json.tmp && \
  mv package.json.tmp package.json
```

#### 3. Documentation Links
```bash
# Update README links
sed -i 's|monorepo-link|new-repo-link|g' README.md
```

### Monitoring and Alerting

#### 1. Extraction Metrics
- Repository size before/after
- Number of commits transferred
- Extraction duration
- Validation results

#### 2. Health Checks
```bash
# Post-extraction health check
git fsck --full
git log --oneline | head -5
du -sh .
```

## Troubleshooting Guide

### Diagnostic Commands

#### 1. Repository Health
```bash
# Check repository integrity
git fsck --full

# Verify commit history
git log --oneline --graph

# Check for corruption
git count-objects -v
```

#### 2. Extraction Validation
```bash
# Verify project structure
find . -type f | head -20

# Check file permissions
ls -la

# Verify git history completeness
git log --stat -- "$PROJECT_NAME/"
```

#### 3. Network Connectivity
```bash
# Test remote connectivity
git ls-remote origin

# Check DNS resolution
nslookup github.com

# Test SSH connection
ssh -T git@github.com
```

### Common Issues and Solutions

#### Issue: "git-filter-repo not found"
**Solution:**
```bash
pip install git-filter-repo
# or
brew install git-filter-repo
```

#### Issue: "Permission denied" during extraction
**Solution:**
```bash
# Check file permissions
ls -la "$MONOREPO_PATH"

# Fix permissions if needed
chmod -R u+rwX "$MONOREPO_PATH"
```

#### Issue: "Repository too large" error
**Solution:**
```bash
# Increase git memory limits
git config core.packedGitLimit 512m
git config core.packedGitWindowSize 32k

# Or use git-filter-branch with memory optimization
git config core.packedGitLimit 2g
git filter-branch --subdirectory-filter "$PROJECT_NAME"
```

## Best Practices

### Pre-Extraction Checklist

- [ ] Run tool verification script
- [ ] Communicate extraction plan to team
- [ ] Create comprehensive backup
- [ ] Verify new repository access
- [ ] Test extraction in staging environment

### During Extraction

- [ ] Monitor progress and logs
- [ ] Verify intermediate results
- [ ] Keep team informed of progress
- [ ] Document any issues encountered

### Post-Extraction

- [ ] Run comprehensive validation
- [ ] Update all references and links
- [ ] Verify CI/CD pipeline functionality
- [ ] Confirm team access to new repository
- [ ] Archive old project location appropriately

## Version History

### v1.0.0 (2025-02-01)
- Initial release
- Complete extraction workflow
- Team safety mechanisms
- Comprehensive validation
- Rollback capabilities

## Support and Contributing

### Getting Help
1. Check this reference document
2. Review script error messages
3. Examine validation reports
4. Consult rollback information

### Contributing
- Follow existing script patterns
- Add comprehensive error handling
- Include detailed logging
- Update documentation
- Test with various repository sizes

---

*This reference document is maintained alongside the Monorepo Extractor skill. For the latest version, check the skill directory.*
