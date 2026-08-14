---
type: Practice
title: Path Traversal in Scanners
description: File scanning tools that accept untrusted paths are vulnerable to traversal via ../, symlinks, and absolute paths. Canonicalize, bound symlink depth, and sandbox to a project root before reading any file.
tags: [security, rust, path-traversal, filesystem, sandbox, scanner]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Path Traversal in Scanners

## Failure Mode

A scanner that walks a user-supplied path without canonicalization can be
tricked into reading files outside the intended project root. Classic vectors
include `../../etc/passwd`, symlink loops that exhaust the walker, and absolute
paths that bypass the configured root. On Windows, `..\` and UNC paths
(`\\?\C:\`) add platform-specific escape routes; on macOS, case-insensitive
filesystems defeat naive string-prefix checks.

## Practice

### Canonicalize, Then Contain

Lexical normalization (`Path::components`) is not enough — it does not resolve
symlinks. Use `std::fs::canonicalize` to resolve the real path, then verify the
canonical path is still inside the sandbox root.

```rust
use std::path::{Path, PathBuf};

fn within_root(root: &Path, target: &Path) -> Result<PathBuf, String> {
    let root = root.canonicalize().map_err(|e| e.to_string())?;
    let resolved = target.canonicalize().map_err(|e| e.to_string())?;
    if !resolved.starts_with(&root) {
        return Err(format!("path escapes root: {}", resolved.display()));
    }
    Ok(resolved)
}
```

### Reject Absolute and Relative Escape Early

Before canonicalization, reject inputs that are obviously hostile. This keeps
error messages clear and avoids touching the filesystem for junk input.

```rust
fn validate_input(root: &Path, input: &str) -> Result<PathBuf, String> {
    let p = Path::new(input);
    if p.is_absolute() {
        return Err("absolute paths are not allowed".into());
    }
    let joined = root.join(p);
    // Lexical pre-check; canonicalize confirms against symlinks.
    if joined.components().any(|c| matches!(c, std::path::Component::ParentDir)) {
        // Allow only if canonicalization still lands inside root.
    }
    within_root(root, &joined)
}
```

### Bound Symlink Depth and Refuse Out-of-Root Links

`walkdir` follows symlinks only when asked. When you must follow them, cap the
depth and re-check containment on every entry.

```rust
use walkdir::WalkDir;

const MAX_SYMLINK_DEPTH: usize = 8;

fn scan(root: &Path) -> Vec<PathBuf> {
    let root = root.canonicalize().unwrap();
    WalkDir::new(&root)
        .follow_links(true)
        .max_depth(MAX_SYMLINK_DEPTH)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| {
            e.path().canonicalize()
                .map(|c| c.starts_with(&root))
                .unwrap_or(false)
        })
        .map(|e| e.into_path())
        .collect()
}
```

### Cross-Platform Risks

- **Windows** — `..\` is the same as `../`; normalize before checking. UNC
  paths (`\\?\C:\`, `\\server\share`) bypass drive-letter roots; reject any
  input containing a UNC prefix.
- **macOS** — HFS+/APFS are case-insensitive by default. A string compare of
  `root.to_str()` against the target will miss `Root/` vs `root/`. Always
  compare canonicalized `PathBuf` values, not strings.
- **All platforms** — `canonicalize` requires the path to exist. For a
  not-yet-created target, canonicalize the parent and join the leaf name.

### Sandbox Patterns for Untrusted Paths

Treat every caller-supplied path as hostile. The safest pattern is to ignore
the caller's path entirely and walk a fixed root, matching files by content
hash or metadata rather than by caller-supplied location. When the caller's
path is required, apply the three checks above in order: reject absolute,
canonicalize, confirm containment.

## Related Concepts

- [Shared Path Cleanliness](shared-path-cleanliness.md) — Containment of
  untrusted paths mirrors containment of secrets to the shared/ boundary.
