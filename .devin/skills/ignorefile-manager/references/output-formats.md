# Output Formats

Each output file has a syntax mode that determines how patterns are
transformed. The generator handles three modes.

## gitignore (standard)

Used by: `.gitignore`, `.codeiumignore`, `.cursorignore`, `.aiexclude`,
`.npmignore`, `.chezmoiignore`

Patterns are written as-is. Negation (`!`) is supported. The generator:
- Concatenates concerns in the order listed in `outputs.yaml`
- Deduplicates patterns (first occurrence wins)
- Sorts patterns alphabetically within each concern section
- Adds section headers (`## concern-name > section-title`)
- Wraps in `BEGIN/END GENERATED CONTENT` markers

Example output:
```gitignore
# Generated: 2026-07-15T16:30:00
# Source concerns: secrets, build-artifacts, os-files
# Syntax: gitignore

## secrets > Cloud credentials
.aws/
.azure/
...

## build-artifacts > Generic build output
[Bb]in/
[Bb]uild/
...
```

## gitignore-no-negation

Used by: `.dockerignore`

Same as `gitignore`, but negation patterns (`!`) are stripped. Docker's
`.dockerignore` has limited negation support (varies by version), so the
generator removes `!` patterns and adds a warning comment listing what
was removed.

Example:
```dockerignore
# WARNING: 2 negation patterns stripped (unsupported in .dockerignore):
#   !.env.example
#   !Cargo.lock

## secrets > Environment files with secrets
.env
.env.*
...
```

## json-glob

Used by: VS Code `files.exclude`, `search.exclude`, `files.watcherExclude`

Patterns are transformed from gitignore syntax to VS Code glob objects:
- `node_modules/` → `"**/node_modules": true` (files.exclude / search.exclude)
- `node_modules/` → `"**/node_modules/**": true` (files.watcherExclude — the `/**` suffix tells the watcher to skip all contents inside the directory)
- `*.log` → `"**/*.log": true`
- `.git/` → `"**/.git": true` (or `"**/.git/**": true` for watcher)
- `/specific` → `"specific": true` (root-anchored, no `**/` prefix)
- `!Cargo.lock` → skipped (negation doesn't map to exclude settings)

The `files.watcherExclude` key uses `**/pattern/**` form for directory
patterns (those ending with `/` in gitignore), while `files.exclude` and
`search.exclude` use `**/pattern` form. This is because the watcher needs
the `/**` suffix to efficiently skip all files inside a directory, while
the Explorer and search only need to match the directory entry itself.

The generator produces a JSON snippet to paste into `settings.json` or
`.code-workspace`:
```json
// Generated: 2026-07-15T16:30:00
// Source concerns: build-artifacts, dependencies, vcs-meta
// Syntax: json-glob
{
  "files.exclude": {
    "**/target": true,
    "**/node_modules": true,
    "**/.git": true
  }
}
```

**Why not auto-merge JSON?** VS Code settings files often contain many
other keys (editor preferences, themes, extensions). Auto-merging risks
corrupting unrelated settings. The snippet approach lets the user paste
into the right location and review before saving.

## Extra Patterns

The `extra` field in `outputs.yaml` adds output-specific patterns that
don't belong in any concern. For example, `.npmignore` excludes `src/`,
`test/`, `docs/` — these aren't universal ignore patterns, they're
packaging-specific.

```yaml
.npmignore:
  syntax: gitignore
  concerns: [secrets, build-artifacts, ...]
  extra:
    patterns: |
      src/
      test/
      docs/
      tsconfig.json
```

## Marker-Based Preservation

Each gitignore-syntax output file has this structure:

```
# Project-specific patterns (preserved across regenerations)
<user's manual additions>

# ===== BEGIN GENERATED CONTENT =====
<generated patterns from concerns>
# ===== END GENERATED CONTENT =====
```

The generator:
1. Reads the existing file
2. Splits at `BEGIN GENERATED CONTENT`
3. Preserves everything above the marker (project-specific)
4. Replaces everything between markers with fresh generated content
5. If no marker exists, the entire file is treated as project content and
   generated content is appended below it

For JSON outputs (VS Code settings), markers use `//` comment syntax:
```
// ===== BEGIN GENERATED CONTENT =====
// ===== END GENERATED CONTENT =====
```
