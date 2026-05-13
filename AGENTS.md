---
modeline: "vim: set ft=markdown:"
title: "Boilerplate: Project Scaffolding Templates"
slug: boilerplate-project-scaffolding
url: {url-to-be-added-after-commit}
synopsis: Copier-based templates for rapidly scaffolding production-ready projects across the monorepo.
author: https://github.com/levonk
date-created: 2025-10-08
date-updated: 2025-11-22
version: 2.0.0
status: "accepted"
aliases: ["template-catalog", "project-templates"]
tags: [doc/templates, scaffolding, copier, jinja]
related-to: ["adr-20251014002-application-organization", "adr-20250926001-package-organization"]
---

# Boilerplate: Project Scaffolding with Copier

## What is This Directory?

This directory contains **Copier templates** that scaffold production-ready projects across the monorepo. When you need to create a new application, service, or package, you use these templates to generate a complete, well-structured starting point with all the expected deliverables.

### Quick Start for Engineers

When asked to "make a new **boilerplate** for [project type]", you:

1. **Find the matching template** in this directory (e.g., `apps/infrastructure/airflow-project`)
2. **Prepare copier answers** (for non-interactive usage):
   ```bash
   # Create an answers file with all required values
   cat > copier-answers.yml <<EOF
   project_name: my-project
   project_slug: my-project
   description: "A project description"
   # Add all other required template variables
   EOF
   ```
3. **Run copier-wrapper.sh** (NOT copier directly) to generate your project:
   ```bash
   devbox run -- ./boilerplate/copier-wrapper.sh copy \
     ./boilerplate/apps/infrastructure/airflow-project \
     ./path/to/new-project \
     --data @copier-answers.yml
   ```
4. **Deliver the generated project** with all required files ready to go

**IMPORTANT: Always use copier-wrapper.sh, never copier directly** - the wrapper handles shared partials and other template-specific setup.

### Ticket Tracking

