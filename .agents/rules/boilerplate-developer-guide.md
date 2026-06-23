# Boilerplate Developer Guide

This file contains the authoritative conventions for creating and modifying boilerplate templates in the levonk-base-boilerplate repository.

## Template Generation

- **Always use `copier-wrapper.sh`** to create boilerplates - this script properly recreates the `partials.bak/` directory and handles shared partials
- **Never use copier directly** - the wrapper script is required for proper template resolution

## File Structure and Naming

### Template Files
- **File extensions**: Use `.jinja` extension for all template files that require variable expansion
- **Workflow files**: Place all workflow files in `.agents/workflows/`
- **Rule files**: Place all rule files in `.agents/rules/`

### Configuration Files
- **Copier configuration**: Use `copier.yml` (not `copier.yaml`) for all Copier configuration files
- **File paths**: Use the `files/` directory in `copier.yml` to hold boilerplate files

## File Operations

- **Renaming/moving files**: Use `git mv` when renaming or moving version-controlled files to preserve git history
- **Never use regular mv or cp** - this breaks git tracking

## DRY Principles and Shared Content

The boilerplate system uses two directories for content sharing:

- **`_shared/`**: Source directory for shared templates and partials - **write all shared content here**
- **`partials.bak/`**: Generated directory recreated by `copier-wrapper.sh` - **NEVER write here directly**

### Why This Structure Exists

- **Avoid duplication**: Shared content lives in one place (`_shared/`)
- **Template resolution**: `copier-wrapper.sh` generates `partials.bak/` from `_shared/` before template execution
- **Clean separation**: Source content vs. generated content

### Content Placement Rules

- **ALWAYS write shared content to `_shared/`** - this is the source of truth
- **NEVER write content directly to `partials.bak/`** - this directory is nuked and recreated by the wrapper script
- **Reference shared partials** from individual templates using the appropriate include syntax

## Variable Naming Conventions

Different boilerplate templates use different variable names in their `copier.yml` files. When creating workflow templates or other files that reference project names, use the variable name that matches the template:

- **`package_name`**: Used in most package templates (typescript, go, bash, swift, python3, web packages)
- **`project_name`**: Used in CLI and infrastructure templates (rust, java, kotlin, powershell, csharp, ruby, kustomize, docker, argocd, fluxcd, airflow, ansible, bootc, gitops, helm, packer)
- **`extension_name`**: Used in VSCode extension templates
- **`service_name`**: Used in FastAPI backend templates

## Template Quality Standards

- **Consistency**: Follow existing patterns in similar templates
- **Completeness**: Include all necessary files for a production-ready starting point
- **Documentation**: Include clear comments and documentation where needed
- **Testing**: Ensure templates can be successfully materialized with copier-wrapper.sh

## Directory Structure

```
boilerplate/
├── apps/                          # Application templates
│   ├── flutter/                   # Cross-platform mobile apps
│   ├── infrastructure/            # Backend services & infrastructure
│   │   ├── airflow-project/       # Apache Airflow DAG projects
│   │   ├── airflow-node/          # Containerized task images for Airflow
│   │   ├── ai-ollama-samples/     # LLM/Ollama integration examples
│   │   └── docker/                # Docker & container templates
│   ├── mobile/                    # Native mobile apps
│   │   ├── kotlin-android/
│   │   ├── react-native/
│   │   └── swift-ios/
│   ├── plugins/                   # Browser extensions, VSCode, MCP servers
│   ├── web/                       # Web applications
│   │   └── typescript/
│   │       └── nextjs/            # Next.js + TypeScript apps
│   └── internal-docs/             # Documentation about app templates
│
├── packages/                      # Reusable library templates
│   └── category/
│       └── web/
│           └── domain/
│               └── package-name/
│                   ├── python3/    # Python packages (logical template root)
│                   └── typescript/ # TypeScript packages (logical template root)
│
├── _shared/                       # Global shared templates and partials
│   ├── partials/
│   │   ├── nx-partials/           # Nx monorepo configuration partials
│   │   └── devbox-partials/       # Devbox configuration partials
│   └── nx.json.template.jinja     # Base Nx workspace configuration
│
└── internal-docs/                 # Boilerplate system documentation
    └── adr/
        └── adr-20260419001-nx-monorepo-build-tool.md  # Nx adoption decision
```

