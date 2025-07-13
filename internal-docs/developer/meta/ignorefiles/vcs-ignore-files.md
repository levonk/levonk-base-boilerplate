# Version Control Ignore Patterns

This document outlines patterns for files that should be excluded from version control systems. These patterns are used to prevent tracking of system files, build artifacts, and other files that don't belong in source control.

## Purpose

VCS ignore patterns help maintain a clean repository by excluding:

1. **System-generated files** (e.g., `.DS_Store`, `Thumbs.db`)
2. **Temporary files** from editors and IDEs
3. **Build artifacts** and intermediate files
4. **Logs and crash dumps**

## Usage

These patterns are included in:
- `.gitignore` (VCS)
- `.npmignore` (Packaging)
- `.codeiumignore` and `.cursorignore` (AI tools)

## Common Patterns

```gitignore
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.swp
*.swo
*~

# Logs and databases
*.log
*.sql
*.sqlite
*.sqlite3

# Dependency directories
node_modules/
jspm_packages/

# Build outputs
/dist/
/build/
/out-tsc/
*.tsbuildinfo

# Coverage directory used by testing tools
/coverage/

# Temporary files
*.tmp
*.temp
*.bak
*.backup
*.rej
*.orig
*.patch

# System Files
.DS_Store
Thumbs.db
```

## Best Practices

1. **Be Comprehensive**: Include patterns for all operating systems
2. **Keep Organized**: Group related patterns together with comments
3. **Update Regularly**: Add new patterns as needed for new tools and environments
4. **Test Changes**: Verify patterns work as expected before committing

## Related Documentation

- [Ignore Files Overview](../README.md)
- [Security Ignore Patterns](./security-ignore-files.md)
- [Development Ignore Patterns](./dev-ignore-files.md)
