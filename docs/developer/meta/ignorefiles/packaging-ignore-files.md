# Packaging Ignore Patterns

This document outlines patterns for files that should be excluded from packaged output (e.g., npm packages) but may be kept in version control. These patterns are used to ensure only necessary files are included in published packages.

## Purpose

Development source code patterns help manage the packaging process by:

1. **Excluding development source code** from production packages
2. **Preserving configuration templates** while excluding local overrides
3. **Maintaining documentation** in the repository while keeping it out of packages
4. **Excluding test and example code** from production builds

## Usage

These patterns are included in:
- `.npmignore` (Packaging)
- (Not included in `.gitignore` or AI ignore files)

## Common Patterns

```gitignore
# Source code directories
/src/
/test/
/__tests__/
/examples/
/benchmarks/

# Configuration templates and local overrides
/config/*.example
/config/*.template
/config/local.*

# Documentation
/docs/
/website/
*.md
!README.md
!CHANGELOG.md
!LICENSE.md

# Development scripts and tools
/scripts/
/tools/
*.config.js
*.config.ts

# TypeScript source files
*.ts
!*.d.ts

# Source maps
*.map
*.js.map

# Test files
*.test.*
*.spec.*
*.e2e.*
```

## Best Practices

1. **Be Specific**: Target only development-specific files and directories
2. **Consider Performance**: Large directories like `node_modules/` should be excluded early
3. **Document Exceptions**: If a pattern needs to be overridden, document why
4. **Keep Updated**: Review and update patterns as the project evolves

## Related Documentation

- [Ignore Files Overview](../README.md)
- [Security Ignore Patterns](./security-ignore-files.md)
