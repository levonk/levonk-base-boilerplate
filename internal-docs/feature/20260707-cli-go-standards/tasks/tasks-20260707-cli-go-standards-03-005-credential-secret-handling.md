---
story_id: "03-005"
story_title: "Credential/Secret Handling"
story_name: "credential-secret-handling"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 5
branch: "feature/current/20260707-cli-go-standards/story-03-005-credential-secret-handling"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-007"]
parallel_safe: true
modules: ["secrets", "config"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "security"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement secure handling of sensitive data with no logging of secrets, secure storage options (keychain, encrypted files), and clear warnings about insecure config methods. Ensure credentials are never exposed in logs, error messages, or config files.

## Sub-Tasks

- [x] Add zalando/go-keyring or 99designs/keyring dependency to go.mod — `core/files/go.mod.jinja`
- [x] Create secret handling utility — `core/files/secrets.go.jinja`
- [x] Implement secret redaction in logs — `core/files/secrets.go.jinja`
- [x] Add keychain storage support using zalando/go-keyring or 99designs/keyring — `core/files/secrets.go.jinja`
- [x] Add encrypted file storage support — `core/files/secrets.go.jinja`
- [x] Implement secret validation — `core/files/secrets.go.jinja`
- [x] Add warnings for insecure config methods — `core/files/secrets.go.jinja`
- [x] Update logger to redact secrets — `core/files/logger.go.jinja`
- [x] Update config validation to check for secrets — `core/files/config.go.jinja`
- [x] Test secret redaction in logs — `core/files/secrets_test.go.jinja`
- [x] Test keychain storage — `core/files/secrets_test.go.jinja`
- [x] Test encrypted file storage — `core/files/secrets_test.go.jinja`
- [x] Test insecure config warnings — `core/files/secrets_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update secret handling
- `apps/cli/go/core/files/logger.go.jinja` — Add secret redaction
- `apps/cli/go/core/files/config.go.jinja` — Add secret validation
- `apps/cli/go/core/files/secrets.go.jinja` — New file for secret handling
- `apps/cli/go/core/files/secrets_test.go.jinja` — New file for secret tests

## Acceptance Criteria

- [x] Secrets are never logged
- [x] Secrets are redacted from error messages
- [x] Keychain storage works on supported platforms
- [x] Encrypted file storage works
- [x] Insecure config methods show clear warnings
- [x] Secret validation prevents insecure storage
- [x] Secrets are handled securely throughout CLI

## Test Plan

- Unit: Test secret redaction and storage
- Integration: Test secret handling in actual operations
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when secrets are accessed
- Log warnings for insecure config
- Don't log secret values

## Compliance

- Ensure no secrets in logs
- Follow security best practices
- Provide clear security warnings

## Risks & Mitigations

- Risk: Keychain may not work on all platforms — Mitigation: Platform-specific fallback
- Risk: Encryption may be complex — Mitigation: Use established Go libraries
- Risk: Secrets may leak in error messages — Mitigation: Comprehensive redaction

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization), 01-007 (Configuration Validation)
- Unblocks: None

## Definition of Done

- Secrets are never exposed
- Secure storage options work
- Warnings are clear
- All tests pass

## Commit Conventions

- `feat(secrets): add secure credential handling`
- `feat(secrets): add keychain storage`
- `feat(secrets): add secret redaction`
- `test(secrets): add tests for secret handling`
