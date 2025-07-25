# Ignore File Structure and Patterns

This document explains the structure and purpose of the ignore files in this project, designed to be AI-friendly and help with maintenance and understanding of the ignore patterns.

## Modular Ignore File System

This repository uses a modular system for managing ignore patterns. Instead of maintaining separate, duplicated ignore files for each tool or environment, we keep small, focused `*.ignorefile` building blocks in `.config/filelists/`, and use the script `bin/generate-ignores.js` to combine them into the actual output ignore files (e.g. `.gitignore`, `.npmignore`, `.codeiumignore`).

### How It Works
- **Source files**: `.config/filelists/*.ignorefile` contain patterns for a single category (e.g. security, packaging, AI, VCS, binaries).
- **Documentation**: `.config/filelists/*.ignorefile.md` files describe the purpose and contents of each ignore category.
- **Generation**: `bin/generate-ignores.js` uses its `CONFIG` object to specify which categories are included/excluded for each output file. It then combines the relevant patterns to produce the final output ignore files.
- **No duplication**: Patterns are only present in their most specific category. For example, credentials/secrets only appear in `security.ignorefile`, not in `packaging.ignorefile`, `vcs.ignorefile`, or `ai.ignorefile`.

### Best Practices
- **Edit only the modular source files** in `.config/filelists/`. Never edit the generated output ignore files directly.
- **Add new patterns to the most specific category** (e.g., secrets to `security.ignorefile`, build outputs to `packaging.ignorefile`).
- **Do not duplicate patterns** across categories.
- **Regenerate output files** after any change using `node bin/generate-ignores.js`.

## File Types and Their Purposes

### `ai.ignorefile` & `ai.ignorefile.md`
- **Purpose**: Patterns for AI-generated files and directories (e.g., `/generated-code/`).
- **Used by**: AI tools like Codeium, Cursor, etc.
- **Should NOT include**: Credentials, secrets, or sensitive info.

### `binary.ignorefile` & `binary.ignorefile.md`
- **Purpose**: Patterns for binary/non-text files (e.g., images, audio, video, compiled code, archives).
- **Used by**: To help tools ignore non-text files.

### `packaging.ignorefile` & `packaging.ignorefile.md`
- **Purpose**: Patterns for files to exclude from published packages (e.g., build artifacts, logs, editor files).
- **Should NOT include**: Credentials, secrets, or sensitive info (these are included automatically from `security.ignorefile`).

### `security.ignorefile` & `security.ignorefile.md`
- **Purpose**: Patterns for secrets, credentials, and sensitive files (e.g., `.env`, keys, cloud credentials).
- **Used by**: Any ignore output that needs to block secrets/credentials.
- **Should ONLY include**: Credentials/secrets. Not duplicated elsewhere.

### `vcs.ignorefile` & `vcs.ignorefile.md`
- **Purpose**: Patterns for files to ignore in version control (e.g., build outputs, test artifacts, editor files).
- **Should NOT include**: Credentials, secrets, or sensitive info (these are included automatically from `security.ignorefile`).

## Output Ignore Files and Category Mapping

The following table (from `generate-ignores.js` CONFIG) shows which categories are included in each generated output:

| Output File         | Includes                   | Excludes         |
|---------------------|----------------------------|------------------|
| .gitignore          | vcs, security              | ai, packaging    |
| .hgignore           | vcs, security              | ai, packaging    |
| .terraformignore    | vcs, security              | ai, packaging    |
| .npmignore          | packaging, vcs, security   | ai               |
| .pnpmignore         | packaging, vcs, security   | ai               |
| .yarnignore         | packaging, vcs, security   | ai               |
| .codeiumignore      | ai, vcs, security          | packaging        |
| .cursorignore       | ai, vcs, security          | packaging        |

- **security** is always included where credential/secrets protection is needed, but never duplicated in other categories.
- **ai, packaging, vcs** are combined as needed per output.

## Regenerating Output Files
After editing any `.ignorefile`, run:

```sh
node bin/generate-ignores.js
```

This will regenerate all output ignore files with the latest patterns from the modular sources.
- Any special considerations

## Core Ignore Files

### `ai.ignorefile` & `ai.ignorefile.md`
- **Purpose**: Patterns for AI-generated files and directories
- **Example**: `/generated-code/`
- **Used by**: AI tools like Codeium, Cursor, etc.

### `binary.ignorefile` & `binary.ignorefile.md`
- **Purpose**: Patterns for AI-generated files and directories
- **Example**: `/generated-code/`
- **Used by**: AI tools like Codeium, Cursor, etc.


### `packaging.ignorefile` & `packaging.ignorefile.md`
- **Purpose**: Files that should be excluded from published packages but kept in version control
- **Includes**:
  - Development configurations
  - Source files (if shipping compiled code)
  - Test files
  - Documentation
- **Used by**: Package managers (npm, pip, etc.)

### `vcs.ignorefile` & `vcs.ignorefile.md`
- **Purpose**: Files that should never be committed to version control
- **Includes**:
  - OS-specific files (`.DS_Store`, `Thumbs.db`)
  - Editor/IDE files
  - Temporary files
  - Build outputs
  - Dependencies
- **Used by**: Version control systems (Git, etc.)

### `security.ignorefile` & `security.ignorefile.md`
- **Purpose**: Sensitive files that should never be committed
- **Includes**:
  - Credentials and API keys
  - Local overrides
  - Sensitive configuration files
  - Backup files with sensitive data
- **Used by**: Pre-commit hooks, security scanners

## Pattern Syntax

- `#` - Comment
- `*` - Wildcard (matches any characters)
- `?` - Matches any single character
- `[]` - Character ranges
- `!` - Negation (include pattern)
- `/` - Directory separator
- `**` - Recursive directory matching

## Best Practices for Maintenance

1. **Keep patterns specific** - Avoid overly broad patterns
2. **Use comments** - Document non-obvious patterns
3. **Organize logically** - Group related patterns together
4. **Test changes** - Verify patterns work as expected
5. **Update documentation** - Keep `.md` files in sync with pattern files

## How to Add New Patterns

1. Identify the appropriate category for your pattern
2. Add the pattern to the relevant `.ignorefile`
3. Update the corresponding `.ignorefile.md` if needed
4. Test the pattern locally
5. Commit both the pattern and documentation changes

## Common Pitfalls

- Overlapping patterns between files
- Overly broad patterns that might exclude needed files
- Forgetting to update documentation when patterns change
- Platform-specific patterns that might not work across all operating systems
