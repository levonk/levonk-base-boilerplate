---
modeline: "vim: set ft=markdown:"
title: "Universal Shared Partials System for Boilerplate Tree"
slug: universal-shared-partials-system
url: {url-to-be-added-after-commit}
synopsis: Extending the copier-wrapper script to support shared partials across the entire boilerplate/ tree while maintaining DRY principles and avoiding repository litter.
author: https://github.com/levonk
date-created: 2025-01-31
date-updated: 2025-01-31
version: 1.0.0
status: "proposed"
aliases: ["boilerplate-shared-partials", "copier-wrapper-universal"]
tags: [doc/templates, scaffolding, copier, jinja, shared-partials]
related-to: ["adr-20250123001-shared-partials-wrapper", "adr-20251014002-application-organization", "adr-20250926001-package-organization"]
---

# ADR-20250131001: Universal Shared Partials System for Boilerplate Tree

## Status

**Proposed** - This decision record outlines the requirements and approach for extending the shared partials system across the entire boilerplate tree.

## Context

The current boilerplate system has a working shared partials implementation limited to `boilerplate/apps/infrastructure/docker/`. The `copier-wrapper.sh` script successfully addresses Copier's limitations with template includes by copying shared partials from `_shared-partials/` to each template's `partials.bak/` directory before running Copier.

### Current State
- **Working solution**: Docker templates use shared partials via wrapper script
- **Proven pattern**: The approach works within Copier's sandbox limitations
- **Limited scope**: Only available in `apps/infrastructure/docker/`
- **Repeated code**: Other boilerplate categories cannot benefit from this system

### Problem Statement
1. **Code duplication**: Templates across `apps/`, `packages/`, and other categories cannot share common patterns
2. **Inconsistent updates**: Changes to common patterns must be manually applied across multiple templates
3. **Scalability issues**: As the boilerplate tree grows, maintaining consistency becomes increasingly difficult
4. **Missed opportunities**: Many templates could benefit from shared configurations (ESLint, TypeScript, Docker, etc.)

## Decision

We will extend the copier-wrapper functionality to support the entire `boilerplate/` tree using a **mirrored directory structure** that maintains the same hierarchy as the boilerplates themselves. This approach:

1. **Preserves the working pattern**: Builds on the proven Docker implementation
2. **Maintains DRY principles**: Shared partials defined once, reused everywhere
3. **Avoids repository litter**: Uses `.bak` suffix which is already in `.gitignore`
4. **Scales organically**: Each boilerplate category has its own shared space
5. **Provides clear scope**: The exact path shows where a template will be used

## Detailed Design

### 1. Directory Structure

```
boilerplate/
├── _shared/                       # Global shared templates (mirrors boilerplate structure)
│   ├── apps/                      # App-level shared templates
│   │   ├── infrastructure/        # Infrastructure app templates
│   │   │   ├── docker/            # Docker-specific shared files
│   │   │   │   ├── docker-header.jinja
│   │   │   │   ├── docker-footer.jinja
│   │   │   │   ├── Dockerfile.base.jinja
│   │   │   │   └── docker-compose.base.yml.jinja
│   │   │   ├── k8s/               # Kubernetes shared files
│   │   │   │   ├── deployment.yaml.jinja
│   │   │   │   └── service.yaml.jinja
│   │   │   └── airflow/           # Airflow shared files
│   │   │       ├── dag-template.py.jinja
│   │   │       └── requirements.txt.jinja
│   │   ├── web/                   # Web app shared templates
│   │   │   └── typescript/
│   │   │       └── nextjs/
│   │   │           ├── next.config.js.jinja
│   │   │           └── tailwind.config.js.jinja
│   │   ├── mobile/                # Mobile app shared templates
│   │   │   ├── kotlin-android/
│   │   │   │   └── build.gradle.jinja
│   │   │   └── react-native/
│   │   │       └── package.json.jinja
│   │   └── plugins/               # Plugin shared templates
│   │       └── mcp/
│   │           └── package.json.jinja
│   └── packages/                  # Package-level shared templates
│       └── category/
│           └── web/
│               └── domain/
│                   └── package-name/
│                       ├── python3/
│                       │   ├── pyproject.toml.jinja
│                       │   └── setup.py.jinja
│                       └── typescript/
│                           ├── package.json.jinja
│                           ├── tsconfig.json.jinja
│                           └── eslint.config.mjs.jinja
├── apps/                          # Actual boilerplate templates
│   ├── infrastructure/
│   │   ├── docker/
│   │   │   ├── docker-linux/
│   │   │   │   └── files/
│   │   │   │       └── Dockerfile.jinja
│   │   │   │           # Includes: {% include "partials.bak/Dockerfile.base.jinja" %}
│   │   │   └── docker-compose/
│   │   │       └── files/
│   │   │           └── docker-compose.yml.jinja
│   │   │               # Includes: {% include "partials.bak/docker-compose.base.yml.jinja" %}
│   │   └── k8s/
│   │       └── deployment/
│   │           └── files/
│   │               └── deployment.yaml.jinja
│   │                   # Includes: {% include "partials.bak/deployment.yaml.jinja" %}
│   └── web/
│       └── typescript/
│           └── nextjs/
│               └── files/
│                   └── next.config.js.jinja
│                       # Includes: {% include "partials.bak/next.config.js.jinja" %}
└── copier-wrapper.sh              # Universal wrapper for all templates
```

