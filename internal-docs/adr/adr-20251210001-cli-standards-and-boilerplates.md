---
modeline: "vim: set ft=markdown:"
title: "ADR: CLI Program Standards"
adr-id: "20251210001"
slug: "20251210001-cli-standards-and-boilerplates"
url: "/internal-docs/adr/adr-20251210001-cli-standards-and-boilerplates.md"
synopsis: "Defines cross-language standards for how CLI programs behave: configuration precedence, input/output rules, signals, exit codes, and quality gates. Boilerplates must implement these standards."
author: "https://github.com/levonk"
date-created: "2025-12-10"
date-updated: "2025-12-13"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "cli", "boilerplate", "tooling", "standard"]
supersedes: []
superseded-by: []
related-to: ["adr-20251129001-copier-based-boilerplate-standard"]
scope:
  impact-scope: ["all CLI programs in this repo", "boilerplate/apps/cli/*", "all CLI projects generated from these templates"]
  excluded-scope: []
---

# Decision Record: CLI Program Standards

- belongs in `internal-docs/adr/adr-20251210001-cli-standards-and-boilerplates.md`

---

## Context

CLI tools are part of the repo's public interface and automation surface. Without codified standards, CLI programs drift across projects and languages, causing inconsistent UX, configuration handling, and operational posture.

The monorepo also maintains multiple production-grade CLI boilerplates (Python, Rust, Go, TypeScript, Bash, PowerShell, C#, Java, Ruby). The existing [ADR 20251129001: Copier-Based Boilerplate Standard](./adr-20251129001-copier-based-boilerplate-standard.md) mandates copier for scaffolding but does not define what CLI programs must do.

## Decision

Adopt a unified cross-language standard for CLI program behavior.

All CLI programs **must** provide:

1. **Configuration Precedence**: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults. Prefer TOML for human-edited config; YAML acceptable for complex structures; JSON reserved for machine-to-machine.
2. **Input & Globbing**: Support recursive `**/*` globbing plus stdin via `-` or piped input; process files or stdin interchangeably.
3. **Output Discipline**: Results to stdout; logs/progress/errors to stderr. Provide `--json` output mode; auto-disable color when stdout not a TTY; honor `NO_COLOR`.
4. **Signals & Exit Codes**: Graceful SIGINT handling with exit code `130`; standard exit codes `0` success, `1` generic error, `2` usage error.
5. **Testing**: Language-appropriate tests covering help output, globbing, stdin, config precedence, json vs human output, and exit-code behavior where feasible.

CLI boilerplates **must** implement these standards and additionally provide:

1. **Developer Experience**: Makefile targets `clean`, `build`, `install`, `lint`, `test`, `run`, `docker-build`, `docker-run`. Include `run.sh` wrapper for Docker usage and a hardened `docker-compose.yml`.
   - Add setup targets: `doctor`, `bootstrap`, `profile`.
   - `doctor` must validate `flake.nix` exists and print `direnv allow` guidance when `direnv` is installed.
2. **Project-Scoped Toolchain**: Include a pinned `flake.nix` devShell and use `nix develop -c` in Makefile targets.
3. **Direnv**: Include a `.envrc` file with `use flake` to auto-load the Nix devShell via `direnv`.
4. **Container Hardening**: Multi-stage Dockerfile, non-root user, drop caps, `no-new-privileges`, read-only root filesystem with tmpfs for writable paths.
5. **Copier Hygiene**: Templates live under `boilerplate/apps/cli/*`, include `.copier-answers.yml` in generated projects, and stay minimal in Jinja logic.

## Rationale

Codified CLI standards prevent drift across languages, give users predictable UX/IO semantics, and simplify security reviews.

Boilerplates are the enforcement mechanism and reference implementation. Requiring Makefile, Docker, and test parity ensures each template is production-ready and updateable via `copier`.

## Technical Approach

- Keep standards language-agnostic; use idiomatic libraries (e.g., Typer, Clap, Cobra, Commander, Spectre.Console, Picocli, Dir.glob).
- Enforce stdout/stderr separation and JSON toggle at the command layer.
- Provide container artifacts (Dockerfile, docker-compose.yml, run.sh) with the hardened defaults above.
- Tests must be part of each template (pytest, assert_cmd, Vitest, bats, Pester, xUnit, JUnit, RSpec, etc.).
- Document standards in the CLI README and cross-link this ADR from architecture docs.

## Consequences

### Positive
- Consistent UX, diagnostics, and configuration across all CLIs.
- Faster onboarding and safer updates via copier re-application.
- Reduced security and compliance review overhead due to hardened defaults.

### Negative
- Existing generated projects may need updates to conform; copier updates could surface merge conflicts.
- Additional upfront work to keep tests and containers current per language ecosystem.

## Alternatives Considered

- **Per-language guidelines only**: Rejected; too much variance and drift.
- **Minimal templates without containers/tests**: Rejected; not production-ready and increases toil later.
- **Ad-hoc per-project customization**: Rejected; undermines consistency and copier-based updates.
