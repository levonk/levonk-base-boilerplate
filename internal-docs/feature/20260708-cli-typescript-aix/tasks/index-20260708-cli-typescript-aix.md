# TypeScript CLI AXI - Task Index

## Overview

This index summarizes all stories for the TypeScript CLI AXI (Agent eXperience Interface) implementation, organized into 5 sequential phases with parallel development tracks. The work follows the AXI specification to enable autonomous AI agents to efficiently interact with TypeScript CLI tools.

## Phase Summary

- **Phase 01**: Core Infrastructure (3 stories) - Mode selection, TOON format, and config updates
- **Phase 02**: Output Optimization (4 stories) - Minimal schemas, content truncation, aggregates, and empty states
- **Phase 03**: Error Handling & Output (3 stories) - Structured errors, no prompts, and output channel separation
- **Phase 04**: Session Integration (2 stories) - Session hooks and agent skills
- **Phase 05**: Content Experience (2 stories) - Content-first no-args and contextual disclosure

## Story Details

### Phase 01: Core Infrastructure (High Priority - Week 1)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 01-001 | Mode Selection Implementation | feature/current/20260708-cli-typescript-aix/story-01-001-mode-selection | None | Parallel-safe: true | [mode, main] |
| 01-002 | TOON Format Implementation | feature/current/20260708-cli-typescript-aix/story-01-002-toon-format | None | Parallel-safe: true | [toon, output] |
| 01-003 | Config File Updates for Mode | feature/current/20260708-cli-typescript-aix/story-01-003-config-updates | None | Parallel-safe: true | [config, mode] |

### Phase 02: Output Optimization (High Priority - Week 1)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 02-001 | Minimal Default Schemas | feature/current/20260708-cli-typescript-aix/story-02-001-minimal-schemas | 01-001, 01-002 | Parallel-safe: true | [schema, output] |
| 02-002 | Content Truncation with Escape Hatches | feature/current/20260708-cli-typescript-aix/story-02-002-content-truncation | 01-002, 01-003 | Parallel-safe: true | [truncation, output] |
| 02-003 | Pre-computed Aggregates | feature/current/20260708-cli-typescript-aix/story-02-003-pre-computed-aggregates | 02-001 | Parallel-safe: true | [aggregates, output] |
| 02-004 | Definitive Empty States | feature/current/20260708-cli-typescript-aix/story-02-004-definitive-empty-states | 02-001, 02-003 | Parallel-safe: true | [output, commands] |

### Phase 03: Error Handling & Output (High Priority - Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 03-001 | Structured Errors and Exit Codes | feature/current/20260708-cli-typescript-aix/story-03-001-structured-errors | 01-001, 02-004 | Parallel-safe: true | [errors, output] |
| 03-002 | No Interactive Prompts | feature/current/20260708-cli-typescript-aix/story-03-002-no-interactive-prompts | 01-001, 03-001 | Parallel-safe: true | [cli, prompts] |
| 03-003 | Output Channels Separation | feature/current/20260708-cli-typescript-aix/story-03-003-output-channels | 03-001, 03-002 | Parallel-safe: true | [output, logging] |

### Phase 04: Session Integration (High Priority - Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 04-001 | Session Hook Infrastructure | feature/current/20260708-cli-typescript-aix/story-04-001-session-hooks | 01-001, 01-002, 03-003 | Parallel-safe: true | [hooks, session] |
| 04-002 | Installable Agent Skill | feature/current/20260708-cli-typescript-aix/story-04-002-agent-skills | 01-002, 04-001 | Parallel-safe: true | [skills, docs] |

### Phase 05: Content Experience (High Priority - Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 05-001 | Content-First No-Args Output | feature/current/20260708-cli-typescript-aix/story-05-001-content-first | 01-001, 01-002, 02-001, 02-003, 04-001 | Parallel-safe: false | [cli, output] |
| 05-002 | Contextual Disclosure with Next Steps | feature/current/20260708-cli-typescript-aix/story-05-002-contextual-disclosure | 05-001 | Parallel-safe: false | [suggestions, output] |

## Dependency Graph

