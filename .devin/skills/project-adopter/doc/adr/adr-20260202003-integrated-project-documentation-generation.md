---
modeline: "vim: set ft=markdown:"
title: "ADR: Integrated Project Documentation Generation"
adr-id: "adr20260202003"
slug: "integrated-project-documentation-generation"
url: "src/current/skills/software-dev/project-adopter/doc/adr-20260202003-integrated-project-documentation-generation.md"
synopsis: "Generate comprehensive project documentation (README.md, AGENTS.md) alongside devbox.json and justfile for complete project setup"
author: "https://github.com/levonk"
date-created: "2026-02-02"
date-updated: "2026-02-02"
date-review: "2026-08-02"
date-triggers: ["2026-02-02"]
version: "1.0.0"
status: "accepted"
aliases: []
tags: [doc/architecture/adr, project-adopter, documentation, readme, agents, devbox, justfile]
supersedes: []
superseded-by: []
related-to: ["adr20260202001-two-mode-project-adoption-system", "adr20260202002-per-language-configuration-scripts"]
scope:
  impact-scope: ["project-adopter skill", "documentation generation", "project setup", "AI agent configuration"]
  excluded-scope: ["core infrastructure", "other AI skills"]
---

# Decision Record: Integrated Project Documentation Generation

## Context

The project-adopter skill needs to provide a complete, out-of-the-box development experience. Initially, it only generated devbox.json and justfile, but this left several gaps:

1. **No User Documentation** - Developers didn't know how to use the generated setup
2. **No AI Agent Documentation** - AI assistants lacked project-specific guidance
3. **Minimal Functionality** - Generated justfiles had placeholder targets
4. **Incomplete Tooling** - Missing essential AI tools (yq-go, jq, etc.)

Users needed comprehensive documentation and functional targets from the start.

## Constraints

- Must generate minimal functional setup immediately
- Must provide both human-readable and AI-readable documentation
- Must include essential AI development tools
- Must respect the two-mode system (adopt vs standardize)
- Must be language-aware and project-specific

## Decision

Implement integrated generation of four core project artifacts:

1. **devbox.json** - Environment and packages (AI tools + language-specific)
2. **justfile** - Standard interface + *_impl targets (real commands)
3. **README.md** - Human-readable setup guide with devbox commands
4. **AGENTS.md** - AI agent configuration with project-specific guidance

## Rationale

This approach provides a complete development ecosystem:

- **Immediate Functionality** - `devbox --list` + `devbox ${TARGET}` work instantly
- **Complete Documentation** - Both humans and AI have comprehensive guidance
- **AI-Ready Environment** - All tools for AI agents to operate effectively
- **Language Optimization** - Tailored to detected project type
- **Mode Awareness** - Respects adopt vs standardize approaches

## Technical Approach

### Integrated Generation Flow
```bash
# Main orchestrator
create_config_files() {
    # Generate devbox.json with AI tools + language packages
    generate_devbox_json "$PROJECT_PATH" "$detected_systems"
    
    # Generate integrated justfile with *_impl targets
    generate_integrated_justfile "$PROJECT_PATH" "$detected_systems"
    
    # Generate README.md with devbox commands
    generate_readme_md "$PROJECT_PATH" "$detected_systems"
    
    # Generate AGENTS.md with AI agent configuration
    generate_agents_md "$PROJECT_PATH" "$detected_systems"
}
```

### Enhanced devbox.json with AI Tools
```json
{
  "packages": [
    "just",           // Command runner
    "yq-go",         // YAML/JSON/TOML processing
    "jq",            // JSON processing
    "ripgrep",        // Fast text search
    "fd",            // File finding
    "bat",           // Enhanced cat with syntax highlighting
    "nodejs_22",     // Language-specific packages
    "pnpm", "typescript", "eslint", "prettier", "jest"
  ]
}
```

### Functional justfile with *_impl Targets
```just
# Standard interface (devbox shell)
dev:
    devbox shell dev

# Language-specific implementation
dev_impl:
    pnpm run dev        # Real command from package.json
```

### Comprehensive README.md Structure
```markdown
# Project Name

## Available Commands
### Devbox Commands
```bash
devbox --list
devbox build
devbox test
```

### Just Commands
```bash
just --list
just loop
just ci
```

## Development Workflow
## Troubleshooting
```

### Project-Specific AGENTS.md
```markdown
# AI Agent Documentation: Project Name

## Repository Structure
## Development Tools
## AI Development Tools
## Testing Strategy
## Common Tasks
```

## Affected Components

- **generate_devbox_json()** - Enhanced with AI tools and mode-aware packages
- **generate_integrated_justfile()** - Real *_impl targets instead of placeholders
- **generate_readme_md()** - New function for comprehensive user documentation
- **generate_agents_md()** - New function for AI agent configuration
- **create_config_files()** - Orchestrates all four generations

## Consequences

### Positive

- **Complete Setup** - Everything works out of the box
- **Dual Documentation** - Both humans and AI have comprehensive guidance
- **AI-Ready** - All tools for AI agents included
- **Real Commands** - No placeholder targets, everything functional
- **Language Awareness** - Tailored to detected project type

### Negative

- **More Complexity** - Four generation functions to maintain
- **Longer Generation** - More files to create and process
- **Documentation Maintenance** - Need to keep docs in sync with functionality

### Neutral

- **File Count** - More files in project directory
- **Generation Time** - Slightly longer setup process

## Alternatives Considered

### Option A: Minimal Generation Only
- **Pros**: Fast, simple
- **Cons**: Incomplete, requires manual setup

### Option B: Documentation Only (No Tooling)
- **Pros**: Comprehensive guidance
- **Cons**: Tools missing, not functional

### Option C: Tooling Only (No Documentation)
- **Pros**: Functional environment
- **Cons**: No guidance on usage

### Option D: Separate Documentation Generation
- **Pros**: Modular
- **Cons**: Incomplete integration, coordination issues

## Rollout / Migration

1. **Phase 1**: Implement AI tools in devbox.json generation
2. **Phase 2**: Create generate_readme_md() function
3. **Phase 3**: Create generate_agents_md() function
4. **Phase 4**: Update justfile generation with real targets
5. **Phase 5**: Integrate all four in create_config_files()
6. **Phase 6**: Test complete generation across all languages and modes

## To Investigate

- Should we generate additional documentation files (CHANGELOG.md, CONTRIBUTING.md)?
- Should we include project-specific AI prompts in AGENTS.md?
- Should README.md include performance benchmarks or deployment instructions?
- Should we generate .gitignore files based on language and mode?

## Validation

- Test complete generation on sample projects for each language
- Verify devbox commands work immediately after generation
- Test AI agent effectiveness with generated AGENTS.md
- Measure developer onboarding time with generated documentation
- Monitor for any missing essential tools or documentation

## Review Schedule

Review after 3 months of usage to assess:
- Completeness of generated documentation
- Effectiveness of AI tool inclusion
- User feedback on generated content quality
- Need for additional generated files or improvements

## Notes

The generation respects the two-mode system:
- **Adopt Mode**: Minimal but functional setup
- **Standardize Mode**: Comprehensive tooling and documentation

All generated files include mode-specific content and language-aware configurations.

## References

- [ADR: Two-Mode Project Adoption System](adr-20260202001-two-mode-project-adoption-system.md)
- [ADR: Per-Language Configuration Scripts](adr-20260202002-per-language-configuration-scripts.md)
- [project-adopter SKILL.md](../SKILL.md)
- [Devbox Documentation](https://www.jetify.com/devbox/docs)
- [Just Command Runner](https://github.com/casey/just)

<!-- vim: set ft=markdown: -->
