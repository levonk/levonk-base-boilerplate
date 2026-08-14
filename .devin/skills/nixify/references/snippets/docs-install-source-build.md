### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

**Choose a specific version:**

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Or use named flake outputs if the flake exposes them
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#latest
```

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
nix flake update <repo>
```
