# Tool-Substitution Table

When the subagent reaches for a tool, it must use the sanctioned form. The
"Disallowed / Wrong" column lists tools that are either not present on the
system, not permitted by the project's universal contracts, or known to
cause problems (e.g., `npx` fetching unvetted packages, `grep` being slow
and noisy on large repos).

## Package runners (host / pnpm workspace)

| Disallowed / Wrong | Sanctioned | Notes |
|---|---|---|
| `npx <pkg>` | `pnpm dlx <pkg>` | Default on host and in any pnpm workspace. |
| `npm exec <cmd>` | `pnpm exec <cmd>` | For binaries already installed in the workspace. |
| `npm run <script>` | `pnpm <script>` | Or `pnpm run <script>` if ambiguous. |
| `npm install` | `pnpm install` | |
| `npm ci` | `pnpm install --frozen-lockfile` | |
| `yarn dlx <pkg>` | `pnpm dlx <pkg>` | |
| `yarn <script>` | `pnpm <script>` | |
| `bunx <pkg>` (on host) | `pnpm dlx <pkg>` | `bunx` is container-only. |
| `bun x <pkg>` (on host) | `pnpm dlx <pkg>` | |

## Package runners (inside a Docker container)

| Disallowed / Wrong | Sanctioned | Notes |
|---|---|---|
| `pnpm dlx <pkg>` (in container) | `bunx <pkg>` | Never install pnpm in a container. |
| `npx <pkg>` (in container) | `bunx <pkg>` | |
| `npm install` (in container) | `bun install` | If the container uses bun. |

## Search and file tools

| Disallowed / Wrong | Sanctioned | Notes |
|---|---|---|
| `grep <pat>` (shell) | The agent's `grep` tool | The agent tool is permission-optimized. |
| `egrep` / `fgrep` | The agent's `grep` tool | |
| `rg <pat>` (shell, when on host) | The agent's `grep` tool | Prefer the agent tool; fall back to `rg` only when the agent tool is unavailable. |
| `find <dir> -name <pat>` | The agent's `find_file_by_name` tool | |
| `cat <file>` / `head -n` / `sed -n 'Np'` | The agent's `read` tool | |
| `mv <committed-file>` | `git mv <committed-file>` | Per the repo's universal contract. |

## Project environment wrappers

| Disallowed / Wrong | Sanctioned | Notes |
|---|---|---|
| Direct `<cmd>` in a devbox project | `just <recipe>` | `just` auto-detects devbox via `_devbox` helper. Only use `devbox run -- <cmd>` for commands not covered by a just target. |
| `rtk <cmd>` directly | `devbox run -- rtk <cmd>` | `rtk` is only available inside devbox. |
| `devbox run -- just <recipe>` | `just <recipe>` | Redundant — `just` auto-detects devbox. |
| Claiming "devbox not found" | Add nix paths to `PATH` first | See [diagnosing-tool-not-found.md](diagnosing-tool-not-found.md). |

## Ansible (infrahub and similar)

| Disallowed / Wrong | Sanctioned | Notes |
|---|---|---|
| `ansible-vault edit` (in subagent) | Escalate to user | Subagents have no interactive TTY. |
| Decrypt → edit → re-encrypt manually | Escalate to user | Corruption risk. |

## See Also

- [diagnosing-tool-not-found.md](diagnosing-tool-not-found.md) — what to do
  when a tool isn't on `PATH` and the sanctioned alternative isn't obvious
- [principle.md](principle.md) — the persist-before-reporting discipline