This project uses the **tkr** tool (<https://github.com/levonk/tkr>) for ticket tracking and task management. When working on boilerplate improvements or new templates:

- **Track your work**: Create tickets for boilerplate enhancements using `tkr`
- **Follow the workflow**: Use `tkr ready` to get the next actionable ticket, `tkr start` to begin work
- **Document changes**: Update tickets with notes about template improvements or issues found
- **Maintain quality**: Ensure all boilerplate work is tracked and reviewed through the ticket system

---

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
│   │       ├── _shared-partials/  # Shared Jinja2 partials (Docker)
│   │       ├── copier-wrapper.sh   # Wrapper script for shared partials
│   │       └── test-template/      # Example using shared partials
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
└── internal-docs/                 # Boilerplate system documentation
```

---

## 🧩 Shared Partials System

### Overview

The boilerplate system includes a **shared partials solution** that allows multiple Copier templates to reuse common Jinja2 partials. This addresses Copier's limitations with template includes:

- **Symlinks don't work**: Copier's Jinja2 sandbox cannot resolve symlinks to templates
- **Relative parent/sibling paths don't work**: Copier only searches within the template subdirectory
- **External paths don't work**: Copier's template rendering is sandboxed to the template directory

### Current Implementation (Docker Templates)

The Docker templates (`apps/infrastructure/docker/`) use a **wrapper script approach**:

```bash
# Instead of running copier directly:
./copier-wrapper.sh copy docker-linux /tmp/my-project --defaults
```

The wrapper script:
1. **Copies shared partials** from `_shared-partials/` to each template's `partials.bak/` directory
2. **Runs Copier** with all provided arguments
3. **Ensures fresh copies** by removing and recreating partials each time

#### Example Usage in Templates

```jinja
{% include "partials.bak/docker-header.jinja" %}

# Your template content here

{% include "partials.bak/docker-footer.jinja" %}
```

### Future Expansion Plans

This pattern is designed to expand across all boilerplate categories using a **mirrored directory structure** that maintains the same hierarchy as the boilerplates themselves:

#### Proposed Structure: Mirrored Hierarchy

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

#### Benefits of Mirrored Structure

- **Clear Scope**: The exact path in `_shared/` shows where a template will be used
- **Intuitive Discovery**: Developers can easily find shared templates by following the same structure
- **Scalable Organization**: Each boilerplate category has its own shared space
- **Whole Files Support**: Not just partials - entire files can be shared (e.g., complete Dockerfiles, config files)
- **Hierarchical Overrides**: More specific levels can override or extend general templates

#### Example Usage Patterns

**1. Complete File Sharing**
```jinja
{# In docker-linux/files/Dockerfile.jinja #}
{% include "partials.bak/Dockerfile.base.jinja" %}

# Add runtime-specific customizations below
RUN useradd -m appuser
USER appuser
```

**2. Configuration File Sharing**
```jinja
{# In nextjs/files/next.config.js.jinja #}
{% include "partials.bak/next.config.js.jinja" %}

# Add project-specific configuration
module.exports = {
  ...sharedConfig,
  experimental: {
    appDir: true,
  },
};
```

**3. Multi-file Composition**
```jinja
{# In k8s-deployment/files/k8s.yaml.jinja #}
{% include "partials.bak/deployment.yaml.jinja" %}

---
{% include "partials.bak/service.yaml.jinja" %}
```

#### Implementation Strategy

1. **Gradual Migration**: Start with Docker templates, then expand to other categories
2. **Wrapper Script Enhancement**: Update `copier-wrapper.sh` to handle the mirrored structure
3. **Template Discovery**: The wrapper could auto-discover shared files based on template location
4. **Naming Convention**: Use `.jinja` suffix for all shared templates that need rendering

### Benefits

- **DRY principle**: Shared partials defined once and reused
- **Consistent updates**: Changes reflected in all templates
- **Works within Copier limitations**: No modifications to Copier required
- **Fresh copies guaranteed**: Each run ensures up-to-date partials
- **Scalable**: Can expand to other boilerplate categories
- **Git-friendly**: Generated `partials.bak/` directories excluded from version control

### Implementation Details

See `apps/infrastructure/docker/internal-docs/adr/adr-20250123001-shared-partials-wrapper.md` for the complete technical decision record.

---

## What Each Template Provides

Every template is a **Copier project** that generates a complete, production-ready structure. When you run `copier copy`, it:

1. **Prompts you for inputs** (defined in `copier.yaml`)
2. **Renders Jinja2 templates** (files ending in `.jinja`)
3. **Generates your project** with all files in place

### Standard Deliverables in Every Template

Each generated project includes:

- **`README.md`** — Usage guide, setup instructions, and examples
- **`docs/`** — Detailed documentation (architecture, design decisions, troubleshooting)
- **`internal-docs/`** — Project-specific ADRs (Architecture Decision Records) and feature specs
- **`src/` or equivalent** — Source code organized by domain/feature
- **`tests/`** — Test files (`.test.mts` for TypeScript, following project conventions)
- **`package.json` / `pyproject.toml` / equivalent** — Dependency management with pinned versions
- **`Dockerfile` / `docker-compose.yml` (if applicable)** — Container definitions
- **`.gitignore`, `.eslintrc`, build configs** — Tooling and CI/CD ready
- **Adapter mocks** — Mock implementations for testing (when applicable)

---

## How Templates Work: Copier + Jinja2

### Template Files

Templates use **Jinja2 syntax** to make files dynamic:

- Files ending in `.jinja` are rendered during project generation
- Variables are replaced with user inputs (e.g., `{{ project_name }}`)
- Conditional logic allows optional sections (e.g., `{% if include_tests %} ... {% endif %}`)

**Example:**
```
files/
├── README.md.jinja              # Rendered with project name
├── src/
│   └── {{ module_name }}.ts.jinja  # Rendered with module name
└── package.json.jinja           # Rendered with version, description
```

### Configuration: `copier.yaml`

Each template has a `copier.yaml` that defines:
- Input prompts (what questions to ask the user)
- Template suffix (`.jinja` by default)
- Subdirectory where template files live (`files/` by default)

**Example:**
```yaml
_min_copier_version: "9.0.0"
_subdirectory: files
_templates_suffix: .jinja

project_name:
  type: str
  help: "Project name (kebab-case)"
  default: "my-project"

include_tests:
  type: bool
  help: "Generate test files?"
  default: true
```

---

## Editing Jinja-Templated Files

### The Challenge with Traditional Tools

**Jinja-templated structured files** (files ending in `.jinja` that contain structured data like JSON, YAML, or TOML) present a unique challenge for traditional editing tools:

- **Template syntax breaks parsers**: JSON/YAML/TOML parsers fail when they encounter `{{ variable }}` or `{% if %}` blocks
- **Structure is obscured**: The template syntax makes it difficult to understand the actual data structure
- **Direct editing is risky**: Manual edits can break template syntax or structure
- **Tool limitations**: Standard editors and parsers cannot handle the hybrid format

### Solution: Use Surgical Configuration Management

For editing Jinja-templated configuration files, use the **surgical-config** skill:

**Skill location**: `https://github.com/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/software-dev/surgical-config`

#### Why Surgical Config?

The surgical-config skill provides:

1. **Template-aware processing**: Automatically detects and handles `.jinja` templated files
2. **Semantic preservation**: Maintains comments, formatting, and structure
3. **Tiered tool hierarchy**: Uses the right tool for the job (semantic parsers → structural rewriters → text utilities)
4. **Non-destructive edits**: Additive modifications that don't overwrite existing content
5. **Idempotent operations**: Safe to run multiple times

#### Example: Using Surgical Config

```bash
# Use the surgical-config skill to modify templated files safely
./skills/surgical-config/scripts/surgical-edit.sh \
  --file devbox.json.jinja \
  --operation '.packages += ["nodejs", "typescript"]'

# The skill automatically handles template processing and applies the change
```

#### Example: Docker Configuration Updates

```bash
# For docker-compose.yml.jinja files, let the skill handle the complexity
./skills/surgical-config/scripts/surgical-edit.sh \
  --file docker-compose.yml.jinja \
  --operation '.services.web.environment += {"NODE_ENV": "production"}'
```

#### How Surgical Config Works

The surgical-config skill automatically handles the complexity of Jinja-templated files through its **tiered tool hierarchy**:

1. **Template Detection**: Automatically identifies `.jinja` files and routes them through template processors
2. **Semantic Parsing**: Uses format-aware tools (like `yq-go`) that understand the underlying structure
3. **Structure Preservation**: Maintains comments, formatting, and template syntax automatically
4. **Built-in Validation**: Ensures both template syntax and structure remain valid

**No manual template extraction/reapplication needed** - the skill handles this internally!

#### Best Practices

- **Always use surgical-config** for `.jinja` files instead of direct editing
- **Prefer semantic operations** (yq-go) over text replacements
- **Test template rendering** after modifications to ensure validity
- **Back up before editing** - the skill provides automatic backups

---

## Creating a New Boilerplate Template

When you're asked to "make a new boilerplate for [something]", follow this checklist:

### 1. Create the Template Directory

```bash
mkdir -p boilerplate/apps/infrastructure/my-new-project/files
```

### 2. Create `copier.yaml`

Define the inputs your template needs:

```yaml
_min_copier_version: "9.0.0"
_subdirectory: files
_templates_suffix: .jinja

project_name:
  type: str
  help: "Project name (kebab-case)"
  default: "my-project"

project_description:
  type: str
  help: "Short description of the project"
  default: "A new project"
```

### 3. Create Template Files in `files/`

All files in `files/` are copied to the generated project. Use `.jinja` suffix for files that need rendering:

```
files/
├── README.md.jinja
├── package.json.jinja
├── src/
│   └── index.ts.jinja
└── tests/
    └── index.test.mts.jinja
```

### 4. Use Jinja2 Variables in Files

In any `.jinja` file, reference user inputs:

```markdown
# {{ project_name }}

{{ project_description }}
```

### 5. Create `README.md` (Not in `files/`)

Document the template itself (not the generated project):

```markdown
# My New Project Boilerplate

Scaffolds a new [project type] with [key features].

## Usage

\`\`\`bash
copier copy ./boilerplate/apps/infrastructure/my-new-project ./path/to/project
\`\`\`

## Inputs

- `project_name`: Project name (kebab-case)
- `project_description`: Short description

## Notes

- [Any special setup or configuration notes]
```

### 6. Ensure All Deliverables Are Included

Your template's `files/` directory must include:

- ✅ `README.md.jinja` — Generated project's README
- ✅ `docs/` — Documentation templates
- ✅ `internal-docs/` — ADRs and specs
- ✅ `src/` or `app/` — Source code structure
- ✅ `tests/` — Test file templates (`.test.mts` for TypeScript)
- ✅ `package.json.jinja` or equivalent — Dependency management
- ✅ `.gitignore`, `.eslintrc`, build configs — Tooling
- ✅ `Dockerfile` (if containerized) — Container definition
- ✅ Adapter mocks (if applicable) — Mock implementations

### 7. Test Your Template

Generate a test project to verify everything works:

```bash
# Create an answers file for testing
cat > /tmp/test-answers.yml <<EOF
project_name: test-project
project_slug: test-project
description: "A test project"
# Add all other required template variables
EOF

# Use copier-wrapper.sh with devbox for testing
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  ./boilerplate/apps/infrastructure/my-new-project \
  /tmp/test-project \
  --data @/tmp/test-answers.yml

cd /tmp/test-project
# Verify the structure and files are correct
```

---

## Existing Templates

### Infrastructure Templates

**`apps/infrastructure/airflow-project/`**
- Scaffolds Apache Airflow DAG projects
- Includes example DAG, requirements, and Kubernetes executor config
- Inputs: `project_name`, `dag_id`, `ollama_base_url`, `ollama_model`

**`apps/infrastructure/airflow-node/`**
- Scaffolds containerized task images for Airflow
- Used by `airflow-project` for task execution

**`apps/infrastructure/ai-ollama-samples/`**
- LLM/Ollama integration examples

**`apps/infrastructure/docker/`**
- Docker container templates with **shared partials system**
- Uses `copier-wrapper.sh` for partial management
- Includes `_shared-partials/` with common Docker configurations
- See [Shared Partials System](#-shared-partials-system) for details

**`apps/infrastructure/docker/paperclip/`**
- Scaffolds a Docker-based deployment of Paperclip (AI orchestration platform)
- Multi-stage Dockerfile with Alpine or Debian base images
- Includes PostgreSQL container via docker-compose
- Inputs: `base_os`, `node_version`, `pnpm_version`, `service_port`, `include_postgres`
- Generates: Dockerfile, docker-compose.yml, README.md, .envrc, .env.example

### Package Templates

> **Note**: Generated packages live under `packages/{active|icebox}/...`.
> The boilerplate paths are logical templates that map into that structure.

**Logical template root**: `boilerplate/packages/category/web/domain/package-name/typescript/`

This template is used to scaffold packages that will ultimately be created in
paths such as:

- `packages/active/core/node/logging/client/typescript`
- `packages/active/features/web/auth/auth-ui/typescript`
- `packages/active/tests/mocks/windhawk/clang` (for native/clang helpers)

The template:

- Scaffolds reusable TypeScript (and other) packages
- Inputs: `package_name`, `package_description`, `category`, `domain`
- Generates: src, tests, docs, ESLint config, TypeScript config

---

### Best Practices

### For Template Authors

- **Keep templates simple**: Focus on the essential structure; avoid over-engineering
- **Use sensible defaults**: Provide good defaults for all inputs
- **Document the template**: Write a clear `README.md` explaining what the template does
- **Test thoroughly**: Generate a test project and verify all files are correct
- **Include examples**: Provide working example code in the generated project
- **Use Jinja2 conditionals**: Make optional sections (e.g., `{% if include_docker %} ... {% endif %}`)
- **Consider shared partials**: For common patterns, use the shared partials system
- **ALWAYS use pnpm**: Never use npm in any template, script, or documentation
- **NEVER work in /tmp**: Always make changes directly in the boilerplate templates, not in temporary directories

### For Template Users

- **Read the template's README**: Understand what inputs are needed
- **Use kebab-case for names**: Consistency across the monorepo
- **Follow the generated structure**: Don't reorganize files after generation
- **Commit the generated project**: Include all generated files in your commit
- **Update docs after generation**: Customize `README.md` and `docs/` with project-specific details
- **Use wrapper scripts**: When available, use provided wrapper scripts (e.g., `copier-wrapper.sh`)
- **ALWAYS use pnpm**: The project specifies `"packageManager": "pnpm@*"` - never use npm
- **Test in real projects**: Validate materialized projects work with actual pnpm installation

---

## Running Copier

### Prerequisites

**Always use devbox** - copier is installed via devbox, not pip or other methods:

```bash
# From the job-aide repository root
devbox run -- ./boilerplate/copier-wrapper.sh copy <template-path> <output-path> [options]
```

### Non-Interactive Usage (Answer Files)

**CRITICAL**: For AI agents and automated systems, ALWAYS use answer files to avoid interactive prompts that can freeze execution:

```bash
# Create an answers file with all required values
cat > copier-answers.yml <<EOF
project_name: my-project
project_slug: my-project
description: "A project description"
# Add all other required template variables
EOF

# Use the answers file
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  <template-path> <output-path> \
  --data @copier-answers.yml
```

**Alternative: Use --defaults flag** (only works if all prompts have defaults):
```bash
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  <template-path> <output-path> \
  --defaults
```

### Generate a New Project

```bash
# Example: Create a browser extension with answer file
cat > copier-answers.yml <<EOF
package_name: my-extension
display_name: "My Extension"
description: "Description here"
author_name: "Developer"
author_email: "dev@example.com"
EOF

devbox run -- ./boilerplate/copier-wrapper.sh copy \
  apps/plugins/browser-extension \
  ./apps/active/plugin/browser/my-extension \
  --data @copier-answers.yml
```

### Using Shared Partials (All Templates with includes)

The `copier-wrapper.sh` automatically handles shared partials from `_shared/` directory:

```bash
# The wrapper copies _shared/ contents to partials.bak/ before running copier
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  apps/infrastructure/docker/docker-linux \
  /tmp/my-project \
  --defaults
```

### Update an Existing Project (if template changes)

```bash
# Use copier-wrapper.sh for updates too
devbox run -- ./boilerplate/copier-wrapper.sh update --vcs-ref=HEAD ./path/to/existing-project
```

### Dry Run (Preview Changes)

```bash
devbox run -- ./boilerplate/copier-wrapper.sh copy --defaults \
  ./boilerplate/apps/infrastructure/airflow-project \
  /tmp/preview
```

### Testing Templates with just

For CLI templates, use the project's justfile for testing:

```bash
# After generating a project, cd into it and use just
cd /tmp/test-project
devbox run -- just test-internal  # Run tests in devbox environment
```

The `just test-internal` command ensures tests run in the proper devbox environment with all dependencies available.

---

## Troubleshooting

### Template Not Found

Ensure the path is correct and the `copier.yaml` exists:
```bash
ls -la ./boilerplate/apps/infrastructure/my-template/copier.yaml
```

### Jinja2 Rendering Errors

Check for syntax errors in `.jinja` files:
- Missing `{{ }}` or `{% %}`
- Undefined variables (ensure they're defined in `copier.yaml`)
- Mismatched `{% if %} ... {% endif %}`

### Shared Partials Not Found / TemplateNotFound Error

If you see `jinja2.exceptions.TemplateNotFound: 'partials.bak/...'`:

1. **Use the wrapper script via devbox** (not direct copier):
   ```bash
   devbox run -- ./boilerplate/copier-wrapper.sh copy <template> <output>
   ```

2. **Do NOT run copier directly** - it won't copy the shared partials:
   ```bash
   # ❌ WRONG - will fail for templates with includes
   copier copy ./boilerplate/apps/plugins/browser-extension ./my-extension
   
   # ✅ CORRECT - use the wrapper via devbox
   devbox run -- ./boilerplate/copier-wrapper.sh copy apps/plugins/browser-extension ./my-extension
   ```

3. **Check wrapper copied hidden files**: The wrapper now copies ALL files including hidden (`.envrc.jinja`, etc.)

4. **Verify copier is available via devbox**:
   ```bash
   devbox run -- which copier
   # Should show path like /nix/store/.../bin/copier
   ```

### Generated Files Have Wrong Names

Ensure `.jinja` suffix is on files that need rendering. Files without `.jinja` are copied as-is.

---

## References

- [Copier Documentation](https://copier.readthedocs.io/)
- [Jinja2 Template Syntax](https://jinja.palletsprojects.com/templates/)
- [ARCHITECTURE: Monorepo Structure](../internal-docs/ARCHITECTURE.md)
- [ADR 002: Refined Package Organization](../internal-docs/adr/adr-20251014001-refined-package-organization.md)
- [ADR 004: Package Path Modifier](../internal-docs/adr/adr-20251016001-package-path-modifier.md)
- [ADR 003: Application Organization](../internal-docs/adr-adr-20251014002-application-organization.md)
- [Shared Partials ADR](apps/infrastructure/docker/internal-docs/adr/adr-20250123001-shared-partials-wrapper.md)

<!-- vim: set ft=markdown: -->
