---
modeline: "vim: set ft=markdown:"
title: "ADR: Standard Developer UX Flow - Devbox First"
adr-id: adr-20260131001
slug: 20260131001-standard-developer-ux-flow
url: /internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md
synopsis: Establish Devbox as the primary developer environment interface with optional direct package manager fallback for optimal developer experience
author: https://github.com/levonk
date-created: 2026-01-31
date-updated: 2026-04-19
version: 1.0.0
status: "proposed"
aliases: []
tags: ["doc/architecture/adr", "developer-experience", "devbox", "tooling", "workflow"]
supersedes: []
superseded-by: []
related-to: ["adr-20251226001-devbox-direnv-dev-environment", "adr-20260419001-nx-monorepo-build-tool", "adr-20251218002-shared-quality-scripts"]
---

## Context

Developers need a consistent, reproducible environment setup that minimizes cognitive overhead while maximizing productivity. The current landscape offers many tools for environment management:

- **Custom shell scripts**: Brittle, hard to maintain, inconsistent across projects
- **Makefiles**: Powerful but complex syntax, not designed for environment management
- **Nix flakes**: Extremely reproducible but steep learning curve, verbose configuration
- **mise**: Fast but limited ecosystem compared to Nix
- **Bazel/Pants**: Overkill for most projects, complex setup, focused on build orchestration

We already have Devbox + direnv established in [ADR 20251226001](./adr-20251226001-devbox-direnv-dev-environment.md), but we need to define the standard developer workflow patterns.

## Decision

### Project-Specific Build Tools

The Standard Developer UX Flow is technology-agnostic. Each project type uses its native build tools:

| Technology | Build | Test | Lint | Dev |
|------------|-------|------|------|-----|
| **Rust** | `cargo build` | `cargo test` | `cargo clippy` | `cargo run` |
| **Node.js** | `nx build` | `nx test` | `nx lint` | `nx dev` |
| **Python** | `python -m build` | `pytest` | `ruff check` | `uv run python src/main.py` |
| **Go** | `go build` | `go test` | `golangci-lint run` | `go run` |
| **Java** | `mvn compile` | `mvn test` | `checkstyle` | `mvn exec:java` |

**Note**: Throughout this ADR, `[build tool]` refers to the appropriate language-specific command from the table above.

### Primary Flow: direnv → devbox → just (*-internal) → [build tool]

**Automated developer workflow** (for AI agents and CI/CD):
```bash
# 1. Enter project directory (direnv auto-activates devbox)
cd project

# 2. For AI agents and automated systems, use devbox run with direct internal calls
devbox run just build-internal      # → language-specific build command
devbox run just test-internal       # → language-specific test command
devbox run just lint-internal       # → language-specific lint command

# OR in devbox shell environment:
devbox shell
just build-internal      # → language-specific build command
just test-internal       # → language-specific test command
```

**Why AI agents use devbox run + *-internal**:
- AI agents operate in automated contexts where environment consistency is critical
- `devbox run` executes commands directly without interactive shell overhead
- More efficient for repeated automated operations and CI/CD pipelines
- `devbox shell` is reserved for interactive human development sessions

**Testing Requirements for All Changes**:
- **Mandatory**: Every feature implementation must include comprehensive tests
- **Mandatory**: Every bug fix must include regression tests to prevent recurrence
- **Test Coverage**: Ensure both happy path and edge cases are covered
- **Test Patterns**: Use established testing patterns for the specific project type
- **Quality Gates**: All tests must pass before considering work complete

### Novice Flow: just (normal targets) → devbox run → just (*-internal) → cargo

**For human developers who want convenient one-off commands**:
```bash
# 1. Human developer runs normal target (ensures devbox environment automatically)
just build

# Flow:
# just build → devbox run build → just build-internal → cargo build
```

**Why humans use just x**:
- Simpler command interface for daily development
- Automatic environment management without thinking about devbox
- Convenient for one-off operations and interactive development
- Lower cognitive overhead for common tasks

**Note**: While `just x` uses `devbox run` internally, humans can also use `devbox shell` for interactive sessions where they want to run multiple commands manually.

