# Rust CLI Boilerplate Requirements

This directory contains the consolidated requirements for the Rust CLI boilerplate template.

## Requirements Documents

- **[cli-standards.md](./cli-standards.md)** - Core CLI Tool Standards compliance (35 standards from ADR-20260607001)
- **[axi-support.md](./axi-support.md)** - Agent eXperience Interface (AXI) support for AI agent integration

## Overview

The Rust CLI boilerplate must achieve full compliance with:

1. **CLI Tool Standards** (35 standards) - Comprehensive cross-language CLI standards covering configuration, logging, daemon support, testing, and more
2. **AXI Standards** (11 requirements) - Agent mode optimization for autonomous AI agent consumption

## Implementation Priority

1. **Phase 1**: Core CLI Standards (cli-standards.md) - 4 weeks
2. **Phase 2**: AXI Support (axi-support.md) - 2 weeks (after core standards complete)

## Related Documentation

- ADR-20260607001: CLI Tool Standards v4.0.0
- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- TOON Format: https://toonformat.dev/reference/spec.html
