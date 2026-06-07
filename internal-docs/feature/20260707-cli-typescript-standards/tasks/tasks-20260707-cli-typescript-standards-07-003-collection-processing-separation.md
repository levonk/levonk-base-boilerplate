---
story_id: "07-003"
story_title: "Collection vs Processing Separation"
story_name: "collection-processing-separation"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 7
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-07-003-collection-processing-separation"
status: "todo"
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

- [ ] Design data collection schema
- [ ] Implement data collection in daemon mode
- [ ] Add data export command
- [ ] Add data import command
- [ ] Implement offline analysis commands
- [ ] Add data format validation
- [ ] Implement collection/processing separation logic
- [ ] Add data serialization/deserialization
- [ ] Add unit tests for data export
- [ ] Add unit tests for data import
- [ ] Add unit tests for offline analysis
- [ ] Add integration tests for collection/processing workflow
- [ ] Update help text to document separation
- [ ] Add data format documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/processing.ts.jinja` - New processing module (to be created)
- `apps/cli/typescript/core/files/src/daemon.ts.jinja` - Daemon with collection logic
- `apps/cli/typescript/core/files/src/processing.test.ts.jinja` - Unit tests for processing (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for separation

## Acceptance Criteria

- [ ] Data collection works in daemon mode
- [ ] Data can be exported to portable format
- [ ] Data can be imported from exported format
- [ ] Offline analysis works without daemon
- [ ] Analysis commands operate on exported data
- [ ] Data format is validated
- [ ] Collection/processing separation is clean
- [ ] Data format is well-documented
- [ ] Export/import is reliable

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
