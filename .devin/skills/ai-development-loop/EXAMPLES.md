# AI Development Loop - Examples

## Example 1: Feature Implementation

### Scenario
Implementing user authentication in a web application.

### Step-by-Step Execution

```bash
# 0. Foundation Check
git status
# On branch feature/auth
# Your branch is up to date with 'origin/feature/auth'
# nothing to commit, working tree clean

just test && just lint
# All tests passed
# No linting errors

# 1. Ticket Selection
tkr ready
# Selected: ja-4a2b1 - Add JWT authentication

# 2. Start Work
tkr start ja-4a2b1
tkr add-note ja-4a2b1 "Starting JWT authentication implementation with refresh tokens"

# 3. Implementation
# (Implementation work done here)
# - Created JWT service
# - Added auth middleware
# - Updated user model
# - Added login/logout endpoints
# - Wrote comprehensive tests

# 4. Verification
just test
# 42 tests passed, 0 failed

just lint
# No linting errors

just typecheck
# Type checking passed

# 5. Completion
tkr add-note ja-4a2b1 "JWT auth complete with refresh tokens. All tests passing. Ready for security review."
tkr ready ja-4a2b1

# 6. Commit Changes
git add .
git commit -m "feat: add JWT authentication with refresh tokens

- Implement JWT service with access/refresh token flow
- Add authentication middleware for protected routes
- Create login/logout endpoints with proper error handling
- Update user model with token storage
- Add comprehensive unit and integration tests
- Update API documentation

Fixes: ja-4a2b1"

# 7. Reflection
# Reflection notes added to ticket:
# - Pattern: Auth service structure could be boilerplated
# - Opportunity: Create auth-testing skill for common auth test patterns
# - Learning: Refresh token rotation is complex, needs clear documentation
```

### Reflection Outcome

**Process Reflection:**
- What went well: Clear requirements made implementation straightforward
- What obstacles: Refresh token security considerations took extra research
- Process improvements: Create security checklist for auth features

**Opportunities Identified:**
- **Boilerplate**: Auth service structure (JWT service, middleware, routes)
- **Skill**: Auth testing patterns (login/logout, token validation, security tests)
- **Template**: API endpoint structure for auth

## Example 2: Bug Fix

### Scenario
Fixing memory leak in data processing service.

### Step-by-Step Execution

```bash
# 0. Foundation Check
git status
# On branch main
# Your branch is behind 'origin/main' by 3 commits
git pull origin main

just test
# 2 tests failing in data processing module

# 1. Ticket Selection
tkr list --status=open
# Selected: ja-9c8d2 - Memory leak in data processor

# 2. Start Work
tkr start ja-9c8d2
tkr add-note ja-9c8d2 "Investigating memory leak in batch data processing"

# 3. Implementation
# (Debugging and fix work)
# - Identified unclosed database connections
# - Added connection pooling
# - Implemented proper cleanup
# - Added memory monitoring tests

# 4. Verification
just test
# All tests passing, including new memory tests

# Memory test specifically
cargo test memory_leak_test -- --nocapture
# Memory usage stable over 1000 iterations

# 5. Completion
tkr add-note ja-9c8d2 "Memory leak fixed. Added connection pooling and cleanup. Memory tests passing."
tkr close ja-9c8d2

# 6. Commit Changes
git commit -m "fix: resolve memory leak in data processor

- Add connection pooling to prevent connection accumulation
- Implement proper cleanup in batch processing
- Add memory monitoring tests
- Update resource management documentation

Fixes: ja-9c8d2"
```

### Reflection Outcome

**Technical Reflection:**
- Pattern: Resource management issues common in batch processing
- Technical debt: Missing cleanup patterns in other services
- Refactoring opportunity: Create resource management utility

**Opportunities Identified:**
- **Workflow**: Resource management checklist for new services
- **Template**: Batch processing service template with proper cleanup
- **Boilerplate**: Connection pooling setup patterns

## Example 3: Infrastructure Update

### Scenario
Updating Docker configuration for better security.

### Step-by-Step Execution

```bash
# 0. Foundation Check
docker-compose config
# Current config validates

just security-scan
# 2 medium severity issues found

# 1. Ticket Selection
tkr ready
# Selected: ja-7f6e3 - Harden Docker security

# 2. Start Work
tkr start ja-7f6e3
tkr add-note ja-7f6e3 "Implementing Docker security hardening recommendations"

# 3. Implementation
# (Docker security updates)
# - Added non-root user to all containers
# - Implemented read-only filesystems
# - Added health checks
# - Updated secrets management
# - Created security scanning workflow

# 4. Verification
docker-compose build
# Build successful

docker-compose up -d
# All services healthy

just security-scan
# All security issues resolved

# 5. Completion
tkr add-note ja-7f6e3 "Docker security hardening complete. All services running as non-root with health checks."
tkr ready ja-7f6e3

# 6. Commit Changes
git commit -m "feat: implement Docker security hardening

- Add non-root user execution for all containers
- Implement read-only filesystems where appropriate
- Add comprehensive health checks
- Update secrets management to use Docker secrets
- Add automated security scanning to CI/CD
- Update Docker documentation with security guidelines

Fixes: ja-7f6e3"
```

### Reflection Outcome

**Process Reflection:**
- What went well: Security scanning provided clear guidance
- What obstacles: Some services required restructuring for non-root execution
- Process improvements: Create security review checklist for infrastructure changes

