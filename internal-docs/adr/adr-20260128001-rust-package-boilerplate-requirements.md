---
modeline: "vim: set ft=markdown:"
title: "Rust Package Boilerplate Requirements"
slug: "rust-package-boilerplate-requirements"
url: "/boilerplate/packages/category/general/domain/docs/requirements/rust-package-boilerplate-requirements.md"
synopsis: "Comprehensive requirements for creating production-ready Rust package boilerplates with proper tooling, testing, documentation, and monorepo integration."
author: "https://github.com/levonk"
date-created: "2025-01-28"
date-updated: "2025-01-28"
version: "1.0.0"
status: "accepted"
aliases: ["rust-boilerplate", "rust-package-standards"]
tags: ["doc/requirements", "rust", "boilerplate", "copier", "package"]
related-to: [
  "adr-20251014001-refined-package-organization",
  "adr-20251129001-copier-based-boilerplate-standard",
  "adr-20251106012-containerization-strategy"
]
---

# Rust Package Boilerplate Requirements

## Overview

This document defines the comprehensive requirements for creating Rust package boilerplates that generate production-ready, well-structured, and maintainable Rust libraries and applications within the monorepo. The boilerplates must follow Rust ecosystem best practices while integrating seamlessly with the monorepo's tooling and standards.

## Core Requirements

### 1. Project Structure and Organization

#### 1.1 Standard Directory Layout
Every generated Rust package must follow this structure:

```
{{ package_slug }}/
├── Cargo.toml.jinja                   # Package manifest with template variables
├── Cargo.lock.jinja                   # Lock file template (generated)
├── README.md.jinja                    # Package documentation
├── LICENSE.jinja                      # License file (AGPL/3.0)
├── .gitignore.jinja                   # Git ignore patterns
├── .rustfmt.toml.jinja                # Rust formatting configuration
├── clippy.toml.jinja                  # Clippy linting configuration
├── Makefile.jinja                     # Build automation
├── docker-compose.yml.jinja           # Container orchestration (container with a test implementor of this package)
├── Dockerfile-{ package_slug }.jinja  # Container definition (spins up the test application that uses this new package)
├── devbox.nix.jinja                   # Devbox Nix flake for reproducible builds
├── .envrc.jinja                       # Direnv configuration for devbox
├── src/
│   ├── lib.rs.jinja                   # Library root
│   ├── {{ module_name }}.rs.jinja     # Main module
│   └── error.rs.jinja                 # Error types (if applicable)
├── tests/
│   ├── integration_tests.rs.jinja     # Integration tests
│   └── common/
│       └── mod.rs.jinja               # Test utilities
├── benches/
│   └── performance.rs.jinja           # Performance benchmarks
└── docs/
    ├── architecture.md.jinja          # Architecture documentation
    └── examples/
        └── basic_usage.rs.jinja       # Usage examples
```

#### 1.2 Module Organization
- **Library crates**: Use `src/lib.rs` as the entry point
- **Binary crates**: Use `src/main.rs` for applications, `src/bin/` for multiple binaries
- **Module structure**: Organize by feature/domain, not by file type
- **Re-exports**: Use `pub use` in `lib.rs` to create a clean public API

### 2. Cargo.toml Configuration

#### 2.1 Required Metadata
```toml
[package]
name = "{{ package_slug }}"
version = "0.1.0"
edition = "2021"
authors = ["{{ author_name }} <{{ author_email }}>"]
description = "{{ description }}"
license = "{{ license }}"  # MIT or Apache-2.0
repository = "{{ repository_url }}"
documentation = "{{ docs_url }}"
keywords = {{ keywords }}
categories = {{ categories }}
rust-version = "1.70"  # Minimum supported Rust version

[dependencies]
# Core dependencies with version pins

[dev-dependencies]
# Test-only dependencies

[features]
default = []
{% if include_async %}
async = ["tokio"]
{% endif %}
{% if include_serde %}
serde = ["dep:serde", "serde/derive"]
{% endif %}
```

#### 2.2 Dependency Management
- **Version pinning**: All dependencies must specify exact versions or compatible version requirements
- **Feature flags**: Use Cargo features for optional functionality
- **Minimal dependencies**: Prefer standard library over external crates when possible
- **Security**: Regularly audit dependencies with `cargo audit`

### 3. Development Tooling Configuration

#### 3.1 Rustfmt Configuration
```toml
# .rustfmt.toml
edition = "2021"
hard_tabs = false
tab_spaces = 2
max_width = 100
use_small_heuristics = "Default"
reorder_imports = true
reorder_modules = true
remove_nested_parens = true
use_field_init_shorthand = true
force_explicit_abi = true
empty_item_single_line = true
struct_lit_single_line = true
```

