### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing (prebuilt binary, default)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Explicitly choose prebuilt or source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#prebuilt
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

The flake tracks the default branch and is auto-bumped to the latest release
daily, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` is updated daily when the
version-bump PR is merged. For reproducibility, pin to a specific commit SHA or
use the nixpkgs package.

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
# Run from the consuming flake directory with the actual input name (e.g. archon)
nix flake update <input-name>
```