```
Phase 01 (Core Infrastructure):
├── 01-001 (Mode Selection) ──┬──> 02-001, 03-001, 03-002, 04-001, 05-001
├── 01-002 (TOON Format) ──────┼──> 02-001, 02-002, 04-001, 04-002, 05-001
└── 01-003 (Config Updates) ───┴──> 02-002

Phase 02 (Output Optimization):
├── 02-001 (Minimal Schemas) ───┬──> 02-003, 02-004, 05-001
├── 02-002 (Content Truncation) ┤
├── 02-003 (Aggregates) ─────────┼──> 02-004, 05-001
└── 02-004 (Empty States) ───────┴──> 03-001

Phase 03 (Error Handling & Output):
├── 03-001 (Structured Errors) ──┬──> 03-002, 03-003
├── 03-002 (No Interactive Prompts) ┼──> 03-003
└── 03-003 (Output Channels) ───────┴──> 04-001

Phase 04 (Session Integration):
├── 04-001 (Session Hooks) ────────┬──> 04-002, 05-001
└── 04-002 (Agent Skills) ──────────┘

Phase 05 (Content Experience):
├── 05-001 (Content First) ─────────┬──> 05-002
└── 05-002 (Contextual Disclosure) ──┘
```

## Parallel Development Strategy

### Phase 01
All 3 stories can be developed in parallel using Git worktrees since they have no dependencies on each other.

### Phase 02
All 4 stories can be developed in parallel. Stories 02-001 and 02-002 depend on Phase 01 completion but not on each other.

### Phase 03
All 3 stories can be developed in parallel. Stories depend on Phase 02 completion but not on each other.

### Phase 04
Both stories can be developed in parallel. Stories depend on Phase 03 completion but not on each other.

### Phase 05
Both stories must be developed sequentially. Story 05-002 depends on 05-001 completion.

## Total Effort Estimate

- **Total Stories**: 14
- **Total Phases**: 5
- **Estimated Duration**: 2 weeks (aligned with PRD timeline)
- **Parallel Development**: Enabled for 12/14 stories (86%)
- **Sequential Bottlenecks**: Phase transitions, 05-001 → 05-002

## AXI Requirements Coverage

### Phase 01 Coverage (AXI Requirements #1-2)
- AXI Requirement #1: Mode Selection (01-001)
- AXI Requirement #2: TOON Format (01-002)
- Config Updates (01-003)

### Phase 02 Coverage (AXI Requirements #3-6)
- AXI Requirement #3: Minimal Default Schemas (02-001)
- AXI Requirement #4: Content Truncation (02-002)
- AXI Requirement #5: Pre-computed Aggregates (02-003)
- AXI Requirement #6: Definitive Empty States (02-004)

### Phase 03 Coverage (AXI Requirement #7)
- AXI Requirement #7: Structured Errors & Exit Codes (03-001)
- No Interactive Prompts (03-002)
- Output Channels Separation (03-003)

### Phase 04 Coverage (AXI Requirements #8-9)
- AXI Requirement #8: Ambient Context via Session Integrations (04-001)
- AXI Requirement #9: Installable Agent Skill (04-002)

### Phase 05 Coverage (AXI Requirements #10-11)
- AXI Requirement #10: Content First (05-001)
- AXI Requirement #11: Contextual Disclosure (05-002)

## TypeScript-Specific Implementation Notes

### File Extensions
- Source files: `.mts` (TypeScript modules)
- Test files: `.test.mts`
- Config files: `.yaml`, `.json`
- Scripts: `.mjs` (JavaScript modules)

### npm/Node.js Ecosystem Libraries
- CLI argument parsing: `commander` or `yargs`
- Config management: `cosmiconfig` or `rc`
- Output formatting: Custom TOON implementation
- Logging: `pino` or `winston`
- File operations: `fs-extra` or `node:fs/promises`
- Process detection: `node:process`, `node:os`

### TypeScript Patterns
- Use strict type checking
- Leverage interfaces for schemas
- Use async/await for I/O operations
- Implement proper error handling with try/catch
- Use JSDoc for documentation

## Success Metrics

- Agent mode works correctly with auto-detection
- TOON format achieves ~40% token savings over JSON
- Session hooks install correctly and provide context
- All AXI requirements (1-11) implemented and tested
- Human mode retains all existing functionality
- 90%+ test coverage for agent mode features
- Agent skill generation works correctly
- Content-first no-args shows relevant state
- Contextual suggestions are relevant and actionable

## Related Documentation

- PRD: `internal-docs/feature/20260708-cli-typescript-aix/prd.md`
- ADR: `adr-20260607001-cli-tool-standards.md` (Agent Mode Standards section)
- AXI Spec: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- TOON Spec: https://toonformat.dev/reference/spec.html