#### 3.2 Clippy Configuration
```toml
# clippy.toml
cognitive-complexity-threshold = 30
too-many-arguments-threshold = 7
type-complexity-threshold = 250
single-char-lifetime-names-threshold = 4
trivial-copy-size-limit = 64
```

#### 3.3 Makefile Targets
```makefile
.PHONY: build test lint fmt check clean doc bench install run docker-build docker-run

# Build targets
build:          ## Build the package
build-release:  ## Build the package in release mode
check:          ## Check if the package compiles
test:           ## Run tests
test-release:   ## Run tests in release mode
bench:          ## Run benchmarks
doc:            ## Generate documentation
doc-open:       ## Generate and open documentation

# Quality targets
lint:           ## Run clippy lints
fmt:            ## Format code with rustfmt
fmt-check:      ## Check if code is formatted
audit:          ## Audit dependencies for security vulnerabilities
outdated:       ## Check for outdated dependencies

# Development targets
run:            ## Run the main binary
dev:            ## Run in development mode with auto-reload
clean:          ## Clean build artifacts

# Installation targets
install:        ## Install the package locally
deploy:         ## deploy the package remotely
uninstall:      ## Uninstall the package

# Container targets
docker-build:   ## Build Docker image
docker-run:      ## Run via Docker

# Devbox integration
devbox-run:      ## Build with Nix

# Nix integration
nix-build:      ## Build with Nix
nix-shell:      ## Enter Nix development shell
```

### 4. Testing Strategy

#### 4.1 Test Organization
- **Unit tests**: Inline in source files using `#[cfg(test)]`
- **Integration tests**: In `tests/` directory for black-box testing
- **Documentation tests**: In doc comments using `///` with code examples
- **Benchmarks**: In `benches/` directory for performance testing

#### 4.2 Required Test Dependencies
```toml
[dev-dependencies]
tokio-test = "0.4"
tempfile = "3.8"
assert_cmd = "2.0"
predicates = "3.0"
serial_test = "2.0"
criterion = { version = "0.5", features = ["html_reports"] }
proptest = "1.4"  # For property-based testing
```

#### 4.3 Test Configuration
```rust
// tests/common/mod.rs
pub fn setup_test_logger() {
    let _ = env_logger::builder()
        .filter_level(log::LevelFilter::Debug)
        .is_test(true)
        .try_init();
}

#[macro_export]
macro_rules! async_test {
    ($test_name:ident, $test_body:block) => {
        #[tokio::test]
        async fn $test_name() {
            let _ = setup_test_logger();
            $test_body
        }
    };
}
```

### 5. Documentation Requirements

#### 5.1 Code Documentation
- **Public items**: All public modules, structs, enums, functions must have rustdoc comments
- **Examples**: Include usage examples in doc comments
- **Error documentation**: Document error variants and their causes
- **Safety documentation**: For unsafe code, explain why it's safe

#### 5.2 README.md Structure
```markdown
# {{ crate_name }}

> {{ description }}

## ✨ Features

- Feature 1
- Feature 2
- Feature 3

## 🚀 Getting Started

### Installation

```bash
cargo add {{ package_slug }}
```

### Quick Start

```rust
use {{ package_slug }}::*;

fn main() {
    // Example usage
}
```

## 📖 Documentation

- [API Documentation](https://docs.rs/{{ package_slug }})
- [Examples](docs/examples/)
- [Architecture](docs/architecture.md)

## 🧪 Testing

```bash
cargo test
```

## 📊 Benchmarks

```bash
cargo bench
```

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

## 📄 License

This project is licensed under the {{ license }} License.
```

### 6. Error Handling

#### 6.1 Error Type Design
```rust
// src/error.rs
use thiserror::Error;

#[derive(Error, Debug)]
pub enum {{ crate_name | title_case }}Error {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Parse error: {0}")]
    Parse(String),

    #[error("Validation error: {field} - {message}")]
    Validation { field: String, message: String },

    #[error("Configuration error: {0}")]
    Config(String),
}

pub type Result<T> = std::result::Result<T, {{ crate_name | title_case }}Error>;
```

#### 6.2 Error Handling Patterns
- Use `thiserror` for structured error types
- Implement `From` traits for error conversion
- Provide context with `anyhow`'s `context()` method when appropriate
- Never use `panic!` in library code except for unrecoverable logic errors

### 7. Async Support

