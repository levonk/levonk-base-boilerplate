# Architecture Decision Records (ADRs)

This directory contains architectural decision records and change documentation for the project-adopter skill.

## ADR Index

| ID | Title | Status | Date |
|-----|-------|---------|------|
| [ADR 20260202001](adr-20260202001-two-mode-project-adoption-system.md) | Two-Mode Project Adoption System | Accepted | 2026-02-02 |
| [ADR 20260202002](adr-20260202002-per-language-configuration-scripts.md) | Per-Language Configuration Scripts | Accepted | 2026-02-02 |
| [ADR 20260202003](adr-20260202003-integrated-project-documentation-generation.md) | Integrated Project Documentation Generation | Accepted | 2026-02-02 |

## Change Documentation

### Project Changes by Type

| Document | Description | Languages Covered |
|----------|-------------|-------------------|
| [changes-all-projects.md](changes-all-projects.md) | Universal changes across all project types | All |
| [changes-nodejs-typescript-projects.md](changes-nodejs-typescript-projects.md) | Node.js/TypeScript specific changes | Node.js, TypeScript |
| [changes-rust-projects.md](changes-rust-projects.md) | Rust specific changes | Rust |
| [changes-python-projects.md](changes-python-projects.md) | Python specific changes | Python |
| [changes-go-projects.md](changes-go-projects.md) | Go specific changes | Go |
| [changes-java-projects.md](changes-java-projects.md) | Java specific changes | Java |

### What Changes Are Documented

Each change document covers:

- **Detection Patterns** - How projects are identified
- **Files Created** - New files added to projects
- **devbox.json Changes** - Environment packages and scripts
- **justfile Changes** - Build targets and commands
- **Surgical Changes** - Non-destructive modifications to existing files
- **Configuration Files** - Language-specific config templates
- **Mode Differences** - Adopt vs Standardize mode variations
- **Validation Steps** - How to verify successful adoption

### Mode-Specific Changes

#### Adopt Mode (Conservative)
- Essential packages only
- Preserves existing configurations
- Basic tooling and documentation
- Safe for 3rd party projects

#### Standardize Mode (Comprehensive)
- Full ecosystem packages
- Enforces our standards
- Complete tooling and documentation
- Optimized for our projects

## ADR Process

### When to Create an ADR

Create an ADR for any "architecturally significant" decision that affects:
- System structure and organization
- Non-functional characteristics
- Dependencies and integrations
- Interfaces and contracts
- Construction techniques and processes
- Technology choices and framework selections
- Pattern implementations and conventions

### When to Update Change Documentation

Update change documentation when:
- New languages are supported
- Package selections change
- Configuration templates are updated
- New files are added to generation
- Mode behaviors are modified
- Dependencies and integrations
- Interfaces and contracts
- Construction techniques and processes
- Technology choices and framework selections
- Pattern implementations and conventions

### ADR Format

Each ADR follows the standard format with:
- Context and constraints
- Decision and rationale
- Technical approach
- Affected components
- Consequences (positive, negative, neutral)
- Alternatives considered
- Rollout/migration plan
- Review schedule

### Numbering Convention

ADRs are numbered sequentially by date: `adrYYYYMMDD###`
- `YYYY` = Year
- `MM` = Month
- `DD` = Day
- `###` = Sequential number for that day

## Current Architecture Decisions

### Core Design Principles

1. **Two-Mode Operation** - Support both conservative (adopt) and aggressive (standardize) approaches
2. **Per-Language Organization** - Structure configuration management by language rather than file type
3. **Integrated Generation** - Generate complete project setup (devbox, justfile, docs) in one operation
4. **AI-Ready Environment** - Include all tools necessary for AI agents to operate effectively
5. **Mode-Aware Configuration** - Respect the chosen mode in all generated artifacts

### Key Architectural Patterns

- **Orchestrator Pattern** - Main script coordinates language-specific configuration scripts
- **Strategy Pattern** - Different strategies for adopt vs standardize modes
- **Template Generation** - Generate files based on detected project type and mode
- **Extraction First** - Extract existing configurations before generating new ones

## Related Documentation

- [project-adopter SKILL.md](../SKILL.md) - Main skill documentation
- [project-adopter REFERENCE.md](../REFERENCE.md) - Configuration patterns and templates
- [project-detection SKILL.md](../../project-detection/SKILL.md) - Project detection capabilities

## Review Process

ADRs should be reviewed:
- **Immediately** after creation for technical accuracy
- **Quarterly** for ongoing relevance
- **When major changes** impact the decision

## Creating New ADRs

1. Copy the latest ADR template
2. Update frontmatter with new ID and details
3. Fill in all sections completely
4. Link to related ADRs
5. Update this index file
6. Request review from team members

<!-- vim: set ft=markdown: -->
