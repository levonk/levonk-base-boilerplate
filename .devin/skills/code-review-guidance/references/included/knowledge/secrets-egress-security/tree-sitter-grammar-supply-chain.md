---
type: Practice
title: Tree-Sitter Grammar Supply Chain
description: Third-party tree-sitter grammars are C extensions compiled into the host Rust process with full privileges. Pin versions, review C source, and isolate untrusted grammars in a subprocess sandbox.
tags: [security, rust, tree-sitter, supply-chain, ffi, sandbox, c-code]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Tree-Sitter Grammar Supply Chain

## Failure Mode

A tree-sitter grammar is not a passive data file. It is C source compiled into
a shared object and loaded into the host process via FFI. A malicious or
compromised grammar runs with the full privileges of the host: it can read
files, open sockets, and exfiltrate source code being parsed. Treating a
grammar crate as "just a parser" is the same error as treating any native
dependency as trusted by default.

## Practice

### What a Grammar Actually Is

The `tree-sitter` 0.23 Rust crate loads grammar crates (e.g.
`tree-sitter-rust`, `tree-sitter-python`) that each ship a `parser.c` and a
generated `Scanner.c` or `Scanner.cc`. The scanner is hand-written C++ that
runs on every byte of input. There is no sandbox between that code and your
process.

```rust
use tree_sitter::{Language, Parser};

// Loading a grammar links C code into this process.
extern "C" { fn tree_sitter_rust() -> Language; }

let mut parser = Parser::new();
parser.set_language(&unsafe { tree_sitter_rust() })
    .expect("failed to load rust grammar");
```

### Pin Grammar Versions

Every grammar crate must be pinned in `Cargo.lock` and reviewed on upgrade.
A grammar is a transitive security dependency, not a convenience.

- Run `cargo update -p tree-sitter-rust --dry-run` to see the candidate
  version before accepting it.
- Diff the upstream `src/parser.c` and `src/scanner.c` between versions.
- Block any grammar upgrade that adds `unsafe`, file I/O, or network calls
  in its C source.

### Review Grammar Source

Before adding a grammar, read the C source, not just the Rust wrapper. Reject
grammars that:

- Open files or sockets from within the scanner.
- Use `system()`, `popen()`, or `exec*`.
- Read environment variables or home-directory paths.
- Link against libraries beyond the C runtime.

A write-only grammar parses input and returns a syntax tree. It performs no
I/O, no allocation beyond the parser arena, and no syscalls beyond what
tree-sitter core requires. Prefer these.

### Sandbox Untrusted Grammars

When you must parse with a grammar you do not fully trust, run it in a
separate process and pass input over a pipe. The child process has no
filesystem access beyond what you grant; a compromise crashes the child, not
the host.

```rust
use std::process::{Command, Stdio};
use std::io::Write;

fn parse_isolated(grammar_bin: &str, source: &str) -> std::io::Result<Vec<u8>> {
    let mut child = Command::new(grammar_bin)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        // On Linux, consider seccomp/landlock here; on macOS, sandbox-exec.
        .spawn()?;
    {
        let mut stdin = child.stdin.take().unwrap();
        stdin.write_all(source.as_bytes())?;
    }
    let out = child.wait_with_output()?;
    Ok(out.stdout)
}
```

The host then trusts only the serialized tree, never the grammar's C code
running in its own address space.

### Audit on Every CI Run

Add a CI step that lists every grammar crate in the dependency graph and
re-checks its source hash against a recorded baseline. A silent grammar bump
is the same class of risk as a silent dependency swap.

```bash
cargo tree -i tree-sitter 2>/dev/null | grep 'tree-sitter-'
sha256sum $(cargo metadata --format-version 1 | \
  jq -r '.packages[] | select(.name|startswith("tree-sitter-")) | .manifest_path')
```

## Related Concepts

- [Dependency Supply Chain](../devsecops-codeguard/dependency-supply-chain.md)
  — Grammars are a special case of native-dependency supply-chain risk.
- [Shared Path Cleanliness](shared-path-cleanliness.md) — Parsed source is
  untrusted input; treat the parser boundary with the same discipline.
