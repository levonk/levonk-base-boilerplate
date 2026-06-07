# Rust CLI Application Boilerplate

Scaffolds a production-ready Rust CLI application with devbox, just, and standard tooling.

## Usage

```bash
devbox run -- ./boilerplate/copier-wrapper.sh copy apps/cli/rust/core ./path/to/new-project
```

## Inputs

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `project_name` | str | Project name (kebab-case) | `my-cli-tool` |
| `project_slug` | str | Binary crate name | `{{ project_name \| lower \| replace(' ', '-') }}` |
| `description` | str | Short description | `A CLI tool` |
| `rust_log_level` | str | Default RUST_LOG level | `info` |
| `rust_backtrace` | str | Default RUST_BACKTRACE | `1` |
| `include_openssl` | bool | Include OpenSSL packages | `false` |
| `include_postgres` | bool | Include PostgreSQL packages | `false` |
| `include_sqlite` | bool | Include SQLite packages + rusqlite crate | `false` |

## Generated Project Structure

```
.
├── src/main.rs          # CLI entry point with clap
├── tests/cli_tests.rs   # Integration tests with assert_cmd
├── docs/                # Documentation directory
├── internal-docs/       # ADRs and specs
├── Cargo.toml           # Dependencies
├── devbox.json          # Development environment
├── justfile             # Task runner
├── README.md            # Project README
└── .gitignore           # Git ignore rules
```

## Notes

- Follows ADR-20260131001 (Standard Developer UX Flow)
- Uses tokio for async runtime support
- Includes tracing for structured logging
- SQLite support adds `rusqlite` crate and `sqlite` devbox package