**Testing Requirements for All Changes**:
- **Mandatory**: Every feature implementation must include comprehensive tests
- **Mandatory**: Every bug fix must include regression tests to prevent recurrence
- **Test Coverage**: Ensure both happy path and edge cases are covered
- **Quality Gates**: All tests must pass before considering work complete

### Power User Flow: (in devbox shell) → just (*-internal) → [build tool]

**For developers already in devbox environment**:
```bash
# 1. Already in devbox shell (via direnv or manual activation)
# 2. Can call *-internal targets directly
just build-internal      # → language-specific build command
just test-internal       # → language-specific test command
```

### Bootstrap Flow: direnv → devbox → just bootstrap-internal → just prime-internal

**For complete project initialization**:
```bash
# 1. Enter project directory (direnv auto-activates devbox)
cd project

# 2. Devbox init_hook calls bootstrap-internal directly
# 3. bootstrap calls prime to run code indexing
# Result: Full environment, dependencies, and code indexing are set up
```

### Testing Requirements for All Development

**MANDATORY**: Tests are required for ALL changes to ensure code quality and prevent regressions

#### Core Testing Principles

1. **Test-First Development (TDD)**: Write failing tests before implementing features
2. **Regression Tests**: Every bug fix must include tests to prevent recurrence
3. **Comprehensive Coverage**: Test both happy paths and edge cases
4. **Quality Gates**: All tests must pass before considering work complete

#### Required Test Types

**For New Features**:
- Unit tests for core functionality
- Integration tests for component interactions
- End-to-end tests for complete workflows
- Error handling and edge case tests

**For Bug Fixes**:
- Regression test that reproduces the original bug
- Verification test that confirms the fix works
- Additional tests to cover related edge cases

**For Refactoring**:
- Existing tests must continue to pass
- New tests for any added functionality
- Performance tests if behavior affects performance

#### Testing Workflow

```bash
# Standard testing workflow across all flows
devbox run just test-internal           # Run all tests
devbox run just test-internal feature   # Run specific test
devbox run just test-internal -- --nocapture  # Run with output

# Quality gates before completion
devbox run just test-internal && devbox run just lint-internal
```

#### Enforcement

- **Pre-commit hooks**: Should prevent commits without passing tests
- **CI/CD pipelines**: Must fail builds without comprehensive test coverage
- **Code review**: Reviewers must verify adequate test coverage
- **Documentation**: Test requirements must be documented in project AGENTS.md

### Target Architecture

**Normal Targets** (Developer interface, ensure devbox environment):
- `just build` - Calls `devbox run build` → `just build-internal`
- `just test` - Calls `devbox run test` → `just test-internal`
- `just lint` - Calls `devbox run lint` → `just lint-internal`
- `just dev` - Calls `devbox run dev` → `just dev-internal`
- `just bootstrap` - Calls `devbox run bootstrap` → `just bootstrap-internal`
- `just prime` - Calls `devbox run prime` → `just prime-internal`

**Note on `devbox run` vs `devbox shell`**:
- `devbox run <cmd>` - Executes a single command in the devbox environment (used in justfile normal targets)
- `devbox shell` - Starts an interactive shell session for manual development

**Internal Targets** (*-internal suffix, actual implementation):
- `just build-internal` - Language-specific build command (see table above)
- `just test-internal` - Language-specific test command (see table above) (MANDATORY for quality gates)
- `just lint-internal` - Language-specific lint command (see table above)
- `just dev-internal` - Language-specific dev command (see table above)
- `just bootstrap-internal` - Actual bootstrap logic
- `just prime-internal` - Actual code indexing and analysis logic

**Devbox Scripts Configuration** (direct calls to *-internal):
```json
{
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "prime": "just prime-internal",
    "doctor": "just doctor-internal",
    "clean": "just clean-internal",
    "build": "just build-internal",
    "lint": "just lint-internal",
    "test": "just test-internal",
    "dev": "just dev-internal"
  }
}
```

**Why Devbox Scripts Point to *-internal**:
- Automated systems (CI/CD, init_hooks) are already in devbox environment
- No need to call normal targets which would add unnecessary devbox run wrapper
- Direct calls are more efficient and clearer for automation

### Fallback Flow: Direct Package Manager

**When direct package manager access is needed**:
```bash
# 1. For quick tasks without full environment
pnpm install
pnpm run dev

# 2. For scripts that don't need devbox environment
npm run lint
```

