# Diagnosing "Tool Not Found"

Before reporting a tool as missing, the subagent must walk this ladder:

1. **Check standard locations** — `command -v <tool>`, then common install
   paths (`/nix/var/nix/profiles/default/bin/`, `~/.local/bin/`,
   `/usr/local/bin/`, `~/.nix-profile/bin/`).
2. **Check for a wrapper** — devbox/mise/flox/direnv/nix wrappers often
   shadow the bare binary. Run `cli-tool-discovery.sh <tool>` (materialized
   in this skill's `scripts/`) to detect wrappers.
3. **Check for a runner** — for ad-hoc packages, use
   `cli-tool-discovery.sh --runner <ecosystem>` to get the sanctioned
   invocation (`pnpm dlx` on host, `bunx` in container, `uvx` for Python,
   `cargo binstall` for Rust, `go install` for Go).
4. **Add the path to `PATH`** — if the tool exists on disk but isn't on
   `PATH`, the subagent must add it (e.g., nix profile paths) rather than
   reporting the tool as missing.
5. **Only then report** — if all four steps fail, report the tool as
   genuinely missing, with the exact commands tried and their output.

The pattern "claim `devbox` is not found and give up" is explicitly
forbidden by the infrahub `AGENTS.md` and the skills-src universal
contracts. The subagent must fix `PATH` first.

## See Also

- [tool-substitution.md](tool-substitution.md) — sanctioned alternatives to
  try before walking this ladder
- [report-templates.md](report-templates.md) — the block-report template to
  use if the tool is genuinely missing after walking the ladder
