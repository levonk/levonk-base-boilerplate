# Boilerplate Catalog

This directory contains **Copier templates** for scaffolding production-ready projects across the monorepo.

## Quick Start

To create a new project from a boilerplate template:

1. **Find a template** from the catalog below
2. **Prepare copier answers**:
   ```bash
   cat > copier-answers.yml <<EOF
   project_name: my-project
   project_slug: my-project
   description: "A project description"
   # Add other required variables for the template
   EOF
   ```
3. **Generate the project**:
   ```bash
   devbox run -- rtk ./boilerplate/copier-wrapper.sh copy \
     ./boilerplate/[template-path] \
     ./path/to/new-project \
     --data @copier-answers.yml
   ```

**IMPORTANT**: Always use `copier-wrapper.sh`, never copier directly.

## Updating Existing Projects

When a boilerplate template changes, you can update your existing materialized project:

```bash
devbox run -- rtk ./boilerplate/copier-wrapper.sh update \
  --vcs-ref=HEAD \
  ./path/to/existing-project
```

This will:
- Apply template changes to your existing project
- Preserve your local customizations where possible
- Show you what will change before applying

**Note**: Review changes carefully before committing, as updates may affect your customizations.

## Available Boilerplates

### Applications

#### Mobile
- `apps/flutter/` - Cross-platform mobile apps
- `apps/mobile/kotlin-android/` - Native Android apps
- `apps/mobile/react-native/` - React Native apps
- `apps/mobile/swift-ios/` - Native iOS apps

#### Web
- `apps/web/typescript/nextjs/` - Next.js + TypeScript web applications

#### Infrastructure
- `apps/infrastructure/airflow-project/` - Apache Airflow DAG projects
- `apps/infrastructure/airflow-node/` - Containerized task images for Airflow
- `apps/infrastructure/ai-ollama-samples/` - LLM/Ollama integration examples
- `apps/infrastructure/docker/` - Docker & container templates

#### Plugins
- `apps/plugins/` - Browser extensions, VSCode extensions, MCP servers

### Packages

#### General Packages
Library templates for general-purpose libraries follow the pattern: `packages/category/general/domain/package-name/`

- `packages/category/general/domain/package-name/bash/` - Bash libraries
- `packages/category/general/domain/package-name/clang/` - C/C++ libraries
- `packages/category/general/domain/package-name/csharp/` - C# libraries
- `packages/category/general/domain/package-name/go/` - Go libraries
- `packages/category/general/domain/package-name/java/` - Java libraries
- `packages/category/general/domain/package-name/powershell/` - PowerShell libraries
- `packages/category/general/domain/package-name/python/` - Python libraries
- `packages/category/general/domain/package-name/ruby/` - Ruby libraries
- `packages/category/general/domain/package-name/rust/core/` - Rust libraries
- `packages/category/general/domain/package-name/swift/` - Swift libraries
- `packages/category/general/domain/package-name/typescript/` - TypeScript libraries

#### Web Packages
Library templates for web-specific libraries follow the pattern: `packages/category/web/domain/package-name/`

- `packages/category/web/domain/package-name/python3/` - Python web packages
- `packages/category/web/domain/package-name/typescript/` - TypeScript web packages

## Nx `project.json` Convention

Every template that represents an Nx project (i.e., not a bare repo scaffold) MUST have a `project.json.jinja`. Currently 51 of 52 templates have one; the only exception is `repo/git-repo` (bare git scaffold, no build system). The `repo/pnpm-monorepo` template uses Nx at the workspace root (`nx.json.jinja`) with per-project `project.json.jinja` files for its `apps/web` and `packages/ui` sub-projects.

### Shared target partials

Nx target definitions live in `_shared/partials/nx-partials/` as composable partials. Each template's `project.json.jinja` is a thin wrapper that includes the relevant partials:

```jinja
{
  "name": "{{ package_name }}",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "src",
  "projectType": "library",
  "targets": {
    {% include "partials.bak/partials/nx-partials/nx-target-rust.jinja" %}
  }
}
```

### Available target partials

**Language partials** (build/test/lint/format for each language):
- `nx-target-rust.jinja` — cargo build/test/clippy/fmt
- `nx-target-go.jinja` — go build/test/golangci-lint/fmt
- `nx-target-bash.jinja` — bats/shellcheck/shfmt
- `nx-target-swift.jinja` — swift build/test/swiftlint
- `nx-target-clang.jinja` — cmake/ctest/clang-tidy/clang-format
- `nx-target-java.jinja` — mvn package/test/spotless
- `nx-target-kotlin.jinja` — gradle build/test/ktlint
- `nx-target-csharp.jinja` — dotnet build/test/format
- `nx-target-ruby.jinja` — bundle/rspec/rubocop
- `nx-target-powershell.jinja` — Pester/ScriptAnalyzer/Formatter
- `nx-target-nodejs-test.jinja` — @nx/vite:test
- `nx-target-nodejs-lint.jinja` — @nx/eslint:lint
- `nx-target-python-test.jinja` — pytest via @nxlv/python
- `nx-target-python-lint.jinja` — ruff check/format via @nxlv/python
- `nx-target-python-serve.jinja` — uvicorn via @nxlv/python

**Framework partials**:
- `nx-target-nextjs-build.jinja` — @nx/next:build
- `nx-target-nextjs-dev.jinja` — @nx/next:server (dev + start)

**Infrastructure partials**:
- `nx-target-docker-build.jinja` — @nx-tools/nx-container:build + push
- `nx-target-docker-compose.jinja` — docker compose up/down
- `nx-target-ansible.jinja` — ansible-lint + validate
- `nx-target-helm.jinja` — helm lint/template/package
- `nx-target-kustomize.jinja` — kustomize build + kubeconform
- `nx-target-packer.jinja` — packer validate/build/fmt
- `nx-target-fluxcd.jinja` — flux lint/build
- `nx-target-argocd.jinja` — argocd validate/diff
- `nx-target-gitops.jinja` — kustomize + kubeconform + yamllint
- `nx-target-bootc.jinja` — bootc install + hadolint

### Rules

- **ALWAYS use target partials** — do not inline target definitions in `project.json.jinja` unless the target requires executor-specific options that the partial doesn't cover (e.g., `cli/typescript` uses `@nx/esbuild:esbuild` with custom platform/bundle/target options).
- **To change a language's targets across all templates**, edit the partial in `_shared/partials/nx-partials/` — do not edit individual template `project.json.jinja` files.
- **When adding a new template**, include the appropriate target partials. If the language/tool doesn't have a partial yet, create one in `_shared/partials/nx-partials/` first.
- **CLI templates** add a `run` target inline (it's 5 lines and CLI-specific).
- **Package/library templates** use `projectType: library` and `{{ package_name }}`. CLI/application templates use `projectType: application` and `{{ project_name | default(...) }}`.

## For Developers

If you need to create or modify boilerplate templates, see the **[Boilerplate Developer Guide](.agents/rules/boilerplate-developer-guide.md)** for detailed conventions and technical requirements, including the **shared partials system** (`partials.bak/` convention) used to keep shared files identical across templates.
