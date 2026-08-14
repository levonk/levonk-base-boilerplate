---
type: Practice
title: TOML Config Injection
description: TOML configuration loaded from untrusted sources can inject tables, arrays, and hostile values via crafted strings. Validate file permissions, parse with serde, and never shell-expand environment variables in config values.
tags: [security, rust, toml, serde, config, injection, permissions]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# TOML Config Injection

## Failure Mode

A service that loads TOML configuration from a user-editable location can be
subverted by injecting newlines into string values, smuggling extra tables or
array entries, or reading a world-writable file that an attacker has replaced.
Custom include systems and shell-style env var expansion open further vectors
that the TOML spec itself does not protect against.

## Practice

### Why serde Prevents Most Injection

The `toml` 0.8 crate parses into typed Rust structs via `serde` 1.0. String
values are decoded as Rust `String`s — a newline inside a TOML basic string
(`"a\nb"`) is a literal newline character in the value, not a parser directive.
You cannot inject a new table by smuggling a `[evil]` header inside a quoted
string, because the parser has already decided it is a string. The injection
risk returns only when you later concatenate that value into another format
(Shell, SQL, a second TOML file) without escaping.

```rust
use serde::Deserialize;

#[derive(Deserialize)]
struct AppConfig {
    name: String,
    endpoints: Vec<String>,
}

fn load(raw: &str) -> Result<AppConfig, toml::de::Error> {
    toml::from_str(raw)
}
```

### Validate File Permissions Before Reading

A config file that is world-writable is a live attack surface. Check the mode
on Unix before parsing, and refuse group-writable files unless explicitly
allowed.

```rust
use std::os::unix::fs::PermissionsExt;
use std::path::Path;

fn check_mode(path: &Path) -> Result<(), String> {
    let meta = std::fs::metadata(path).map_err(|e| e.to_string())?;
    let mode = meta.permissions().mode();
    if mode & 0o002 != 0 {
        return Err("config is world-writable".into());
    }
    if mode & 0o020 != 0 {
        return Err("config is group-writable".into());
    }
    Ok(())
}
```

### Include Directive Risks

TOML has no native include mechanism. Any custom include system you build on
top (a `include = "other.toml"` key, a templating preprocessor) is a new
injection surface: the included file is parsed with the privileges of the
caller, and a path traversal in the include key can pull in arbitrary files.
If you implement includes, apply path-traversal containment to the include
target and re-check permissions on every included file.

### Env Var Expansion Safety

Never run config values through a shell. Do not use `sh -c` or `eval`-style
expansion on TOML content. Use explicit, bounded lookup instead.

```rust
fn expand_env(value: &str) -> String {
    // Replace ${VAR} with std::env::var, nothing else.
    let mut out = String::new();
    let bytes = value.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'$' && i + 1 < bytes.len() && bytes[i + 1] == b'{' {
            if let Some(end) = value[i + 2..].find('}') {
                let name = &value[i + 2..i + 2 + end];
                let val = std::env::var(name).unwrap_or_default();
                out.push_str(&val);
                i += 2 + end + 1;
                continue;
            }
        }
        out.push(bytes[i] as char);
        i += 1;
    }
    out
}
```

This rejects shell metacharacters (`$(...)`, backticks, `|`) entirely. If a
value needs shell behavior, that is a sign the value should not be in config.

### Reject Unexpected Keys

Use `#[serde(deny_unknown_fields)]` so an attacker cannot smuggle extra
configuration past your struct. Unknown keys are a common hiding place for
options that flip a security setting in a downstream consumer.

```rust
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct AppConfig {
    name: String,
    endpoints: Vec<String>,
}
```

## Related Concepts

- [TOML Config Validation](../rust-development-practices/toml-config-validation.md)
  — Companion page on schema-level validation of TOML configs in Rust services.
- [Shared Path Cleanliness](shared-path-cleanliness.md) — Config files are
  secrets-adjacent and deserve the same containment discipline.
