# Python CLI AXI - Task Index

## Overview

This index summarizes all stories for the Python CLI AXI (Agent eXperience Interface) implementation, organized into 5 sequential phases with parallel development tracks. The implementation follows the AXI specification to enable autonomous AI agents to efficiently interact with Python CLI tools via shell execution.

## Phase Summary

- **Phase 01**: Core Infrastructure (3 stories) - Mode selection, TOON format, config updates
- **Phase 02**: Output Optimization (4 stories) - Minimal schemas, content truncation, aggregates, empty states
- **Phase 03**: Error Handling & Idempotency (3 stories) - Structured errors, no prompts, idempotent operations
- **Phase 04**: Session Integration (2 stories) - Session hooks, agent skills
- **Phase 05**: UX Enhancement (2 stories) - Content-first no-args, contextual disclosure

## Story Details

### Phase 01: Core Infrastructure (Week 1)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 01-001 | Mode Selection Implementation | feature/current/20260708-cli-python-aix/story-01-001-mode-selection | None | Parallel-safe: true | [cli.py, config.py] |
| 01-002 | TOON Format Implementation | feature/current/20260708-cli-python-aix/story-01-002-toon-format | None | Parallel-safe: true | [output.py, toon.py] |
| 01-003 | Config Updates for Agent Mode | feature/current/20260708-cli-python-aix/story-01-003-config-updates | None | Parallel-safe: true | [config.py] |

### Phase 02: Output Optimization (Week 1)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 02-001 | Minimal Default Schemas | feature/current/20260708-cli-python-aix/story-02-001-minimal-schemas | 01-002 | Parallel-safe: true | [output.py, schema.py] |
| 02-002 | Content Truncation | feature/current/20260708-cli-python-aix/story-02-002-content-truncation | 01-002 | Parallel-safe: true | [output.py, truncation.py] |
| 02-003 | Pre-computed Aggregates | feature/current/20260708-cli-python-aix/story-02-003-aggregates | 02-001 | Parallel-safe: true | [output.py, aggregates.py] |
| 02-004 | Definitive Empty States | feature/current/20260708-cli-python-aix/story-02-004-empty-states | 02-001 | Parallel-safe: true | [output.py, empty.py] |

### Phase 03: Error Handling & Idempotency (Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 03-001 | Structured Errors & Exit Codes | feature/current/20260708-cli-python-aix/story-03-001-structured-errors | 02-004 | Parallel-safe: true | [errors.py, output.py] |
| 03-002 | No Interactive Prompts | feature/current/20260708-cli-python-aix/story-03-002-no-prompts | 03-001 | Parallel-safe: true | [cli.py, prompts.py] |
| 03-003 | Idempotent Operations | feature/current/20260708-cli-python-aix/story-03-003-idempotent-ops | 03-001, 03-002 | Parallel-safe: true | [operations.py, idempotent.py] |

### Phase 04: Session Integration (Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 04-001 | Session Hook Infrastructure | feature/current/20260708-cli-python-aix/story-04-001-session-hooks | 03-003 | Parallel-safe: true | [hooks.py, session.py] |
| 04-002 | Installable Agent Skill | feature/current/20260708-cli-python-aix/story-04-002-agent-skills | 04-001 | Parallel-safe: true | [skills.py, skill_generator.py] |

### Phase 05: UX Enhancement (Week 2)

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Modules |
| -------- | ----------- | ------ | ------------ | ------------- | ------- |
| 05-001 | Content First No-Args | feature/current/20260708-cli-python-aix/story-05-001-content-first | 04-002 | Parallel-safe: false | [cli.py, output.py] |
| 05-002 | Contextual Disclosure with Next Steps | feature/current/20260708-cli-python-aix/story-05-002-contextual-disclosure | 05-001 | Parallel-safe: false | [output.py, suggestions.py] |

## Dependency Graph

```
Phase 01 (Core Infrastructure):
├── 01-001 (Mode Selection) ────────┤
├── 01-002 (TOON Format) ───────────┼──> 02-001, 02-002
└── 01-003 (Config Updates) ────────┘

Phase 02 (Output Optimization):
├── 02-001 (Minimal Schemas) ───────┼──> 02-003, 02-004
├── 02-002 (Content Truncation) ─────┤
├── 02-003 (Aggregates) ─────────────┤
└── 02-004 (Empty States) ───────────┴──> 03-001

Phase 03 (Error Handling & Idempotency):
├── 03-001 (Structured Errors) ───────┼──> 03-002, 03-003
├── 03-002 (No Prompts) ───────────────┼──> 03-003
└── 03-003 (Idempotent Ops) ───────────┴──> 04-001

Phase 04 (Session Integration):
├── 04-001 (Session Hooks) ───────────┼──> 04-002
└── 04-002 (Agent Skills) ─────────────┴──> 05-001

Phase 05 (UX Enhancement):
├── 05-001 (Content First) ────────────┼──> 05-002
└── 05-002 (Contextual Disclosure) ────┘
```

