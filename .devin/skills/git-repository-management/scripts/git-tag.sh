#!/usr/bin/env bash

# git-tag.sh - Create an annotated git tag at HEAD
# Purpose: Single handoff to tag HEAD, either with an explicit path or a
#          conventional-commit category + descriptive slug.
# Usage:
#   git-tag.sh --category <feat|fix|chore|...> --slug <descriptive-slug> [--message <msg>] [repo_root]
#   git-tag.sh --path <explicit/tag/path> [--message <msg>] [repo_root]
# Default tag path: tags/<category>/YYYY/MM/DD/<slug>
#   YYYY = 4-digit year, MM/DD = 2-digit zero-prefixed month/day.
# Output: Execution result for the tag operation.

set -euo pipefail

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "ERROR: $target_path is not inside a git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

# Conventional-commit categories accepted for the default path scheme.
# ponytail: closed list keeps tags greppable; extend only when a real caller needs a new one.
VALID_CATEGORIES="feat fix chore docs style refactor perf test build ci revert"

validate_category() {
    local cat="$1"
    for valid in $VALID_CATEGORIES; do
        [[ "$cat" == "$valid" ]] && return 0
    done
    echo "ERROR: Invalid category '$cat'. Valid: $VALID_CATEGORIES" >&2
    exit 1
}

# Slug must be kebab-case: lowercase letters, digits, hyphens; no leading/trailing hyphen.
validate_slug() {
    local slug="$1"
    if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        echo "ERROR: Invalid slug '$slug'. Use kebab-case (lowercase, hyphen-separated, no leading/trailing hyphen)." >&2
        exit 1
    fi
}

main() {
    local category=""
    local slug=""
    local tag_path=""
    local message=""
    local target_path="."

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --category) category="$2"; shift 2 ;;
            --slug)     slug="$2"; shift 2 ;;
            --path)     tag_path="$2"; shift 2 ;;
            --message)  message="$2"; shift 2 ;;
            -h|--help)
                sed -n '2,12p' "$0"
                exit 0
                ;;
            *) target_path="$1"; shift ;;
        esac
    done

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    # Resolve tag path: explicit --path wins, otherwise build from category + slug + today.
    if [[ -z "$tag_path" ]]; then
        if [[ -z "$category" || -z "$slug" ]]; then
            echo "ERROR: Either --path <tag> or both --category <cat> and --slug <slug> are required" >&2
            exit 1
        fi
        validate_category "$category"
        validate_slug "$slug"
        local today
        today=$(date +%Y/%m/%d)
        tag_path="tags/${category}/${today}/${slug}"
    fi

    # Refuse to clobber an existing tag — silent overwrite is a data-loss footgun.
    if git rev-parse -q --verify "refs/tags/${tag_path}" >/dev/null 2>&1; then
        echo "ERROR: Tag already exists: ${tag_path}" >&2
        echo "TAG_FAILED:TAG_EXISTS"
        exit 1
    fi

    if [[ -z "$message" ]]; then
        message="Tag ${tag_path}"
    fi

    echo "=== TAG_START ==="
    echo "TAG_PATH:${tag_path}"
    echo "TARGET:$(git rev-parse HEAD)"
    if git tag -a "$tag_path" -m "$message"; then
        echo "TAG_SUCCESS:${tag_path}"
    else
        echo "TAG_FAILED:GIT_ERROR"
        exit 1
    fi
    echo "=== TAG_END ==="
}

main "$@"