#### 7.1 Async Configuration
```toml
[dependencies]
tokio = { version = "1.35", features = ["full"] }
tokio-util = "0.7"
futures = "0.3"
async-trait = "0.1"
```

#### 7.2 Async Patterns
- Use `async fn` for async functions
- Prefer `tokio` as the async runtime
- Use `#[tokio::test]` for async tests
- Implement `Stream` for async iterators when appropriate

### 8. Serialization Support

#### 8.1 Serde Integration
```toml
[dependencies]
serde = { version = "1.0", features = ["derive"], optional = true }
serde_json = { version = "1.0", optional = true }
toml = { version = "0.8", optional = true }
```

#### 8.2 Serialization Patterns
- Derive `Serialize` and `Deserialize` for public types
- Use `serde(skip_serializing_if = "Option::is_empty")` for optional fields
- Provide custom serialization for complex types
- Support multiple formats (JSON, TOML) when applicable

### 9. Container Support

#### 9.1 Dockerfile Requirements
```dockerfile
# Multi-stage build for minimal runtime image
FROM rust:1.75-slim as builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -r -s /bin/false rustuser

WORKDIR /app
COPY --from=builder /app/target/release/{{ package_slug }} /usr/local/bin/

USER rustuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD {{ package_slug }} --health-check || exit 1

ENTRYPOINT ["{{ package_slug }}"]
```

#### 9.2 Docker Compose Integration
```yaml
version: '3.8'

services:
  {{ package_slug }}:
    build: .
    image: {{ package_slug }}:latest
    container_name: {{ package_slug }}
    restart: unless-stopped
    environment:
      - RUST_LOG=info
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    volumes:
      - ./data:/app/data
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD", "{{ package_slug }}", "--health-check"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### 10. Nix Integration

#### 10.1 Flake Configuration
```nix
{
  description = "{{ description }}";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo-watch
            cargo-audit
            cargo-outdated
            rustfmt
            clippy
          ];

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "{{ package_slug }}";
          version = "0.1.0";
          src = ./.;

          cargoLock.lockFile = ./Cargo.lock;
        };
      });
}
```

### 11. Copier Template Configuration

#### 11.1 copier.yml Structure
```yaml
_min_copier_version: "9.0.0"
_subdirectory: files
_templates_suffix: .jinja

# Basic project information
package_name:
  type: str
  help: What is the package name?
  validate: |
    {% if not package_name|regex_match('^[a-z][a-z0-9-_]*$') %}
    Package name must be lowercase, start with a letter, and contain only letters, numbers, hyphens, and underscores.
    {% endif %}

package_slug:
  type: str
  help: What is the crate slug (for Cargo.toml)?
  default: "{{ package_name | lower | replace(' ', '-') | replace('_', '-') }}"

crate_name:
  type: str
  help: What is the crate name (for Rust code)?
  default: "{{ package_slug | replace('-', '_') }}"

module_name:
  type: str
  help: What is the main module name?
  default: "{{ crate_name }}"

description:
  type: str
  help: Short description of the package
  default: "A Rust package"

author_name:
  type: str
  help: Author name
  default: "Your Name"

author_email:
  type: str
  help: Author email
  default: "your.email@example.com"

license:
  type: str
  help: License type
  choices:
    - MIT
    - Apache-2.0
    - MPL-2.0
  default: "MIT"

repository_url:
  type: str
  help: Repository URL
  default: "https://github.com/yourusername/{{ package_slug }}"

# Feature flags
include_async:
  type: bool
  help: Include async support (tokio)?
  default: false

include_serde:
  type: bool
  help: Include serialization support (serde)?
  default: false

include_cli:
  type: bool
  help: Include CLI support (clap)?
  default: false

include_docker:
  type: bool
  help: Include Docker configuration?
  default: true

include_nix:
  type: bool
  help: Include Nix flake?
  default: true

# Dependencies
keywords:
  type: str
  help: Comma-separated keywords
  default: "rust,library"

categories:
  type: str
  help: Comma-separated categories
  default: "development-tools::cargo-plugins"
