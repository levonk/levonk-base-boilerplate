---
story_id: "06-003"
story_title: "Credential/Secret Handling"
story_name: "credential-secret-handling"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 6
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-06-003-credential-secret-handling"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["secrets/"]
priority: "MUST"
risk_level: "high"
tags: ["feat", "cli", "security"]
due: "2026-08-18"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement secure handling of sensitive data with no logging of secrets. Support secure storage options (keyring, environment variables), provide clear warnings about insecure config methods, and implement secret detection and redaction in logs. This implements CLI Tool Standards ADR requirement #25.

## Sub-Tasks

- [x] Create secrets module for credential management
- [x] Implement secret detection and redaction
- [x] Add secure storage option using keyring library
- [x] Add environment variable support for secrets
- [x] Implement secret validation
- [x] Add insecure config method warnings
- [x] Implement secret redaction in all log output
- [x] Add secret redaction in error messages
- [x] Add secret redaction in debug output
- [x] Add unit tests for secret detection
- [x] Add unit tests for secret redaction
- [x] Add integration tests for secret handling
- [x] Update help text to document secret handling
- [x] Add security best practices documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/secrets.ts.jinja` - New secrets module (to be created)
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger with secret redaction
- `apps/cli/typescript/core/files/src/error.ts.jinja` - Error handling with secret redaction
- `apps/cli/typescript/core/files/src/secrets.test.ts.jinja` - Unit tests for secrets (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for secrets
- `apps/cli/typescript/core/files/package.json.jinja` - Add keyring dependency

## Acceptance Criteria

- [x] Secrets are never logged in plain text
- [x] Secrets are redacted from all log output
- [x] Secrets are redacted from error messages
- [x] Secrets are redacted from debug output
- [x] Secure storage using keyring is available
- [x] Environment variable support for secrets is available
- [x] Insecure config methods show clear warnings
- [x] Secret detection works for common patterns
- [x] Secret redaction is comprehensive
- [x] Security best practices are documented

## Test Plan

- Unit: `vitest run src/secrets.test.ts` - Test secret detection and redaction
- Integration: `vitest run src/index.test.ts` - Test secret handling in logs
- Manual: Verify secrets are redacted in all output
- Manual: Test secure storage options

## Observability

- Log secret redaction events in debug mode (without exposing secrets)
- Track secret handling for security auditing
- Add metrics for secret storage usage

## Compliance

- Follows CLI Tool Standards ADR requirement #25 (Credential/Secret Handling)
- Ensures security best practices for sensitive data

## Risks & Mitigations

- Risk: Secret redaction misses some patterns
  - Mitigation: Comprehensive pattern testing, regular security reviews
- Risk: Keyring library doesn't work on all platforms
  - Mitigation: Platform detection, fallback to environment variables
- Risk: Secrets are exposed in stack traces
  - Mitigation: Stack trace redaction, error handling review

## Dependencies

- None - this can be developed in parallel with other Phase 6 stories

## Notes

- Use node-keytar or similar library for secure storage
- Secret patterns should include: passwords, api keys, tokens, secrets
- Redaction should use consistent placeholder like [REDACTED]
- Document all secret handling clearly for security auditing