### 2. Enhanced Wrapper Script

The universal `copier-wrapper.sh` will:

#### 2.1. Auto-Discovery Logic
```bash
# Function to discover shared partials for a given template
discover_shared_partials() {
    local template_path="$1"
    local relative_path="${template_path#$BOILERPLATE_ROOT/}"
    
    # Convert: apps/infrastructure/docker/docker-linux
    # To: _shared/apps/infrastructure/docker/
    local shared_path="$BOILERPLATE_ROOT/_shared/$(dirname "$relative_path")"
    
    echo "$shared_path"
}
```

#### 2.2. Recursive Copy Logic
```bash
# Function to copy shared partials recursively
copy_shared_partials() {
    local template_dir="$1"
    local shared_source_dir="$(discover_shared_partials "$template_dir")"
    local target_dir="$template_dir/partials.bak"
    
    # Remove existing to ensure fresh copy
    rm -rf "$target_dir" 2>/dev/null || true
    
    # Copy if shared directory exists
    if [ -d "$shared_source_dir" ]; then
        mkdir -p "$target_dir"
        cp -r "$shared_source_dir"/* "$target_dir/"
        echo "  Copied shared partials from: $shared_source_dir"
    fi
}
```

#### 2.3. Template Detection
```bash
# Find all templates with copier.yml/yaml
find_all_templates() {
    find "$BOILERPLATE_ROOT" -name "copier.yml" -o -name "copier.yaml" | while read -r config; do
        dirname "$config"
    done
}
```

### 3. Usage Patterns

#### 3.1. Complete File Sharing
```jinja
{# In any template file #}
{% include "partials.bak/base-config.jinja" %}

# Template-specific additions
```

#### 3.2. Configuration File Sharing
```jinja
{# In package.json.jinja #}
{% include "partials.bak/package-base.json.jinja" %}

{
  "name": "{{ package_name }}",
  ...baseConfig,
  "scripts": {
    ...baseScripts,
    "custom": "command"
  }
}
```

#### 3.3. Multi-file Composition
```jinja
{# In k8s deployment #}
{% include "partials.bak/deployment.yaml.jinja" %}

---
{% include "partials.bak/service.yaml.jinja" %}

---
{% include "partials.bak/configmap.yaml.jinja" %}
```

## Requirements

### Functional Requirements

#### FR-001: Universal Template Support
- The wrapper script must work with **any** template in the boilerplate tree
- Support all categories: `apps/`, `packages/`, and future additions
- Maintain backward compatibility with existing Docker templates

#### FR-002: Mirrored Directory Structure
- Shared templates must mirror the boilerplate directory structure
- Path mapping: `boilerplate/X/Y/Z` → `_shared/X/Y/`
- Clear scope: Shared location indicates intended usage

#### FR-003: Auto-Discovery
- Wrapper must automatically discover appropriate shared partials
- No manual configuration required per template
- Graceful handling when no shared partials exist

#### FR-004: Fresh Copy Guarantee
- Always remove existing `partials.bak/` before copying
- Ensure up-to-date shared partials on each run
- Prevent stale partial issues

#### FR-005: Recursive Copy Support
- Support nested shared directory structures
- Preserve directory hierarchy in `partials.bak/`
- Handle both files and directories

### Non-Functional Requirements

#### NFR-001: Performance
- Wrapper execution must complete within 5 seconds for typical usage
- Minimal overhead for templates without shared partials
- Efficient file operations (avoid unnecessary copies)

#### NFR-002: Maintainability
- Single source of truth for shared partials logic
- Clear error messages for debugging
- Well-documented code and usage patterns

#### NFR-003: Compatibility
- Work with existing Copier versions (>= 9.0.0)
- No modifications to Copier itself required
- Preserve all existing wrapper script functionality

#### NFR-004: Git-Friendliness
- Generated `partials.bak/` directories must be ignored
- No accidental commits of generated content
- Clean working directory after wrapper execution

### Technical Requirements

#### TR-001: Script Location
- Universal wrapper at `boilerplate/copier-wrapper.sh`
- Replace existing Docker-specific wrapper
- Single entry point for all boilerplate operations

