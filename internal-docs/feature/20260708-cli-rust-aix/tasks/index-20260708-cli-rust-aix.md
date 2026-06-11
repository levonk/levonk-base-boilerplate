# Rust CLI AXI Task Index

| Story ID | Story Title | Status | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------ | ------------ | ------------- | ------- |
| 01-001 | Mode Selection and Auto-detection | [x] Done | feature/current/20260708-cli-rust-aix/story-01-001-mode-selection | None | Parallel-safe: true | [cli-core, config] |
| 01-002 | TOON Format Implementation | [x] Done | feature/current/20260708-cli-rust-aix/story-01-002-toon-format | None | Parallel-safe: true | [output-formats] |
| 01-003 | Configuration System Updates | [x] Done | feature/current/20260708-cli-rust-aix/story-01-003-config-updates | None | Parallel-safe: true | [config] |
| 02-001 | Minimal Default Schemas | [x] Done | feature/current/20260708-cli-rust-aix/story-02-001-minimal-schemas | 01-002 | Parallel-safe: true | [output-formats, cli-commands] |
| 02-002 | Content Truncation | [x] Done | feature/current/20260708-cli-rust-aix/story-02-002-content-truncation | 01-002 | Parallel-safe: true | [output-formats] |
| 02-003 | Pre-computed Aggregates | [x] Done | feature/current/20260708-cli-rust-aix/story-02-003-aggregates | 01-001 | Parallel-safe: true | [data-layer, output-formats] |
| 02-004 | Definitive Empty States | [x] Done | feature/current/20260708-cli-rust-aix/story-02-004-empty-states | 01-001 | Parallel-safe: true | [output-formats, cli-commands] |
| 03-001 | Structured Errors & Exit Codes | [x] Done | feature/current/20260708-cli-rust-aix/story-03-001-structured-errors | 01-001, 01-002 | Parallel-safe: true | [error-handling, output-formats] |
| 03-002 | Idempotent Operations | [x] Done | feature/current/20260708-cli-rust-aix/story-03-002-idempotent-ops | 01-001 | Parallel-safe: true | [cli-commands, business-logic] |
| 03-003 | No Interactive Prompts in Agent Mode | [x] Done | feature/current/20260708-cli-rust-aix/story-03-003-no-prompts | 01-001 | Parallel-safe: true | [cli-commands, user-interaction] |
| 04-001 | Session Hook Infrastructure | [x] Done | feature/current/20260708-cli-rust-aix/story-04-001-session-hooks | 01-001, 01-002 | Parallel-safe: true | [session-integration, cli-commands] |
| 04-002 | Agent Skill Support | [x] Done | feature/current/20260708-cli-rust-aix/story-04-002-agent-skills | 01-002 | Parallel-safe: true | [skill-generation, documentation] |
| 05-001 | Content-First No-Args Behavior | [~] In-Progress | feature/current/20260708-cli-rust-aix/story-05-001-content-first | 01-001, 01-002, 02-003 | Parallel-safe: false | [cli-commands, output-formats] |
| 05-002 | Contextual Disclosure | [ ] Todo | feature/current/20260708-cli-rust-aix/story-05-002-contextual-disclosure | 01-001, 01-002, 02-003 | Parallel-safe: false | [cli-commands, suggestion-engine] |

## Phase Summary

- **Phase 01**: Core infrastructure (mode selection, TOON format, config updates) - 3 parallel stories
- **Phase 02**: Output formatting features (schemas, truncation, aggregates, empty states) - 4 parallel stories  
- **Phase 03**: Error handling and behavior (structured errors, idempotent ops, no prompts) - 3 parallel stories
- **Phase 04**: Session integration (hooks, skills) - 2 parallel stories
- **Phase 05**: User experience enhancements (content-first, contextual disclosure) - 2 sequential stories

## Notes

- Total stories: 14
- Parallel development opportunities: 11 stories can be developed in parallel within their phases
- Critical path: 01-001 → 01-002 → 02-003 → 05-001/05-002
- Estimated timeline: 2 weeks based on 1-2 weeks per PRD
