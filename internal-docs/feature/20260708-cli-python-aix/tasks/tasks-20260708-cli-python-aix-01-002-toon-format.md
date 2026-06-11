---
story_id: "01-002"
story_title: "TOON Format Implementation"
story_name: "toon-format"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260708-cli-python-aix/story-01-002-toon-format"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["output.py", "toon.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "toon", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement TOON (Token-Oriented Object Notation) format for token-efficient structured output. Add `--toon` flag and `--format=toon|json|human` flag. Default to TOON in agent mode, JSON/human in human mode. Keep internal logic in JSON, convert at output boundary.

## Sub-Tasks

- [x] Research or implement TOON encoder/decoder for Python — `output/toon.py`
- [x] Follow TOON format specification from https://toonformat.dev/reference/spec.html — `output/toon.py`
- [x] Implement compact, agent-readable syntax — `output/toon.py`
- [x] Add `--toon` flag to CLI using click/typer — `cli/main.py`
- [x] Add `--format=toon|json|human` flag to CLI — `cli/main.py`
- [x] Implement output format selection logic based on mode and flags — `output/formatter.py`
- [x] Default to TOON format in agent mode for stdout — `output/formatter.py`
- [x] Keep internal logic in JSON, convert at output boundary — `output/formatter.py`
- [x] Test TOON encoding/decoding with various data structures — `tests/test_toon.py`
- [x] Test format selection with mode and flag combinations — `tests/test_format.py`
- [x] Verify ~40% token savings over equivalent JSON — `tests/test_toon.py`

## Relevant Files

- `apps/cli/python/core/files/output/toon.py.jinja` — New module for TOON encoder/decoder
- `apps/cli/python/core/files/output/formatter.py.jinja` — Output formatter with format selection
- `apps/cli/python/core/files/cli/main.py.jinja` — CLI with format flags
- `apps/cli/python/core/files/tests/test_toon.py.jinja` — Tests for TOON format
- `apps/cli/python/core/files/tests/test_format.py.jinja` — Tests for format selection

## Acceptance Criteria

- [x] `--toon` flag outputs in TOON format
- [x] `--format=toon|json|human` flag selects format explicitly
- [x] Agent mode defaults to TOON format for stdout
- [x] Human mode uses JSON or human-readable formats
- [x] TOON output follows specification from toonformat.dev
- [x] TOON achieves ~40% token savings over equivalent JSON
- [x] Internal logic remains in JSON
- [x] Conversion happens at output boundary only
- [x] All tests pass

## Test Plan

- Unit: Test TOON encoding/decoding with various data types
- Unit: Test format selection logic
- Integration: Test actual CLI output with different formats
- Performance: Measure token savings vs JSON
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log selected output format
- Log TOON encoding/decoding performance metrics
- Track format usage if telemetry added later

## Compliance

- Follow TOON format specification exactly
- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: TOON specification changes — Mitigation: Pin to specific version, add tests
- Risk: Encoding/decoding performance overhead — Mitigation: Benchmark, optimize if needed
- Risk: Complex data structures not supported — Mitigation: Handle gracefully, fall back to JSON

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-003 (Config Updates), 02-001 (Minimal Schemas), 02-002 (Content Truncation)

## Definition of Done

- TOON encoder/decoder fully implemented
- Format selection works correctly
- Token savings achieved
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add TOON format encoder/decoder`
- `feat(cli): add --toon and --format flags`
- `test(output): add tests for TOON format`