## Rationale

### Why direnv → devbox → just

1. **Zero Configuration**: `devbox.json` is simpler than `flake.nix`
2. **Familiar Interface**: Commands like `devbox add <package>` feel natural
3. **Nix Foundation**: Maintains reproducibility without Nix complexity
4. **direnv Integration**: Automatic environment activation
5. **Performance**: Optimized shell activation and caching
6. **just Integration**: Clean command recipes without Makefile complexity

### Why just over Makefiles

1. **No Phony Targets**: All recipes are treated as commands, no `.PHONY` needed
2. **Simple Syntax**: No confusing `=` vs `:=` assignments or `$$` for variables
3. **Better Error Messages**: Clear feedback when commands fail
4. **Command Runner Focus**: Designed for development tasks, not build systems
5. **Cross-Platform**: Consistent behavior across different systems
6. **Dependencies**: Clean recipe dependencies without complex syntax

### Why Allow Direct Package Manager Access

1. **Lower Barrier**: New developers can start immediately
2. **Simple Projects**: Not every project needs full environment management
3. **Migration Path**: Gradual adoption from existing workflows
4. **CI/CD Compatibility**: Tools & Build systems often expect native package managers

### Why Not Other Solutions

#### Makefiles
- **Problem**: Complex syntax, `.PHONY` requirements, confusing variable assignments
- **Example**: `make test` refuses to run if a file named `test` exists
- **Better**: `just test` always runs the recipe, designed for command execution

#### Custom Shell Scripts
- **Problem**: Brittle, inconsistent, hard to maintain
- **Example**: `./setup.sh` that fails silently or has hidden dependencies
- **Better**: `just`'s declarative recipes with automatic dependency resolution

#### Nix Flakes
- **Problem**: Steeper learning curve, verbose for simple cases
- **Example**: 50-line `flake.nix` for a simple Node.js project
- **Better**: Devbox's JSON configuration with `just` for commands

#### mise
- **Problem**: Limited package ecosystem compared to Nix, no reproducibility guarantees
- **Problem**: No rollback capability - once packages are installed, you can't easily revert to previous versions
- **Example**: Missing niche packages available in nixpkgs, no way to lock exact package versions across team members
- **Better**: Devbox's access to entire Nix ecosystem with `devbox.lock` for reproducible environments and rollback capability

#### Bazel/Pants
- **Problem**: Overkill for most projects, complex setup
- **Problem**: Not supported well with native platform tooling
- **Example**: Full Bazel setup for a simple web app
- **Better**: `just`'s lightweight approach focused on development tasks

## Consequences

### Positive

1. **Consistent Experience**: Same workflow across all projects
2. **Low Barrier**: Easy for new developers to start
3. **Flexible**: Can use simple or advanced workflows as needed
4. **Reproducible**: Nix foundation ensures environment consistency
5. **Productive**: Minimal cognitive overhead for common tasks

### Negative

1. **Tooling Dependency**: Requires Devbox installation
2. **Learning Curve**: Developers need to learn Devbox basics
3. **Migration Effort**: Existing projects need workflow updates
4. **Devbox Script Generation Issues**: Devbox script generation can fail, requiring fallback patterns (see Troubleshooting)

## Implementation

### Standard Devbox Configuration

```json
{
  "packages": [
    "just"  # Add just to the environment
  ],
  "shell": {
    "init_hook": [
      "just bootstrap-internal"
    ]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "prime": "just prime-internal",
    "doctor": "just doctor-internal",
    "clean": "just clean-internal",
    "build": "just build-internal",
    "lint": "just lint-internal",
    "test": "just test-internal",
    "dev": "just dev-internal"
  },
  "nix_pkgs": [
    "just"  # Ensure just is available for script execution
  ]
}
```

**Important**: Devbox script generation can fail (see Troubleshooting section). Always test `devbox run <script>` after configuration and provide `just <command>` fallbacks.

### Standard justfile Configuration

**Required Targets** - All boilerplate projects MUST include these targets:

