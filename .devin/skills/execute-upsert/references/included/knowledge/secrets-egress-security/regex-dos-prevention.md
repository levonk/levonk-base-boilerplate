---
type: Practice
title: Regex DoS Prevention
description: User-supplied regular expressions can denial-of-service a service even with the linear-time Rust regex crate. Limit complexity, bound input length, and reject untrusted patterns when parsing is not required.
tags: [security, rust, regex, dos, input-validation, supply-chain]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Regex DoS Prevention

## Failure Mode

A service that accepts user-supplied regular expressions and runs them against
unbounded input is vulnerable to regular-expression denial of service (ReDoS).
Even with a backtracking-free engine, a pathological pattern compiled into a
large DFA can exhaust memory, and an adversary can craft inputs that maximize
matching time against the linear scan.

## Practice

### Why the Rust `regex` Crate Is Safer, Not Safe

The `regex` crate (1.10) uses finite automata — NFA, DFA, and a lazy DFA —
rather than backtracking. This gives a linear-time guarantee *by design* and
eliminates the classic catastrophic backtracking of PCRE. The remaining risks
are real and must be handled explicitly:

1. **DFA memory blowup** — a pattern can produce a DFA whose state space is
   exponential in the pattern length. The lazy DFA mitigates this but can still
   allocate heavily on adversarial patterns.
2. **Unbounded input length** — linear time on a 10 GB input is still a DoS.
3. **Compile cost** — compiling a hostile pattern can be expensive on its own.

### Bound Input and Compile Time

Always cap the input string before matching, and compile untrusted patterns
behind a budget.

```rust
use regex::Regex;
use std::time::Duration;

const MAX_INPUT_LEN: usize = 64 * 1024;
const MAX_PATTERN_LEN: usize = 256;

fn safe_match(pattern: &str, input: &str) -> Result<bool, String> {
    if pattern.len() > MAX_PATTERN_LEN {
        return Err("pattern too long".into());
    }
    if input.len() > MAX_INPUT_LEN {
        return Err("input too long".into());
    }
    // Regex::new is the compile step; bound it with a timeout in the caller.
    let re = Regex::new(pattern).map_err(|e| format!("bad pattern: {e}"))?;
    Ok(re.is_match(input))
}
```

For compile-time protection, run the match in a worker thread with a deadline
and abort the thread if it exceeds the budget.

### Generate Adversarial Inputs in Tests

Do not assume a pattern is safe because it compiles. Fuzz the matcher with
inputs designed to maximize DFA state transitions.

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_oversized_pattern() {
        let pat = "a".repeat(MAX_PATTERN_LEN + 1);
        assert!(safe_match(&pat, "a").is_err());
    }

    #[test]
    fn bounded_input_on_repeating_capture() {
        // A pattern that would be catastrophic under backtracking.
        let pat = "(a+)+$";
        let input = "a".repeat(MAX_INPUT_LEN);
        // Must return quickly, not hang.
        let _ = safe_match(pat, &input);
    }
}
```

### When to Reject User-Supplied Regex Entirely

Prefer fixed patterns compiled at build time. Accept user-supplied regex only
when the feature is essential, and then:

- Require an explicit feature flag (`allow_user_regex = true`).
- Rate-limit compilation per tenant.
- Cache compiled patterns by hash to bound repeated compile cost.
- Log every user pattern for audit.

If the use case is "search for this string," use `str::contains` or
`aho-corasick` instead of a regex. If the use case is "validate this format,"
ship a fixed pattern rather than accepting one from the caller.

## Related Concepts

- [Shared Path Cleanliness](shared-path-cleanliness.md) — Input validation is
  part of the same security posture as secret hygiene.
- [Linter Security Patterns](../devsecops-codeguard/linter-security-patterns.md)
  — Linters that reject dangerous regex in source under review.
