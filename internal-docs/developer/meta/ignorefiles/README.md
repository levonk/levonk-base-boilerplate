# Repository File Lists Management

This documentation covers the management of ignore files in the repository.

## Overview

To maintain consistency across different types of ignore files, we've modularized the ignore patterns into separate files that can be combined as needed. This approach ensures that:
- Common patterns are defined once and reused
- Different tools get the appropriate ignore rules
- Maintenance is simplified

## Documentation

For detailed information about specific ignore file types, see:

- [AI Ignore Files](./ai-ignore-files.md) - Patterns for AI coding assistants (Codeium, Cursor)
- [Security Considerations](./security-considerations.md) - Security-related ignore patterns

## File Combinations

### VCS Ignore Files
- **Example outputs**: `.gitignore`
- **Included patterns**:
  - `vcs.ignorefile`
  - `vcs.ignorefile.md`
  - `security.ignorefile`
- **Excluded patterns**:
  - `ai.ignorefile`
  - `dev.ignorefile`

### Packaging Ignore Files
- **Example outputs**: `.npmignore`
- **Included patterns**:
  - `packaging.ignorefile`
  - `packaging.ignorefile.md`
  - `vcs.ignorefile`
  - `security.ignorefile`
- **Excluded patterns**:
  - `ai.ignorefile`

### AI Ignore Files
See [AI Ignore Files](./ai-ignore-files.md) for detailed documentation.

## How to Generate

### From the command line

```bash
node .config/filelists/generate-ignores.js
```

### From npm scripts

Add to your `package.json`:

```json
{
  "scripts": {
    "generate-ignores": "node .config/filelists/generate-ignores.js"
  }
}
```

Then run:

```bash
npm run generate-ignores
```

## Maintenance

1. To modify ignore patterns, edit the appropriate `.ignorefile` in `.config/filelists/`
2. Run the generator to update all output files
3. Commit both the source files and generated files

## Best Practices

- Keep patterns specific to their purpose
- Document non-obvious patterns
- Review and update patterns regularly
- Test changes to ensure they work as expected
