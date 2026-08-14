# Repository Health Review Skill

A comprehensive skill for repository health analysis, detecting outdated information, conflicting rules, undocumented standards, lessons from failures, missing tool documentation, and security/access patterns.

## Overview

The Repository Health Review skill provides enterprise-grade analysis for maintaining code quality, security, and documentation standards across repositories. It's designed as a standalone skill that can be used independently or integrated with other skills like the monorepo-extractor.

## Why This Skill Exists

### The Problem

Repository health degrades over time due to:

- **Outdated Information**: Deprecated tools, old dates, broken links
- **Conflicting Rules**: Contradictory configurations and standards
- **Undocumented Standards**: Hidden knowledge and missing documentation
- **Technical Debt**: Temporary code, workarounds, and known issues
- **Security Gaps**: Hardcoded secrets, insecure configurations
- **Missing Documentation**: Tools without setup guides and explanations

### Our Solution

The Repository Health Review skill implements **systematic analysis** with **actionable insights**:

- **Comprehensive Analysis**: 6 categories of repository health issues
- **Severity-Based Classification**: Critical, high, medium, low, info priorities
- **Quantified Scoring**: 0-100 health score for easy assessment
- **Actionable Recommendations**: Specific improvement suggestions
- **Integration Ready**: Works with other skills and CI/CD pipelines

## Quick Start

### Basic Usage

```bash
# Comprehensive health review
./scripts/repository-health-review.sh /path/to/repository

# Verbose output with detailed analysis
./scripts/repository-health-review.sh --verbose /path/to/repository

# Generate JSON report for tracking
./scripts/repository-health-review.sh --report health.json /path/to/repository
```

### Focused Analysis

```bash
# Security-focused analysis
./scripts/repository-health-review.sh --categories security /path/to/repository

# Outdated information and conflicts
./scripts/repository-health-review.sh --categories outdated,conflicts /path/to/repository

# Quick analysis (high-priority files only)
./scripts/repository-health-review.sh --quick /path/to/repository
```

### Integration Examples

```bash
# Pre-migration analysis
./scripts/repository-health-review.sh --pre-extraction /path/to/monorepo project-name

# Post-migration validation
./scripts/repository-health-review.sh --post-extraction /path/to/extracted-repo

# CI/CD integration
./scripts/repository-health-review.sh --report ci-health.json --categories security .
```

## Understanding the Analysis

### Analysis Categories

#### 1. Outdated Information Detection

**What it finds:**
- Date references older than 365 days
- Deprecated tools (bower, gulp 3, webpack 3, babel 6, etc.)
- Outdated URLs and broken gist references
- Legacy configuration patterns

**Impact:**
- 🔴 **Critical**: Security vulnerabilities in outdated dependencies
- 🟡 **Warning**: Performance issues with deprecated tools
- 🔵 **Info**: Documentation that needs updating

#### 2. Conflicting Rules Analysis

**What it finds:**
- ESLint configuration conflicts (quotes, semicolons)
- Gitignore pattern contradictions
- Package.json script conflicts
- Documentation contradictions

**Common Issues:**
- `"quotes": "single"` vs `"quotes": "double"`
- `!*.log` vs `*.log` in gitignore
- Duplicate script names in package.json

#### 3. Undocumented Standards Detection

**What it finds:**
- Custom npm scripts without documentation
- Environment variables without explanation
- Custom file formats without descriptions
- Internal conventions without documentation

**Documentation Gaps:**
- Missing README sections
- Undocumented API endpoints
- Hidden dependencies
- Implicit team knowledge

#### 4. Lessons from Failures Analysis

**What it finds:**
- TODO/FIXME comments with urgency indicators
- Temporary workarounds marked as permanent
- Known issues without resolution plans
- Security-related temporary code
- Performance warnings

**Failure Patterns:**
- "TODO fix later" without timeline
- "HACK temporary" still in production
- "BUG critical" without fix
- "Remove before production" still present

#### 5. Missing Tool Documentation

**What it finds:**
- Tools mentioned without setup instructions
- Configuration files without explanations
- Development environment setup gaps
- Deployment process documentation