#### TR-002: Path Resolution
- Handle both absolute and relative template paths
- Support templates called from any directory
- Robust path normalization and validation

#### TR-003: Error Handling
- Graceful failure when shared directories don't exist
- Clear error messages for path resolution issues
- Non-zero exit codes for critical failures

#### TR-004: Logging
- Informative output showing which partials were copied
- Silent mode option for automated usage
- Debug mode for troubleshooting

## Implementation Plan

### Phase 1: Core Wrapper Enhancement (Week 1)
1. **Backup existing wrapper**: Move Docker wrapper to `copier-wrapper-docker.sh.bak`
2. **Create universal wrapper**: Implement auto-discovery and recursive copy
3. **Basic testing**: Verify Docker templates still work
4. **Add logging**: Implement informative output

### Phase 2: Shared Directory Structure (Week 2)
1. **Create `_shared/` directory**: Establish mirrored structure
2. **Migrate Docker shared partials**: Move from `_shared-partials/` to `_shared/apps/infrastructure/docker/`
3. **Add initial shared templates**: Create common configurations for TypeScript, ESLint, etc.
4. **Update documentation**: Reflect new structure in README files

### Phase 3: Template Integration (Week 3)
1. **Update existing templates**: Modify templates to use shared partials where beneficial
2. **Test integration**: Verify all updated templates work correctly
3. **Performance testing**: Ensure wrapper execution is efficient
4. **Create usage examples**: Document common patterns

### Phase 4: Validation and Documentation (Week 4)
1. **End-to-end testing**: Test entire boilerplate tree with wrapper
2. **Update AGENTS.md**: Document universal shared partials system
3. **Create migration guide**: Help template authors adopt shared partials
4. **Final review**: Ensure all requirements are met

## Benefits

### Immediate Benefits
- **DRY principle**: Eliminate code duplication across templates
- **Consistency**: Ensure common patterns are applied uniformly
- **Maintainability**: Single location to update shared configurations
- **Developer experience**: Easier to create new templates with shared foundations

### Long-term Benefits
- **Scalability**: New boilerplate categories can immediately benefit
- **Quality**: Shared partials can be reviewed and tested once
- **Innovation**: Easier to experiment with new patterns across multiple templates
- **Onboarding**: New developers can understand common patterns through shared partials

## Risks and Mitigations

### Risk 1: Performance Impact
- **Mitigation**: Efficient file operations, only copy when necessary
- **Monitoring**: Add timing metrics to wrapper script

### Risk 2: Complexity
- **Mitigation**: Clear documentation, simple usage patterns
- **Fallback**: Keep direct copier usage as an option

### Risk 3: Path Resolution Issues
- **Mitigation**: Robust path handling, comprehensive error messages
- **Testing**: Test from various working directories

### Risk 4: Template Coupling
- **Mitigation**: Clear scope definition, minimal shared dependencies
- **Documentation**: Guidelines for what should be shared vs. template-specific

## Alternatives Considered

### Alternative 1: Symlink Approach
- **Rejected**: Copier's Jinja2 sandbox cannot resolve symlinks
- **Evidence**: Current Docker implementation proves this doesn't work

### Alternative 2: Copier Plugin Development
- **Rejected**: Requires modifying Copier itself, complex maintenance
- **Evidence**: Wrapper approach works within existing limitations

### Alternative 3: External Template Engine
- **Rejected**: Adds complexity, loses Copier's features
- **Evidence**: Copier provides valuable prompting and project generation

## Future Enhancements

### Enhancement 1: Template Validation
- Validate that shared partials include statements are correct
- Warn about orphaned shared partials
- Suggest optimizations for template authors

### Enhancement 2: Shared Partial Versioning
- Support multiple versions of shared partials
- Allow templates to specify required shared partial version
- Backward compatibility for older templates

### Enhancement 3: Intelligent Copying
- Only copy shared partials that are actually used
- Track which shared partials are used by which templates
- Optimize performance for large boilerplate trees

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-01-31 | Adopt mirrored directory structure | Clear scope, intuitive discovery, scalable organization |
| 2025-01-31 | Use .bak suffix for generated directories | Already in .gitignore, proven pattern |
| 2025-01-31 | Implement auto-discovery | No manual configuration required |
| 2025-01-31 | Preserve existing Docker functionality | Backward compatibility, proven approach |

## References

- [ADR-20250123001: Shared Partials Wrapper](../apps/infrastructure/docker/internal-docs/adr/adr-20250123001-shared-partials-wrapper.md)
- [Boilerplate AGENTS.md](../AGENTS.md)
- [Copier Documentation](https://copier.readthedocs.io/)
- [Jinja2 Template Documentation](https://jinja.palletsprojects.com/)

<!-- vim: set ft=markdown: -->
