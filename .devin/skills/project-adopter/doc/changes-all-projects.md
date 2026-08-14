# Project Adoption Changes - All Projects

This document outlines all changes made by the project-adopter skill across all project types and modes.

## Overview

The project-adopter skill makes changes to projects in two distinct modes:

- **Adopt Mode** (`--mode adopt`) - Conservative changes for 3rd party projects
- **Standardize Mode** (`--mode standardize`) - Comprehensive changes for our projects

## Universal Changes (All Languages)

### Files Always Created

| File | Source of Truth | Description |
|------|------------------|-------------|
| **devbox.json** | `generate_devbox_json()` in `adopt-project.sh` | Environment configuration with AI tools |
| **justfile** | `generate_integrated_justfile()` in `adopt-project.sh` | Standard interface with *-internal targets |
| **README.md** | `generate_readme_md()` in `adopt-project.sh` | Comprehensive setup documentation |
| **AGENTS.md** | `generate_agents_md()` in `adopt-project.sh` | AI agent configuration guide |
| **.envrc** | `create_config_files()` in `adopt-project.sh` | Direnv environment configuration |

### Universal AI Tools Added to devbox.json

| Tool | Source of Truth | Purpose |
|------|------------------|---------|
| **just** | `generate_devbox_json()` - base packages | Command runner |
| **yq-go** | `generate_devbox_json()` - ai_tools | YAML/JSON/TOML processing |
| **jq** | `generate_devbox_json()` - ai_tools | JSON processing |
| **ripgrep** | `generate_devbox_json()` - ai_tools | Fast text search |
| **fd** | `generate_devbox_json()` - ai_tools | File finding |
| **bat** | `generate_devbox_json()` - ai_tools | Enhanced cat with syntax highlighting |

### Universal Justfile Structure

| Target | Source of Truth | Description |
|--------|------------------|-------------|
| **default** | `generate_integrated_justfile()` - standard targets | Lists all available targets |
| **clean** | `generate_integrated_justfile()` - standard targets | Calls clean-internal |
| **dev** | `generate_integrated_justfile()` - standard targets | Calls dev-internal |
| **build** | `generate_integrated_justfile()` - standard targets | Calls build-internal |
| **test** | `generate_integrated_justfile()` - standard targets | Calls test-internal |
| **lint** | `generate_integrated_justfile()` - standard targets | Calls lint-internal |
| **typecheck** | `generate_integrated_justfile()` - standard targets | Calls typecheck-internal |
| **bootstrap** | `generate_integrated_justfile()` - standard targets | Calls bootstrap-internal |
| **loop** | `generate_integrated_justfile()` - additional targets | Development loop (bootstrap → build → test → dev) |
| **ci** | `generate_integrated_justfile()` - additional targets | CI pipeline (bootstrap → lint → typecheck → test → build) |

```just
# _devbox helper — DRY auto-detection of devbox environment
_devbox target *args:
    #!/usr/bin/env bash
    if [ "${DEVBOX_SHELL_ENABLED:-0}" = "1" ]; then
        exec just "{{target}}" {{args}}
    elif command -v devbox >/dev/null 2>&1; then
        exec devbox run -- just "{{target}}" {{args}}
    else
        echo "❌ devbox not found in PATH." >&2
        just doctor 2>/dev/null || true
        exit 1
    fi

# Standard interface targets — delegate to _devbox
default:
    @just --list

clean:
    just _devbox clean_impl

dev:
    just _devbox dev_impl

build:
    just _devbox build_impl

test:
    just _devbox test_impl

lint:
    just _devbox lint_impl

typecheck:
    just _devbox typecheck_impl

bootstrap:
    just _devbox bootstrap_impl

# Development loop targets
loop: || (bootstrap build test dev)
ci: || (bootstrap lint typecheck test build)
```