```

### 12. Security Considerations

#### 12.1 Security Checklist
- **Input validation**: Validate all external inputs
- **Memory safety**: Leverage Rust's memory safety guarantees
- **Dependency auditing**: Regular security audits with `cargo audit`
- **Safe FFI**: Proper error handling for foreign function interfaces
- **Secrets management**: Never commit secrets, use environment variables

#### 12.2 Security Dependencies
```toml
[dependencies]
secrecy = "0.8"  # For secret handling
zeroize = "1.7"   # For secure memory clearing
```

### 13. Performance Guidelines

#### 13.1 Performance Requirements
- **Zero-cost abstractions**: Prefer compile-time optimizations
- **Memory efficiency**: Use appropriate data structures
- **Async efficiency**: Use efficient async patterns
- **Benchmarking**: Include benchmarks for critical paths

#### 13.2 Performance Tools
```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }
iai = "0.1"  # For stable benchmarking
divan = "0.1"  # Alternative benchmarking framework
```

### 14. Integration with Monorepo

#### 14.1 Turborepo Integration
```json
// turbo.json (root level)
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["target/dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "lint": {
      "outputs": []
    },
    "doc": {
      "dependsOn": ["build"],
      "outputs": ["target/doc/**"]
    }
  }
}
```

#### 14.2 Workspace Configuration
```toml
# In root Cargo.toml
[workspace]
members = [
    "packages/active/*/rust/*",
    "packages/icebox/*/rust/*",
    "apps/active/*/rust/*"
]

[workspace.dependencies]
# Shared dependencies with version pins
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
anyhow = "1.0"
thiserror = "1.0"
```

### 15. Quality Gates

#### 15.1 Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

#### 15.2 CI/CD Requirements
- **Multiple Rust versions**: Test against stable, beta, and nightly
- **Cross-platform**: Test on Linux, macOS, and Windows
- **Documentation**: Ensure docs build without warnings
- **Security**: Run `cargo audit` in CI

### 16. Optional Features

#### 16.1 CLI Applications
```toml
[dependencies]
clap = { version = "4.4", features = ["derive", "env"] }
console = "0.15"
indicatif = "0.17"
dialoguer = "0.11"
```

#### 16.2 Web Services
```toml
[dependencies]
axum = "0.7"
tower = "0.4"
tower-http = { version = "0.5", features = ["cors", "trace"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
```

#### 16.3 Database Integration
```toml
[dependencies]
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres"] }
diesel = { version = "2.1", features = ["postgres"], optional = true }
```

### 17. Migration and Upgrades

#### 17.1 Version Management
- **Semantic versioning**: Follow SemVer for releases
- **Changelog**: Maintain CHANGELOG.md with version history
- **Migration guide**: Document breaking changes
- **Deprecation warnings**: Use deprecated attribute for old APIs

#### 17.2 Compatibility
- **Rust version policy**: Support current stable - 2 versions
- **Platform support**: Tier 1 platforms (Linux, macOS, Windows)
- **Dependency updates**: Regular updates with compatibility testing

## Implementation Checklist

### Must-Have Requirements
- [ ] Complete directory structure with all required files
- [ ] Proper Cargo.toml with all required metadata
- [ ] Comprehensive Makefile with all standard targets
- [ ] Rustfmt and Clippy configuration
- [ ] Basic test suite with unit and integration tests
- [ ] Documentation in README.md and code comments
- [ ] Error handling with thiserror
- [ ] Git ignore patterns
- [ ] Copier configuration with all required prompts
- [ ] Docker support (multi-stage builds, non-root user)
- [ ] Nix flake for reproducible builds

### Should-Have Requirements
- [ ] Async support with tokio (optional feature)
- [ ] Serde integration (optional feature)
- [ ] CLI support with clap (optional feature)
- [ ] Benchmarks with criterion
- [ ] Security auditing configuration
- [ ] Performance optimization guidelines
- [ ] Migration and upgrade documentation

### Could-Have Requirements
- [ ] Web service templates with axum
- [ ] Database integration examples
- [ ] Cross-compilation configuration
- [ ] FFI examples
- [ ] Custom allocators
- [ ] Embedded system support

## Validation Criteria

A Rust package boilerplate is considered complete when:

1. **Generation**: `copier copy` successfully generates a complete project
2. **Compilation**: `cargo check` passes without warnings
3. **Testing**: `cargo test` passes all tests
4. **Linting**: `cargo clippy` passes without warnings
5. **Formatting**: `cargo fmt --check` passes
6. **Documentation**: `cargo doc` generates docs without warnings
7. **Building**: `cargo build --release` succeeds
8. **Container**: Docker image builds and runs successfully
9. **Nix**: `nix build` succeeds in development shell

## References

- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [The Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Thiserror Documentation](https://docs.rs/thiserror/)
- [Tokio Documentation](https://docs.rs/tokio/)
- [Serde Documentation](https://docs.rs/serde/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/)
- [Rustfmt Configuration](https://rust-lang.github.io/rustfmt/)

---

*This requirements document serves as the authoritative guide for creating Rust package boilerplates in the monorepo. All boilerplates must meet these requirements to ensure consistency, quality, and maintainability across the ecosystem.*
