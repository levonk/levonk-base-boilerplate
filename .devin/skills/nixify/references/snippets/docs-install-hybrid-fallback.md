### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing (prebuilt where available, source fallback otherwise)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Explicitly choose prebuilt (only on platforms with a release binary)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#prebuilt

# Explicitly choose from-source build (available on all buildable platforms)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

The flake tracks the default branch and is auto-bumped to the latest release
daily, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` is updated daily when the
version-bump PR is merged. For reproducibility, pin to a specific commit SHA or
use the nixpkgs package.

**Platform coverage**: The prebuilt binary is available on
`<list-prebuilt-platforms>`. On `<list-fallback-platforms>`, `#default` builds
from source. Use `#prebuilt` to explicitly require the prebuilt binary or
`#source` to explicitly build from source on any platform.

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
# Run from the consuming flake directory with the actual input name (e.g. archon)
nix flake update <input-name>
```
