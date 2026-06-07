---
story_id: "02-005"
story_title: "Man Pages"
story_name: "man-pages"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 5
branch: "feature/current/20260707-cli-go-standards/story-02-005-man-pages"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["docs", "main"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "docs"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Generate traditional Unix man pages for documentation, accessible via `man {command}` or `--man` flag. Include all command documentation in the man pages using Go doc generation tools.

## Sub-Tasks

- [ ] Add --man flag to root command — `core/files/main.go.jinja`
- [ ] Create man page template — `core/files/man.1.jinja`
- [ ] Implement man page generation logic — `core/files/docs.go.jinja`
- [ ] Generate man page from command structure — `core/files/docs.go.jinja`
- [ ] Add man page installation to install flag — `core/files/install.go.jinja`
- [ ] Test man page generation — `core/files/docs_test.go.jinja`
- [ ] Test --man flag displays man page — `core/files/docs_test.go.jinja`
- [ ] Test man page installation — `core/files/docs_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add --man flag
- `apps/cli/go/core/files/docs.go.jinja` — New file for man page logic
- `apps/cli/go/core/files/man.1.jinja` — New template for man page
- `apps/cli/go/core/files/docs_test.go.jinja` — New file for docs tests
- `apps/cli/go/core/files/install.go.jinja` — Add man page installation

## Acceptance Criteria

- [ ] Man pages are generated from command structure
- [ ] `--man` flag displays man page
- [ ] Man pages include all command documentation
- [ ] Man pages are installed via --install flag
- [ ] Man pages follow Unix man page format
- [ ] Man pages are accessible via `man {command}`

## Test Plan

- Unit: Test man page generation
- Integration: Test man page display and installation
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when man page is generated
- Log when man page is installed

## Compliance

- Ensure man pages follow standard format
- Include all necessary sections (NAME, SYNOPSIS, DESCRIPTION, etc.)

## Risks & Mitigations

- Risk: Man page format may be complex — Mitigation: Use established Go libraries
- Risk: Man pages may become outdated — Mitigation: Auto-generate from command structure

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Man pages are generated correctly
- --man flag works
- Man pages are installed via --install
- All tests pass

## Commit Conventions

- `feat(docs): add man page generation`
- `feat(docs): add --man flag`
- `test(docs): add tests for man pages`
