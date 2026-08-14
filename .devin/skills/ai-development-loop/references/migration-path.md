# Migration Path and Workflow Details

## Critical Warnings: Feature and Test Preservation

### 🚨 EMPLOYMENT TERMINATION OFFENSES

**WARNING: The following actions will result in immediate termination unless explicitly requested by the ticket:**

#### 1. Feature Removal
- **NEVER** delete or remove existing features unless the ticket explicitly states "remove feature X"
- **NEVER** disable functionality that users depend on
- **NEVER** comment out or bypass existing code without explicit justification
- **ALWAYS** preserve backward compatibility when possible

#### 2. Test Coverage Reduction
- **NEVER** delete existing tests unless replacing with better coverage
- **NEVER** reduce test coverage percentages
- **NEVER** skip or disable tests without explicit ticket requirement
- **ALWAYS** maintain or improve test coverage for any code you modify

#### 3. Code Quality Degradation
- **NEVER** remove error handling or validation
- **NEVER** reduce type safety or introduce known bugs
- **NEVER** remove documentation or comments without replacement
- **ALWAYS** improve or maintain code quality standards

#### 4. Stopping Work
- **NEVER** Stop processing open tickets in the **LOOP**. If you have questions, note it on the ticket, set the ticket to blocked and move to the next ticket

#### 5. Sensitive Data Leakage
- **NEVER** Send data out of owned and operated systems without permission

#### 6. Lying to Owner
- **NEVER** knowingly misinform the owner user explicitly or indirectly via omission, or direct lies

### Verification Requirements
Before completing any ticket, verify:
- [ ] No features were removed unless explicitly required
- [ ] Test coverage was maintained or improved
- [ ] All existing functionality still works
- [ ] No regressions introduced
- [ ] Documentation reflects current state

### Exception Process
Only remove features or tests when:
1. **Ticket explicitly states**: "remove feature X" or "delete test Y"
2. **Technical debt cleanup**: With clear justification and replacement plan
3. **Security vulnerability**: With immediate replacement of affected functionality
4. **Deprecated functionality**: With proper migration path documented

**If in doubt, ASK before removing anything!**

## Workflow Principles

### 1. Atomic Operations
- Update ticket status immediately when starting work
- Update ticket status immediately when completing work
- Never leave tickets in ambiguous states

### 2. Verification First
- Always run tests before marking a ticket complete
- Ensure all linting passes
- Verify the implementation meets acceptance criteria

### 3. Documentation Updates
- Update relevant documentation as part of the work
- Add notes to tickets explaining what was done
- Keep README.md and AGENTS.md in sync

### 4. Quality Gates
- All tests must pass before completion
- Code must follow established patterns
- Dependencies must be properly resolved

### 5. Feature Preservation
- Never remove features without explicit ticket requirement
- Maintain backward compatibility when possible
- Preserve existing functionality while adding new features

## Ticket Status Flow

```text
open → in_progress → ready → closed
  ↑         ↓           ↓
  └─────── ready ←─────┘
           ↓
    stale (>7d) → open (auto-cleanup)
```

- **open**: Ready to start work
- **in_progress**: Currently being worked on (auto-cleanup after 7 days)
- **ready**: Work complete, ready for review
- **closed**: Fully completed and verified

### Stale Ticket Lifecycle

**Automatic Cleanup Process:**
1. **Detection**: System checks for tickets in `in_progress` > 7 days
2. **Reopening**: Stale tickets automatically moved to `open` status
3. **Notification**: Cleanup note added with timestamp
4. **Visibility**: Recently reopened tickets flagged in selection

**Manual Intervention:**
- Developers can manually reopen stale tickets at any time
- Team leads can override auto-cleanup for valid long-running work
- Extended deadlines can be set for complex tasks

**Preventing Stale Tickets:**
- Break large work into smaller, completable tickets
- Use `blocked` status for waiting on dependencies
- Regular progress updates keep tickets active
- Set realistic time estimates during planning

## Dependency Management

### Handling Dependencies
```bash
# Check if dependencies are resolved
tkr show <ticket-id>         # Review dependencies
tkr ready                    # See if blocked tickets are ready

# Add dependencies if needed
tkr dep <ticket-id> <dep-id>  # Add dependency relationship
```

