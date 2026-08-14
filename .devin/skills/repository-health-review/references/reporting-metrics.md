# Reporting and Metrics

## Health Score Calculation

```bash
calculate_health_score() {
    local total_issues=$1
    local critical_issues=$2
    local warning_issues=$3
    local info_issues=$4

    # Base score starts at 100
    local score=100

    # Deduct points based on severity
    score=$((score - (critical_issues * 10)))
    score=$((score - (warning_issues * 5)))
    score=$((score - (info_issues * 1)))

    # Ensure score doesn't go below 0
    [[ $score -lt 0 ]] && score=0

    echo $score
}
```

## Report Structure

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
    "warnings": 5,
    "info": 12,
    "total": 19
  },
  "categories": {
    "outdated_information": {
      "issues": 3,
      "severity": "warning",
      "findings": [...]
    },
    "conflicting_rules": {
      "issues": 1,
      "severity": "critical",
      "findings": [...]
    },
    "undocumented_standards": {
      "issues": 8,
      "severity": "info",
      "findings": [...]
    },
    "failure_lessons": {
      "issues": 2,
      "severity": "warning",
      "findings": [...]
    },
    "missing_tool_documentation": {
      "issues": 4,
      "severity": "info",
      "findings": [...]
    },
    "security_patterns": {
      "issues": 1,
      "severity": "critical",
      "findings": [...]
    }
  },
  "recommendations": [
    {
      "priority": "high",
      "category": "security",
      "action": "Remove hardcoded credentials",
      "files": ["config/database.js"]
    }
  ],
  "trends": {
    "health_score_history": [90, 88, 85],
    "issues_trend": "decreasing"
  }
}
```

## Integration with CI/CD

```yaml
# GitHub Actions example
- name: Repository Health Review
  run: |
    ./scripts/repository-health-review.sh --report . health-report.json
    # Fail build on critical issues
    if [[ $(jq '.issues.critical' health-report.json) -gt 0 ]]; then
      echo "Critical security issues found"
      exit 1
    fi
```

## Performance Optimization

```bash
# Quick analysis (high-priority files only)
./scripts/repository-health-review.sh --quick /path/to/repo

# Specific categories only
./scripts/repository-health-review.sh --categories security,outdated /path/to/repo

# Exclude directories
./scripts/repository-health-review.sh --exclude node_modules,dist /path/to/repo
```