## Copier Configuration Requirements

All `copier.yml` files must include:

### Required Sections
- **`_subdirectory`**: Must point to the template subdirectory (typically `files/`)
- **`_migrations`**: Migration rules for template version changes
- **`_exclude`**: Files to exclude from template generation
- **`questions`**: All required template variables with proper validation

### Question Requirements
- **Type safety**: Specify types for all questions (str, int, bool, etc.)
- **Validation**: Use `validate` field for complex validation logic
- **Defaults**: Provide sensible defaults where appropriate
- **Help text**: Include `help` field explaining each variable

### Example copier.yml Structure

```yaml
_subdirectory: files
_migrations:
  - version: 1.0.0
    before:
      - migration_script.py
_exclude:
  - "*.bak"
  - "partials.bak/**"
questions:
  - name: project_name
    type: str
    help: The name of the project
    default: my-project
    validate: /^[a-z][a-z0-9-]*$/
```

## Nx Monorepo Integration

All boilerplate templates include **Nx monorepo build orchestration** support. Nx is the unified build system for the monorepo, providing:

- **Polyglot build support**: JavaScript/TypeScript, Docker, Python, Rust, and more
- **Computation caching**: Build artifacts cached across all technologies
- **Task orchestration**: Dependency-aware task scheduling
- **Unified developer experience**: Consistent commands across all project types

### Nx Configuration in Templates

Each generated project includes Nx configuration:

- **`nx.json`**: Workspace-level configuration (generated from `_shared/nx.json.template.jinja`)
- **`project.json`**: Project-specific tasks and targets (or `nx` key in `package.json`)
- **Nx plugins**: Technology-specific plugins (`@nx/js`, `@nx/docker`, `@nx/python`, etc.)

### Shared Nx Partials

The boilerplate system includes reusable Nx configuration partials in `_shared/partials/nx-partials/`:

#### Core Configuration
- `nx-base-config.jinja`: Base Nx workspace configuration
- `nx-packages-core.jinja`: Core package definitions

#### Technology-Specific Packages
- `nx-packages-docker.jinja`: Docker build packages
- `nx-packages-nodejs.jinja`: Node.js/TypeScript packages
- `nx-packages-python.jinja`: Python packages

#### Technology-Specific Plugins
- `nx-plugins-docker.jinja`: Docker plugin configuration
- `nx-plugins-nodejs.jinja`: Node.js plugin configuration
- `nx-plugins-python.jinja`: Python plugin configuration

#### Target Definitions
- `nx-target-docker-build.jinja`: Docker build target
- `nx-target-docker-compose.jinja`: Docker Compose target
- `nx-target-nextjs-build.jinja`: Next.js build target
- `nx-target-nextjs-dev.jinja`: Next.js dev server target
- `nx-target-nodejs-lint.jinja`: Node.js linting target
- `nx-target-nodejs-test.jinja`: Node.js testing target
- `nx-target-python-lint.jinja`: Python linting target
- `nx-target-python-serve.jinja`: Python serve target
- `nx-target-python-test.jinja`: Python testing target

### Template-Specific Nx Configuration

Different template types include appropriate Nx configuration:

- **TypeScript/Next.js apps**: `@nx/next` plugin with build/dev/test targets
- **Docker services**: `@nx/docker` plugin with build/compose targets
- **Python services**: Python plugin with lint/test/serve targets
- **CLI tools**: Node.js or language-specific plugins with appropriate targets

### For Template Authors

When creating or modifying boilerplate templates:

