# Dependency Synchronization in Boilerplate Templates

## Overview

All boilerplate templates now include automatic dependency synchronization to prevent common build failures in reproducible environments (Nix, Docker, CI/CD). This addresses the issue where dependency manifest files (Cargo.toml, package.json, etc.) are modified but their corresponding lock files are not updated.

## Problem Solved

When developers modify dependency manifest files without updating lock files, it causes:
- Nix profile upgrade failures
- Docker build inconsistencies
- CI/CD pipeline failures
- Reproducibility issues across environments

## Solution

Each technology stack now includes:
1. **`sync-deps` target**: Updates lock files when manifest files change
2. **`pre-commit` target**: Orchestrates pre-commit checks, including dependency sync
3. **Automatic detection**: Only runs sync when manifest files are actually modified

## Implementation

### Shared Partials

All synchronization logic lives in `_shared/partials/justfile-partials/`:

- `rust-deps-sync.jinja`: Cargo.toml → Cargo.lock
- `swift-deps-sync.jinja`: Package.swift → Package.resolved
- `typescript-deps-sync.jinja`: package.json → lock file (pnpm/npm/yarn)
- `java-maven-deps-sync.jinja`: pom.xml → dependency validation
- `java-gradle-deps-sync.jinja`: build.gradle → gradle.lockfile

### Updated Templates

#### Rust Templates
- `apps/cli/rust/core/files/justfile.jinja`
- Includes: sync-deps, pre-commit targets

#### Swift Templates
- `_shared/apps/cli/swift/core/justfile.jinja`
- `_shared/packages/category/general/domain/package-name/swift/justfile.jinja`
- Includes: sync-deps, pre-commit targets

#### TypeScript/Node Templates
- `_shared/apps/cli/typescript/core/justfile.jinja`
- `_shared/apps/web/typescript/nextjs/justfile.jinja`
- `_shared/apps/plugins/typescript/justfile.jinja`
- `_shared/apps/infrastructure/airflow-node/justfile.jinja`
- `_shared/packages/category/web/domain/package-name/typescript/justfile.jinja`
- Includes: sync-deps, pre-commit targets with auto-detection of package manager

#### Java Templates
- `apps/cli/java/core/files/Makefile.jinja`
- Includes: sync-deps, pre-commit targets (Maven-based)

## Usage

### Manual Usage
```bash
# Sync dependencies manually
just sync-deps

# Run all pre-commit checks
just pre-commit
```

### Git Hook Integration
Projects can add git hooks to automatically run `just pre-commit`:

```bash
#!/bin/sh
# .git/hooks/pre-commit
just pre-commit
```

## Technology-Specific Behavior

### Rust
- Detects `Cargo.toml` modifications
- Runs `cargo update`
- Stages `Cargo.lock` automatically

### Swift
- Detects `Package.swift` modifications
- Runs `swift package resolve`
- Stages `Package.resolved` automatically

### TypeScript/Node
- Detects `package.json` modifications
- Auto-detects package manager (pnpm/npm/yarn)
- Runs appropriate install command
- Stages corresponding lock file

### Java (Maven)
- Detects `pom.xml` modifications
- Runs `mvn dependency:resolve`
- Validates dependency resolution (no lock file in Maven)

### Java (Gradle)
- Detects `build.gradle` modifications
- Runs `./gradlew dependencies --write-locks`
- Stages `gradle.lockfile` (requires dependency locking enabled)

## Benefits

✅ **Prevents build failures** in reproducible environments
✅ **Automated dependency management** - no manual lock file updates
✅ **Consistent developer experience** across all tech stacks
✅ **Better CI/CD reliability** - consistent dependency resolution
✅ **Template maintainability** - single source of truth in shared partials
✅ **Extensible** - easy to add more pre-commit checks to the orchestration target

## Future Enhancements

The `pre-commit` target can be extended to include:
- Linting checks
- Formatting validation
- Type checking
- Custom project-specific validations
- Security audits

## Migration Notes

Existing projects generated from these templates can be updated by:
1. Running the boilerplate update process
2. Manually adding the sync-deps and pre-commit targets to their justfiles
3. Setting up git hooks to call `just pre-commit`

## Related Documentation

- [Boilerplate Developer Guide](.agents/rules/boilerplate-developer-guide.md)
- [Boilerplate Catalog](AGENTS.md)
