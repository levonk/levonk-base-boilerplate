---
title: "ADR-20250123001: Shared Templates in Copier via Wrapper Script with Mirrored Structure"
status: "accepted"
decision-date: 2025-01-23
authors:
  - https://github.com/levonk
---

# Shared Templates in Copier via Wrapper Script with Mirrored Structure

## Context

When creating multiple Copier templates across the monorepo, we needed to share common templates (like Dockerfiles, configuration files, and partials) across different boilerplate categories to avoid duplication and maintain consistency.

### Problem Statement

Copier has several limitations that prevent straightforward sharing of templates:

1. **Symlinks don't work**: Copier's Jinja2 sandbox cannot resolve symlinks to templates outside the template directory
2. **Relative parent/sibling paths don't work**: Copier only searches for templates within the specified `_subdirectory`
3. **External paths don't work**: Copier's template rendering is sandboxed to the template directory for security
4. **Directories starting with `_` are special**: Copier treats directories starting with underscore specially (they're not copied to output but are available for includes)

### Previous Attempts

1. **Direct external includes**: `{% include "../../shared/common-header" %}` - Failed with `TemplateNotFound`
2. **Symlinks to shared directory**: Created `_partials` as symlinks to external shared directory - Failed with `TemplateNotFound`
3. **Absolute paths**: `{% include "/absolute/path/to/shared" %}` - Failed with `TemplateNotFound`
4. **Relative paths within template**: `{% include "../shared/common-header" %}` - Failed because it goes outside the `_subdirectory`

## Decision

We implemented a **wrapper script approach with mirrored directory structure** that:

1. **Mirrors the boilerplate hierarchy**: A `_shared/` directory exactly mirrors the `boilerplate/` structure, making the scope and organization intuitive
2. **Copies shared templates**: From the appropriate `_shared/` subdirectory into each template's `files/partials.bak/` directory
3. **Runs before Copier**: The wrapper script executes the copy operation before invoking the actual `copier` command
4. **Supports whole files**: Not just partials - entire files like Dockerfiles, config files, and manifests can be shared
5. **Maintains single source of truth**: Shared templates live in one central location with clear scope

### Proposed Mirrored Structure

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
│   │   └── mobile/                # Mobile app shared templates
│   │       ├── kotlin-android/
│   │       │   └── build.gradle.jinja
│   │       └── react-native/
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

### Implementation Details

```bash
# copier-wrapper.sh (enhanced for mirrored structure)
copy_shared_templates() {
    local template_dir="$1"
    local target_dir="$template_dir/files/partials.bak"

    # Determine shared source based on template location
    local relative_path="${template_dir#$BOILERPLATE_ROOT/}"
    local shared_source="$BOILERPLATE_ROOT/_shared/$relative_path"

    # Remove existing copies
    rm -rf "$target_dir" 2>/dev/null || true

    # Create fresh directory and copy files
    mkdir -p "$target_dir"
    if [ -d "$shared_source" ]; then
        cp -r "$shared_source"/* "$target_dir/"
    fi

    # Also copy parent-level shared templates (for inheritance)
    local parent_path=$(dirname "$relative_path")
    while [ "$parent_path" != "." ]; do
        local parent_shared="$BOILERPLATE_ROOT/_shared/$parent_path"
        if [ -d "$parent_shared" ]; then
            cp -r "$parent_shared"/* "$target_dir/"
        fi
        parent_path=$(dirname "$parent_path")
    done
}
```

Templates then include shared files using:
```jinja
{# Complete file sharing #}
{% include "partials.bak/Dockerfile.base.jinja" %}

{# Partial sharing #}
{% include "partials.bak/docker-header.jinja" %}

{# Multi-file composition #}
{% include "partials.bak/deployment.yaml.jinja" %}
---
{% include "partials.bak/service.yaml.jinja" %}
```

## Consequences

### Positive

- **Clear scope and organization**: The mirrored structure makes it immediately obvious where each shared template will be used
- **Intuitive discovery**: Developers can find shared templates by following the same structure they're used to
- **DRY principle achieved**: Shared templates are defined once and reused across the entire boilerplate system
- **Consistent updates**: Changes to shared templates are reflected in all dependent templates
- **Whole file support**: Can share complete Dockerfiles, config files, not just partials
- **Hierarchical inheritance**: Templates can inherit from parent-level shared files
- **Scalable organization**: Each boilerplate category has its own dedicated shared space
- **Works within Copier limitations**: Doesn't require modifying Copier itself
- **Fresh copies guaranteed**: Each run ensures templates are up-to-date

### Negative

- **Additional step**: Requires using the wrapper script instead of direct `copier` command
- **Disk space**: Creates copies of shared templates for each template (minimal impact)
- **Slight overhead**: Copy operation adds small delay before template generation
- **Learning curve**: Developers need to understand the mirrored structure concept

### Neutral

- **Directory naming**: Uses `partials.bak` to avoid conflicts and make it clear these are generated copies
- **Git integration**: `partials.bak/` is added to `.gitignore` to avoid committing generated copies
- **Naming convention**: Uses `.jinja` suffix for all shared templates that need rendering

## Related Decisions

- [ADR-20251014002: Application Organization](../../../internal-docs/adr/adr-20251014002-application-organization.md) - Defines the structure of boilerplate templates
- [ADR-20250926001: Package Path Modifier](../../../internal-docs/adr/adr-20251016001-package-path-modifier.md) - Copier template organization patterns

## Usage

```bash
# Use the wrapper script instead of direct copier
./copier-wrapper.sh copy docker-linux /tmp/my-project --defaults

# The wrapper automatically:
# 1. Determines shared template source from _shared/apps/infrastructure/docker/
# 2. Copies to template/partials.bak/
# 3. Runs copier with all arguments
# 4. Ensures partials.bak/ is not copied to final output
```

## Future Considerations

1. **Copier enhancement**: If Copier adds support for external template includes, this approach could be simplified
2. **Template inheritance**: Could explore Copier's template inheritance features if they mature
3. **Template versioning**: Could add versioning to shared templates for backward compatibility
4. **Automated testing**: Could add automated tests to ensure shared templates work correctly across templates
5. **Cross-category sharing**: The mirrored structure allows for potential sharing between different categories (e.g., common CI/CD templates)
6. **Template discovery**: Enhanced wrapper could auto-discover and suggest available shared templates based on context

## Implementation Status

- ✅ Wrapper script created with comprehensive comments
- ✅ Current shared partials directory structure established for Docker templates
- ✅ .gitignore updated to exclude generated `partials.bak/` directories
- ✅ Example partials created (docker-header, docker-footer)
- ✅ Tested in experimental environment
- 📋 Mirrored directory structure designed and documented
- 📋 Enhanced wrapper script logic planned for hierarchical inheritance
- 📋 Migration strategy defined for expanding to all boilerplate categories

This approach provides a robust, scalable solution for sharing templates across the entire Copier boilerplate system while working within the tool's current limitations and providing clear organization through the mirrored directory structure.
