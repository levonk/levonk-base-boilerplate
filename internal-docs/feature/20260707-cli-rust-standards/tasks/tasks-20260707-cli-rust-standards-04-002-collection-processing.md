---
story_id: "04-002"
story_title: "Collection/Processing Separation"
story_name: "collection-processing"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260707-cli-rust-standards/story-04-002-collection-processing"
status: "todo"
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

- [ ] Design collection/processing separation architecture
- [ ] Implement data collection daemon mode
- [ ] Add data export commands for collected data
- [ ] Implement offline analysis commands that operate on exported data
- [ ] Add data format specification for export/import
- [ ] Implement collection job tracking
- [ ] Add processing job tracking
- [ ] Create tests for data collection
- [ ] Create tests for data export
- [ ] Create tests for offline analysis
- [ ] Create tests for cross-environment workflow

## Relevant Files

- `apps/cli/rust/src/daemon.rs` — Collection daemon
- `apps/cli/rust/src/processor.rs` — Offline analysis module (new)
- `apps/cli/rust/src/export.rs` — Data export module (new)
- `apps/cli/rust/src/cli.rs` — Add export and analysis commands
- `apps/cli/rust/tests/collection_test.rs` — Collection/processing tests

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
