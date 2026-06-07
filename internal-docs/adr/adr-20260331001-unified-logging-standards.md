---
modeline: "vim: set ft=markdown:"
title: "ADR: Unified Logging Standards"
adr-id: "20260331001"
slug: "20260331001-unified-logging-standards"
url: "/internal-docs/adr/adr-20260331001-unified-logging-standards.md"
synopsis: "Establishes unified logging standards across all applications and packages, requiring smart color detection, datetime stamping, and application identification for consistent, production-ready log output."
author: "https://github.com/levonk"
date-created: "2026-03-31"
date-updated: "2026-03-31"
version: "1.0.0"
status: "proposed"
aliases: []
tags:
  - "doc/architecture/adr"
  - "adr"
  - "logging"
  - "standards"
  - "cross-cutting"
  - "observability"
supersedes: []
superseded-by: []
related-to:
  - "adr-20251210001-cli-standards-and-boilerplates"
  - "packages/icebox/core/logging/typescript/logging/internal-docs/features/initial/logging-initial.md"
scope:
  impact-scope: ["all applications", "all packages", "all services", "all cli tools"]
  excluded-scope: []
---

# Decision Record: Unified Logging Standards

- belongs in `internal-docs/adr/adr-20260331001-unified-logging-standards.md`

---

## Context

The monorepo contains diverse applications (web apps, CLI tools, services, daemons) that currently implement logging inconsistently. This creates several problems:

- **Inconsistent output**: Different applications use different log formats, making aggregation and analysis difficult
- **Missing context**: Some log messages lack datetime stamps or application identification, hindering debugging
- **Color handling**: Applications either always use color or never use color, without considering terminal capabilities
- **Operational friction**: DevOps teams must handle multiple log formats when troubleshooting production issues

While a comprehensive logging package exists in `packages/icebox/core/logging/`, there is no ADR mandating its consistent use across the monorepo or establishing baseline logging standards for all applications.

## Constraints

1. **Backward Compatibility**: Existing applications must be able to migrate incrementally
2. **Performance**: Logging standards must not significantly impact application performance
3. **Developer Experience**: Standards should enhance, not hinder, local development workflows
4. **Production Readiness**: Log output must be suitable for both local development and production log aggregation systems
5. **Terminal Compatibility**: Color support must work across different terminals and environments

## Decision

**Adopt unified logging standards that mandate smart color detection, datetime stamping, and application identification for all log output across the monorepo.**

All applications and packages **must**:

1. **Smart Color Detection**: Automatically detect color support and disable color when output doesn't support it
2. **DateTime Stamping**: Include ISO8601 UTC timestamps in all log messages
3. **Application Identification**: Include the application/service name in all log messages
4. **Structured Output**: Use structured logging (JSON) for production environments
5. **Standard Levels**: Use consistent log levels (trace, debug, info, warn, error, fatal)

## Rationale

Unified logging standards provide:

- **Consistent Observability**: Standardized format enables easier log aggregation and analysis
- **Better Debugging**: DateTime stamps and application identification make troubleshooting faster
- **Terminal Awareness**: Smart color detection provides good UX in terminals while ensuring compatibility with log aggregators
- **Production Ready**: Structured output works well with modern log management systems
- **Developer Friendly**: Colorized output in supported terminals enhances local development experience

## Technical Approach

### 1. Color Detection Standards

All applications **must** implement smart color detection:

```typescript
// Example logic for color detection
function supportsColor(): boolean {
  // Check NO_COLOR environment variable
  if (process.env.NO_COLOR) return false;
  
  // Check if output is a TTY
  if (!process.stdout.isTTY) return false;
  
  // Check TERM environment variable
  const term = process.env.TERM || '';
  if (term.includes('color') || term.includes('256')) return true;
  
  // Default to true for modern terminals
  return true;
}
```

- **Honor `NO_COLOR`**: Always disable color when `NO_COLOR` environment variable is set
- **TTY Detection**: Disable color when output is not a terminal (piped to file, CI/CD)
- **TERM Detection**: Check terminal capabilities via `TERM` environment variable
- **Default Behavior**: Enable color for interactive terminal sessions unless explicitly disabled