### Dependency Resolution Strategy
1. **Check First**: Always verify dependencies before starting
2. **Block Appropriately**: Mark tickets as blocked when waiting on deps
3. **Unblock Promptly**: Update dependent tickets when deps are resolved

## Reflection Phase (Enhancement)

After each completed cycle, perform systematic reflection:

### 1. Process Reflection
- What went well in this cycle?
- What obstacles were encountered?
- How could the process be improved?

### 2. Technical Reflection
- What patterns emerged in the code?
- Are there opportunities for refactoring?
- What technical debt was discovered?

### 3. Documentation Reflection
- What documentation needs updating?
- Are there patterns that should be codified?
- What decisions need to be recorded?

### 4. Tooling Reflection
- Were the right tools available?
- Are there missing commands or workflows?
- Could automation improve the process?

## Opportunity Identification (Enhancement)

During reflection, actively identify opportunities:

### 1. Boilerplate Opportunities
Look for repeated patterns that could become boilerplate:
- Similar file structures across features
- Repeated setup code
- Common configuration patterns

**Action**: Create or update boilerplate templates

### 2. Workflow/Command Opportunities
Identify missing or inefficient workflows:
- Manual steps that could be automated
- Complex command sequences that could be simplified
- Missing quality gates or checks

**Action**: Create new workflow files or command aliases

### 3. Skill Opportunities
Recognize expertise that should be codified:
- Specialized knowledge used repeatedly
- Complex problem-solving approaches
- Domain-specific best practices

**Action**: Create new AI skills using ai-upsert workflow

### 4. Template Opportunities
Find reusable templates:
- Document structures (README, API docs)
- Code templates (components, services)
- Configuration templates

**Action**: Create or update template files

## Continuous Improvement Loop

The AI agent should:

1. **Reflect** on each completed cycle
   - Document what worked and what didn't
   - Identify patterns and improvements

2. **Learn** from issues encountered
   - Update processes to prevent recurrence
   - Share learnings with the team

3. **Improve** the process for next iteration
   - Implement identified improvements
   - Update documentation and workflows

4. **Document** new patterns and decisions
   - Update AGENTS.md with new insights
   - Create ADRs (Architecture Decision Records)
   - Add examples to codebase

## Integration with Other Skills

This skill works best with:
- **code-review**: For verifying implementation quality
- **frontend-design**: For UI/UX work
- **ansible-rules**: For infrastructure work
- **ai-upsert**: For creating new skills from discovered patterns
- **git-repository-management**: For organized, secure repository operations
- **code-quality-validation**: For comprehensive code quality checks

### Skill Integration Benefits

The ai-development-loop now delegates specialized operations to dedicated skills:

**Git Repository Management**:
- Handles repository analysis, change organization, and commits
- Provides security scanning and secret detection
- Manages documentation updates and repository verification
- Ensures clean repository state with proper commit organization

**Code Quality Validation**:
- Automatic language detection and appropriate tool selection
- Comprehensive linting, formatting, and testing
- Security scanning and dependency auditing
- Environment-aware execution with proper tool wrapping

This delegation provides:
- **Better separation of concerns** - Each skill focuses on its domain
- **Reduced duplication** - VCS and quality logic centralized
- **Improved maintainability** - Changes to specialized logic in dedicated skills
- **Enhanced reusability** - Skills can be used independently

## Quality Checklist

Before marking any ticket complete, verify:

- [ ] Foundation checks passed (environment validation, security scan)
- [ ] Code quality validation passed (using code-quality-validation skill)
- [ ] Git repository management completed (using git-repository-management skill)
- [ ] Ticket status updated appropriately
- [ ] Implementation meets requirements
- [ ] Tests added and passing
- [ ] **CRITICAL: Ticket audit completed with 90%+ coverage**
- [ ] **CRITICAL: All ticket requirements fully implemented**
- [ ] **CRITICAL: No features or tests removed unless explicitly required by ticket**
- [ ] **CRITICAL: Test coverage maintained or improved**
- [ ] **CRITICAL: All existing functionality still works**
- [ ] **CRITICAL: No regressions introduced**
- [ ] Documentation updated
- [ ] Code follows established patterns
- [ ] Dependencies properly handled
- [ ] **Step 10: Assessment completed for technology, process, and project improvements**
- [ ] **Step 11: Improvement tickets created and prioritized appropriately**
- [ ] Changes committed

