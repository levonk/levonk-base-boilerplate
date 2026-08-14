# Git Commit Templates

## Feature Commits

### Basic Feature
```
feat: Add user authentication system

- Implement JWT token-based authentication
- Add login/logout endpoints
- Create user registration flow
- Add password reset functionality
- Implement session management

Closes #123
```

### API Feature
```
feat(api): Add REST endpoints for data management

- GET /api/data - Retrieve data collection
- POST /api/data - Create new data entry
- PUT /api/data/:id - Update existing data
- DELETE /api/data/:id - Remove data entry
- Add input validation and error handling

Closes #456
```

### UI Feature
```
feat(ui): Create responsive navigation component

- Add mobile-friendly navigation menu
- Implement dropdown functionality
- Add keyboard navigation support
- Include accessibility features
- Add dark mode support

Closes #789
```

## Bug Fix Commits

### Critical Bug Fix
```
fix: Resolve null pointer exception in user service

- Add null checks for user objects
- Implement defensive programming practices
- Add unit tests for edge cases
- Update error handling logic

Fixes #101
```

### Performance Fix
```
fix(perf): Optimize database query performance

- Add database indexes for frequently queried fields
- Implement query result caching
- Reduce N+1 query problems
- Improve response time by 40%

Fixes #202
```

### Security Fix
```
fix(security): Patch XSS vulnerability in input fields

- Sanitize user input before rendering
- Implement Content Security Policy
- Add input validation middleware
- Update security headers

Fixes #303
```

## Refactoring Commits

### Code Cleanup
```
refactor: Extract common validation utilities

- Move validation logic to shared module
- Create reusable validation functions
- Update all modules to use new utilities
- Remove duplicate code

Reduces code duplication by 30%
```

### Architecture Improvement
```
refactor: Implement dependency injection pattern

- Replace static dependencies with DI container
- Create service interfaces and implementations
- Update constructor injection
- Improve testability and modularity

Improves code maintainability and test coverage
```

## Documentation Commits

### API Documentation
```
docs: Update API documentation for v2.0

- Document new authentication requirements
- Add endpoint examples and responses
- Update rate limiting information
- Include error code reference
- Add integration guides
```

### User Documentation
```
docs: Improve user onboarding experience

- Add step-by-step getting started guide
- Create video tutorial links
- Update FAQ section
- Add troubleshooting guide
- Include best practices section
```

## Testing Commits

### Unit Tests
```
test: Add comprehensive unit tests for user service

- Test all public methods with 95% coverage
- Include edge cases and error scenarios
- Add mock implementations for dependencies
- Verify business logic correctness

Coverage increased from 70% to 95%
```

### Integration Tests
```
test: Add end-to-end integration tests

- Test complete user registration flow
- Verify API integration with database
- Test authentication and authorization
- Add performance benchmarks

Ensures system reliability under load
```

## Maintenance Commits

### Dependency Updates
```
chore(deps): Upgrade React 17→18 and patch security vulnerabilities

- Update React from 17.0.2 to 18.2.0
- Upgrade Node.js dependencies
- Update security patches
- Resolve deprecated package warnings

All tests passing, no breaking changes
```

### Build Improvements
```
chore(build): Optimize webpack configuration

- Enable code splitting for better performance
- Add compression plugins
- Optimize bundle size by 25%
- Improve build time by 40%

Bundle size reduced from 2.5MB to 1.9MB
```

## Release Commits

> **Title rule**: Lead with the headline change, not the version number.
> `release: Ship named outputs and lint pipeline for v2.9.0` — not
> `release: Prepare for v2.9.0 release`. See
> [Significant-Change Titles](references/commit-organization.md#significant-change-titles-critical)
> in the Commit Organization reference.

### Version Release
```
release: Ship named outputs and lint pipeline for v2.9.0

- Add #prebuilt named output alongside #default and #source
- Add lint-artifacts step with yamllint, markdownlint-cli2, statix, deadnix
- Add scan-artifacts step for identity-leak detection
- Replace nix profile install with nix profile add (Nix 2.30 deprecation)
- Bump version to 2.9.0, update dates

Highlights:
- Named outputs for prebuilt tarballs
- Lint and scan steps in the workflow
- nix profile add migration
```

### Hotfix Release
```
release: Patch XSS vulnerability in authentication for v2.0.1

- Sanitize user input before rendering
- Update security dependencies
- Regenerate security tokens
- Update documentation
- Bump version to 2.0.1

All users should upgrade immediately
```
