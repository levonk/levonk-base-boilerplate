---
story_id: "03-005"
story_title: "Credential/Secret Handling"
story_name: "credential-secret-handling"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 5
branch: "feature/current/20260707-cli-python-standards/story-03-005-credential-secret-handling"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-007"]
parallel_safe: true
modules: ["secrets", "config"]
priority: "SHOULD"
risk_level: "high"
tags: ["feat", "security"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Secure handling of sensitive data. No logging of secrets or credentials, support secure storage options (keychain, encrypted files), and provide clear warnings about insecure config methods.

## Sub-Tasks

- [x] Add keyring library dependency
- [x] Implement secure storage using keychain
- [x] Implement encrypted file storage
- [x] Add secret redaction from logs
- [x] Add warnings for insecure config
- [x] Add tests for credential handling
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/security.py.jinja` - Security module
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `tests/test_security.py.jinja` - Security tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Secrets not logged
- [ ] Credentials not logged
- [ ] Secure storage via keychain supported
- [ ] Encrypted file storage supported
- [ ] Warnings for insecure config methods
- [ ] Tests verify credential handling

## Test Plan

- Unit: `pytest tests/test_security.py -v -k test_credentials`
- Integration: `pytest tests/test_main.py -v -k test_secrets`
- Manual: Test secure storage and verify no logging

## Observability

- Log secret storage operations (without secrets)
- Log insecure config warnings

## Compliance

- Follow security best practices
- Never log sensitive data

## Risks & Mitigations

- Risk: Keychain not available — Mitigation: Fallback to encrypted files
- Risk: Encryption fails — Mitigation: Clear error messages

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization), 01-007 (Config Validation)
- Unblocks: None

## Definition of Done

- Credential handling implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(security): add credential/secret handling`

## Changelog

- 2025-07-08: initialized story file
