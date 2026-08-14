#!/usr/bin/env bats
# test_git_commit_batch.bats — unit tests for git-commit-batch.sh
# Tests pre-staged file handling, dry-run mode, and body-quality validation.
#
# Run via: bats scripts/tests/test_git_commit_batch.bats
#
# Creates temp git repos under /tmp/skill-test/git-commit-batch/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
BATCH="$SCRIPT_DIR/../git-commit-batch.sh"
TEST_BASE="/tmp/skill-test/git-commit-batch"

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

# Disable commit tagging in a test repo (creates the project config override).
# Usage: disable_tagging <dir>
disable_tagging() {
    local dir="$1"
    local cfg_dir="$dir/.agents/config/skills/levonk/skills-releases/software-dev/git-repository-management"
    mkdir -p "$cfg_dir"
    printf '[commit-tagging]\nenabled = false\n' > "$cfg_dir/config.toml"
}

# Create a temp git repo. Echoes the dir path.
# Tagging is DISABLED by default so existing tests using tag-free messages pass.
# Use setup_repo_with_tagging for tests that exercise the tag enforcement.
# Usage: setup_repo scenario_name
setup_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    disable_tagging "$dir"
    echo "$dir"
}

# Create a temp git repo with NO initial commit (unborn HEAD). Echoes the dir path.
# Usage: setup_unborn_repo scenario_name
setup_unborn_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    disable_tagging "$dir"
    echo "$dir"
}

# Create a temp git repo WITH commit tagging enabled (the default behavior).
# Use this for tests that verify the NO_TAG_ARRAY enforcement.
# Usage: setup_repo_with_tagging scenario_name
setup_repo_with_tagging() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# --- pre-staged file handling (Improvement #1) ---

