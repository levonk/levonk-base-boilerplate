# Deterministic Configuration

This skill uses **deterministic scripts** with tools like `jq`, `yq`, and `surgical-config` to ensure predictable and repeatable configuration changes:

## JSON Configuration (package.json, devbox.json)
```bash
# Add devDependencies without overwriting existing ones
jq '.devDependencies += {"@job-aide/tools-lint-eslint-config": "^1.0.0"}' package.json

# Add packages to devbox.json
jq '.packages += ["nodejs", "typescript"]' devbox.json
```

## YAML Configuration (GitHub Actions, ESLint)
```bash
# Add new jobs to GitHub Actions without modifying existing ones
yq eval '.jobs += {"lint": {"runs-on": "ubuntu-latest", "steps": [...]}}' .github/workflows/ci.yml

# Add ESLint rules without overwriting existing rules
yq eval '.rules += {"@job-aide/tools-lint-eslint-config/recommended": "error"}' .eslintrc.yml
```
