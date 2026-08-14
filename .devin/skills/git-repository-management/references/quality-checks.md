# Secret Scanning and Quality Check Details

### Quality Check Results
The script runs quality checks and returns results:
```
=== QUALITY_CHECKS_START ===
ESLINT:
✓ No ESLint warnings
PRETTIER:
✓ All files formatted
NPM_TEST:
✓ All tests passed
=== QUALITY_CHECKS_END ===
```

### Quality Check Integration
Quality checks are included in `git-collect.sh` - no separate handoff needed:

```bash
# Single call gets changes + quality check results
./scripts/git-collect.sh

# AI analyzes results:
# - ESLINT_STATUS:PASS
# - PRETTIER_STATUS:FAIL
# - NPM_TEST_STATUS:PASS
# - Changes: 5 files modified

# AI decides: Fix prettier formatting, then proceed with commits
```

## Security Considerations

- **Identity-leak scanning**: `git-commit-batch.sh` runs `scan-artifacts.sh` after staging files and before committing. The script resolves the current machine's identity values (`$HOME`, `whoami`, `hostname`, WiFi SSID, DNS search domain) and scans the staged diff for those specific strings. HARD leaks (resolved paths, usernames, WiFi SSID) block the commit with `COMMIT_FAILED:SCAN_ARTIFACTS`; REVIEW items (hostname, DNS domain) require AI judgment. Set `SCAN_ARTIFACTS_PRIVATE=1` for private repos where HARD leaks are informational only (exit 0)
- **Secret-pattern scanning**: `git-commit-batch.sh` runs `scan-secrets.sh` after `scan-artifacts.sh` and before committing. The script uses `cli-tool-discovery.sh` to find [git-secrets](https://github.com/awslabs/git-secrets) through environment wrappers (devbox, mise, flox, direnv, nix) and standard PATH locations. If git-secrets is available, it runs `git secrets --scan --cached` against staged files to detect AWS access keys, secret keys, account IDs, and other prohibited patterns registered in the repo or global git config. If git-secrets finds prohibited patterns, the commit is blocked with `COMMIT_FAILED:SCAN_SECRETS`. If git-secrets is not installed, the scan is skipped (exit 0) — secret scanning is opt-in, not a hard dependency. Set `SCAN_SECRETS_PRIVATE=1` for private repos where findings are informational only (exit 0). Set `SCAN_SECRETS_SKIP=1` to skip secret scanning entirely. To register AWS patterns before scanning, run `scan-secrets.sh --register-aws`. To add false-positive patterns as allowed, run `git secrets --add -a '<pattern>'`
- **Private information**: Checks for accidental data exposure
- **Safe execution**: All operations are non-destructive until explicit commit
- **Rollback capability**: Maintains ability to undo changes if needed
- **No AI attribution**: Commits must never contain AI signatures or co-author trailers (see No AI Signatures rule above)
- **Automatic tagging**: Pre and post tags provide audit trail for every skill run (see Automatic Run Tagging rule above)
- **RTK proxy**: Use rtk for token-optimized command output when available (see Use RTK When Available rule above)
- **Devbox wrapping**: Use devbox run for reproducible environment execution when available (see Use Devbox When Available rule above)
- **Jujutsu**: Use jj for log and history operations when available (see Use Jujutsu When Available rule above)
- **Diff tools**: Use difftastic > delta > raw for enhanced diffs (see Use Difftastic and Delta for Diffs rule above)
- **Hunk**: Use hunk for interactive diff review when available (see Use Hunk for Interactive Diff Review rule above)
- **git-extras**: Use git-extras subcommands for convenience operations when available (see Use git-extras When Available rule above)
- **Fetch-rebase-push with backup**: git-push.sh creates a backup branch before attempting rebase/merge with auto-resolution, ensuring original work is always recoverable

## Error Handling

### Script Failures
- **Graceful degradation**: Script continues with fallbacks when optional tools unavailable
- **Clear error messages**: All failures include actionable error descriptions
- **Exit codes**: Standard exit codes for automation (0=success, 1=failure)
- **Structured output**: Errors are machine-readable for AI analysis

### Git Conflicts
- **Detection**: Script detects merge/rebase conflicts before committing
- **AI decision**: AI decides whether to halt, attempt resolution, or notify user
- **Safe state**: Never leaves repository in inconsistent state

### Missing Dependencies
- **Devbox**: Falls back to native execution if devbox unavailable
- **Quality tools**: Continues without optional tools (eslint, prettier)
- **AI adaptation**: AI adjusts strategy based on available tooling

### Subdirectory / Repository Root Failures
- **Symptom**: `fatal: not a git repository` when running from a path that is inside a git repo
- **Root cause**: The script was invoked from a subdirectory without first resolving the repository root
- **Fix**: The script automatically discovers repository root using `git rev-parse --show-toplevel`
- **Prevention**: Script always resolves root before any git operations

### Commit Message Shows Literal `\n` Instead of Newlines
- **Symptom**: `git log` shows `fix: subject\n\n- body line` with literal backslash-n instead of real line breaks
- **Root cause**: `devbox run -- rtk git commit -m "$msg"` serializes argv in a way that re-escapes newlines, turning real `\n` into literal `\n` text in the committed message. Direct `git commit -m` or `rtk git commit -m` (without devbox wrapping) preserves newlines correctly.
- **Fix**: The script uses `git commit -F <tempfile>` (via `commit_with_message`) instead of `-m`, writing the expanded message to a temp file so it never passes through devbox's argv serialization.
- **Prevention**: Any new code that commits through the `devbox_run` / `git_cmd` wrapper chain must use `-F`, not `-m`, for multi-line messages.