### Universal devbox.json Scripts
```json
{
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl",
    "clean": "just clean_impl"
  }
}
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Minimal language packages** - Essential tools only
- **Preserves existing configurations** - Surgical edits only
- **Basic documentation** - Essential setup instructions
- **Conservative approach** - Won't break existing workflows

### Standardize Mode (Comprehensive)
- **Comprehensive language packages** - Full tooling ecosystem
- **Standardizes configurations** - Enforces our standards
- **Complete documentation** - Comprehensive guides and references
- **Aggressive approach** - Takes liberties to optimize

## Surgical Configuration Changes

The project-adopter uses surgical-config for non-destructive modifications:

### Existing File Modifications

| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **package.json** | `apply_surgical_configs()` - Node.js section in `adopt-project.sh` | Add development scripts and dependencies |
| **Cargo.toml** | `apply_surgical_configs()` - Rust section in `adopt-project.sh` | Add development dependencies and features |
| **pyproject.toml** | `apply_surgical_configs()` - Python section in `adopt-project.sh` | Add development dependencies and tool configs |
| **go.mod** | `apply_surgical_configs()` - Go section in `adopt-project.sh` | Add development dependencies |
| **build.gradle/settings.gradle** | `apply_surgical_configs()` - Java section in `adopt-project.sh` | Add plugins and dependencies |

### Modification Principles
- **Additive only** - Never removes existing configurations
- **Structure preserving** - Maintains formatting and comments
- **Semantic parsing** - Uses format-aware tools (yq-go)
- **Idempotent** - Safe to run multiple times

## Documentation Changes

### README.md Sections Added

| Section | Source of Truth | Content |
|--------|------------------|---------|
| **Development Setup** | `generate_readme_md()` - setup section | Prerequisites and quick start instructions |
| **Available Commands** | `generate_readme_md()` - commands section | Devbox and just command examples |
| **Project Structure** | `generate_readme_md()` - structure section | Language-specific directory layout |
| **Development Workflow** | `generate_readme_md()` - workflow section | Daily development process |
| **Environment Details** | `generate_readme_md()` - environment section | Tools and packages information |
| **Troubleshooting** | `generate_readme_md()` - troubleshooting section | Common issues and solutions |
| **Contributing Guidelines** | `generate_readme_md()` - contributing section | Development contribution process |

### AGENTS.md Sections Added

| Section | Source of Truth | Content |
|--------|------------------|---------|
| **Repository Structure** | `generate_agents_md()` - structure section | Language-specific directory layout |
| **Configuration Files** | `generate_agents_md()` - config section | File descriptions and purposes |
| **Development Tools** | `generate_agents_md()` - tools section | Essential and AI development tools |
| **AI Development Tools** | `generate_agents_md()` - ai tools section | yq-go, jq, ripgrep, fd, bat usage |
| **Testing Strategies** | `generate_agents_md()` - testing section | Language-specific testing approaches |
| **Build Processes** | `generate_agents_md()` - build section | Build commands and workflows |
| **AI Agent Guidelines** | `generate_agents_md()` - guidelines section | Code style and development practices |
| **Common Tasks** | `generate_agents_md()` - tasks section | Debugging, performance, feature development |

## Environment Changes

### .envrc Configuration
```bash
# Project Environment Configuration
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox shellenv)"
fi

export PROJECT_NAME="$(basename "$PWD")"
export PROJECT_PATH="$PWD"

watch_file devbox.json
watch_file package.json
watch_file Cargo.toml
watch_file pyproject.toml
watch_file go.mod
```

## Language-Specific Changes

See language-specific change documents for detailed modifications:

- [Node.js/TypeScript Changes](changes-nodejs-typescript-projects.md)
- [Rust Changes](changes-rust-projects.md)
- [Python Changes](changes-python-projects.md)
- [Go Changes](changes-go-projects.md)
- [Java Changes](changes-java-projects.md)

## Safety and Rollback

### Backup Strategy
- **No destructive operations** - All changes are additive
- **Git tracking** - All changes are version controlled
- **Rollback capability** - Can revert with git

### Loop Prevention
- **Lock files** - Prevents infinite loops between skills
- **Caller detection** - Identifies nested skill calls
- **Environment checks** - Detects skill context

## Verification

### Post-Adoption Validation
```bash
# Verify environment setup
devbox --list
just --list

# Test basic functionality
just bootstrap
just build
just test

# Verify documentation
cat README.md
cat AGENTS.md
```

## Troubleshooting

### Common Issues
- **Permission errors** - Check file permissions
- **Tool conflicts** - Verify devbox package compatibility
- **Path issues** - Ensure correct working directory
- **Loop detection** - May need to clear lock files

### Debug Commands
```bash
# Enable verbose output
./adopt-project.sh --verbose --mode adopt /path/to/project

# Check surgical-config integration
./adopt-project.sh --no-loop-prevention /path/to/project

# Force regeneration
./adopt-project.sh --force --mode standardize /path/to/project
```

## Related Documentation

- [Two-Mode System ADR](adr-20260202001-two-mode-project-adoption-system.md)
- [Per-Language Scripts ADR](adr-20260202002-per-language-configuration-scripts.md)
- [Integrated Documentation ADR](adr-20260202003-integrated-project-documentation-generation.md)
- [Surgical-Config SKILL.md](../../surgical-config/SKILL.md)

<!-- vim: set ft=markdown: -->
