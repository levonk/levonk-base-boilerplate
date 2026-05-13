# CLI App Boilerplates

This directory contains production-grade CLI tool boilerplates for various languages, adhering to strict industry best practices for configuration, output, and user experience.

## Standards and ADRs

- **CLI Program Standards:** See [ADR 20251210001: CLI Program Standards](../../../internal-docs/adr/adr-20251210001-cli-standards-and-boilerplates.md) for the canonical rules on config precedence, input/output, signals, exit codes, and quality gates.
- **Boilerplate Tooling:** Follows [ADR 20251129001: Copier-Based Boilerplate Standard](../../../internal-docs/adr/adr-20251129001-copier-based-boilerplate-standard.md).
- Every template ships with: Makefile (clean/build/install/lint/test/run/docker-build/docker-run), `run.sh` Docker wrapper, hardened multi-stage Dockerfile, docker-compose, and language-appropriate tests covering help, globbing, stdin, JSON vs. human output, and exit codes.

## Getting Started

Use `copier` to generate a new CLI project from one of the available templates.

### Python
```bash
copier copy gh:lrepo52/job-aide/boilerplate/apps/cli/python/core my-tool
```

### Rust
```bash
copier copy gh:lrepo52/job-aide/boilerplate/apps/cli/rust/core my-tool
```

### Go
```bash
copier copy gh:lrepo52/job-aide/boilerplate/apps/cli/go/core my-tool
```

### TypeScript / Node.js
```bash
copier copy gh:lrepo52/job-aide/boilerplate/apps/cli/typescript/core my-tool
```

### Other Languages
Available templates:
- `bash/core`
- `powershell/core`
- `csharp/core` (.NET Native AOT)
- `java/core` (GraalVM / JBang)
- `ruby/core`

---

## Best Practices (The Golden Rules)

Every boilerplate in this repository implements these core principles.

### 1. Configuration Precedence Order
A robust tool should resolve configuration in the following order (highest priority to lowest):
1.  **CLI Arguments:** Flags passed directly (e.g., `--port 8080`).
2.  **Environment Variables:** Useful for containers/CI (e.g., `MYTOOL_PORT=8080`).
3.  **Local Project Config:** `.mytoolrc` or `mytool.toml` in the current working directory.
4.  **User Config:** Global user settings. Use the **XDG Base Directory Specification**:
    *   Linux/Mac: `~/.config/mytool/config.toml` (managed via `XDG_CONFIG_HOME`).
    *   Windows: `%APPDATA%\mytool\config.toml`.
5.  **System/Enterprise Config:** `/etc/mytool/config` (Linux) or `ProgramData` (Windows).
6.  **Hardcoded Defaults:** The fallback values inside your code.

**Preferred Config Formats:**
*   **TOML:** Preferred for human-editable configuration. It is unambiguous and easy to read.
*   **YAML:** Acceptable for complex, deeply nested configurations, but prone to whitespace errors.
*   **JSON:** Avoid for user-editable config (no comments). Use only for machine-to-machine communication.

### 2. The Rules of Output (Stdout vs. Stderr)
*   **Stdout:** Only machine-readable data (the "result").
*   **Stderr:** Logs, progress bars, status updates, and errors.
*   **Why?** This allows users to pipe your tool cleanly: `mytool list | grep "foo"`. If you print "Searching..." to stdout, you break the pipe.

### 3. User Experience (UX)
*   **Help & Usage:** Always provide clear `-h/--help` output.
*   **Colors:**
    *   **Automatic Detection:** Detect if `stdout` is a TTY. Disable colors if piping to a file.
    *   **`NO_COLOR`:** Respect the `NO_COLOR` environment variable.
*   **Interactivity:** Never prompt for input if not running in an interactive terminal (TTY), unless explicitly forced.
*   **Error Messages:** Be concise. "File not found" is better than a 50-line stack trace (unless `--debug` is passed).

### 4. Signal Handling & Cleanup
*   **SIGINT (Ctrl+C):** Handle graceful shutdown. Release locks, clean up temp files, and exit with code `130`.
*   **Exit Codes:**
    *   `0`: Success.
    *   `1`: Generic error.
    *   `2`: Usage error (bad flags).
    *   `130`: Terminated by user (Ctrl+C).

### 5. Developer Experience (DX)
*   **Packaging:**
    *   **Single Binary:** Prefer compiling to a single static binary (Go, Rust, GraalVM, C# AOT) or bundling (PyInstaller, pkg).
    *   **Container:** Provide a minimal Dockerfile.
*   **Linting & Formatting:** Enforce standard style guides (Black/Ruff for Python, Rustfmt, Prettier, etc.).
