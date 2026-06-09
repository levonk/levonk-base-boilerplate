---
story_id: "07-003"
story_title: "Collection vs Processing Separation"
story_name: "collection-processing-separation"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 7
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-07-003-collection-processing-separation"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["05-002"]
parallel_safe: true
modules: ["daemon/", "processing/"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "cli", "architecture"]
due: "2026-08-25"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Separate collection (daemon/background) from processing (offline analysis). Allow data collection in one environment and processing in another. Provide export commands for collected data and analysis commands that operate on exported data without requiring the collection daemon. This implements CLI Tool Standards ADR requirement #28.

## Sub-Tasks

- [x] Design data collection schema
- [x] Implement data collection in daemon mode
- [x] Add data export command
- [x] Add data import command
- [x] Implement offline analysis commands
- [x] Add data format validation
- [x] Implement collection/processing separation logic
- [x] Add data serialization/deserialization
- [x] Add unit tests for data export
- [x] Add unit tests for data import
- [x] Add unit tests for offline analysis
- [x] Add integration tests for collection/processing workflow
- [x] Update help text to document separation
- [x] Add data format documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/processing.ts.jinja` - Processing module with data schema and export/import
- `apps/cli/typescript/core/files/src/daemon.ts.jinja` - Daemon with collection logic and event tracking
- `apps/cli/typescript/core/files/src/index.ts.jinja` - CLI with export/import/analysis commands
- `apps/cli/typescript/core/files/src/processing.test.ts.jinja` - Unit tests for processing
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for separation
- `apps/cli/typescript/core/files/docs/data-format.md.jinja` - Data format documentation

## Acceptance Criteria

- [x] Data collection works in daemon mode
- [x] Data can be exported to portable format
- [x] Data can be imported from exported format
- [x] Offline analysis works without daemon
- [x] Analysis commands operate on exported data
- [x] Data format is validated
- [x] Collection/processing separation is clean
- [x] Data format is well-documented
- [x] Export/import is reliable

## Test Plan

- Unit: `vitest run src/processing.test.ts` - Test export/import logic
- Integration: `vitest run src/index.test.ts` - Test collection/processing workflow
- Manual: Test data collection and export
- Manual: Test offline analysis on exported data

## Observability

- Log collection/processing separation in debug mode
- Track data export/import for analytics
- Add metrics for data processing performance

## Compliance

- Follows CLI Tool Standards ADR requirement #28 (Collection vs Processing Separation)
- Enables flexible deployment architectures

## Risks & Mitigations

- Risk: Data format changes break compatibility
  - Mitigation: Version data format, support migration
- Risk: Collection/processing separation adds complexity
  - Mitigation: Clear architecture, comprehensive documentation
- Risk: Data export/import is slow for large datasets
  - Mitigation: Efficient serialization, streaming for large data

## Dependencies

- 05-002 (Daemon Process Support) - Collection requires daemon infrastructure

## Notes

- Use JSON or other portable format for data export
- Consider compression for large datasets
- Data format should be self-documenting
- Collection and processing should be independently testable
