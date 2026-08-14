# Project Adopter Reference

## Skill Integration

This skill is designed to work seamlessly with other skills in the ecosystem:

### Primary Dependencies

#### Project Detection Skill
- **Purpose**: Comprehensive detection of project types, build systems, and tooling
- **Usage**: Source detection functions from `../project-detection/scripts/`
- **Benefits**:
  - Avoids duplicating detection logic
  - Provides comprehensive analysis of build systems, CI/CD, workspace tools
  - Supports 50+ build systems and CI/CD platforms
- **Integration**:
  ```bash
  DETECTION_SKILL_PATH="$(dirname "${BASH_SOURCE[0]}")/../project-detection"
  source "$DETECTION_SKILL_PATH/scripts/detect-build-systems.sh"
  build_systems=$(detect_systems "$PROJECT_PATH" "false")
  ```

#### AI Development Loop Skill
- **Purpose**: Systematic 9-step workflow for high-quality development cycles
- **Usage**: Follow the enhanced workflow after project setup
- **Benefits**:
  - Ensures consistent, high-quality development process
  - Includes strategy phase for implementation decisions
  - Integrates with ticketr for ticket management
- **Integration**: Project setup → AI development loop workflow

#### Project Configuration Skill
- **Purpose**: Configure projects with standard tooling based on detection
- **Usage**: Reference for configuration patterns and templates
- **Benefits**:
  - Leverages existing configuration expertise
  - Provides templates for devbox, justfile, CI/CD
  - Handles migration scenarios
- **Integration**: Use as reference for configuration patterns

## Configuration Templates

### Devbox Templates by Language

#### TypeScript/Node.js
```json
{
  "packages": [
    "just",
    "nodejs_22",
    "pnpm",
    "typescript"
  ],
  "shell": {
    "init_hook": ["just bootstrap_impl"]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl"
  }
}
```

#### Rust
```json
{
  "packages": [
    "just",
    "rustc",
    "cargo",
    "clippy",
    "rustfmt"
  ],
  "shell": {
    "init_hook": ["just bootstrap_impl"]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "clean": "just clean_impl"
  }
}
```

#### Python
```json
{
  "packages": [
    "just",
    "python3",
    "poetry",
    "black",
    "ruff",
    "mypy"
  ],
  "shell": {
    "init_hook": ["just bootstrap_impl"]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl"
  }
}
```

#### Go
```json
{
  "packages": [
    "just",
    "go",
    "gopls",
    "golangci-lint"
  ],
  "shell": {
    "init_hook": ["just bootstrap_impl"]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "clean": "just clean_impl"
  }
}
```

### Justfile Templates by Language

#### TypeScript/Node.js
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap_impl:
    pnpm install
    echo "✅ TypeScript environment ready!"

# Implementation targets
build_impl:
    pnpm run build

test_impl:
    pnpm run test

dev_impl:
    pnpm run dev

lint_impl:
    pnpm run lint

typecheck_impl:
    pnpm run typecheck

clean_impl:
    rm -rf dist node_modules/.cache
```

#### Rust
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap_impl:
    cargo build
    echo "✅ Rust environment ready!"

# Implementation targets
build_impl:
    cargo build --release

test_impl:
    cargo test

dev_impl:
    cargo run

lint_impl:
    cargo clippy

clean_impl:
    cargo clean
```

#### Python
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap_impl:
    poetry install
    echo "✅ Python environment ready!"

# Implementation targets
build_impl:
    poetry build

test_impl:
    poetry run pytest

dev_impl:
    poetry run python -m src

lint_impl:
    poetry run ruff check

typecheck_impl:
    poetry run mypy

clean_impl:
    rm -rf build dist .pytest_cache
```

#### Go
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap_impl:
    go mod download
    echo "✅ Go environment ready!"

# Implementation targets
build_impl:
    go build ./...

test_impl:
    go test ./...

dev_impl:
    go run main.go

lint_impl:
    golangci-lint run

clean_impl:
    go clean -cache
```

## Dependency Management Commands

### yq-go Usage Patterns

