---
# Product Requirements Document (PRD)

## Introduction / Overview
- **Feature name:** TypeScript CLI AXI (Agent eXperience Interface) Support
- **Summary:** Implementation of agent mode standards following the AXI specification to enable autonomous AI agents to efficiently interact with TypeScript CLI tools via shell execution, while preserving human-friendly features.
- **Context:**
  - This feature extends the TypeScript CLI boilerplate to support agent mode as defined in ADR-20260607001 (CLI Tool Standards v4.0.0)
  - AXI optimizes CLIs for autonomous agent consumption with token-efficient output, structured data, and session integrations
  - Target users: AI agents (Claude Code, Codex, OpenCode) that interact with CLIs via shell execution
  - Related ADR: adr-20260607001-cli-tool-standards.md (Agent Mode Standards section)
  - Reference spec: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
  - Implementation priority: High - to be implemented after core CLI standards are complete

## Goals
- Enable autonomous AI agents to efficiently use TypeScript CLI tools with minimal token consumption
- Provide agent mode as default behavior with human mode available via explicit selection
- Implement session hook infrastructure for ambient context injection
- Support TOON format for token-efficient structured output
- Maintain full backward compatibility with existing human-centric features
- Complete implementation within 1-2 weeks timeline

## User Stories

### As an AI agent using a TypeScript CLI tool
- I want token-efficient TOON output so that I can parse responses quickly and minimize token costs
- I want minimal default schemas (3-4 fields) so that I get just enough information to decide next steps
- I want content truncation with escape hatches so that I can preview large fields without wasting tokens
- I want pre-computed aggregates (total counts, derived status) so that I don't need follow-up calls
- I want definitive empty states so that I know when a query has no results
- I want structured errors on stdout so that I can parse and act on failures programmatically
- I want idempotent operations so that repeating commands doesn't cause errors
- I want no interactive prompts so that all operations are completable via flags alone
- I want content-first no-args output so that I can see live state immediately
- I want contextual disclosure with next steps so that I can discover CLI capabilities organically

### As a developer using the TypeScript CLI boilerplate
- I want agent mode to be the default so that AI agents work optimally without configuration
- I want human mode available via `--human` or `--interactive` flags so that I can use the CLI normally
- I want auto-detection based on environment so that the right mode is chosen automatically
- I want session hook infrastructure so that agents can integrate with the CLI lifecycle
- I want TOON format as an optional output format alongside JSON and human-readable
- I want comprehensive testing for agent mode features so that agent interactions are reliable

### As a DevOps engineer deploying TypeScript CLI tools
- I want the CLI to work seamlessly in both agent and human environments
- I want consistent behavior across different invocation contexts
- I want clear documentation on mode selection and configuration

## Functional Requirements

### Mode Selection (AXI Requirement #1)
1. **Default Agent Mode**
   - Agent mode is the default behavior when no explicit mode selection is provided
   - Auto-detection: Use agent mode when TTY is not present OR when agent session is detected
   - Agent session detection: Check for environment variables like `CLAUDE_SESSION`, `CODEX_SESSION`, or presence of agent-specific process parents

2. **Human Mode Triggers**
   - Explicit `--human` flag forces human mode
   - Explicit `--interactive` or `--tui` flag forces human mode
   - Auto-detection: Use human mode when TTY is present AND no agent session is detected
   - Config file setting: `mode = "agent" | "human"` in config file
   - Environment variable: `MYTOOL_MODE=agent|human` (highest precedence after CLI args)

3. **Mode Precedence Chain**
   - CLI flags (`--human`, `--interactive`) > Environment variable (`MYTOOL_MODE`) > Config file setting > Auto-detection

### Token-Efficient Output (TOON Format) (AXI Requirement #2)
4. **TOON Format Implementation**
   - Add `--toon` flag to output in TOON format (Token-Oriented Object Notation)
   - TOON provides ~40% token savings over equivalent JSON
   - Convert to TOON at output boundary — keep internal logic in JSON
   - In agent mode, default to TOON format for stdout
   - In human mode, continue using JSON or human-readable formats
   - Support `--format=toon|json|human` flag for explicit format selection

5. **TOON Format Specification**
   - Follow TOON format specification: https://toonformat.dev/reference/spec.html
   - Use compact, agent-readable syntax
   - Example: `tasks[2]{id,title,status,assignee}: "1",Fix auth bug,open,alice "2",Add pagination,closed,bob`
   - Implement TOON encoder/decoder for TypeScript/JavaScript

