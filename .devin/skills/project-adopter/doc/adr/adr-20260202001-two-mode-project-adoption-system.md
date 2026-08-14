---
modeline: "vim: set ft=markdown:"
title: "ADR: Two-Mode Project Adoption System"
adr-id: "adr20260202001"
slug: "two-mode-project-adoption-system"
url: "src/current/skills/software-dev/project-adopter/doc/adr-20260202001-two-mode-project-adoption-system.md"
synopsis: "Implement dual-mode system (adopt vs standardize) for appropriate levels of project intervention"
author: "https://github.com/levonk"
date-created: "2026-02-02"
date-updated: "2026-02-02"
date-review: "2026-08-02"
date-triggers: ["2026-02-02"]
version: "1.0.0"
status: "accepted"
aliases: []
tags: [doc/architecture/adr, project-adopter, modes, standardization]
supersedes: []
superseded-by: []
related-to: ["adr20260202002-per-language-configuration-scripts"]
scope:
  impact-scope: ["project-adopter skill", "devbox.json generation", "justfile generation", "configuration management"]
  excluded-scope: ["other AI skills", "core infrastructure"]
---

# Decision Record: Two-Mode Project Adoption System

## Context

The project-adopter skill needs to handle two fundamentally different use cases:

1. **3rd Party Projects** - Where we need to be conservative and respect existing build standards
2. **Our Projects** - Where we want to take liberties and enforce comprehensive standardization

A single approach cannot serve both needs effectively. Conservative approaches leave our projects under-configured, while aggressive approaches risk breaking 3rd party projects.

## Constraints

- Must support both conservative and aggressive standardization approaches
- Must not unilaterally change 3rd party build standards
- Must provide comprehensive tooling for our projects
- Must be configurable at runtime

## Decision

Implement a dual-mode system with two distinct operation modes:

- **Adopt Mode** (`--mode adopt`) - Conservative approach for 3rd party projects
- **Standardize Mode** (`--mode standardize`) - Aggressive standardization for our projects

## Rationale

This approach provides appropriate levels of intervention based on project ownership:

- **3rd Party Projects**: Get essential tooling without disrupting existing workflows
- **Our Projects**: Get comprehensive standardization with full tooling ecosystem
- **Flexibility**: Teams can choose appropriate level of intervention
- **Maintainability**: Single codebase serving both use cases cleanly

## Technical Approach

### Mode Detection
```bash
ADOPTION_MODE="${1:-adopt}"  # Default to adopt mode
if [[ "$ADOPTION_MODE" != "adopt" && "$ADOPTION_MODE" != "standardize" ]]; then
    log_error "Invalid mode: $ADOPTION_MODE. Use --mode adopt or --mode standardize"
    exit 1
fi
```

### Package Selection Logic
```bash
if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
    if [[ "$ADOPTION_MODE" == "standardize" ]]; then
        # Comprehensive tooling: playwright, tailwindcss, vite, webpack, etc.
        language_packages='"nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest", "playwright", "tailwindcss", "postcss", "vite", "webpack", "rollup", "esbuild"'
    else
        # Minimal essential tooling
        language_packages='"nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest"'
    fi
fi
```

## Affected Components

- **project-adopter/scripts/adopt-project.sh** - Main orchestrator with mode parsing
- **generate_devbox_json()** - Mode-aware package selection
- **generate_integrated_justfile()** - Mode-aware target generation
- **generate_readme_md()** - Mode-aware documentation
- **generate_agents_md()** - Mode-aware AI agent configuration

## Consequences

### Positive

- **Appropriate Intervention** - Right level of changes for each project type
- **Developer Experience** - Comfortable for 3rd parties, comprehensive for our teams
- **Maintainability** - Single codebase serving both needs
- **Flexibility** - Easy to choose appropriate approach per project

### Negative

- **Complexity** - Additional mode parameter and conditional logic
- **Testing** - Need to test both modes for each language
- **Documentation** - Need to explain when to use each mode

### Neutral

- **Learning Curve** - Teams need to understand which mode to use
- **Configuration** - Additional parameter to remember

## Alternatives Considered

### Option A: Single Conservative Approach
- **Pros**: Simple, safe for 3rd parties
- **Cons**: Leaves our projects under-configured

### Option B: Single Aggressive Approach  
- **Pros**: Comprehensive for our projects
- **Cons**: Risks breaking 3rd party projects

### Option C: Separate Skills
- **Pros**: Clean separation
- **Cons**: Code duplication, maintenance overhead

## Rollout / Migration

1. **Phase 1**: Add mode parameter to main function
2. **Phase 2**: Update generation functions to respect mode
3. **Phase 3**: Add mode-specific package selections
4. **Phase 4**: Update documentation and help text
5. **Phase 5**: Test both modes across all supported languages

## To Investigate

- Should we detect project ownership automatically?
- Should we have a "prompt" mode that asks user which to use?
- Should we add mode detection from existing configuration files?

## Validation

- Test adopt mode on various 3rd party projects to ensure no disruption
- Test standardize mode on our projects to ensure comprehensive tooling
- Measure developer satisfaction with both approaches
- Monitor for any mode-related issues or confusion

## Review Schedule

Review after 6 months of usage to assess:
- Mode selection patterns
- User feedback on appropriateness
- Need for additional mode-specific features

## Notes

The default mode is "adopt" to ensure safe operation for 3rd party projects. Teams must explicitly choose "standardize" mode for aggressive standardization.

## References

- [ADR: Per-Language Configuration Scripts](adr-20260202002-per-language-configuration-scripts.md)
- [project-adopter SKILL.md](../SKILL.md)
- [Devbox Documentation](https://www.jetify.com/devbox/docs)

<!-- vim: set ft=markdown: -->
