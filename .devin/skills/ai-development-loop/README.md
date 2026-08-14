# AI Development Loop Skill

A comprehensive skill that codifies the systematic workflow for AI agents working with ticketr to ensure consistent, high-quality development cycles with reflection and continuous improvement.

## Overview

This skill enhances the basic AI Development Loop from ticketr with:

- **Systematic workflow** with clear steps and quality gates
- **Reflection phase** for continuous improvement
- **Opportunity identification** for boilerplate, workflows, skills, and templates
- **Integration patterns** with other skills
- **Helper script** for common operations

## Files Structure

```
ai-development-loop/
├── SKILL.md          # Main skill documentation with workflow
├── REFERENCE.md      # Comprehensive reference guide and command reference
├── EXAMPLES.md       # Practical examples across different scenarios
├── README.md         # This file - overview and setup
└── scripts/
    └── dev-loop-helper.sh  # Helper script for workflow automation
```

## Quick Start

1. **Install the helper script** (optional but recommended):
   ```bash
   # Add to your PATH or create an alias
   alias dev-loop="/path/to/skills/software-dev/ai-development-loop/scripts/dev-loop-helper.sh"
   ```

2. **Run foundation check**:
   ```bash
   dev-loop foundation
   ```

3. **Get next ticket**:
   ```bash
   dev-loop next
   ```

4. **Start work**:
   ```bash
   dev-loop start ja-1234
   ```

5. **Complete work**:
   ```bash
   dev-loop complete ja-1234
   ```

6. **Reflect on the work**:
   ```bash
   dev-loop reflect ja-1234
   ```

## Core Workflow

### 9-Step Development Loop

1. **Foundation Check** - Ensure clean starting state
2. **Ticket Selection** - Grab next actionable ticket
3. **Start Work** - Mark ticket as in_progress
4. **High Quality** - Ensure upstream has adequate testing and testable
5. **Strategy** - Determine implementation approach (reuse, dependency, new package, external service)
6. **Implementation** - Do the actual work
7. **Verification** - Add/update/run tests and validate
8. **Completion** - Mark ticket ready/closed
9. **Commit & Loop** - Commit changes and repeat from step 2

### Workflow Principles

- **Atomic Operations**: Update ticket status immediately
- **High Quality**: Always try to add quality tests to any work in progress, or any old code inadequately tested
- **Verification First**: Always run tests before completion
- **Documentation Updates**: Update docs as part of work
- **Quality Gates**: All tests must pass before completion

## Enhanced Features

### Reflection Phase

After each completed cycle, perform systematic reflection:

- **Process Reflection**: What went well, obstacles, improvements
- **Technical Reflection**: Patterns, technical debt, refactoring opportunities
- **Documentation Reflection**: Documentation needs, patterns to codify
- **Tooling Reflection**: Tool effectiveness, missing tools, automation opportunities

### Opportunity Identification

Actively identify opportunities during reflection:

- **Boilerplate Opportunities**: Repeated patterns that could become templates
- **Workflow Opportunities**: Manual steps that could be automated
- **Skill Opportunities**: Expertise that should be codified
- **Template Opportunities**: Reusable document/code structures

### Handling No Tickets Scenarios

When no tickets are available, the skill provides a foundation-first workflow:

### Automatic Detection
The `dev-loop next` command will:
- Report "No ready tickets found"
- Show current ticket status
- Suggest alternative actions
- Recommend running foundation checks

### Foundation-First Workflow
Use `dev-loop no-tickets` to:
1. **Run foundation checks** - Ensure system is ready
2. **Identify opportunities** - Look for improvements
3. **Suggest next steps** - Create tickets, update docs, refactor
4. **Show system status** - Git state, repository info

### Alternative Activities When No Tickets
- **System improvements** - Update dependencies, fix technical debt
- **Documentation** - Update README, create templates, improve examples
- **Refactoring** - Address code smells, improve architecture
- **Tooling** - Improve scripts, add automation, enhance workflows
- **Create tickets** - Document identified work for future sessions

### Example Workflow
```bash
# Check for tickets
dev-loop next
# Output: "No ready tickets found"

# Run foundation-first workflow
dev-loop no-tickets
# Runs foundation checks and suggests next steps

# Create new tickets based on findings
tkr create "Update documentation for API endpoints"
tkr create "Refactor authentication service"
```

## Helper Script Commands

```bash
# Helper script commands
dev-loop foundation

# Ticket management
dev-loop next                    # Get next ready ticket
dev-loop start <id>             # Start work on ticket
dev-loop complete <id>          # Mark ticket as ready
dev-loop close <id>             # Mark as completed
dev-loop show <id>              # Show ticket details
dev-loop list [status]          # List tickets by status

# Reflection and status
dev-loop reflect <id>            # Reflection helper
dev-loop status                 # Status overview

# No tickets scenario
dev-loop no-tickets             # Handle no tickets workflow

# Help
dev-loop help                    # Show all commands
```

## Quality Gates

Before marking any ticket complete, verify:

- [ ] Foundation checks passed (clean repo, tests pass)
- [ ] Ticket status updated appropriately
- [ ] Implementation meets requirements
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] Code follows established patterns
- [ ] Dependencies properly handled
- [ ] Reflection completed
- [ ] Opportunities identified and tracked
- [ ] Changes committed

## Examples Included

- **Feature Implementation**: JWT authentication example
- **Bug Fix**: Memory leak resolution example
- **Infrastructure Update**: Docker security hardening example
- **Documentation Update**: API documentation example
- **Refactoring**: Microservice extraction example

See `EXAMPLES.md` for complete walkthroughs.

## Metrics and KPIs

Track these metrics to measure effectiveness:

- **Cycle Time**: Start → Ready → Close times
- **Quality Metrics**: Test coverage, lint issues, security issues
- **Process Metrics**: Reflection completion, opportunity identification
- **Opportunity Metrics**: Boilerplate/workflow/skill opportunities found

## Troubleshooting

### Common Issues

- **Tests failing**: Check if tests need updating or implementation is incorrect
- **Linting errors**: Run with auto-fix if available, then manual fixes
- **Merge conflicts**: Rebase onto latest main, resolve conflicts carefully
- **Stuck tickets**: Add clarification notes, create dependency tickets, split work

### Getting Unstuck

1. Review requirements and check understanding
2. Look for similar implementations in codebase
3. Ask for clarification if ambiguous
4. Document blockers and create tickets for them
5. Split large tasks into smaller tickets

## Integration with ticketr

This skill is designed to work seamlessly with the ticketr CLI tool. Key commands:

```bash
tkr ready                    # Get next actionable ticket
tkr start <id>              # Mark as in_progress
tkr ready <id>              # Mark as ready for review
tkr close <id>              # Mark as completed
tkr add-note <id> "message" # Add timestamped note
tkr show <id>               # Show ticket details
tkr list --status=open      # List open tickets
```

## Continuous Improvement Loop

The AI agent should:

1. **Reflect** on each completed cycle
2. **Learn** from issues encountered
3. **Improve** the process for next iteration
4. **Document** new patterns and decisions

This creates a virtuous cycle where each iteration improves the development process.

## References

- ticketr CLI documentation: `tkr help`
- Project AGENTS.md for specific patterns
- ai-upsert for codifying discovered patterns
- Workflow templates in `.windsurf/workflows/`

---

*This skill ensures consistent, high-quality development while maintaining clear ticket state tracking and continuously improving the development process through reflection and opportunity identification.*
