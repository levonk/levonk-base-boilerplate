# Security Ignore Patterns

This document outlines the security-focused ignore patterns used across the project to prevent sensitive information from being committed to version control or included in builds.

## Purpose

Security ignore patterns help protect sensitive information by ensuring that:

1. **Credentials** (API keys, tokens, passwords) are never committed
2. **Configuration files** with sensitive data are excluded
3. **Local development files** containing personal settings are kept local
4. **Temporary files** that might contain sensitive data are ignored

## Usage

These patterns are included in:
- `.gitignore` (VCS)
- `.npmignore` (Packaging)
- `.codeiumignore` and `.cursorignore` (AI tools)

## Common Patterns

```gitignore
# Credentials and sensitive data
**/.env*
**/*.pem
**/*.key
**/*.crt
**/*.p12
**/*.pfx
**/secrets/*
**/credentials/*
**/*password*
**/*secret*
**/*token*

# SSH and encryption
**/id_rsa*
**/id_dsa*
**/*.gpg
**/*.pgp

# Local development overrides
**/local.*
**/local_*
**/*.local.*
**/config/local.*

# Session and temporary files
**/sessions/*
**/tmp/*
**/temp/*
**/*.swp
**/*.swo
**/*.swn
**/Thumbs.db
**/ehthumbs.db
```

## Best Practices

1. **Be Specific**: Target only files that contain sensitive information
2. **Test Changes**: Verify patterns work as expected before committing
3. **Document Exceptions**: If a pattern needs to be overridden, document why
4. **Keep Updated**: Review and update patterns as the project evolves

## Related Documentation

- [Ignore Files Overview](../README.md)
- [Security Guidelines](../security/guidelines.md) (if applicable)
