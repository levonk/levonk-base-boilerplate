# Language-Specific Helper Details

## Migration Path

The orchestrator automatically detects project type and uses the appropriate helper script, ensuring that Node.js projects get Node.js-specific logic while maintaining the comprehensive environment management and security scanning features.

## Script-Automated Steps

The following steps are **fully automated** by the development loop script. Use `--verbose` flag for detailed step-by-step logging:

```bash
# Step 0: Foundation Check
./scripts/dev-loop-helper.sh --verbose foundation

# Step 1: Ticket Selection
./scripts/dev-loop-helper.sh --verbose next

# Step 2: Start Work
./scripts/dev-loop-helper.sh --verbose start <ticket-id>

# Step 8: Completion
./scripts/dev-loop-helper.sh --verbose complete <ticket-id>
```

**The script provides detailed in-situ instructions for any errors encountered.** Run with `--verbose` to see step-by-step execution and get specific guidance for troubleshooting.

**Note**: The foundation check includes automatic stale ticket cleanup (tickets in `in_progress` > 7 days are moved back to `open` status).

### Manual Steps (Not Handled by Script)

These steps require manual execution and judgment:

#### Step 3: High Quality
Ensure upstream code has adequate testing and is testable:

```bash
# Use code-quality-validation skill for comprehensive checks
./scripts/quality-validator.sh complete

# Check existing test coverage
just test-coverage              # If available
find . -name "*.test.*" -o -name "*_test.*" | head -10
```

**Quality checks:**
- Use code-quality-validation skill for linting, formatting, and testing
- Assess existing test coverage for the area you'll be working on
- Identify gaps in test coverage that need to be filled
- Ensure the codebase is testable and well-structured
- Look for opportunities to add tests to untested code

#### Step 4: Strategy
Determine implementation strategy by analyzing existing solutions:

```bash
# Search for existing functionality
rg -i "search_term" --type ts --type js --type py
find . -name "*.md" -exec grep -l "related_feature" {} \;

# Check existing dependencies
cat package.json | grep -E "(dependencies|devDependencies)"
cat requirements.txt | grep -E "package_name"
```

**Strategy decision tree:**
1. **Code already exists?** → Reuse or extend existing functionality
2. **Existing dependency works?** → Use established library/package
3. **New dependency needed?** → Evaluate and add appropriate dependency
4. **New package required?** → Create new package in monorepo
5. **3rd party service?** → Integrate external API/service

#### Step 5: Implementation
Do the actual work following best practices:
- Add tests as needed (TDD approach preferred)
- Implement required changes
- If any opportunities for an improvement, a standalone package, etc... come up in this stage, add another ticket
- Follow coding standards and best practices
- Update documentation
- Keep changes atomic and focused

#### Step 6: Verification
Add/update/run tests and validate implementation:

```bash
just test                     # Run tests
just lint                     # Run linting
just typecheck                # Run type checking
# OR manual testing of the feature
```

**Quality gates:**
- All tests must pass
- No linting errors
- Type checking passes
- Manual verification of functionality

#### Step 7: Ticket Audit (Coverage Validation)

Systematically audit the implementation against ticket requirements using the same methodology as plan auditing:

#### 7.1: Requirement Extraction
For each requirement in the ticket:

1. **Extract Requirements**: Parse ticket title, description, and acceptance criteria
2. **Identify Functional Requirements**: What the feature must do
3. **Identify Non-Functional Requirements**: Performance, security, usability constraints
4. **Identify Technical Requirements**: Code quality, test coverage, documentation

#### 7.2: Coverage Analysis
For each identified requirement:

1. **Mark Coverage Status**:
   - `covered` - Requirement fully implemented with tests
   - `partial` - Requirement partially implemented or insufficiently tested
   - `missing` - Requirement not implemented

2. **Provide Evidence**: Cite specific code locations, test files, or documentation
3. **Document Gaps**: Note missing functionality or insufficient test coverage

#### 7.3: Coverage Scoring
1. **Calculate Coverage Score**: 0-100 based on requirement fulfillment
2. **Provide Rationale**: 1-2 sentence explanation of the score
3. **Quality Gate**: Must achieve 90%+ coverage before completion

#### 7.4: Gap Analysis
List gaps prioritized by impact:

1. **Critical Gaps**: Missing core functionality from ticket
2. **Major Gaps**: Partial implementation or insufficient testing
3. **Minor Gaps**: Documentation, edge cases, or optimizations

#### 7.5: Implementation Patching
Address identified gaps:

1. **Add Missing Functionality**: Implement uncovered requirements
2. **Enhance Test Coverage**: Add tests for partial coverage areas
3. **Update Documentation**: Ensure all implemented features are documented
4. **Preserve Existing**: Never remove features unless explicitly required

#### 7.6: Re-audit Until Complete
Repeat audit process until 99% compliance is achieved:

```bash
# Quick audit checklist before marking complete
- [ ] All ticket requirements implemented
- [ ] All implemented features have tests
- [ ] Test coverage meets quality standards
- [ ] Documentation updated
- [ ] No regressions introduced
```

**Audit Evidence Format**:
- **Requirement**: "user can reset password" → **Covered**: `PasswordResetService.reset()` in `auth/password-reset.ts`
- **Requirement**: "password reset email sent" → **Covered**: `EmailService.sendPasswordReset()` in `auth/email.ts`
- **Requirement**: "rate limiting on reset attempts" → **Missing**: No rate limiting implemented

