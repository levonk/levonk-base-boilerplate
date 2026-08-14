# Rust Project Changes

This document outlines all changes made by the project-adopter skill specifically for Rust projects.

## Detection Patterns

Projects are detected as Rust when they contain:
- `Cargo.toml`
- `Cargo.lock`
- `src/main.rs` or `src/lib.rs`

## Files Created

### Core Files
- **devbox.json** - Environment with Rust packages
- **justfile** - Rust-specific targets and commands
- **README.md** - Rust development setup guide
- **AGENTS.md** - Rust AI agent configuration
- **.envrc** - Rust environment configuration

## devbox.json Changes

### Adopt Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "rustc", "cargo", "clippy", "rustfmt", "rust-analyzer"
  ]
}
```

### Standardize Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "rustc", "cargo", "clippy", "rustfmt", "rust-analyzer",
    "cargo-audit", "cargo-outdated", "cargo-deny", "cargo-expand",
    "cargo-flamegraph", "cargo-metadata", "cargo-tree", "cargo-udeps"
  ]
}
```

## justfile Changes

### Standard Interface Targets
```just
# Standard interface (uses devbox)
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

clean:
    devbox shell clean
```

### Language-Specific *_impl Targets
```just
# Rust-specific implementations
dev_impl:
    cargo run

build_impl:
    cargo build

test_impl:
    cargo test

lint_impl:
    cargo clippy -- -D warnings

typecheck_impl:
    cargo check

clean_impl:
    cargo clean

bootstrap_impl:
    cargo build
    echo "Rust development environment ready!"
```

### Additional Targets
```just
# Development loop
loop: || (bootstrap build test dev)

# CI pipeline
ci: || (bootstrap lint typecheck test build)

# Release builds
build-release:
    cargo build --release

# Documentation
doc:
    cargo doc --open

# Security audit
audit:
    cargo audit
```

## Cargo.toml Surgical Changes

### Development Dependencies Added (Adopt Mode)
```toml
[dev-dependencies]
tokio-test = "0.4"
serde_json = "1.0"
```

### Development Dependencies Added (Standardize Mode)
```toml
[dev-dependencies]
tokio-test = "0.4"
serde_json = "1.0"
criterion = "0.5"
proptest = "1.0"
```

### Features Added
```toml
[features]
default = []
dev = ["tokio-test", "serde_json"]
```

## Configuration Files

### .rustfmt.toml (Created if missing)
```toml
edition = "2021"
hard_tabs = false
tab_spaces = 4
max_width = 100
newline_style = "Unix"
```

### clippy.toml (Created if missing)
```toml
msrv = "1.70.0"
warn-all-levels = true
allow-dirty = false
```

## README.md Sections

### Rust-Specific Content
```markdown
## Development Setup

### Prerequisites
- Rust 1.70+
- Cargo
- Devbox
- Just

### Quick Start
```bash
# Clone and setup
git clone <repository-url>
cd project-name

# Setup development environment
devbox shell

# Bootstrap the project
just bootstrap

# Start development
just dev
```

## Project Structure
src/                     # Source code
├── main.rs              # Application entry point
├── lib.rs               # Library root
├── bin/                 # Binary executables
├── models/              # Data models
├── services/            # Business logic
└── utils/               # Utility modules

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── common/              # Test utilities

target/                  # Build output (auto-generated)
```

## Testing Strategy
- **Unit tests**: `just test` (cargo test)
- **Integration tests**: `just test:integration`
- **Documentation tests**: `just test:doc`
- **Benchmarks**: `just test:bench`
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Essential packages only** - rustc, cargo, clippy, rustfmt, rust-analyzer
- **Basic configuration** - Minimal rustfmt and clippy configs
- **Standard commands** - build, test, run, check, clean
- **Preserves existing** - Won't override existing Cargo.toml sections

### Standardize Mode (Comprehensive)
- **Full ecosystem** - Adds cargo-audit, cargo-outdated, cargo-deny, etc.
- **Complete configuration** - Comprehensive linting and formatting rules
- **Advanced commands** - Security audit, dependency analysis, profiling
- **Standardizes** - Enforces our preferred Rust configurations

## Related Documentation

- [All Projects Changes](changes-all-projects.md)
- [Node.js Project Changes](changes-nodejs-typescript-projects.md)
- [Python Project Changes](changes-python-projects.md)
- [Go Project Changes](changes-go-projects.md)
- [Java Project Changes](changes-java-projects.md)

<!-- vim: set ft=markdown: -->
