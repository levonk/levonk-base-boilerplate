---
story_id: "01-002"
story_title: "TOON Format Implementation"
story_name: "toon-format"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260708-cli-go-aix/story-01-002-toon-format"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["output-formats"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "output", "axi"]
due: "2026-06-15"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement TOON (Token-Oriented Object Notation) format support for token-efficient structured output. TOON provides ~40% token savings over equivalent JSON while remaining readable by agents. This includes implementing TOON encoder/decoder, adding format selection flags, and integrating TOON as the default output format in agent mode.

## Sub-Tasks

- [x] Research TOON format specification from https://toonformat.dev/reference/spec.html
- [x] Design TOON data structures and encoding strategy for Go
- [x] Implement TOON encoder for basic types (strings, numbers, booleans, null)
- [x] Implement TOON encoder for arrays with schema headers
- [x] Implement TOON encoder for objects with field definitions
- [x] Implement TOON decoder for parsing TOON format back to Go structs
- [x] Add `--toon` flag to CLI argument parser
- [x] Add `--format=toon|json|human` flag to CLI argument parser
- [x] Implement format selection logic based on mode and flags
- [x] Set TOON as default format in agent mode
- [x] Keep JSON/human-readable as default in human mode
- [x] Integrate TOON encoder into existing output pipeline
- [x] Add TOON format to all command outputs
- [x] Write unit tests for TOON encoder/decoder
- [x] Write integration tests for format selection logic
- [x] Write tests for TOON output format compliance
- [x] Add benchmarks for TOON vs JSON encoding performance
- [x] Update CLI help text to document format options

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/toon/encoder.go.jinja` — TOON encoder implementation (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/encoder_test.go.jinja` — Tests for TOON encoder (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/decoder.go.jinja` — TOON decoder implementation (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/decoder_test.go.jinja` — Tests for TOON decoder (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/types.go.jinja` — TOON data structures (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/compliance_test.go.jinja` — TOON spec compliance tests (new file)
- `boilerplate/apps/cli/go/core/files/internal/toon/benchmark_test.go.jinja` — Performance benchmarks (new file)
- `boilerplate/apps/cli/go/core/files/internal/formatting/formatter.go.jinja` — Output formatting logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/formatting/formatter_test.go.jinja` — Tests for output formatter (new file)
- `boilerplate/apps/cli/go/core/files/main.go.jinja` — Add format flags and integrate formatter

## Acceptance Criteria

- [ ] TOON encoder correctly encodes all basic Go types
- [ ] TOON encoder correctly encodes arrays with schema headers
- [ ] TOON encoder correctly encodes objects with field definitions
- [ ] TOON decoder correctly parses TOON format back to Go structs
- [ ] `--toon` flag successfully enables TOON output
- [ ] `--format=toon` flag successfully enables TOON output
- [ ] `--format=json` flag successfully enables JSON output
- [ ] `--format=human` flag successfully enables human-readable output
- [ ] Agent mode defaults to TOON format
- [ ] Human mode defaults to JSON/human-readable format
- [ ] TOON output achieves ~40% token savings over equivalent JSON
- [ ] TOON encoding/decoding adds minimal overhead (<10ms)
- [ ] All TOON functionality has test coverage
- [ ] Help text documents format selection options

## Test Plan

- Unit: `go test ./internal/toon/...`
- Unit: `go test ./internal/output/...`
- Integration: `go test ./cli/...`
- Benchmark: `go test -bench=. ./internal/toon/...`
- Manual: Verify TOON output format against specification examples
- Manual: Compare token counts between TOON and JSON for sample outputs

## Observability

- Add logging for format selection decisions at debug level
- Add metrics for format usage (TOON vs JSON vs human)
- Add metrics for TOON encoding/decoding performance

## Compliance

- Ensure TOON format specification compliance
- Validate that TOON output doesn't leak sensitive information

## Risks & Mitigations

- Risk: TOON specification may change — Mitigation: Pin to specific version, document compliance level
- Risk: TOON encoding may be slower than expected — Mitigation: Optimize critical paths, add benchmarks
- Risk: TOON format may not handle all Go types — Mitigation: Document limitations, provide fallback to JSON

## Dependencies

- Requires: TOON format specification (https://toonformat.dev/reference/spec.html)
- No dependencies on other stories (can be developed in parallel)

## Notes

- TOON encoder should be designed for performance as it will be called on every output
- Consider using code generation for TOON encoding if performance is critical
- Document any deviations from TOON specification and rationale
- Keep TOON implementation simple and maintainable