```just
# Normal targets - Developer interface (REQUIRED)
# Primary pattern: just x → devbox run x → just x-internal
# Fallback pattern: just x → devbox run <direct command>

clean:
    devbox run clean

dev:
    devbox run dev

build:
    devbox run build

test:
    devbox run test

lint:
    devbox run lint

typecheck:
    devbox run typecheck

# Quality checks (REQUIRED for all projects)
quality:
    just lint
    just test
    just typecheck

# Bootstrap recipes (REQUIRED)
bootstrap:
    # Ensure devbox is available and environment is ready
    devbox run bootstrap

bootstrap-internal:
    # Internal bootstrap logic called by devbox init_hook
    # Language-specific dependency installation
    just setup
    echo "Project bootstrap complete!"

# Fallback pattern for critical commands (when devbox scripts fail)
# Use direct commands instead of just x-internal when needed
run:
    # Fallback: devbox run [language-specific run command]
    devbox run run

view-web:
    # Fallback: devbox run [language-specific web command]
    devbox run view-web

export:
    # Fallback: devbox run [language-specific export command]
    devbox run export
```

# Prime recipes (REQUIRED)
prime:
    # Prime code indexing and analysis tools
    devbox run prime

prime-internal:
    # Internal prime logic for code indexing and analysis tools
    # Run universal-ctags, roam-code, desloppify, etc.
    echo "Priming code indexing and analysis tools..."
    echo "Code indexing complete!"

### Prime Target Purpose

The **prime target** automates code indexing and analysis tool initialization to enhance developer productivity:

- **universal-ctags**: Generates code navigation tags (.tags file) for IDE integration
- **roam-code**: Creates semantic code understanding and documentation indexes
- **desloppify**: Scans for code patterns and generates analysis reports

**Why Prime After Bootstrap**:
- Bootstrap ensures all tools are installed and dependencies are available
- Prime runs after bootstrap to utilize the fully initialized environment
- Separates installation (bootstrap) from indexing (prime) for faster re-runs
- Allows developers to re-run indexing without full re-bootstrap

**Prime Integration**:
- Automatically called during bootstrap: `bootstrap → prime`
- Can be run independently: `just prime` (for re-indexing after code changes)
- Follows same *-internal pattern: `just prime-internal` (actual implementation)

# Health and diagnostics (REQUIRED)
doctor:
    # Check development environment health
    devbox run doctor

# Quality checks (OPTIONAL but RECOMMENDED)
quality:
    just lint
    just test
    just typecheck

# Language-specific commands (OPTIONAL)
# Add as needed for specific project types:
# - Database operations for web apps
# - Package management for libraries
# - Extension-specific commands for plugins

# Development setup (OPTIONAL)
setup:
    # Language/project-specific setup
    echo "Development environment ready!"

# Clean up (OPTIONAL)
clean-internal:
    # Language-specific cleanup (remove build artifacts, caches, etc.)
    rm -rf build dist node_modules/.cache
    echo "Build artifacts removed"

# Deep clean (OPTIONAL)
clean-all-internal:
    # Remove all build artifacts, dependencies, and caches
    rm -rf build dist node_modules .cache
    echo "All build artifacts and dependencies removed"
```

**Notes**:
- **Required targets** must be present in all boilerplate justfiles
- **Optional targets** can be added based on project type
- **Internal targets** (ending in `-internal`) are called by devbox scripts
- **External targets** are the main interface for developers
- **Language-specific commands** should follow the patterns in the Project-Specific Build Tools table

### Standard direnv Configuration

```bash
# .envrc
use_devbox() {
    watch_file devbox.json
    eval "$(devbox shellenv)"
}

use devbox
```

### Agent Documentation Requirements

All projects MUST include comprehensive agent documentation to ensure consistent AI assistant behavior:

#### AGENTS.md Requirement (MANDATORY)

**Purpose**: Central reference for AI agents working on the project, containing deterministic workflows and cross-references to other documentation.

**Required Content**:
- **Core Tools**: Environment management (mise/devbox), package management (TURBO + PNPM)
- **Monorepo Structure**: Directory organization (`apps/active/`, `packages/active/`, etc.)
- **Development Guidelines**: Greenfield development principles, code reuse patterns
- **Testing Workflows**: `/tmp` directory testing, boilerplate materialization procedures
- **Deterministic Scripts**: References to scripts in `scripts/` with clear execution patterns
- **Cross-References**: Links to relevant files in `internal-docs/`, boilerplate templates, and configuration files

**Key Principles**:
- Use references to other files rather than duplicating content
- Include deterministic script patterns from `scripts/` directory
- Provide clear workflow instructions for AI agents
- Reference `internal-docs/ARCHITECTURE.md` for project structure

#### CLAUDE.md Reference (MANDATORY)

**Purpose**: Lightweight redirect file that points to AGENTS.md for comprehensive information.

**Required Content**:
```markdown
# Claude Assistant Guide