### Minimal Default Schemas (AXI Requirement #3)
6. **Default Output Schema Design**
   - Default list schemas: 3-4 fields (identifier, title, status), not 10+
   - Default limits: high enough for common cases (e.g., 100 items if most repos have <100)
   - Long-form content (bodies, descriptions) belongs in detail views, not lists
   - Offer `--fields` flag to let agents request additional fields explicitly
   - Example: `mytool list --fields id,title,status,assignee,priority`

7. **Schema Implementation**
   - Define default output schemas for each command
   - Implement field selection logic
   - Support comma-separated field names in `--fields` flag
   - Validate field names against available fields
   - Apply schema to both TOON and JSON output formats

### Content Truncation (AXI Requirement #4)
8. **Truncation Strategy**
   - Truncate large text fields by default (500-1500 chars)
   - Never omit large fields entirely — always include a truncated preview
   - Show total size so the agent knows how much it's missing
   - Suggest escape hatch (`--full`) only when content is actually truncated
   - Choose truncation limit that covers most use cases (configurable, default 1000 chars)

9. **Truncation Implementation**
   - Add `--full` flag to disable truncation and show complete content
   - Implement truncation logic for all large text fields (descriptions, bodies, logs)
   - Include truncation metadata in output: `... (truncated, 8432 chars total)`
   - Add help suggestions: `help[1]: Run mytool view 42 --full to see complete body`
   - Apply to both agent and human modes

### Pre-computed Aggregates (AXI Requirement #5)
10. **Aggregate Counts**
    - Include total count in list output, not just page size
    - Format: `count: 30 of 847 total`
    - Agents need "how many are there?" and will paginate if answer isn't definitive
    - Compute counts efficiently at query time

11. **Derived Status Fields**
    - Include lightweight summary inline when next step commonly involves checking related state
    - Only include derived fields backend can provide cheaply
    - Example: `checks: 3/3 passed`, `comments: 7`
    - Provide summary, not full data
    - Apply to detail views and list views where relevant

### Definitive Empty States (AXI Requirement #6)
12. **Empty State Formatting**
    - When answer is "nothing", say so explicitly
    - State the zero with context
    - Make clear command succeeded — absence of results is the answer
    - Example: `tasks: 0 closed tasks found in this repository`

13. **Empty State Implementation**
    - Detect empty result sets across all commands
    - Format empty states consistently
    - Include context (filter criteria, scope)
    - Ensure exit code 0 for successful empty queries

### Structured Errors & Exit Codes (AXI Requirement #7)
14. **Idempotent Mutations**
    - Don't error when desired state already exists
    - If agent closes something already closed, acknowledge and move on with exit code 0
    - Reserve non-zero exit codes for situations where agent's intent cannot be satisfied
    - Example: `task: #42 already closed (no-op) # exit 0`

15. **Structured Errors on Stdout**
    - Errors go to stdout in same structured format as normal output
    - Include what went wrong and actionable suggestion
    - Never let raw dependency output (API errors, stack traces) leak through
    - Example: `error: --title is required help: tasks create --title "..." [--body "..."]`
    - Validate required flags before calling any dependency
    - Translate errors — extract actionable meaning, discard noise
    - Never leak dependency names — suggestions reference CLI's commands, not underlying tools

16. **No Interactive Prompts**
    - Every operation must be completable with flags alone
    - If required value is missing, fail immediately with clear error — don't prompt
    - Suppress prompts from wrapped tools in agent mode
    - Human mode can retain prompts (unless `--force` is used)

