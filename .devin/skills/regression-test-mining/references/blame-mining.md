# Blame-Based Mining

`git blame` can identify bug-introducing commits — the commits that *added*
the buggy line, not the commits that *fixed* it. This is a complementary
signal to the conventional / trailer / revert sources.

## When to Use Blame

Blame-based mining is **opt-in** (`--blame`) because it is slow on large
repos and produces noisier results than commit-message-based mining. Use it
when:

- The project does not use conventional commits (so `fix:` prefixes miss
  most fixes)
- The project has a long history of bugs without `Fixes #N` trailers
- The user specifically wants to find bug-introducing commits (e.g., to
  understand which changes introduced the most regressions)

## The Workflow

`mine-bug-fixes.sh --blame` emits a marker line; the heavy analysis is the
AI's job. The workflow:

1. **Identify hot files** — files touched by the most fix commits (from the
   conventional / trailer / revert sources). These are the files most likely
   to contain bug-introducing lines.
   ```bash
   git log --pretty=format: --name-only --grep='^fix:' -i | \
     sort | uniq -c | sort -rn | head -20
   ```

2. **Run `git blame` on each hot file** — for each line, `git blame` shows
   the commit that last touched it. Lines touched by commits that were
   *later* fixed are candidate bug-introducing commits.
   ```bash
   git blame <file>
   ```

3. **Cross-reference with fix commits** — for each blame commit, check
   whether a later commit in the same file fixed a bug introduced by it.
   The signal: a blame commit `<blame-sha>` is bug-introducing if a later
   fix commit `<fix-sha>` touches the same lines and the fix's diff reverts
   or modifies the blame commit's changes.

4. **Classify** — apply the normal
   [Commit Classification](commit-classification.md) decision tree, but
   against the bug-introducing commit (`<blame-sha>`) and the fix commit
   (`<fix-sha>`). The test should reproduce the bug as it existed at
   `<blame-sha>` and pass after `<fix-sha>`.

## Limitations

- **`git blame` is line-level** — it identifies the last commit to touch a
  line, not the commit that *introduced the bug*. A refactor that moved a
  buggy line will claim the refactor's SHA, not the original bug-introducing
  commit. Use `git blame -w` (ignore whitespace) and `git blame -C`
  (detect moved lines from the same file) to reduce this noise.
- **Squash merges break blame** — a squash merge resets blame for all
  included lines to the squash commit. The original branch commits are not
  in the main history. This is a known limitation of squash-merge workflows;
  there is no fix beyond switching to merge commits or rebase-with-merges.
- **Performance** — `git blame` on a large file with a long history is slow.
  Bound it: `git blame --since="180 days ago"` to limit to recent history.

## When to Stop

Blame-based mining has diminishing returns. Stop when:

- The hot files have been analyzed and the bug-introducing commits classified
- The blame commits are older than the project's test infrastructure (tests
  did not exist when the bug was introduced — the gap is expected, not a
  finding)
- The blame commits are in files that have since been deleted or rewritten
  (the bug is gone with the file)