See AGENTS.md for comprehensive agent documentation, workflows, and project guidelines.
```

**Why CLAUDE.md Exists**:
- Provides a familiar entry point for Claude-specific interactions
- Maintains backward compatibility with existing agent patterns
- Ensures all important content is centralized in AGENTS.md
- Prevents documentation drift between multiple agent files

**Documentation Structure**:
```
project/
├── AGENTS.md          # Comprehensive agent documentation (PRIMARY)
├── CLAUDE.md          # Redirect to AGENTS.md (SECONDARY)
├── internal-docs/     # Detailed project documentation
├── scripts/           # Deterministic scripts and workflows
└── boilerplates/      # Project templates and patterns
```

### Workflow Examples

#### New Project Setup (direnv → devbox → just (*-internal))
```bash
# 1. Create project (language-specific boilerplate)
copier copy boilerplate/[category]/[technology] my-project
cd my-project

# 2. Devbox auto-activates (direnv), just available
# 3. Automated init_hook calls bootstrap-internal directly
# 4. bootstrap calls prime-internal for code indexing
# 5. Start development
just dev-internal  # Calls language-specific dev command
```

#### Bootstrap Project Initialization (direnv → devbox → just bootstrap-internal → just prime-internal)
```bash
# 1. Clone and enter project
git clone <project> my-app
cd my-app

# 2. Devbox auto-activates, init_hook calls bootstrap-internal
# 3. bootstrap calls prime-internal for code indexing
# Flow: direnv → devbox → just bootstrap-internal → just prime-internal
# Result: Fully initialized development environment with code indexing
```

#### Existing Project Migration (just normal → devbox shell → just *-internal)
```bash
# 1. Add justfile to existing project
echo "dev:\n    [language-specific dev command]" > justfile

# 2. Start with just commands (no devbox yet)
just dev      # Direct language-specific command

# 3. Add devbox when environment complexity grows
devbox init
devbox add [language-specific packages] just
just dev      # Now calls devbox run dev-internal
```

#### Complex Multi-Language Project
```bash
# 1. Devbox handles multiple tools
devbox add [multiple language packages]

# 2. Single justfile orchestrates everything
just build    # Builds all components (language-specific builds)
just test     # Runs all tests (language-specific tests)
just dev      # Starts all services
just deploy   # Deploys all services
```

#### Existing Project Migration (just → devbox → just)
```bash
# 1. Add justfile to existing project
echo "dev:\n    pnpm run dev" > justfile

# 2. Start with just commands (no devbox yet)
just dev

# 3. Add devbox when environment complexity grows
devbox init
devbox add nodejs pnpm just
just dev    # Now runs with devbox environment
```

#### Complex Multi-Language Project
```bash
# 1. Devbox handles multiple tools
devbox add python go rust nodejs

# 2. Single justfile orchestrates everything
just build    # Builds all components
just test     # Runs all tests
just dev      # Starts all services
just deploy   # Deploys all services
```

## Troubleshooting

### Devbox Script Generation Issues

**Problem**: `devbox run <command>` fails with "command not found" error despite proper devbox.json configuration.

**Root Cause**: **Known devbox regression bug** introduced in v0.14.x series affecting script generation in `.devbox/gen/scripts/.cmd.sh`. This is a confirmed upstream bug, not a configuration issue.

**Affected Versions**: devbox 0.14.0, 0.14.2, 0.16.0 (and likely other 0.14.x+ versions)

**GitHub Issues**:
- #2517: `error: tool 'git' not found` after upgrading to 0.14.0
- #2108: Running script inside devbox shell throws `file not found` error
- #2607: Cannot run devbox script if another script is sourced in the init hook

**Symptoms**:
```bash
devbox run view-web
# Error: /path/to/.devbox/gen/scripts/.cmd.sh: line 7: view-web: command not found
```

**Workaround Solutions**:

#### Option 1: Use just Directly (Recommended)
Bypass broken devbox scripts entirely:

```bash
# Instead of: devbox run view-web
just view-web

