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

## For Developers

If you need to create or modify boilerplate templates, see the **[Boilerplate Developer Guide](.agents/rules/boilerplate-developer-guide.md)** for detailed conventions and technical requirements.
