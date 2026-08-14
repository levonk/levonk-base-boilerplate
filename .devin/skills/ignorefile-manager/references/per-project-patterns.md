# Per-Project Patterns

Each generated output file uses a marker-based system to preserve
project-specific patterns across regenerations.

## How It Works

### File structure

```
# Project-specific patterns (preserved across regenerations)
<user's manual additions — these survive re-generation>

# ===== BEGIN GENERATED CONTENT =====
# Generated: 2026-07-15T16:30:00
# Source concerns: secrets, build-artifacts, os-files
<generated patterns from concern sources>
# ===== END GENERATED CONTENT =====
```

### Generation behavior

1. **Read** the existing output file
2. **Split** at `# ===== BEGIN GENERATED CONTENT =====`
3. **Preserve** everything above the marker (project-specific content)
4. **Replace** everything between `BEGIN` and `END` markers with fresh
   generated content
5. **Write** the combined file

### First-time generation (no marker)

If the file exists but has no marker, the entire file is treated as
project content. The generator appends the generated block below it:

```
<existing file content — now treated as project-specific>

# ===== BEGIN GENERATED CONTENT =====
<generated patterns>
# ===== END GENERATED CONTENT =====
```

This ensures manual additions are never lost on first generation.

### JSON outputs (VS Code settings)

For VS Code settings, markers use `//` comment syntax:
```
// ===== BEGIN GENERATED CONTENT =====
// ===== END GENERATED CONTENT =====
```

## Adding Project-Specific Patterns

Add patterns **above** the `BEGIN GENERATED CONTENT` marker. They will
survive all future regenerations.

```gitignore
# Project-specific: this repo has a custom generated directory
custom-generated/

# ===== BEGIN GENERATED CONTENT =====
...
```

## Moving a Pattern to Concerns

If a project-specific pattern should apply to all projects:

1. Move it from the project-specific section to the appropriate concern
   file in `assets/concerns/`
2. Remove it from the project-specific section
3. Re-run `generate_ignores.py generate --target <project>`
4. The pattern now appears in the generated block for all outputs that
   include that concern

## Handling Marker Corruption

If a file has a `BEGIN` marker but no `END` marker (e.g. manual editing
accident), the generator treats everything from `BEGIN` to end-of-file as
generated content and replaces it all.

To fix a corrupted file:
1. Remove the generated block manually
2. Re-run `generate_ignores.py generate --target <project>`
3. The generator will append a fresh generated block

## Multiple Output Files in One Project

Each output file (`.gitignore`, `.codeiumignore`, etc.) has its own
marker pair. Project-specific content in `.gitignore` is independent of
project-specific content in `.codeiumignore` — they can have different
manual additions.