## Parallel Development Strategy

### Phase 01
All 3 stories can be developed in parallel using Git worktrees since they have no dependencies on each other.

### Phase 02
All 4 stories can be developed in parallel. Stories 02-001 and 02-002 depend on Phase 01 completion but not on each other. Stories 02-003 and 02-004 depend on 02-001.

### Phase 03
All 3 stories can be developed in parallel. Story 03-001 depends on Phase 02 completion. Stories 03-002 and 03-003 depend on 03-001.

### Phase 04
Both stories can be developed in parallel. Story 04-002 depends on 04-001.

### Phase 05
Both stories must be developed sequentially. Story 05-002 depends on 05-001. Neither is parallel-safe due to UX changes affecting the entire CLI.

## Total Effort Estimate

- **Total Stories**: 14
- **Total Phases**: 5
- **Estimated Duration**: 2 weeks (aligned with PRD timeline)
- **Parallel Development**: Enabled for 12/14 stories (86%)
- **Sequential Bottlenecks**: Phase transitions, 05-001 → 05-002

## AXI Requirements Coverage

### Phase 01 Coverage (Requirements #1-2)
- Requirement #1: Mode Selection (01-001)
- Requirement #2: TOON Format (01-002)
- Config Updates (01-003)

### Phase 02 Coverage (Requirements #3-6)
- Requirement #3: Minimal Default Schemas (02-001)
- Requirement #4: Content Truncation (02-002)
- Requirement #5: Pre-computed Aggregates (02-003)
- Requirement #6: Definitive Empty States (02-004)

### Phase 03 Coverage (Requirements #7)
- Requirement #7: Structured Errors & Exit Codes (03-001)
- No Interactive Prompts (03-002)
- Idempotent Operations (03-003)

### Phase 04 Coverage (Requirements #8-9)
- Requirement #8: Session Hook Infrastructure (04-001)
- Requirement #9: Installable Agent Skill (04-002)

### Phase 05 Coverage (Requirements #10-11)
- Requirement #10: Content First (05-001)
- Requirement #11: Contextual Disclosure (05-002)

## Python Ecosystem Libraries

The implementation leverages Python CLI libraries:

- **click**: For CLI argument parsing and command structure
- **typer**: Alternative CLI framework with type hints
- **argparse**: Standard library CLI argument parser
- **pyyaml**: For config file parsing
- **rich**: For terminal output formatting (human mode)
- **colorama**: For cross-platform color support

## Risk Assessment

### High Risk Stories
- 01-002: TOON Format (new format, specification changes)
- 03-001: Structured Errors (error translation complexity)
- 04-001: Session Hooks (cross-platform hook installation)

### Medium Risk Stories
- 01-001: Mode Selection (detection reliability)
- 02-003: Aggregates (performance impact)
- 04-002: Agent Skills (template maintenance)

### Low Risk Stories
- 01-003: Config Updates (straightforward schema changes)
- 02-001: Minimal Schemas (well-defined requirements)
- 02-002: Content Truncation (simple logic)
- 02-004: Empty States (formatting only)
- 03-002: No Prompts (suppression logic)
- 03-003: Idempotent Ops (state checking)
- 05-001: Content First (UX change)
- 05-002: Contextual Disclosure (suggestion logic)

## Success Metrics

- Agent mode works correctly with auto-detection
- TOON format achieves ~40% token savings over JSON
- Session hooks install correctly and provide context
- All agent mode requirements (1-11) implemented and tested
- Human mode retains all existing functionality
- 90%+ test coverage for agent mode features
- Agent skill generation works correctly
- Content-first no-args shows relevant state
- Contextual suggestions are relevant and actionable

## Notes

- All stories use Python-specific file extensions (.py)
- Implementation follows existing Python CLI boilerplate patterns
- Config system extends existing config from core CLI standards
- Testing uses pytest with coverage reporting
- Linting uses ruff and black
- Type checking uses mypy
