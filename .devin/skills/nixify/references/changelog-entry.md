# Changelog Entry

If the project maintains a CHANGELOG.md, add an entry under `## Unreleased` -> `### Added`:

```markdown
### Added
- Added optional Nix flake support for building, running, installing, and developing <project-name> with Nix. (#<issue-number>)
```

**Format guidelines:**
- Use present tense ("Added" not "Adds")
- Reference the issue number if available
- Keep it concise and factual
- Follow the existing changelog style in the project
- **When `platform_scope` is `darwin_only` or `linux_only`** (Step 4a), mention
  the platform scope in the entry, e.g.:
  `Added optional Nix flake support for <project-name> on macOS (Apple Silicon & Intel). (#<issue-number>)`
  This sets user expectations correctly — Linux users seeing the changelog
  won't expect a `nix run` path that doesn't exist for their platform.