#### TypeScript/Node.js
```bash
# Add standard dev dependencies
yq eval '.devDependencies["@job-aide/tools-lint-eslint-config"] = "^1.0.0"' package.json -i
yq eval '.devDependencies["@job-aide/tools-vitest-config"] = "^1.0.0"' package.json -i
yq eval '.devDependencies["typescript"] = "^5.6.0"' package.json -i
yq eval '.devDependencies["vitest"] = "^2.0.0"' package.json -i
yq eval '.devDependencies["@types/node"] = "^22.0.0"' package.json -i

# Add standard scripts
yq eval '.scripts.build = "tsc"' package.json -i
yq eval '.scripts.test = "vitest"' package.json -i
yq eval '.scripts.lint = "eslint . --ext .ts,.tsx"' package.json -i
yq eval '.scripts.typecheck = "tsc --noEmit"' package.json -i
yq eval '.scripts.dev = "tsx watch src/index.ts"' package.json -i

# Set package manager
yq eval '.packageManager = "pnpm@9.15.0"' package.json -i
```

#### Rust
```bash
# Add standard dependencies
yq eval '.dependencies["tokio"] = { version = "^1.0", features = ["full"] }' Cargo.toml -i
yq eval '.dependencies["anyhow"] = "^1.0"' Cargo.toml -i
yq eval '.dependencies["serde"] = { version = "^1.0", features = ["derive"] }' Cargo.toml -i
yq eval '.dependencies["clap"] = { version = "^4.4", features = ["derive"] }' Cargo.toml -i
yq eval '.dependencies["uuid"] = { version = "^1.0", features = ["v4"] }' Cargo.toml -i

# Add dev dependencies
yq eval '.devDependencies["cargo-watch"] = "^8.0"' Cargo.toml -i
yq eval '.devDependencies["cargo-expand"] = "^1.0"' Cargo.toml -i
```

#### Python
```bash
# Add pyproject.toml dependencies (if using poetry)
yq eval '.devDependencies["black"] = "^24.0.0"' pyproject.toml -i
yq eval '.devDependencies["ruff"] = "^0.1.0"' pyproject.toml -i
yq eval '.devDependencies["mypy"] = "^1.0.0"' pyproject.toml -i
yq eval '.devDependencies["pytest"] = "^8.0.0"' pyproject.toml -i
```

## File Structure Patterns

### Standard Project Layout
```
project-name/
├── .envrc                    # direnv configuration
├── devbox.json              # Devbox packages and scripts
├── justfile                 # Build commands
├── AGENTS.md                # AI agent workflow guide (created before README)
├── README.md                # Generated by readme-upsert (greenfield: from template; brownfield: preserve + update)
├── LICENSE.md               # Proprietary license
├── .gitignore               # Generated by ignorefile-manager
├── .dockerignore            # Generated by ignorefile-manager
├── .codeiumignore           # Generated by ignorefile-manager
├── .cursorignore            # Generated by ignorefile-manager
├── .aiexclude               # Generated by ignorefile-manager
├── .npmignore               # Generated by ignorefile-manager (npm packages)
├── docker-compose.yml       # Container orchestration
├── docker/
│   └── Dockerfile          # Container definition
├── .github/
│   ├── workflows/
│   │   └── ci.yml          # GitHub Actions
│   └── dependabot.yml      # Dependency updates
└── src/                     # Source code
```

> **Note**: All ignore files (`.gitignore`, `.dockerignore`, `.codeiumignore`, `.cursorignore`, `.aiexclude`, `.npmignore`, VS Code excludes, ripgrep config) are generated by the [ignorefile-manager](../../../general/ignorefile-manager/SKILL.md) skill from modular concern sources. `README.md` is created or updated by the [readme-upsert](../../../ai/readme-upsert/SKILL.md) skill (greenfield: from `references/README-project-root-template.md.tmpl`; brownfield: preserve accurate sections, update stale ones; then `verify_consistency.py` checks README↔AGENTS.md agreement). The git repository is initialized and the adoption changeset is committed by the [git-repository-management](../git-repository-management/SKILL.md) skill. Do NOT hand-write ignore files, README content, or call `git init`/`git commit` directly — see [Repository & Ignore File Management](SKILL.md) in the main skill file.

