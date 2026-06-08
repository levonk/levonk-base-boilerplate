---
story_id: "01-002"
story_title: "TOON Format Implementation"
story_name: "toon-format"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260708-cli-typescript-aix/story-01-002-toon-format"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["toon", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "toon", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement TOON (Token-Oriented Object Notation) format support for token-efficient structured output. Add `--toon` flag, implement TOON encoder/decoder for TypeScript, and integrate TOON as default output format in agent mode.

## Sub-Tasks

- [ ] Research TOON format specification — `docs/toon-spec.md`
- [ ] Implement TOON encoder class — `src/toon/encoder.mts`
- [ ] Implement TOON decoder class — `src/toon/decoder.mts`
- [ ] Add `--toon` flag to CLI — `src/cli/flags.mts`
- [ ] Add `--format=toon|json|human` flag to CLI — `src/cli/flags.mts`
- [ ] Integrate TOON output into formatter system — `src/output/formatter.mts`
- [ ] Set TOON as default format in agent mode — `src/output/formatter.mts`
- [ ] Add TOON encoding tests — `tests/toon/encoder.test.mts`
- [ ] Add TOON decoding tests — `tests/toon/decoder.test.mts`
- [ ] Add integration tests for TOON output — `tests/toon/integration.test.mts`
- [ ] Verify ~40% token savings over JSON — `tests/toon/benchmark.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/toon/encoder.mts.jinja` — New file for TOON encoding
- `apps/cli/typescript/core/files/src/toon/decoder.mts.jinja` — New file for TOON decoding
- `apps/cli/typescript/core/files/src/cli/flags.mts.jinja` — CLI flags (updated with TOON flags)
- `apps/cli/typescript/core/files/src/output/formatter.mts.jinja` — Output formatter (updated with TOON support)
- `apps/cli/typescript/core/files/tests/toon/encoder.test.mts.jinja` — New file for encoder tests
- `apps/cli/typescript/core/files/tests/toon/decoder.test.mts.jinja` — New file for decoder tests
- `apps/cli/typescript/core/files/tests/toon/integration.test.mts.jinja` — New file for integration tests
- `apps/cli/typescript/core/files/tests/toon/benchmark.test.mts.jinja` — New file for benchmark tests

## Acceptance Criteria

- [ ] TOON encoder follows TOON format specification
- [ ] TOON decoder can parse TOON output correctly
- [ ] `--toon` flag outputs in TOON format
- [ ] `--format=toon|json|human` flag works correctly
- [ ] Agent mode defaults to TOON format for stdout
- [ ] Human mode continues using JSON or human-readable formats
- [ ] TOON achieves ~40% token savings over equivalent JSON
- [ ] Internal logic remains in JSON, conversion at output boundary
- [ ] All tests pass

## Test Plan

- Unit: Test TOON encoding with various data structures
- Unit: Test TOON decoding with valid and invalid input
- Integration: Test CLI output with `--toon` flag
- Integration: Test CLI output with `--format=toon`
- Benchmark: Verify token savings over JSON
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log output format selection
- Log TOON encoding/decoding errors
- Track token savings metrics if telemetry added

## Compliance

- Follow TOON format specification: https://toonformat.dev/reference/spec.html
- No sensitive data handling

## Risks & Mitigations

- Risk: TOON specification may change — Mitigation: Pin to specific version, monitor for updates
- Risk: TOON encoding/decoding may have edge cases — Mitigation: Comprehensive test coverage
- Risk: Token savings may not meet 40% target — Mitigation: Optimize encoder, benchmark against JSON

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-003 (Config Updates), 02-001 (Minimal Schemas), 02-002 (Content Truncation), 02-003 (Aggregates), 02-004 (Empty States)

## Definition of Done

- TOON encoder/decoder fully implemented
- TOON format follows specification
- `--toon` and `--format` flags work
- Agent mode defaults to TOON
- Token savings verified
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(toon): implement TOON encoder`
- `feat(toon): implement TOON decoder`
- `feat(output): add --toon and --format flags`
- `feat(output): set TOON as default in agent mode`
- `test(toon): add tests for TOON encoding/decoding`