# Instead of: devbox run run
just run

# Instead of: devbox run export
just export
```

#### Option 2: Use devbox shell + just-internal (Most Reliable)
Enter devbox shell first, then use internal targets directly:

```bash
# Enter devbox environment
devbox shell

# Inside devbox shell, use internal targets directly
just view-web-internal
just run-internal
just export-internal
just bootstrap-internal

# Or use standard targets (they work inside devbox shell)
just view-web
just run
just export
```

**Why this works**: Inside `devbox shell`, the environment is properly loaded and `just` can find all dependencies and execute internal targets directly.

#### Option 2: Version Rollback
Use devbox 0.13.7 (last known working version):

```bash
export DEVBOX_USE_VERSION=0.13.7
devbox run view-web  # Now works
```

#### Option 3: Direct Command Pattern
Update justfile to call commands directly through devbox:

```just
# Bypass devbox script generation - language-specific examples
view-web:
    # devbox run [language-specific web command]

run:
    # devbox run [language-specific run command]
```

**Prevention**:
1. **Test devbox scripts after setup**: Verify `devbox run <script>` works for all scripts
2. **Prefer just commands**: Document `just <command>` as primary interface in README
3. **Add bug comments**: Include known bug reference in devbox.json files
4. **Monitor devbox issues**: Track upstream fixes for script generation regression

**Detection**:
```bash
# Test if devbox scripts are working
devbox run --help  # Should show available scripts
devbox run <script>  # Test each script

# If scripts fail, use just directly
just --list  # Shows available just targets
```

**Status**: **Upstream Bug** - This is a devbox regression that needs to be fixed by the devbox team. The ADR pattern remains correct; devbox implementation is broken.

### Environment Issues

**Problem**: Commands work in devbox shell but not through devbox run

**Solution**: Ensure all dependencies are in both `packages` and `nix_pkgs` in devbox.json

```json
{
  "packages": {
    "[language]": {"version": "[version]"},
    "[package-manager]": "latest"
  },
  "nix_pkgs": [
    "[nix-package-name]",
    "[package-manager]",
    "just"
  ]
}
```

*See Project-Specific Build Tools table above for language-specific package names.*

## Migration Strategy

### Phase 1: Documentation (Week 1)
- Document standard workflows
- Update project templates
- Create migration guides

### Phase 2: New Projects (Week 2)
- All new projects use Devbox-first workflow
- Boilerplates updated with Devbox configuration
- CI/CD pipelines updated to use Devbox

### Phase 3: Existing Projects (Month 1-2)
- Priority projects migrated first
- Gradual adoption, maintaining compatibility
- Documentation and training for teams

### Phase 4: Optimization (Month 2-3)
- Performance tuning
- Advanced Devbox features
- Integration with existing tooling

## Rollout Plan

### Immediate Actions
1. Update boilerplate templates with Devbox configuration
2. Document standard workflows in project README
3. Update onboarding documentation

### Success Metrics
- Developer onboarding time reduced by 50%
- Environment-related issues decreased by 80%
- Consistent workflow adoption across 90% of projects

## To Investigate

- [ ] Devbox performance with large monorepos
- [ ] Integration with existing CI/CD pipelines
- [ ] Remote caching for Devbox environments
- [ ] IDE integration improvements
- [ ] Migration tools for existing projects
- [x] **Devbox script generation reliability** - Investigate why `.devbox/gen/scripts/.cmd.sh` fails to execute just commands
- [ ] **Root cause of devbox run failures** - Determine if this is version-specific or systemic issue
- [ ] **Alternative script generation approaches** - Explore more reliable devbox script patterns

## References

- [Devbox Documentation](https://www.jetify.com/devbox/docs)
- [just Command Runner](https://github.com/casey/just)
- [direnv Documentation](https://direnv.net/)
- [Nix Package Manager](https://nixos.org/)
- [ADR 20251226001 - Devbox + direnv](./adr-20251226001-devbox-direnv-dev-environment.md)
- [ADR 20260419001 - NX Monorepo Build Tool](./adr-20260419001-nx-monorepo-build-tool.md)

<!-- vim: set ft=markdown: -->
