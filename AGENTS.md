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
- `nx-target-nodejs-test.jinja` — nx:run-commands + pnpm exec vitest run
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

## Iron Proxy Egress Security

Selected boilerplate templates include an **initially disabled** GitHub Actions workflow that wraps the build process with [iron-proxy-action](https://github.com/ironsh/iron-proxy-action) — an egress firewall for CI pipelines that intercepts and validates all outbound network traffic against an allowlist.

### How it works

- The workflow file (`.github/workflows/iron-proxy.yml`) is generated from the shared partial at `_shared/.github/workflows/iron-proxy.yml.jinja`
- An `egress-rules.yaml` file defines the allowed domains (npm registry, Node.js, GitHub)
- The job is gated by `if: vars.IRON_PROXY_ENABLED == 'true'` — it will not run until the repository variable `IRON_PROXY_ENABLED` is set to `true`
- When enabled, the action installs iron-proxy, redirects all DNS through it, and locks down outbound traffic with iptables
- A summary step prints every domain the job contacted and whether requests were allowed or denied

### Enabling iron-proxy in a generated project

1. Review the `egress-rules.yaml` file and add any additional domains your build requires
2. Set the repository variable: **Settings → Secrets and variables → Actions → Variables → New repository variable** → Name: `IRON_PROXY_ENABLED`, Value: `true`
3. Run the workflow (it triggers on push, PR, and manual dispatch)
4. Start with `warn: true` (the default) to see all traffic without blocking
5. Once the allowlist is dialed in, set `warn: false` in the workflow to enforce blocking

### Templates with iron-proxy support

- `repo/pnpm-monorepo/` — pnpm monorepo with Nx build orchestration

### Adding iron-proxy to additional templates

To add iron-proxy egress security to another boilerplate template:

1. Create `.github/workflows/iron-proxy.yml.jinja` in the template's `files/` directory with: `{% include "partials.bak/.github/workflows/iron-proxy.yml.jinja" %}`
2. Create `egress-rules.yaml.jinja` in the template's `files/` directory with: `{% include "partials.bak/egress-rules.yaml.jinja" %}`
3. Adjust the build steps in the shared partial if the template uses a different build tool (the default uses pnpm + Nx)

## For Developers

If you need to create or modify boilerplate templates, see the **[Boilerplate Developer Guide](.agents/rules/boilerplate-developer-guide.md)** for detailed conventions and technical requirements, including the **shared partials system** (`partials.bak/` convention) used to keep shared files identical across templates.

## Shared Scripts

The `_shared/scripts/` directory contains reusable bash scripts for post-copy tasks:

- **`_shared/scripts/ensure-devbox-x86-pin.sh`** — Detects x86_64-darwin (Intel Mac) at runtime and injects the nixpkgs commit pin (`293d6abedf0478e681a4dfcfcb35b30fc796a32f`) into `devbox.json` if the pin is missing. This is a fallback for when copier is invoked without `copier-wrapper.sh` (which passes `nix_target_arch` as data). Non-destructive: if a pin already exists, it does nothing. On non-x86_64-darwin platforms, it exits 0 immediately.

- **`_shared/scripts/token-commit.sh`** — Creates an initial git commit in the current directory if no commits exist yet. Initializes git if `.git` is not present. Non-destructive: if commits already exist, it does nothing. Intended for copier post-copy tasks (`_tasks:`) to ensure generated projects have a clean git baseline.

### When adding a new template

- If the template's `.envrc.jinja` references `{{REPO_ROOT}}`, define `REPO_ROOT` in its `copier.yml` with `default: "."`
- If the template's post-copy task runs `devbox install`, call `ensure-devbox-x86-pin.sh` before `devbox install` (or inline the x86 detection logic)
- If the template's post-copy task runs `git init`, call `token-commit.sh` after `git init` (or inline the token-commit logic)
