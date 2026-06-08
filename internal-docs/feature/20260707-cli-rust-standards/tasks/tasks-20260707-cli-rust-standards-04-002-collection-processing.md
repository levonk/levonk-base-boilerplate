---
story_id: "04-002"
story_title: "Collection/Processing Separation"
story_name: "collection-processing"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260707-cli-rust-standards/story-04-002-collection-processing"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["02-004"]
parallel_safe: true
modules: ["daemon.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "architecture"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement separation of collection (daemon/background) from processing (offline analysis) for CLIs that collect data and perform analysis, allowing data collection in one environment and processing in another with export commands.

## Sub-Tasks

- [x] Design collection/processing separation architecture
- [x] Implement data collection daemon mode
- [x] Add data export commands for collected data
- [x] Implement offline analysis commands that operate on exported data
- [x] Add data format specification for export/import
- [x] Implement collection job tracking
- [x] Add processing job tracking
- [x] Create tests for data collection
- [x] Create tests for data export
- [x] Create tests for offline analysis
- [x] Create tests for cross-environment workflow

## Relevant Files

- `apps/cli/rust/core/files/src/daemon.rs.jinja` — Collection daemon with DaemonMode, JobType, collection/processing job submission
- `apps/cli/rust/core/files/src/processor.rs.jinja` — Offline analysis module (new) with filter, aggregate, transform, analyze operations
- `apps/cli/rust/core/files/src/export.rs.jinja` — Data export module (new) with JSON, CSV, YAML formats and import/export
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Added Export and Process subcommands
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrated export and processing subcommand handlers
- `apps/cli/rust/core/files/src/config.rs.jinja` — Added daemon_mode and daemon_data_storage_path config fields
- `apps/cli/rust/core/files/src/lib.rs.jinja` — Exported new types and modules
- `apps/cli/rust/core/files/Cargo.toml.jinja` — Added gethostname dependency
- `apps/cli/rust/core/files/templates/config.toml.jinja` — Added daemon mode configuration
- `apps/cli/rust/core/files/tests/collection_test.rs.jinja` — Comprehensive collection/processing tests (new)

## Acceptance Criteria

- [ ] Data collection works in daemon mode
- [ ] Data export commands produce valid export files
- [ ] Offline analysis commands work on exported data
- [ ] Collection and processing separated cleanly
- [ ] Cross-environment workflow supported
- [ ] All tests pass

## Test Plan

- Unit: `cargo test collection`
- Integration: Test collection, export, offline analysis workflow
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log collection jobs, export operations, analysis jobs
- Metrics: Track collection volume, export sizes, analysis duration

## Compliance

- No regulatory constraints
- Ensure exported data doesn't contain sensitive information unless required

## Risks & Mitigations

- Risk: Data format changes break compatibility — Mitigation: Versioned data format, migration support
- Risk: Large export files cause performance issues — Mitigation: Streaming export, chunking options

## Dependencies & Sequencing

- Depends on: 02-004 (daemon support)
- Unblocks: None (architectural feature)

## Definition of Done

- Collection/processing separation implemented
- Data export commands working
- Offline analysis commands working
- Cross-environment workflow supported
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(daemon): implement collection/processing separation`
- `feat(export): add data export commands`
- `feat(analysis): add offline analysis commands`
- `test(collection): add collection/processing tests`
