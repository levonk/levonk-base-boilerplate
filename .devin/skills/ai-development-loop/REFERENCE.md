# AI Development Loop - Reference Guide

## Command Reference

### ticketr Commands
```bash
# Ticket management
tkr ready                    # Get next actionable ticket
tkr list --status=open       # List all open tickets
tkr show <ticket-id>         # Show ticket details
tkr start <ticket-id>        # Mark as in_progress
tkr ready <ticket-id>        # Mark as ready for review
tkr close <ticket-id>        # Mark as completed
tkr dep <ticket-id> <dep-id> # Add dependency

# Notes and communication
tkr add-note <ticket-id> "message"  # Add timestamped note

# Status and filtering
tkr list --status=in_progress  # Show work in progress
tkr list --status=ready         # Show ready for review
tkr list --status=closed       # Show completed tickets
```

### Git Commands
```bash
# Foundation checks
git status                   # Check working directory state
git pull origin main         # Update to latest
git log --oneline -5         # Show recent commits

# Commit workflow
git add .                    # Stage all changes
git commit -m "type: description

detailed explanation

Fixes: ticket-id"
git push origin feature-branch
```

### Quality Commands
```bash
# Common quality gates (varies by project)
just test                    # Run test suite
just lint                    # Run linting
just typecheck               # Run type checking
just build                   # Build project
just security                # Run security scans
```

## Status Flow Diagram

```
    ┌─────────┐
    │   open  │ ←──────────────┐
    └────┬────┘               │
         │                    │
         ▼                    │
┌─────────────┐               │
│ in_progress │               │
└─────┬───────┘               │
      │                       │
      ▼                       │
┌─────────────┐               │
│    ready    │ ──────────────┘
└─────┬───────┘
      │
      ▼
┌─────────────┐
│   closed    │
└─────────────┘
```

## Reflection Template

Use this template after each completed cycle:

### Process Reflection
- **What went well**: 
- **What obstacles**: 
- **Process improvements**: 

### Technical Reflection
- **Patterns discovered**: 
- **Technical debt identified**: 
- **Refactoring opportunities**: 

### Documentation Reflection
- **Docs updated**: 
- **Docs needed**: 
- **Decisions to record**: 

### Tooling Reflection
- **Tools effective**: 
- **Tools missing**: 
- **Automation opportunities**: 

### Opportunities Identified
- **Boilerplate**: 
- **Workflows**: 
- **Skills**: 
- **Templates**: 

## Opportunity Tracking

### Boilerplate Opportunities
Track patterns that should become boilerplate:

| Pattern | Location | Frequency | Action |
|---------|----------|-----------|--------|
| Component structure | apps/*/src/components/ | High | Create component boilerplate |
| API endpoint | apps/*/src/api/ | Medium | Create API template |
| Test setup | */tests/ | High | Create test template |

### Workflow Opportunities
Track command sequences that could be automated:

| Sequence | Commands | Frequency | Proposed Workflow |
|----------|----------|-----------|------------------|
| New feature setup | git branch, tkr start, just test | Daily | /new-feature-setup |
| Release process | git tag, build, deploy | Weekly | /release-workflow |
| Bug triage | tkr list, reproduce, document | Daily | /bug-triage |

### Skill Opportunities
Track expertise that should be codified:

| Domain | Expertise | Used In | Skill Status |
|--------|----------|---------|-------------|
| Authentication | JWT implementation | Multiple apps | Identified |
| Database | Migration patterns | All services | Draft skill created |
| Testing | Integration test setup | All projects | Existing skill |

## Integration Patterns

### With Code Review Skill
- Use code-review skill during verification step
- Apply code-review checklist before marking ready
- Document review findings in ticket notes

### With Frontend Design Skill
- Use for UI/UX implementation tickets
- Apply design system verification
- Include design review in verification step

### With AI Skill Create
- Use reflection outcomes to create new skills
- Codify discovered patterns as skills
- Update existing skills based on learnings

## Quality Gates Checklist

### Pre-Work Gates
- [ ] Repository is clean (git status)
- [ ] On latest main (git pull)
- [ ] Tests pass (just test)
- [ ] Lint passes (just lint)
- [ ] On feature branch (not main)

### Implementation Gates
- [ ] Ticket started (tkr start)
- [ ] Requirements understood
- [ ] Tests written (TDD)
- [ ] Code follows patterns
- [ ] Documentation updated

### Pre-Completion Gates
- [ ] All tests pass
- [ ] No linting errors
- [ ] Type checking passes
- [ ] Manual verification done
- [ ] Dependencies handled

### Post-Completion Gates
- [ ] Ticket marked ready/closed
- [ ] Changes committed
- [ ] Reflection completed
- [ ] Opportunities documented
- [ ] Learnings shared

## Common Patterns

### Ticket Naming Convention
```
ja-<hash>     # Job-Aide tickets
tk-<hash>     # Ticketr tickets
feature-<name> # Feature branches
fix-<issue>   # Bug fix branches
```

### Commit Message Format
```
type(scope): description

detailed explanation if needed

Fixes: ticket-id
```

Types: feat, fix, docs, style, refactor, test, chore

### Branch Naming
```
feature/feature-name
fix/issue-description
hotfix/critical-fix
```

## Troubleshooting Guide

### Stuck Tickets
**Symptom**: Can't proceed with ticket
**Causes**:
- Requirements unclear
- Dependencies blocked
- Technical obstacles

**Solutions**:
1. Add clarification note to ticket
2. Create dependency tickets
3. Break into smaller tickets

### Test Failures
**Symptom**: Tests failing after implementation
**Causes**:
- Test expectations outdated
- Implementation incorrect
- Environment issues

**Solutions**:
1. Run tests individually for details
2. Update tests if requirements changed
3. Check environment setup

### Merge Conflicts
**Symptom**: Can't merge feature branch
**Causes**:
- Main branch updated
- Overlapping changes

**Solutions**:
1. Rebase onto latest main
2. Resolve conflicts carefully
3. Run full test suite after resolution

## Metrics and KPIs

### Cycle Time Metrics
- **Start → Ready**: Implementation time
- **Ready → Closed**: Review time
- **Open → Closed**: Total cycle time

### Quality Metrics
- **Test coverage**: Percentage of code covered
- **Lint issues**: Number of linting errors
- **Bug rate**: Bugs found per feature

### Process Metrics
- **Reflection completion**: % of cycles with reflection
- **Opportunity identification**: # of improvements found
- **Process adherence**: % of steps followed correctly

---

*Use this reference guide to support consistent application of the AI Development Loop skill.*
