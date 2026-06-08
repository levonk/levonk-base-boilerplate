---
story_id: "02-002"
story_title: "Content Truncation"
story_name: "content-truncation"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260708-cli-python-aix/story-02-002-content-truncation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["output.py", "truncation.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "truncation", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement content truncation for large text fields (500-1500 chars, default 1000). Add `--full` flag to disable truncation. Include truncation metadata in output and help suggestions. Apply to both agent and human modes.

## Sub-Tasks

- [ ] Implement truncation logic for text fields — `output/truncation.py`
- [ ] Add configurable truncation limit (default 1000) — `output/truncation.py`
- [ ] Add `--full` flag to CLI using click/typer — `cli/main.py`
- [ ] Implement truncation metadata in output (total chars) — `output/truncation.py`
- [ ] Add help suggestions when content is truncated — `output/truncation.py`
- [ ] Apply truncation to descriptions, bodies, logs — `output/truncation.py`
- [ ] Ensure large fields are never omitted entirely — `output/truncation.py`
- [ ] Show total size so agent knows how much is missing — `output/truncation.py`
- [ ] Suggest `--full` only when actually truncated — `output/truncation.py`
- [ ] Test truncation with various field sizes — `tests/test_truncation.py`
- [ ] Test `--full` flag disables truncation — `tests/test_truncation.py`
- [ ] Test truncation metadata and help suggestions — `tests/test_truncation.py`

## Relevant Files

- `apps/cli/python/core/files/output/truncation.py.jinja` — Truncation logic
- `apps/cli/python/core/files/cli/main.py.jinja` — CLI with --full flag
- `apps/cli/python/core/files/tests/test_truncation.py.jinja` — Truncation tests

## Acceptance Criteria

- [ ] Large text fields are truncated by default (1000 chars)
- [ ] Truncation limit is configurable
- [ ] `--full` flag disables truncation
- [ ] Truncation metadata shows total char count
- [ ] Help suggestions appear when truncated
- [ ] Large fields are never omitted entirely
- [ ] Truncation applies to both agent and human modes
- [ ] All tests pass

## Test Plan

- Unit: Test truncation logic with various sizes
- Unit: Test truncation metadata generation
- Unit: Test help suggestion generation
- Integration: Test actual CLI output with truncation
- Integration: Test actual CLI output with --full flag
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log truncation events
- Log truncation limit used
- Track --full flag usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Truncation limit too short for some content — Mitigation: Make configurable, provide --full escape hatch
- Risk: Truncation metadata confusing — Mitigation: Clear format, consistent across outputs
- Risk: Help suggestions not actionable — Mitigation: Test with real scenarios, ensure commands work

## Dependencies & Sequencing

- Depends on: 01-002 (TOON Format)
- Unblocks: 02-003 (Aggregates)

## Definition of Done

- Truncation logic fully implemented
- `--full` flag works correctly
- Truncation metadata included
- Help suggestions actionable
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add content truncation for large fields`
- `feat(cli): add --full flag to disable truncation`
- `test(output): add tests for truncation logic`
