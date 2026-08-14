# AI/IDE Configuration Analysis

## AI/IDE Analysis Scripts

- `scripts/analyze-ai-ide-configs.sh` - **Intelligent Configuration Analysis**: Analyzes AI/IDE configs and documentation for migration relevance
- `scripts/smart-content-filter.sh` - **Smart Content Filtering**: Intelligently filters and adapts content for standalone repository migration
- `scripts/repository-health-review.sh` - **Repository Health Analysis**: Comprehensive analysis for outdated info, conflicting rules, undocumented standards, failures, missing docs, and security patterns

## Repository Health Analysis

The `repository-health-review.sh` script provides comprehensive repository health analysis:

### Analysis Categories

- **Outdated Information**: Detects deprecated tools, old dates, outdated URLs
- **Conflicting Rules**: Identifies ESLint conflicts, gitignore contradictions, configuration inconsistencies
- **Undocumented Standards**: Finds undocumented scripts, environment variables, custom formats
- **Lessons from Failures**: Detects TODO/FIXME patterns, temporary code, performance warnings
- **Missing Tool Documentation**: Identifies tools without setup instructions, undocumented config files
- **Security and Access Patterns**: Finds hardcoded secrets, insecure configs, permission issues

### Usage Examples

```bash
# Comprehensive health review
./scripts/repository-health-review.sh /path/to/repository

# Security-focused analysis
./scripts/repository-health-review.sh --categories security /path/to/repository

# Pre-extraction analysis
./scripts/repository-health-review.sh --pre-extraction /path/to/monorepo project-name

# Generate detailed report
./scripts/repository-health-review.sh --report health.json /path/to/repository
```

### Health Scoring

- **90-100**: Excellent repository health
- **80-89**: Good repository health
- **70-79**: Fair repository health
- **50-69**: Poor repository health
- **Below 50**: Critical repository health

### Integration with Extraction

The monorepo extractor automatically runs repository health reviews when AI/IDE analysis is enabled, providing:

- Pre-extraction health assessment
- Critical issue identification
- Migration readiness evaluation
- Post-extraction validation
