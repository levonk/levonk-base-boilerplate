# Build Target Extraction

The skill now includes **build target extraction** that reads existing configuration files and generates justfiles with actual project targets:

## Supported Configuration Files

- **package.json** - Extracts npm/pnpm/yarn scripts
- **Cargo.toml** - Generates Cargo-based targets
- **Makefile** - Converts make targets to justfile format
- **pyproject.toml** - Python/poetry targets
- **go.mod** - Go module targets
- **pom.xml** - Maven targets
- **build.gradle / build.gradle.kts** - Gradle targets
- **devbox.json** - Devbox shell targets (ADR 20260131001 compliant)

## Extraction Examples

**From package.json:**

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "test": "jest",
    "lint": "eslint ."
  }
}
```

**Generated justfile:**

```just
dev:
    npm run dev

build:
    npm run build

test:
    npm run test

lint:
    npm run lint
```

**From Makefile:**

```makefile
build:
    cargo build --release
test:
    cargo test
clean:
    cargo clean
```

**Generated justfile:**

```just
build:
    make build

test:
    make test

clean:
    make clean
```

**From devbox.json:**

```json
{
  "packages": ["nodejs_22", "pnpm", "just"],
  "shell": {
    "init": ["echo 'Development environment ready!'"]
  }
}
```

**Generated justfile (ADR 20260131001 compliant):**

```just
# Standard devbox targets (ADR 20260131001 compliant)

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

# Bootstrap recipes (REQUIRED)
bootstrap:
    devbox shell bootstrap

bootstrap_impl:
    # Language-specific setup handled by devbox
    echo "Development environment ready!"

# Package management
install:
    devbox install

shell:
    devbox shell
```