**Tool Categories:**
- Container tools (Docker, Kubernetes)
- CI/CD platforms (GitHub Actions, GitLab CI)
- Infrastructure tools (Terraform, Ansible)
- Development tools (ESLint, Prettier)

#### 6. Security and Access Patterns

**What it finds:**
- Hardcoded secrets and credentials
- Insecure configurations
- Overly permissive access patterns
- Missing security headers
- Authentication implementation gaps

**Security Issues:**
- API keys in configuration files
- Debug mode in production
- SSL/TLS verification disabled
- 777 file permissions
- Missing authentication safeguards

### Health Scoring

The repository health score is calculated as follows:

- **Base Score**: 100 points
- **Critical Issues**: -10 points each
- **High Issues**: -7 points each
- **Medium Issues**: -5 points each
- **Low Issues**: -2 points each
- **Info Issues**: -1 point each

**Score Interpretation:**
- **90-100**: Excellent repository health
- **80-89**: Good repository health
- **70-79**: Fair repository health
- **50-69**: Poor repository health
- **Below 50**: Critical repository health

## Advanced Usage

### Command Line Options

```bash
Usage: ./scripts/repository-health-review.sh [OPTIONS] REPOSITORY_PATH [PROJECT_NAME]

Options:
  -v, --verbose              Show detailed analysis output
  -q, --quick               Quick analysis (high-priority files only)
  -r, --report FILE          Generate JSON report to FILE
  -c, --categories LIST     Comma-separated categories
  -e, --exclude LIST        Comma-separated directories to exclude
  --pre-extraction          Pre-extraction analysis mode
  --post-extraction         Post-extraction analysis mode
  -h, --help                Show this help message

Categories:
  outdated        - Outdated information and deprecated tools
  conflicts       - Conflicting rules and configurations
  undocumented    - Undocumented standards and conventions
  failures        - Lessons from failures and temporary code
  missing_docs   - Missing tool documentation
  security        - Security and access patterns
```

### Report Structure

```json
{
  "repository": {
    "path": "/path/to/repository",
    "name": "project-name",
    "last_analyzed": "2025-02-05T12:00:00Z"
  },
  "health_score": 85,
  "issues": {
    "critical": 2,
    "high": 5,
    "medium": 8,
    "low": 12,
    "info": 3,
    "total": 30
  },
  "categories": {
    "outdated_information": {
      "issues": 3,
      "severity": "warning",
      "findings": ["Deprecated webpack version", "Old date reference"]
    },
    "security_patterns": {
      "issues": 1,
      "severity": "critical",
      "findings": ["Hardcoded API key detected"]
    }
  },
  "recommendations": [
    {
      "priority": "high",
      "category": "security",
      "action": "Remove hardcoded credentials",
      "files": ["config/database.js"]
    }
  ]
}
```

### Integration with Other Skills

#### Monorepo Extractor Integration

The monorepo-extractor skill automatically calls this skill for health analysis:

```bash
# The monorepo-extractor runs this automatically
../repository-health-review/scripts/repository-health-review.sh \
  --pre-extraction \
  --report health-analysis.json \
  /path/to/monorepo project-name
```

#### CI/CD Integration

```yaml
# GitHub Actions example
- name: Repository Health Review
  run: |
    ./scripts/repository-health-review.sh --report health.json .
    
    # Fail build on critical issues
    if [[ $(jq '.issues.critical' health.json) -gt 0 ]]; then
      echo "Critical security issues found"
      exit 1
    fi
```

#### Development Workflow Integration

```bash
# Pre-commit hook
#!/bin/bash
./scripts/repository-health-review.sh --quick --categories security,conflicts .
```

## Best Practices

### Before Running Health Review

1. **Clean Repository State**: Ensure working directory is clean
2. **Update Dependencies**: Run package updates for latest security patches
3. **Backup Repository**: Create backup before major changes
4. **Notify Team**: Let team know about upcoming audit

### During Health Review

1. **Use Verbose Mode**: Get detailed output for thorough analysis
2. **Generate Reports**: Create JSON reports for tracking trends
3. **Review Critical Issues**: Address security and critical issues first
4. **Document Findings**: Keep record of issues and resolutions

