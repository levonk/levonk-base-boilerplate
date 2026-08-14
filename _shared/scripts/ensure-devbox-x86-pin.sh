#!/usr/bin/env bash
#
# ensure-devbox-x86-pin.sh
#
# Detects x86_64-darwin (Intel Mac) at runtime and injects the nixpkgs commit
# pin into devbox.json if the pin is missing.
#
# nixpkgs dropped x86_64-darwin support in the 26.11 release cycle. Most
# devbox.json.jinja templates conditionally pin nixpkgs when
# nix_target_arch == "x86_64-darwin" (the pin is injected by copier-wrapper.sh
# via the detect_nix_target_arch() function). However, if copier is invoked
# directly without the wrapper, the pin is skipped and `devbox install` fails
# on Intel Macs.
#
# This script is a fallback for that case: it detects the platform at runtime
# and, when running on x86_64-darwin, ensures devbox.json contains the
# nixpkgs.commit pin pointing at the last nixpkgs commit with x86_64-darwin
# support:
#
#   293d6abedf0478e681a4dfcfcb35b30fc796a32f
#
# Usage:
#   ./ensure-devbox-x86-pin.sh        # operates on ./devbox.json in CWD
#
# Exit codes:
#   0 - success or no-op (not x86_64-darwin, no devbox.json, or pin already present)
#   1 - error
#
set -euo pipefail

# The last nixpkgs commit with x86_64-darwin support.
NIXPKGS_X86_DARWIN_COMMIT="293d6abedf0478e681a4dfcfcb35b30fc796a32f"

# --- Platform detection ------------------------------------------------------
#
# uname -s -> darwin / linux
# uname -m -> x86_64 / arm64 / aarch64
#
# Only proceed on darwin/x86_64 (Intel Mac). On every other platform this is a
# no-op.
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

if [[ "$os" != "darwin" || "$arch" != "x86_64" ]]; then
    exit 0
fi

# --- Locate devbox.json ------------------------------------------------------
#
# Operate on devbox.json in the current working directory. If it does not exist
# there is nothing to pin, so exit cleanly.
devbox_json="devbox.json"

if [[ ! -f "$devbox_json" ]]; then
    exit 0
fi

# --- Check for an existing nixpkgs.commit pin --------------------------------
#
# If devbox.json already contains a nixpkgs section with a commit field, the
# pin is already in place — do nothing (non-destructive).
if grep -q '"commit"[[:space:]]*:' "$devbox_json" 2>/dev/null; then
    # Narrow the check: only treat it as present if a nixpkgs object with a
    # commit key exists. A loose grep is sufficient because devbox.json only
    # uses "commit" inside the nixpkgs block.
    if grep -q '"nixpkgs"' "$devbox_json" 2>/dev/null; then
        exit 0
    fi
fi

# --- Inject the nixpkgs.commit pin -------------------------------------------
#
# The injected JSON should look like:
#
#   {
#     "nixpkgs": {
#       "commit": "293d6abedf0478e681a4dfcfcb35b30fc796a32f"
#     },
#     ...existing keys...
#   }
#
# The nixpkgs key is inserted at the top of the JSON object, matching the
# pattern used in the existing devbox.json.jinja templates.
#
# Strategy: try python3 first (proper JSON manipulation), then jq, then sed as
# a last-resort fallback.

inject_with_python() {
    python3 - "$devbox_json" "$NIXPKGS_X86_DARWIN_COMMIT" <<'PYEOF'
import json
import sys

path, commit = sys.argv[1], sys.argv[2]

with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

# Non-destructive: if a nixpkgs.commit already exists, leave it alone.
nixpkgs = data.get("nixpkgs")
if isinstance(nixpkgs, dict) and "commit" in nixpkgs:
    sys.exit(0)

# Insert nixpkgs at the top of the object, preserving existing key order.
new_data = {"nixpkgs": {"commit": commit}}
new_data.update(data)

with open(path, "w", encoding="utf-8") as fh:
    json.dump(new_data, fh, indent=2)
    fh.write("\n")
PYEOF
}

inject_with_jq() {
    local tmp
    tmp="$(mktemp)"
    # Insert nixpkgs at the top of the object by merging a new object with the
    # original (jq object construction preserves insertion order for keys).
    jq --arg commit "$NIXPKGS_X86_DARWIN_COMMIT" \
        '{nixpkgs: {commit: $commit}} + .' \
        "$devbox_json" > "$tmp"
    mv "$tmp" "$devbox_json"
}

inject_with_sed() {
    # Fallback: insert the nixpkgs block right after the opening brace.
    # This assumes the JSON starts with "{" (possibly followed by whitespace
    # or a newline), which is the case for all devbox.json files produced by
    # the boilerplate templates.
    local tmp
    tmp="$(mktemp)"
    {
        echo '  "nixpkgs": {'
        echo "    \"commit\": \"$NIXPKGS_X86_DARWIN_COMMIT\""
        echo '  },'
    } > "$tmp"

    # Use sed to insert the block after the first "{" line. We operate on the
    # first occurrence only.
    local inserted
    inserted=0
    while IFS= read -r line; do
        printf '%s\n' "$line"
        if [[ $inserted -eq 0 ]] && [[ "$line" =~ ^[[:space:]]*\{[[:space:]]*$ ]]; then
            cat "$tmp"
            inserted=1
        fi
    done < "$devbox_json" > "${devbox_json}.tmp"

    rm -f "$tmp"
    mv "${devbox_json}.tmp" "$devbox_json"
}

if command -v python3 >/dev/null 2>&1; then
    inject_with_python
elif command -v jq >/dev/null 2>&1; then
    inject_with_jq
else
    inject_with_sed
fi

exit 0