**Integration with Ticket Workflow**:
- Add audit results to ticket notes: `tkr add-note <ticket-id> "Audit: 95% coverage. Missing rate limiting."`
- Create follow-up tickets for gaps: `tkr create "Add rate limiting to password reset"`
- Only mark ticket ready/closed after audit passes 90% threshold

#### Step 9: Commit Changes
Use git-repository-management skill for organized, secure commits:

```bash
# Use git-repository-management skill for complete workflow
./scripts/git-repo-manager.sh complete

# Or run specific phases
./scripts/git-repo-manager.sh organize    # Plan commit groupings
./scripts/git-repo-manager.sh commit      # Execute commits
./scripts/git-repo-manager.sh verify      # Verify clean state
```

The skill handles:
- Change analysis and organization by functionality
- Secret scanning and security validation
- Commit message formatting and documentation updates
- Final repository state verification

#### Step 10: Assess - Opportunities for Improvement
Assess opportunities for improvement across three key areas:

#### 10.1: Technology Assessment
Evaluate technical improvements and knowledge gaps:

**Technology Knowledge:**
- What can we improve about our knowledge of these tools?
- What are preferred alternative tools to prevent future iterations/problems?
- What alternative implementations should we consider?
- What tools should we avoid using and why?

**Integration & Testing:**
- How should we better integrate these tools?
- How can we improve testing approaches for this technology?
- What can we make reusable from our technical implementation?

**Documentation & Standards:**
- What technical patterns should be documented?
- What standards should we establish for tool usage?
- What best practices emerged that should be codified?

#### 10.2: Process Assessment
Evaluate process improvements and workflow optimizations:

**Process Improvements:**
- What can we improve about how we do things?
- Are there manual steps that should be automated?
- What bottlenecks or inefficiencies did we encounter?

**Testing Process:**
- How can we improve our testing processes?
- What test coverage gaps were identified?
- Are there opportunities for better test automation?

**Workflow Creation:**
- What rules/workflows/skills/tools should we create to improve process?
- What templates would streamline future work?
- What checklists or validation steps are needed?

#### 10.3: Project Assessment
Evaluate project-specific improvements:

**Project Structure:**
- What improvements can be made to this project's organization?
- Are there architectural patterns that should be refined?
- What dependencies or packages could be better organized?

**Cross-Project Learning:**
- What learnings from this project apply to other projects?
- What patterns should be shared across the monorepo?
- Are there opportunities for standardization?

**Future Prevention:**
- What issues did we encounter that could be prevented?
- What guardrails or validations should be added?
- What documentation would prevent future confusion?

#### Step 11: Codify - Create and Prioritize Improvement Tickets
Take the results from Step 10 and create actionable tickets:

##### 11.1: Ticket Creation
Create tickets for identified opportunities:

```bash
# Create tickets for high-priority improvements
tkr create "Improve testing process for X technology" \
  --type=improvement \
  --priority=high \
  --description="Based on assessment from ticket <current-ticket-id>"

# Create tickets for process improvements
tkr create "Add automation workflow for Y process" \
  --type=process \
  --priority=medium \
  --description="Automate manual steps identified in ticket <current-ticket-id>"
```

##### 11.2: Prioritization Decision Framework
Decide on priority and scope for each identified improvement:

**Immediate Action (High ROI):**
- Expect immediate and high return on investment for current priorities
- Address critical blockers or efficiency gains
- Implement for current project when impact is clear

**Queue for Later:**
- Important but not urgent for current work
- Lower ROI but still valuable improvements
- Add to backlog with appropriate priority

**Cross-Project Application:**
- Apply to other projects in the monorepo
- Create reusable packages or tools
- Standardize across multiple projects

**Tool/Package Improvements:**
- Improve tools, packages, or projects we're using
- Contribute upstream improvements
- Create better alternatives to existing tools

##### 11.3: Ticket Organization
Organize created tickets appropriately:

```bash
# Link to current ticket as context
tkr link <new-ticket-id> <current-ticket-id>

# Add dependencies if needed
tkr dep <new-ticket-id> <dependency-ticket-id>

# Set appropriate priority based on assessment
tkr priority <new-ticket-id> high|medium|low

# Add to appropriate project/category
tkr project <new-ticket-id> <project-name>
tkr category <new-ticket-id> <category-name>
```

##### 11.4: Documentation of Assessment
Document the assessment outcomes:

```bash
# Add assessment summary to current ticket
tkr add-note <current-ticket-id> "Assessment completed:
- Technology: Created 2 tickets for tool improvements
- Process: Identified 3 workflow automation opportunities
- Project: 1 cross-project standardization opportunity
- Priorities: 1 immediate, 2 queued, 1 cross-project"
```

#### Step 12: Commit Changes
Use git-repository-management skill for final repository cleanup and any remaining commits:

```bash
# Final cleanup and verification
./scripts/git-repo-manager.sh verify

# Ensure repository is in clean state
./scripts/git-repo-manager.sh complete
```

This ensures all changes are properly organized, documented, and the repository is left in a clean state.

#### Step 13: Loop Again
Grab the next ticket and repeat the cycle:
```bash
./scripts/dev-loop-helper.sh --verbose next
```