### 🚨 Pre-Completion Security Check
**Ask yourself these questions before marking complete:**
1. Did I remove any existing features? (If yes, was it explicitly required?)
2. Did I delete any tests? (If yes, was it explicitly required?)
3. Did I reduce test coverage? (If yes, was it justified?)
4. Did I break any existing functionality?
5. Did I introduce any regressions?
6. **Did I complete the ticket audit with 90%+ coverage?**
7. **Did I complete Step 10: Assessment for technology, process, and project improvements?**
8. **Did I complete Step 11: Create and prioritize improvement tickets based on the assessment?**

**If you answer YES to any of these without explicit ticket requirement, STOP and fix it!**

## Examples

### Example: Starting a New Feature
```bash
# 0-2. Foundation, selection, and start work (automated)
./scripts/dev-loop-helper.sh --verbose foundation
./scripts/dev-loop-helper.sh --verbose next
./scripts/dev-loop-helper.sh --verbose start ja-1234
# Selected: ja-1234 - Add user authentication
# Auto-cleanup runs in foundation, moving stale tickets back to open

# 3-7. Strategy, implementation, verification, audit (manual)
# (work done here)
just test && just lint

# 8. Complete
./scripts/dev-loop-helper.sh --verbose complete ja-1234

# 9. Commit
git commit -m "feat: add JWT authentication

- Implement JWT token generation/validation
- Add auth middleware
- Update user model
- Add comprehensive tests

Fixes: ja-1234"

# 10. Assess opportunities
# Technology: Need better JWT testing utilities
# Process: Manual token setup could be automated
# Project: Auth pattern should be reusable

# 11. Codify improvements
tkr create "Create JWT testing utilities" --type=improvement --priority=high
tkr create "Automate auth token setup" --type=process --priority=medium
tkr create "Extract auth boilerplate to package" --type=project --priority=medium

# 12. Loop again
./scripts/dev-loop-helper.sh --verbose next
```

## Troubleshooting

### Script-Based Error Handling

**The development loop script provides detailed in-situ instructions for all errors.** Run commands with `--verbose` flag to get step-by-step troubleshooting guidance:

```bash
# Get detailed error information and fix instructions
./scripts/dev-loop-helper.sh --verbose foundation
./scripts/dev-loop-helper.sh --verbose complete <ticket-id>
```

**Common script-handled scenarios:**
- **Security scan failures**: Script provides specific fix instructions for configuration issues
- **Missing tools**: Script shows installation commands for required dependencies
- **Quality check failures**: Script gives detailed guidance for fixing test, lint, and type errors
- **Environment issues**: Script detects and suggests fixes for environment setup problems

### Manual Troubleshooting

For issues not handled by the script:

**Issue**: Tests failing after implementation
**Script Solution**: Run `./scripts/dev-loop-helper.sh --verbose complete <ticket-id>` for detailed test failure guidance
**Manual Check**: Review test output, verify implementation matches requirements

**Issue**: Linting errors
**Script Solution**: Run with `--verbose` for specific linting fix instructions
**Manual Check**: Run linting with auto-fix if available

**Issue**: Dependencies not resolved
**Solution**:
- Check dependency tickets with `tkr show <dep-id>`
- Add new dependencies if discovered
- Mark ticket as blocked if waiting on deps

### Getting Unstuck

If stuck on a ticket:
1. **Use script diagnostics**: `./scripts/dev-loop-helper.sh --verbose status` for system overview
2. **Review requirements** - Ensure understanding is correct
3. **Check examples** - Look for similar implementations
4. **Ask for clarification** - Don't proceed with ambiguity
5. **Document blockers** - Create tickets for discovered issues
6. **Split work** - Break large tasks into smaller tickets

### Script Investigation

To investigate the script itself:
```bash
# See all available commands
./scripts/dev-loop-helper.sh --verbose help

# Check environment detection
./scripts/dev-loop-helper.sh --verbose env

# Clear cache if needed
./scripts/dev-loop-helper.sh cache-clear
```

## References

- ticketr CLI documentation: `tkr help`
- Project AGENTS.md for specific patterns
- ai-upsert for codifying discovered patterns
- Workflow templates in `.windsurf/workflows/`