### After Health Review

1. **Address Critical Issues**: Fix security vulnerabilities immediately
2. **Plan Improvements**: Create roadmap for addressing warnings
3. **Update Documentation**: Fix documentation gaps identified
4. **Schedule Follow-up**: Plan regular health checks

## Examples

### Example 1: Basic Repository Health Check

```bash
./scripts/repository-health-review.sh /opt/my-project

# Output:
# Repository Health Score: 82/100
# Critical Issues: 1
# Warnings: 4
# Info: 8
# 
# 🔴 Critical: Hardcoded API key in config.js
# 🟡 Warning: Deprecated webpack version in package.json
# 🟡 Warning: Conflicting ESLint rules
# 🟡 Warning: TODO comments older than 6 months
# 🟡 Warning: Missing security headers documentation
```

### Example 2: Security-Focused Review

```bash
./scripts/repository-health-review.sh --security --verbose /opt/my-project

# Output:
# Security Analysis Results:
# 🔴 Critical: Hardcoded database password
# 🔴 Critical: SSL verification disabled
# 🟡 Warning: Debug mode enabled in production config
# 🟡 Warning: Overly permissive file permissions
# 🔵 Info: Authentication patterns documented
```

### Example 3: Pre-Migration Analysis

```bash
./scripts/repository-health-review.sh --pre-extraction /opt/company-monorepo webapp

# Output:
# Pre-Extraction Health Review for 'webapp':
# Migration Readiness: 78/100
# 
# Issues to address before extraction:
# 🔴 Critical: Shared secrets in project config
# 🟡 Warning: Monorepo-specific paths in documentation
# 🟡 Warning: Undocumented build dependencies
# 
# Recommendations:
# 1. Extract and secure shared secrets
# 2. Update documentation for standalone project
# 3. Document all build dependencies
```

## Customization

### Adding Custom Analysis Categories

```bash
# Add to repository-health-review.sh
analyze_custom_patterns() {
    local file="$1"
    local project="$2"
    
    # Add custom pattern detection
    if grep -q "CUSTOM_PATTERN" "$file"; then
        echo "Custom pattern detected"
    fi
}
```

### Configuring Severity Levels

```bash
# Customize severity weights
declare -A SEVERITY_SCORES=(
    ["critical"]=10
    ["high"]=7
    ["medium"]=5
    ["low"]=2
    ["info"]=1
)
```

### Custom Pattern Lists

```bash
# Update deprecated tools list
deprecated_tools=("bower" "gulp 3" "webpack 3" "babel 6" "nodejs < 14" "python 2" "angularjs")

# Add custom security patterns
secret_patterns+=("custom_secret.*=.*['\"][^'\"]+['\"]")
```

## Troubleshooting

### Common Issues

**Analysis Takes Too Long**:
- Use `--quick` flag for faster analysis
- Limit analysis with `--categories` flag
- Exclude large directories with `--exclude`

**False Positives**:
- Review analysis patterns and adjust regex
- Use `--ignore-patterns` to exclude known false positives
- Customize analysis functions for your repository

**Missing Issues**:
- Ensure analysis patterns cover your use cases
- Add custom analysis functions for domain-specific issues
- Update pattern lists regularly

### Performance Optimization

```bash
# Quick analysis (high-priority files only)
./scripts/repository-health-review.sh --quick /path/to/repo

# Specific categories only
./scripts/repository-health-review.sh --categories security,outdated /path/to/repo

# Exclude directories
./scripts/repository-health-review.sh --exclude node_modules,dist /path/to/repo
```

## Resources

### Related Skills
- `monorepo-extractor` - Uses this skill for pre/post-extraction health analysis
- `project-configuration` - Can use health review for setup validation

### Documentation
- Repository health guidelines
- Security best practices
- Documentation standards
- Code quality metrics

### External Resources
- OWASP security guidelines
- Industry documentation standards
- Security vulnerability databases
- Code quality frameworks

---

**Remember**: Repository health is an ongoing process, not a one-time fix. Regular health reviews help maintain code quality, security, and documentation standards over time.
