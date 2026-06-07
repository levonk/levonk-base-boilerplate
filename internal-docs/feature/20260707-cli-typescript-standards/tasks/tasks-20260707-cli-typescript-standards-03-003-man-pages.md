---
story_id: "03-003"
story_title: "Man Pages"
story_name: "man-pages"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-03-003-man-pages"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["docs/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "documentation"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Generate traditional Unix man pages for the CLI tool. Make man pages accessible via `man <command>` or `--man` flag. Include all command options, examples, and usage information. Use man page generation tools compatible with TypeScript. This implements CLI Tool Standards ADR requirement #18.

## Sub-Tasks

- [ ] Create man page generation module
- [ ] Define man page structure and sections
- [ ] Implement man page generation from command structure
- [ ] Add `--man` flag to index.ts
- [ ] Generate man page for main command
- [ ] Generate man pages for subcommands
- [ ] Add man page installation logic
- [ ] Include examples in man pages
- [ ] Include all command options in man pages
- [ ] Add unit tests for man page generation
- [ ] Add integration tests for --man flag
- [ ] Update help text to reference man pages
- [ ] Add man page to install/uninstall process

## Relevant Files

- `apps/cli/typescript/core/files/src/man.ts.jinja` - New man page generation module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with --man flag
- `apps/cli/typescript/core/files/src/man.test.ts.jinja` - Unit tests for man pages (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for --man flag
- `apps/cli/typescript/core/files/man/` - Directory for generated man pages (to be created)

## Acceptance Criteria

- [ ] Man page is generated for main command
- [ ] Man pages are generated for all subcommands
- [ ] `--man` flag displays man page content
- [ ] Man pages include all command options
- [ ] Man pages include usage examples
- [ ] Man pages follow standard Unix man page format
- [ ] Man pages are installed in correct location
- [ ] Man pages are accessible via `man <command>`

## Test Plan

- Unit: `vitest run src/man.test.ts` - Test man page generation
- Integration: `vitest run src/index.test.ts` - Test --man flag behavior
- Manual: Run --man flag and verify output
- Manual: Install man page and test with `man <command>`

## Observability

- Log man page generation in verbose mode
- Track man page version in generated files
- Add metrics for man page usage

## Compliance

- Follows CLI Tool Standards ADR requirement #18 (Man Pages)
- Provides traditional Unix documentation format

## Risks & Mitigations

- Risk: Man page generation becomes complex with many commands
  - Mitigation: Auto-generate from command structure, use templates
- Risk: Man page installation requires system permissions
  - Mitigation: Install in user directory, document system-wide installation
- Risk: Man pages become out of sync with command changes
  - Mitigation: Auto-generate as part of build process

## Dependencies

- None - this can be developed in parallel with other Phase 3 stories

## Notes

- Consider using man-page or similar library for man page generation
- Man pages should follow standard sections: NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, SEE ALSO
- Man page generation should be part of the build process
- Consider generating man pages from the same source as help text
