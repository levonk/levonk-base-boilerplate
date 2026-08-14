# Output Formats

## Standard Output
- **Colored results**: Success/warning/error indicators
- **Progress bars**: Long-running operation progress
- **Summaries**: Pass/fail counts and statistics
- **Recommendations**: Actionable improvement suggestions

## JSON Reports
```bash
# Generate machine-readable reports
./scripts/quality-validator.sh complete --report --format json
```

```json
{
  "summary": {
    "total_issues": 5,
    "errors": 1,
    "warnings": 4,
    "status": "failed"
  },
  "phases": {
    "lint": {
      "status": "passed",
      "issues": 0
    },
    "format": {
      "status": "failed",
      "issues": 3
    }
  }
}
```

## JUnit XML
```bash
# CI-compatible reports
./scripts/quality-validator.sh complete --report --format junit
```