17. **Output Channels**
    - stdout: structured output (data, errors, suggestions)
    - stderr: debug logging, progress indicators, diagnostics (agents don't read this)
    - Exit codes: 0 = success (including no-ops), 1 = error, 2 = usage error
    - Never mix progress messages into stdout

### Ambient Context via Session Integrations (AXI Requirement #8)
18. **Session Hook Infrastructure**
    - Add `--session-context` command that outputs compact state in TOON format
    - Output should be token-budget-aware (ruthlessly minimized)
    - Include just enough for agent to orient and act; deep data belongs in explicit invocations
    - Directory-scoped: show only state relevant to current working directory
    - Example output: `tasks[2]{id,title,status}: 1,Fix bug,open 2,Add feature,closed help[1]: Run mytool view <id> for details`

19. **Setup Command for Hooks**
    - Add `--install-agent-hooks` command to register session hooks
    - Check existing hooks and update executable path if changed
    - Idempotent: repeated installs with same path are silent no-ops
    - Portable commands: use PATH-verified binary name, fall back to absolute path
    - Explicit opt-in: only register from user-invoked setup command, not ordinary CLI commands
    - Support hook installation for:
      - Claude Code: `~/.claude/settings.json` or project `.claude/settings.json`
      - Codex: `~/.codex/hooks.json` or project `.codex/hooks.json`
      - Future: OpenCode plugin system

20. **Lifecycle Capture**
    - Use session-end hooks to capture what happened (transcripts, files touched, specs referenced)
    - Future session-start context gets richer over time
    - Implement session-end hook registration in setup command
    - Store session metadata in local cache for future context enrichment

### Installable Agent Skill (AXI Requirement #9)
21. **Agent Skill Support**
    - Generate `SKILL.md` from same content as no-args home view
    - Add `--check-skill` build step to CI that fails if committed skill is stale
    - Strip live state from skill (static only, no dynamic data like open sessions)
    - Rewrite command examples to non-interactive form (e.g., `npx -y mytool ...`)
    - Include trigger-shaped frontmatter: `name` and `description` as trigger
    - Document both paths (hook and skill) in README
    - Make clear user only needs one (hook or skill)

22. **Skill Generation**
    - Add `--generate-skill` command to output SKILL.md content
    - Template-based generation from CLI help and examples
    - Include in CI/CD pipeline for automatic skill updates
    - Support skill installation via agentskills.io

### Content First (AXI Requirement #10)
23. **No-Args Behavior**
    - Running CLI with no arguments shows most relevant live content, not usage manual
    - When agent sees actual state, it can act immediately
    - When it sees help text, it has to make a second call
    - Example: `$ mytool` outputs `tasks[3]{id,title,status}: 1,Fix bug,open 2,Add feature,open 3,Update docs,closed help[2]: Run mytool view <id> for details Run mytool create --title "..." to add a task`

24. **Content-First Implementation**
    - Redesign no-args invocation to show state summary
    - Move detailed help to `--help` flag (unchanged)
    - Apply to both agent and human modes
    - Show different content based on current directory/context

### Contextual Disclosure (AXI Requirement #11)
25. **Next Steps Suggestions**
    - Include few next steps that follow logically from current output
    - Agent discovers CLI surface area organically by using it
    - Relevant: after open item → suggest closing; after empty list → suggest creating; after list → suggest viewing
    - Actionable: every suggestion is complete command carrying forward disambiguating flags
    - Concise: 2-4 suggestions maximum, ranked by relevance
    - Structured: use `help[]` array in TOON output for machine parsing

26. **Contextual Disclosure Implementation**
    - Add suggestion engine for each command
    - Generate contextual help based on current state and output
    - Format as structured `help[]` array in TOON
    - Include in all command outputs
    - Make suggestions smart (context-aware, not generic)

## Non-Functional Requirements
- **Performance**: TOON encoding/decoding must add minimal overhead (<10ms)
- **Token Efficiency**: TOON output must achieve ~40% token savings over equivalent JSON
- **Backward Compatibility**: All existing human-centric features must work unchanged
- **Testing**: Comprehensive test coverage for all agent mode features
- **Documentation**: Clear documentation on mode selection, TOON format, and session integration
- **Maintainability**: Code must follow TypeScript/JavaScript best practices and existing boilerplate patterns

## Technical Considerations
- **TOON Library**: Implement custom TOON encoder/decoder or find npm package
- **Mode Detection**: Use environment variable checks and process parent detection
- **Session Hooks**: Use file-based configuration for hook registration
- **Schema System**: Implement field selection and validation system
- **Truncation**: Add configurable truncation with metadata
- **Aggregation**: Optimize count queries and derived field computation
- **Error Handling**: Centralize error formatting and translation
- **Skill Generation**: Template-based SKILL.md generation from CLI metadata
- **Dependencies**: Leverage existing Node.js ecosystem (commander, yargs, inquirer) where possible
- **Config Management**: Extend existing config system for mode settings

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

## Open Questions
- Should TOON format be the default in agent mode, or require explicit `--toon` flag?
- What specific session metadata should be captured for lifecycle enrichment?
- Should skill generation be automated in CI or manual?
- How should truncation limits be configured (global, per-field, per-command)?

## Dependencies
- ADR-20260607001 v4.0.0 (CLI Tool Standards with Agent Mode) - must be followed exactly
- AXI specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- TOON format specification: https://toonformat.dev/reference/spec.html
- Existing TypeScript CLI boilerplate - must be extended, not replaced
- Core CLI standards implementation (20260707-cli-typescript-standards) - should be complete first

## Timeline / Milestones
- **Week 1**: Implement mode selection, TOON format, minimal schemas, content truncation, pre-computed aggregates, empty states
- **Week 2**: Implement structured errors, session hook infrastructure, agent skill support, content-first no-args, contextual disclosure, comprehensive testing

---
*Generated from PRD template*