### 2. DateTime Standards

All log messages **must** include ISO8601 UTC timestamps:

```json
{
  "timestamp": "2026-03-31T17:56:00.000Z",
  "level": "info",
  "application": "my-service",
  "message": "Request processed",
  "context": { "requestId": "req-123", "duration": 45 }
}
```

- **Format**: ISO8601 with millisecond precision
- **Timezone**: Always UTC to avoid timezone confusion
- **Consistency**: Same timestamp format across all applications

### 3. Application Identification

All log messages **must** include the application/service name:

```json
{
  "timestamp": "2026-03-31T17:56:00.000Z",
  "level": "info",
  "application": "job-aide-api",
  "loggerName": "packages.core.auth",
  "message": "User authenticated successfully"
}
```

- **Application Field**: Top-level `application` field identifying the service
- **Logger Field**: Optional `loggerName` field for module-level identification
- **Naming Convention**: Use kebab-case for application names (e.g., `job-aide-api`, `localnet-dns`)

### 4. Output Format Standards

Applications **must** support both structured and human-readable output:

- **Production**: JSON format for log aggregation systems
- **Development**: Pretty-printed format with colors when terminal supports it
- **Configuration**: Allow format selection via environment variable `LOG_FORMAT=json|pretty`

### 5. Integration with Existing Logging Package

Applications **should** use the existing logging package from `packages/icebox/core/logging/` when available:

- **TypeScript Applications**: Use the TypeScript logging package
- **Other Languages**: Implement equivalent behavior following these standards
- **Legacy Applications**: Gradually migrate to meet these standards

## Consequences

### Positive

- **Consistent Experience**: Developers see the same log format across all applications
- **Better Operations**: DevOps teams can aggregate and analyze logs consistently
- **Enhanced Debugging**: Timestamps and application identification speed up troubleshooting
- **Terminal Friendly**: Smart color detection provides good UX without breaking log aggregation

### Negative

- **Migration Effort**: Existing applications need updates to conform to standards
- **Implementation Complexity**: Smart color detection adds some complexity to logging libraries

### Neutral

- **Performance Impact**: Minimal overhead from timestamp generation and color detection
- **Learning Curve**: Developers need to understand the logging standards and package usage

## Alternatives Considered

1. **Extend CLI Standards ADR Only**
   - *Pros*: Simpler, fewer ADRs to maintain
   - *Cons*: CLI-specific, wouldn't cover web apps, services, or daemons
   - *Rejected*: Logging is a cross-cutting concern affecting all application types

2. **No Color Detection (Always or Never)**
   - *Pros*: Simpler implementation
   - *Cons*: Poor UX or breaks log aggregation
   - *Rejected*: Smart detection provides best of both worlds

3. **Application-Level Standards Only (No Package Mandate)**
   - *Pros*: More flexibility for individual applications
   - *Cons*: Inconsistent implementation, harder to maintain
   - *Rejected*: Consistency is key for operational excellence

## Rollout / Migration

1. **Phase 1 (Immediate)**: New applications must follow these standards from creation
2. **Phase 2 (3 months)**: Update all active applications to use the logging package and conform to standards
3. **Phase 3 (6 months)**: Update all boilerplate templates to include logging standards by default
4. **Phase 4 (Ongoing)**: Review compliance during code reviews and update documentation

## Validation

This ADR will be considered successful if:

- All new applications include proper color detection, timestamps, and application identification
- Log aggregation systems can consistently parse logs from all applications
- Developer feedback indicates improved debugging experience
- CI/CD pipelines show consistent log output across all applications
- Production troubleshooting time decreases due to standardized log format

## References

- [ADR 20251210001: CLI Program Standards](./adr-20251210001-cli-standards-and-boilerplates.md) - Existing CLI color handling standards
- [Logging Package Specification](../../packages/icebox/core/logging/typescript/logging/internal-docs/features/initial/logging-initial.md) - Technical implementation foundation
- [NO_COLOR Specification](https://no-color.org/) - Standard for disabling color output
- [ISO8601 Standard](https://www.iso.org/iso-8601-date-and-time-format.html) - DateTime format standard