1. **Include Nx configuration**: Add `nx.json.jinja` or use shared partials
2. **Define project targets**: Create `project.json.jinja` with appropriate targets
3. **Use shared partials**: Include relevant Nx partials from `_shared/partials/nx-partials/`
4. **Test Nx integration**: Verify `nx build`, `nx test`, and other targets work correctly
5. **Document Nx usage**: Include Nx-specific commands in the generated README

### References

- [Nx Documentation](https://nx.dev)
- [ADR: Nx Monorepo Build Tool](../internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md)
- [Nx Plugin Ecosystem](https://nx.dev/packages)

## Shared Partials System

### Overview

The boilerplate system includes a **shared partials solution** that allows multiple Copier templates to reuse common Jinja2 partials. This addresses Copier's limitations with template includes:

- **Symlinks don't work**: Copier's Jinja2 sandbox cannot resolve symlinks to templates
- **Relative parent/sibling paths don't work**: Copier only searches within the template subdirectory
- **External paths don't work**: Copier's template rendering is sandboxed to the template directory

### Current Implementation

The boilerplate system uses a **wrapper script approach**:

```bash
# Instead of running copier directly:
./copier-wrapper.sh copy [template-name] /tmp/my-project --defaults
```

The wrapper script:
1. **Copies shared partials** from `_shared/` to each template's `partials.bak/` directory
2. **Runs Copier** with all provided arguments
3. **Ensures fresh copies** by removing and recreating partials each time

### Example Usage in Templates

```jinja
{% include "partials.bak/shared-header.jinja" %}

# Your template content here

{% include "partials.bak/shared-footer.jinja" %}
```

## Jinja Syntax Guidelines

### Variable Usage
- Use `{{ variable_name }}` for variable interpolation
- Use `{% if %}` blocks for conditional logic
- Use `{% for %}` loops for iteration

### Filters
- Use standard Jinja filters: `| upper`, `| lower`, `| replace()`, etc.
- Create custom filters in template preprocessing if needed

### Best Practices
- **Indentation**: Match Jinja indentation with target file indentation
- **Whitespace control**: Use `{%-` and `-%}` to control whitespace
- **Comments**: Use `{# comment #}` for Jinja comments (removed from output)
- **Safety**: Always validate user input in copier.yml questions

## Testing Boilerplates

### Manual Testing

1. **Create test answers file**:
   ```bash
   cat > test-answers.yml <<EOF
   project_name: test-project
   # Add all required variables
   EOF
   ```

2. **Generate test project**:
   ```bash
   devbox run -- rtk ./boilerplate/copier-wrapper.sh copy \
     ./boilerplate/[template-path] \
     /tmp/test-project \
     --data @test-answers.yml
   ```

3. **Verify output**:
   - Check all files are generated correctly
   - Verify variable substitution works
   - Test Nx commands if applicable
   - Check for any Jinja syntax errors

### Automated Testing

Consider adding automated tests for critical templates:
- Test basic template generation
- Test variable substitution
- Test Nx integration
- Test shared partials inclusion

## Ticket Tracking

This project uses the **tkr** tool (<https://github.com/levonk/tkr>) for ticket tracking and task management. When working on boilerplate improvements or new templates:

- **Track your work**: Create tickets for boilerplate enhancements using `tkr`
- **Follow the workflow**: Use `tkr ready` to get the next actionable ticket, `tkr start` to begin work
- **Document changes**: Update tickets with notes about template improvements or issues found
- **Maintain quality**: Ensure all boilerplate work is tracked and reviewed through the ticket system

## ADR References

When making architectural decisions about boilerplate templates, reference existing ADRs:

- **[ADR-20260419001: Nx Monorepo Build Tool](../internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md)** - Decision to adopt Nx for build orchestration
- **[ADR-20251014002: Application Organization](../internal-docs/adr/adr-20251014002-application-organization.md)** - Application structure and organization
- **[ADR-20250926001: Package Organization](../internal-docs/adr/adr-20250926001-package-organization.md)** - Package structure and organization