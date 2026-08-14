

# {project name}

{project-overview}

## Quick Start

```bash
# Clone and enter project
git clone <repo-url>
cd {project-name}

# direnv auto-activates devbox environment
# If not auto-activated, run:
direnv allow
source .envrc

# Bootstrap environment
just bootstrap

# Start development
just dev
```

## Development Environment

This project uses **devbox + direnv + just** for a reproducible development environment.

### Environment Setup

**Automatic (Recommended)**
- `direnv` auto-activates when you enter the project directory
- `devbox` provides the reproducible environment
- `just` provides convenient command recipes

**Manual (If Needed)**
```bash
# Activate direnv
direnv allow
source .envrc

# Enter devbox shell
devbox shell

# Or run commands directly
devbox run just build
```

### Environment Health

```bash
# Check environment health
just doctor

# Re-bootstrap if needed
just bootstrap
```

## Build System (NX)

We use **NX** for monorepo build orchestration, accessed through **just** commands:

```bash
# Build project
just build

# Run tests
just test

# Lint code
just lint

# Type check
just typecheck

# Start dev server
just dev

# View dependency graph
just graph
```

**Note**: Always use `just` commands. NX is called internally by justfile recipes.

## Project Structure


```
.
├── apps/
│   ├── active/          # Working applications
│   └── icebox/          # Prototype applications
├── packages/
│   ├── active/          # Working packages
│   └── icebox/          # Prototype packages
├── boilerplates/        # Project templates
├── internal-docs/       # ADRs, architecture docs
├── scripts/            # Deterministic scripts
├── justfile             # Command runner recipes
├── devbox.json          # Devbox environment config
├── nx.json              # NX workspace config
└── .envrc              # direnv configuration
```

## Development Workflow

### Standard Workflow

```bash
# 1. Enter project (direnv auto-activates)
cd {project-name}

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Write failing test first (TDD)
just test

# 4. Implement feature
# ... make changes ...

# 5. Run quality gates
just lint
just test
just typecheck

# 6. Commit
git commit -m "feat: add my feature"

# 7. Rebase on main if needed
git rebase main

# 8. Open PR
```

### In devbox Shell (Power User)

```bash
# Enter devbox shell for extended sessions
devbox shell

# Run commands directly without devbox wrapper
just build
just test
just lint
```

## Testing

**Mandatory Testing Requirements**
- All features must include comprehensive tests
- All bug fixes must include regression tests
- Test coverage must include happy paths and edge cases
- All tests must pass before committing

```bash
# Run all tests
just test

# Run specific test
just test <test-name>

# Run with output
just test -- --nocapture

# Quality gates
just lint && just test && just typecheck
```

## Package Management

- Use **pnpm** for JavaScript/TypeScript packages
- Never use `npm` or `yarn` directly

```bash
# Install dependencies
pnpm install

# Add dependency
pnpm add <package>

# Add dev dependency
pnpm add -D <package>
```

## Troubleshooting

### Devbox Script Generation Bug

If `devbox run <command>` fails with "command not found":

**Solution 1**: Use `just` directly
```bash
just build
just test
```

**Solution 2**: Enter devbox shell first
```bash
devbox shell
just build_impl
```

### Environment Not Activating

```bash
# Manually activate direnv
direnv allow
source .envrc

# Check environment
just doctor

# Re-bootstrap
just bootstrap
```

## AI Agent Documentation

For AI assistants working on this project, see [AGENTS.md](AGENTS.md) for comprehensive agent-specific workflows and guidelines.

## Tech Stack

**Core Infrastructure**
- devbox - Reproducible development environment
- direnv - Automatic environment activation
- just - Command runner for development tasks
- nx - Monorepo build orchestration and caching

**Package Management**
- pnpm - JavaScript/TypeScript package manager

**Language-Specific**
- nodejs:22 - JavaScript runtime
- typescript:5 - TypeScript compiler
- [other languages with versions]

## Contributing

1. Check existing packages and boilerplates before creating new ones
2. Follow TDD: write tests first
3. Run quality gates before committing
4. Use conventional commit messages
5. All changes require tests

## License

[License information]
