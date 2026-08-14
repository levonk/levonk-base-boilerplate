# Workspace Mode

The `workspace` mode finds all `*.code-workspace` files under a directory
tree and auto-merges VS Code exclude settings into each one.

## Why This Mode Exists

The `generate` mode prints JSON snippets for manual paste into
`settings.json` or `.code-workspace`. This is safe but tedious when you
have many workspace files across a monorepo or dotfiles tree. The
`workspace` mode automates the merge.

## Usage

```bash
# Dry-run: show which files would change
uv run --script scripts/generate_ignores.py workspace --target ~/p/gh --dry-run

# Update all workspace files
uv run --script scripts/generate_ignores.py workspace --target ~/p/gh
```

## What It Does

1. Recursively finds all `*.code-workspace` files under `--target`
2. For each file, parses the JSON
3. Reads the `settings` object (creates it if missing)
4. For each json-glob output in `outputs.yaml` (`files.exclude`,
   `search.exclude`, `files.watcherExclude`):
   - Collects patterns from the configured concerns
   - Transforms them to VS Code glob syntax (`**/pattern`)
   - Merges into the exclude object, preserving user entries
5. Writes the file back with tab indentation

## Merge Strategy

Each exclude object (`files.exclude`, `search.exclude`, etc.) is merged
using a marker-based approach:

```json
{
  "files.exclude": {
    "// ===== BEGIN GENERATED CONTENT =====": true,
    "**/node_modules": true,
    "**/target": true,
    "// ===== END GENERATED CONTENT =====": true,
    "my-custom-exclude": true
  }
}
```

- **User entries**: any key not between the markers. Preserved across re-runs.
- **Generated entries**: between `BEGIN` and `END` marker keys. Replaced on
  each run.
- **Marker keys**: use `// =====` prefix. VS Code ignores unknown keys, so
  these are harmless no-ops that survive JSON serialization.

## Idempotency

Re-running `workspace` on the same files produces no changes if the
concerns haven't changed. The script compares the current generated
entries with the new ones and only writes if they differ.

## Limitations

- Only handles `.code-workspace` files, not `.vscode/settings.json` (those
  are handled by the `generate` mode with manual paste)
- Uses `json.loads` / `json.dumps`, so JSONC (JSON with comments) files
  will lose their comments on write. Most `.code-workspace` files are
  pure JSON.
- The `--concerns-dir` flag overrides the bundled concerns directory,
  useful for chezmoi-deployed concern files