### Monorepo Layout
```
monorepo/
├── .envrc
├── devbox.json
├── justfile
├── pnpm-workspace.yaml
├── turbo.json
├── apps/
│   └── active/
│       └── app-name/
├── packages/
│   └── active/
└── internal-docs/
```

## Migration Strategies

### Existing Project Migration

1. **Assessment Phase**
   ```bash
   # Check current setup
   find . -name "package.json" -o -name "Cargo.toml" -o -name "pyproject.toml"
   ls -la | grep -E "(Makefile|justfile|\.envrc|devbox\.json)"
   ```

2. **Gradual Adoption**
   ```bash
   # 1. Add justfile (keep existing Makefile)
   echo "dev:\n    npm run dev" > justfile

   # 2. Add devbox (optional initially)
   devbox init
   devbox add nodejs pnpm just

   # 3. Configure direnv
   echo 'use devbox' > .envrc

   # 4. Migrate commands gradually
   # Replace Makefile targets with justfile recipes
   ```

3. **Full Migration**
   ```bash
   # Remove old tooling
   rm Makefile package-lock.json
   git add .
   git commit -m "Migrate to devbox + just workflow"
   ```

### Greenfield Project Setup

1. **Initialize with boilerplate**
   ```bash
   # Use existing boilerplates if available
   copier copy boilerplate/apps/web/typescript/nextjs my-app
   cd my-app
   ```

2. **Manual setup**
   ```bash
   mkdir my-app && cd my-app
   npm init -y
   devbox init
   devbox add nodejs pnpm just typescript
   # Apply this skill to set up remaining files
   ```

## Quality Gates

### Pre-commit Checklist
- [ ] Devbox configuration exists and is valid
- [ ] Justfile has required targets
- [ ] .envrc is configured and allowed
- [ ] AGENTS.md is present for AI workflow (created before README)
- [ ] README.md generated or updated via readme-upsert (verify_consistency.py passes)
- [ ] Dependencies are properly declared
- [ ] CI/CD is configured
- [ ] License file exists

### Validation Commands
```bash
# Test devbox configuration
devbox shell -- echo "Devbox works"

# Test justfile
just --list

# Test direnv
direnv allow

# Run full quality check
just quality  # if defined
```

## Troubleshooting

### Common Issues

1. **Devbox not found**
   ```bash
   # Install nix first
   curl -L https://nixos.org/nix/install | sh
   nix profile install nixpkgs#devbox
   ```

2. **direnv not working**
   ```bash
   # Install direnv
   brew install direnv  # macOS
   sudo apt install direnv  # Ubuntu

   # Hook into shell
   echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
   ```

3. **just not found**
   ```bash
   # Add to devbox
   devbox add just

   # Or install directly
   cargo install just
   ```

4. **Permission denied on .envrc**
   ```bash
   # Allow direnv
   direnv allow
   ```

## Integration Examples

### With Existing CI/CD

#### GitHub Actions Migration
```yaml
# Before: Using Node.js setup
- uses: actions/setup-node@v4
  with:
    node-version: '22'

# After: Using Devbox
- uses: jetify-com/devbox-action@v0.10.0
- run: just test
```

#### Docker Integration
```dockerfile
# Use devbox in Docker
FROM jetify/devbox:latest as builder
WORKDIR /app
COPY devbox.json ./
RUN just build

FROM node:22-alpine as runtime
COPY --from=builder /app/dist ./dist
```

## Best Practices

### Devbox Configuration
- Keep packages minimal
- Use specific versions for reproducibility
- Group related packages
- Document why unusual packages are needed

### Justfile Design
- Separate user-facing targets from internal ones
- Use `_impl` suffix for implementation details
- Keep recipes simple and focused
- Add comments for complex workflows

### direnv Usage
- Watch only necessary files
- Avoid expensive operations in .envrc
- Use devbox for heavy setup
- Keep environment variables minimal

### Documentation
- Generate or update README.md via readme-upsert (do NOT hand-write)
- Keep AGENTS.md current with project changes
- Include troubleshooting section
- Document any project-specific patterns