@test "prestaged files not absorbed" {
    local dir; dir="$(setup_repo prestaged)"
    # Create and commit two independent files
    echo "a" > "$dir/a.txt"
    echo "b" > "$dir/b.txt"
    git -C "$dir" add a.txt b.txt
    git -C "$dir" commit -qm "init files"

    # Modify both, then stage a.txt (pre-staged) while leaving b.txt unstaged
    echo "a-modified" > "$dir/a.txt"
    echo "b-modified" > "$dir/b.txt"
    git -C "$dir" add a.txt  # pre-staged: this should NOT leak into commit 2

    # Batch: commit 1 should contain ONLY b.txt; a.txt must not be absorbed
    local batch
    batch=$(printf 'COMMIT:Update b only\\n\\n- Modify b.txt content\nFILES:b.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug prestaged "$dir" ) 2>&1)" || true

    assert_contains "INDEX_RESET:mixed" "$out"
    assert_contains "COMMIT_SUCCESS" "$out"

    # The commit should contain ONLY b.txt, not a.txt
    local files_in_commit
    files_in_commit=$(git -C "$dir" show --stat --name-only HEAD --pretty=format: | tr -d ' ' | sort)
    echo "$files_in_commit" | grep -q '^b.txt$' && ! echo "$files_in_commit" | grep -q '^a.txt$' || {
        echo "expected commit to contain only b.txt, got: $files_in_commit" >&3
        return 1
    }

    # a.txt should still be staged (its pre-staged state preserved after reset+commit)
    # Actually after reset --mixed, a.txt becomes unstaged. After committing b.txt,
    # a.txt remains modified in worktree but unstaged. Verify it's still dirty.
    ! git -C "$dir" diff --cached --name-only | grep -q '^a.txt$' || {
        echo "a.txt was left staged (should have been unstaged by reset)" >&3
        return 1
    }
}

# --- dry-run mode (Improvement #3) ---

@test "dry run no commits" {
    local dir; dir="$(setup_repo dryrun)"
    echo "new" > "$dir/file1.txt"
    echo "new" > "$dir/file2.txt"

    local batch
    batch=$(printf 'COMMIT:Add two files\\n\\n- Add file1 and file2\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug dryrun "$dir" ) 2>&1)" || true

    assert_contains "PROCESSING_COMMIT:1" "$out"
    assert_contains "MESSAGE:Add two files" "$out"
    assert_contains "FILES:file1.txt file2.txt" "$out"
    assert_not_contains "COMMIT_SUCCESS" "$out"
    assert_not_contains "AUTO_TAG_PRE" "$out"
    assert_not_contains "AUTO_TAG_POST" "$out"

    # Repo state: no new commits beyond the initial empty one
    local count
    count=$(git -C "$dir" rev-list --count HEAD)
    [[ "$count" -eq 1 ]] || { echo "expected 1 commit, got $count" >&3; return 1; }
}

@test "dry run rejects bodyless" {
    local dir; dir="$(setup_repo dryrun-nobody)"
    echo "new" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:No body here\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug dryrun-nobody "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_FAILED:NO_BODY" "$out"
    assert_not_contains "COMMIT_SUCCESS" "$out"
}

# --- body-quality validation (Improvement #8) ---

@test "body quality warning for file listing" {
    local dir; dir="$(setup_repo bodywarning)"
    echo "new" > "$dir/file1.txt"
    echo "new" > "$dir/file2.txt"

    # Body is just file paths — should trigger WARNING but still commit
    local batch
    batch=$(printf 'COMMIT:Add files\\n\\nfile1.txt\nfile2.txt\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug bodywarning "$dir" ) 2>&1)" || true

    assert_contains "WARNING:BODY_LOOKS_LIKE_FILE_LISTING" "$out"
    assert_contains "COMMIT_SUCCESS" "$out"
}

@test "body quality no warning for prose" {
    local dir; dir="$(setup_repo bodyprose)"
    echo "new" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\n- Needed because the prior approach did not handle edge case Y\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug bodyprose "$dir" ) 2>&1)" || true

    assert_not_contains "WARNING:BODY_LOOKS_LIKE_FILE_LISTING" "$out"
    assert_contains "COMMIT_SUCCESS" "$out"
}

# --- unborn HEAD / root-commit case ---
# Regression: git-commit-batch.sh used to fail with exit 128 on a repo with
# no commits yet because `git rev-parse HEAD` (for the pre-tag) and
# `git reset --mixed HEAD` (for index reset) both require an existing HEAD.
# The script must skip the pre-tag, clear the index via `git read-tree --empty`,
# land the root commit, and still emit the post-tag.

@test "unborn head root commit" {
    local dir; dir="$(setup_unborn_repo unborn)"
    echo "content" > "$dir/file1.txt"
    echo "content" > "$dir/file2.txt"

    local batch
    batch=$(printf 'COMMIT:Initial commit\\n\\n- Add file1 and file2\n- Seed the repository\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug initial "$dir" ) 2>&1)" || true

    assert_contains "AUTO_TAG_PRE:SKIPPED_UNBORN_HEAD" "$out"
    assert_not_contains "AUTO_TAG_PRE:tags/auto/grm/" "$out"
    assert_contains "INDEX_RESET:mixed" "$out"
    assert_contains "COMMIT_SUCCESS" "$out"
    assert_contains "AUTO_TAG_POST:tags/auto/grm/" "$out"

    # Exactly one commit (the root commit) should now exist
    local count
    count=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo 0)
    [[ "$count" -eq 1 ]] || { echo "expected 1 commit, got $count" >&3; return 1; }

    # Post-tag should point at the new root commit
    local post_tag
    post_tag=$(git -C "$dir" tag -l 'tags/auto/grm/*-initial-post' | head -1)
    [[ -n "$post_tag" ]] || { echo "no post-tag found" >&3; return 1; }
    local tag_commit_sha commit_sha
    tag_commit_sha=$(git -C "$dir" rev-parse "${post_tag}^{commit}" 2>/dev/null || echo "")
    commit_sha=$(git -C "$dir" rev-parse HEAD)
    [[ "$tag_commit_sha" == "$commit_sha" ]] || {
        echo "post-tag commit ($tag_commit_sha) != HEAD ($commit_sha)" >&3
        return 1
    }
}

@test "unborn head slug from branch" {
    # On an unborn branch, slug should still derive from the branch name
    # (e.g. "main") via `git symbolic-ref --short HEAD`, not fall back to "run".
    local dir; dir="$(setup_unborn_repo unborn-slug)"
    echo "content" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:Initial commit\\n\\n- Seed the repository\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" "$dir" ) 2>&1)" || true

    # The post-tag slug should be the branch name (main or master), not "run".
    # We accept either main or master since the default branch name varies.
    echo "$out" | grep -qE 'AUTO_TAG_POST:tags/auto/grm/[0-9]{4}/[0-9]{2}/[0-9]+-(main|master)-post' || {
        echo "slug should be branch name (main/master), got: $out" >&3
        return 1
    }
}

@test "unborn head index reset clears staged" {
    # On an unborn branch, pre-staged files must be unstaged before the batch
    # runs so commit 1 contains ONLY its FILES: list. `git read-tree --empty`
    # is the unborn-HEAD equivalent of `git reset --mixed HEAD`.
    local dir; dir="$(setup_unborn_repo unborn-index)"
    echo "a" > "$dir/a.txt"
    echo "b" > "$dir/b.txt"
    # Pre-stage a.txt — it must NOT leak into the commit that only lists b.txt
    git -C "$dir" add a.txt

    local batch
    batch=$(printf 'COMMIT:Add b only\\n\\n- Add b.txt to the repository\nFILES:b.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug unborn-index "$dir" ) 2>&1)" || true

    assert_contains "INDEX_RESET:mixed" "$out"
    assert_contains "COMMIT_SUCCESS" "$out"

    # The root commit should contain ONLY b.txt
    local files_in_commit
    files_in_commit=$(git -C "$dir" show --stat --name-only HEAD --pretty=format: | tr -d ' ' | sort)
    echo "$files_in_commit" | grep -q '^b.txt$' && ! echo "$files_in_commit" | grep -q '^a.txt$' || {
        echo "root commit should contain only b.txt, got: $files_in_commit" >&3
        return 1
    }
}

# --- multi-line commit message format (Format A) ---
# The script accepts two equivalent input formats:
#   Format A: multi-line (subject\n\nbody\nFILES:...) — natural for heredocs
#   Format B: \n literals (COMMIT:subject\n\nbody\nFILES:...) — compact for printf
# These tests verify Format A works for both dry-run and real execution.

@test "multiline format dry run" {
    local dir; dir="$(setup_repo multiline-dryrun)"
    echo "new" > "$dir/file1.txt"

    # Format A: real newlines, multi-line COMMIT block
    local batch
    batch=$(cat <<'BATCH_EOF'
COMMIT:Add file1 with multi-line body

- Add file1 to support new feature X
- Needed because the prior approach did not handle edge case Y
FILES:file1.txt
BATCH_EOF
)
    local out
    out="$(printf '%s\n' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug multiline-dryrun "$dir" ) 2>&1)" || true

    assert_contains "PROCESSING_COMMIT:1" "$out"
    assert_contains "MESSAGE:Add file1 with multi-line body" "$out"
    assert_contains "FILES:file1.txt" "$out"
    assert_not_contains "COMMIT_FAILED" "$out"
}

@test "multiline format real commit" {
    local dir; dir="$(setup_repo multiline-real)"
    echo "content" > "$dir/file1.txt"

    # Format A: real newlines, multi-line COMMIT block
    local batch
    batch=$(cat <<'BATCH_EOF'
COMMIT:Add file1 with multi-line body

- Add file1 to support new feature X
- Needed because the prior approach did not handle edge case Y
FILES:file1.txt
BATCH_EOF
)
    local out
    out="$(printf '%s\n' "$batch" | ( cd "$dir" && bash "$BATCH" --slug multiline-real "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_SUCCESS" "$out"
    assert_not_contains "COMMIT_FAILED" "$out"

    # Verify the commit message has the correct subject and body
    local subject body
    subject=$(git -C "$dir" log -1 --format='%s')
    body=$(git -C "$dir" log -1 --format='%b')
    [[ "$subject" == "Add file1 with multi-line body" ]] || {
        echo "subject should be 'Add file1 with multi-line body', got: $subject" >&3
        return 1
    }
    echo "$body" | grep -q "Add file1 to support new feature X" \
       && echo "$body" | grep -q "Needed because the prior approach" || {
        echo "body missing bullets, got: $body" >&3
        return 1
    }
}

@test "multiline format multiple commits" {
    local dir; dir="$(setup_repo multiline-multi)"
    echo "a" > "$dir/a.txt"
    echo "b" > "$dir/b.txt"

    # Format A: two commits, both multi-line
    local batch
    batch=$(cat <<'BATCH_EOF'
COMMIT:Add a

- First file for feature X
FILES:a.txt
COMMIT:Add b

- Second file for feature X
FILES:b.txt
BATCH_EOF
)
    local out
    out="$(printf '%s\n' "$batch" | ( cd "$dir" && bash "$BATCH" --slug multiline-multi "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_SUCCESS" "$out"

    # Verify both commits landed with correct subjects
    local subj1 subj2
    subj1=$(git -C "$dir" log -1 --format='%s')
    subj2=$(git -C "$dir" log -2 --format='%s' | tail -1)
    [[ "$subj1" == "Add b" ]] || {
        echo "second commit subject should be 'Add b', got: $subj1" >&3
        return 1
    }
    [[ "$subj2" == "Add a" ]] || {
        echo "first commit subject should be 'Add a', got: $subj2" >&3
        return 1
    }
}

# --- tag array enforcement (NO_TAG_ARRAY) ---

@test "rejects commit without tag array when tagging enabled" {
    local dir; dir="$(setup_repo_with_tagging no-tag-reject)"
    echo "a" > "$dir/a.txt"

    # Valid body, valid subject, but NO #tag array line
    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\n- Needed because the prior approach did not handle edge case Y\nFILES:a.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug no-tag-reject "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_FAILED:NO_TAG_ARRAY" "$out"
    # Verify no commit was created (only the initial commit remains)
    local count
    count=$(git -C "$dir" rev-list --count HEAD)
    [[ "$count" == "1" ]] || {
        echo "expected 1 commit (initial only), got $count" >&3
        return 1
    }
}

@test "accepts commit with tag array when tagging enabled" {
    local dir; dir="$(setup_repo_with_tagging tag-accept)"
    echo "a" > "$dir/a.txt"

    # Valid body + valid tag array as last line of body
    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\n- Needed because the prior approach did not handle edge case Y\\n\\n#project-test #type-feat #skill-grm-created\nFILES:a.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug tag-accept "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_SUCCESS" "$out"
    assert_not_contains "NO_TAG_ARRAY" "$out"
}

@test "tag array accepted before optional footer" {
    local dir; dir="$(setup_repo_with_tagging tag-with-footer)"
    echo "a" > "$dir/a.txt"

    # Tag line followed by a Closes #N footer — tag line is still detected
    local batch
    batch=$(printf 'COMMIT:Fix overflow in sidebar\\n\\n- Add null check before rendering sidebar menu\\n- Fixes crash on narrow viewports\\n\\n#project-ui #type-fix #skill-grm-created\\n\\nFixes #42\nFILES:a.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug tag-footer "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_SUCCESS" "$out"
    assert_not_contains "NO_TAG_ARRAY" "$out"
}

@test "tag array enforcement bypassed by project config" {
    local dir; dir="$(setup_repo tag-config-disable)"
    echo "a" > "$dir/a.txt"

    # setup_repo created the disable config — commit without tags should pass
    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\nFILES:a.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug tag-config-disable "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_SUCCESS" "$out"
    assert_not_contains "NO_TAG_ARRAY" "$out"
}

@test "dry-run rejects commit without tag array when tagging enabled" {
    local dir; dir="$(setup_repo_with_tagging dry-run-no-tag)"
    echo "a" > "$dir/a.txt"

    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\nFILES:a.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug dry-run-no-tag "$dir" ) 2>&1)" || true

    assert_contains "COMMIT_FAILED:NO_TAG_ARRAY" "$out"
    assert_contains "BATCH_COMMIT_DRY_RUN" "$out"
}