**Opportunities Identified:**
- **Workflow**: Security hardening workflow for all services
- **Template**: Secure Docker service template
- **Skill**: Infrastructure security review skill

## Example 4: Documentation Update

### Scenario
Updating API documentation for new endpoints.

### Step-by-Step Execution

```bash
# 0. Foundation Check
git status
# Clean working directory

# 1. Ticket Selection
tkr list --status=open
# Selected: ja-3b4c5 - Update API docs for v2 endpoints

# 2. Start Work
tkr start ja-3b4c5
tkr add-note ja-3b4c5 "Updating OpenAPI spec and documentation for new v2 endpoints"

# 3. Implementation
# (Documentation work)
# - Updated OpenAPI specification
# - Added endpoint examples
# - Created migration guide
# - Updated client SDK documentation
# - Added interactive API explorer

# 4. Verification
# Test documentation generation
npm run docs:build
# Documentation builds successfully

# Validate OpenAPI spec
swagger-cli validate api-spec.yaml
# Specification is valid

# 5. Completion
tkr add-note ja-3b4c5 "API documentation updated with v2 endpoints. Migration guide created."
tkr close ja-3b4c5

# 6. Commit Changes
git commit -m "docs: update API documentation for v2 endpoints

- Update OpenAPI specification with new endpoints
- Add request/response examples for all v2 APIs
- Create v1 to v2 migration guide
- Update client SDK documentation
- Add interactive API explorer
- Include breaking changes documentation

Fixes: ja-3b4c5"
```

### Reflection Outcome

**Documentation Reflection:**
- Pattern: API documentation needs automated validation
- Documentation needed: Template for API change documentation
- Decision: Adopt OpenAPI-first approach for future APIs

**Opportunities Identified:**
- **Template**: API change documentation template
- **Workflow**: Automated documentation validation workflow
- **Skill**: Technical writing skill for API documentation

## Example 5: Refactoring

### Scenario
Refactoring monolithic service into microservices.

### Step-by-Step Execution

```bash
# 0. Foundation Check
just test
# All tests passing

# 1. Ticket Selection
tkr ready
# Selected: ja-8d9e0 - Refactor user service into microservices

# 2. Start Work
tkr start ja-8d9e0
tkr add-note ja-8d9e0 "Beginning user service refactoring into auth, profile, and preferences services"

# 3. Implementation
# (Refactoring work done in phases)
# Phase 1: Extract authentication service
# Phase 2: Extract profile service  
# Phase 3: Extract preferences service
# Phase 4: Update service communication
# Phase 5: Migrate data and update tests

# 4. Verification
# Test each new service
just test:auth && just test:profile && just test:preferences
# All service tests passing

# Integration tests
just test:integration
# All integration tests passing

# 5. Completion
tkr add-note ja-8d9e0 "User service refactoring complete. Three microservices deployed and tested."
tkr ready ja-8d9e0

# 6. Commit Changes
git commit -m "refactor: split user service into microservices

- Extract authentication service with JWT handling
- Create profile service for user data management
- Add preferences service for user settings
- Implement inter-service communication via events
- Add comprehensive integration tests
- Update deployment configuration
- Create migration guide for data separation

Fixes: ja-8d9e0"
```

### Reflection Outcome

**Technical Reflection:**
- Pattern: Service extraction follows consistent steps
- Technical debt: Event-driven communication needs standardization
- Refactoring opportunity: Other monolithic services could benefit

**Opportunities Identified:**
- **Boilerplate**: Microservice extraction template
- **Workflow**: Service refactoring workflow
- **Template**: Inter-service communication patterns

## Integration Examples

### Using with Code Review Skill

```bash
# During verification step of AI Development Loop
tkr start ja-1a2b3
# ... implementation work ...

# Use code-review skill before marking ready
"Please review this implementation using code-review skill"
# Code review skill applied, issues found and fixed

tkr ready ja-1a2b3
```

### Using with Frontend Design Skill

```bash
# For UI/UX tickets
tkr start ja-4c5d6
"Use frontend-design skill to implement this user profile page"
# Frontend design skill guides implementation

# Verification includes design system checks
tkr ready ja-4c5d6
```

### Creating New Skills from Reflection

```bash
# After reflection identifies pattern
tkr add-note ja-7f8e9 "Reflection: Auth testing pattern repeated. Creating auth-testing skill."

# Use ai-upsert to codify the pattern
"Use ai-upsert to create auth-testing skill based on discovered patterns"
# New skill created and available for future use
```

## Metrics Examples

### Cycle Time Tracking

| Ticket | Start | Ready | Close | Implementation | Review | Total |
|--------|-------|-------|-------|----------------|--------|-------|
| ja-4a2b1 | 09:00 | 11:30 | 14:00 | 2.5h | 2.5h | 5h |
| ja-9c8d2 | 14:00 | 15:30 | 15:30 | 1.5h | 0h | 1.5h |
| ja-7f6e3 | 16:00 | 18:00 | 20:00 | 2h | 2h | 4h |

### Quality Metrics

- **Test Coverage**: 95% average across all tickets
- **Lint Issues**: 0 after implementation
- **Security Issues**: 2 found and resolved
- **Reflection Completion**: 100% for completed tickets

### Opportunity Metrics

- **Boilerplate Opportunities**: 4 identified, 2 created
- **Workflow Opportunities**: 3 identified, 1 implemented  
- **Skill Opportunities**: 5 identified, 2 created

---

*These examples demonstrate practical application of the AI Development Loop skill across different types of work.*
