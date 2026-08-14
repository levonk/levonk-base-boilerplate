# Usage Patterns

## As a Library Skill

Other skills can source the detection functions:

```bash
# In another skill's script
source "$(dirname "${BASH_SOURCE[0]}")/../project-detection/scripts/detect-build-systems.sh"

# Use detection functions
build_systems=$(detect_systems "/path/to/project" "false")
ci_cd_systems=$(detect_ci_cd_systems "/path/to/project" "false")
```

## As a Standalone Tool

```bash
# Get JSON output for programmatic use
./scripts/detect-all-systems.sh /path/to/project --format json

# Get human-readable analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose
```

## Integration Examples

### Project Configuration Skill
```bash
# Detect project type and configure standard tooling
build_systems=$(./scripts/detect-build-systems.sh /path/to/project)
if [[ "$build_systems" == *"pnpm"* ]]; then
    ./scripts/configure-pnpm-project.sh /path/to/project
fi
```

### Monorepo Extractor Skill
```bash
# Detect all systems before extraction
./scripts/detect-all-systems.sh /path/to/monorepo
./scripts/detect-ci-cd-systems.sh /path/to/monorepo
# Proceed with extraction knowing all tooling
```
