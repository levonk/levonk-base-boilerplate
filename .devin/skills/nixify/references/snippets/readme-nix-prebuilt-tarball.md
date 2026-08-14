## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake exposes the prebuilt release binary as `#prebuilt` (also `#default`) and a from-source build as `#source`.

```bash
# Run without installing (prebuilt binary, default)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Explicitly choose prebuilt or source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#prebuilt
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

The flake tracks the default branch and is auto-bumped to the latest release by a
daily [workflow](.github/workflows/nix-release.yml), so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO`
is updated daily when the version-bump PR is merged. (Release tags are cut before
the bump lands, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` is not a valid
pin — use the nixpkgs package or a specific commit SHA if you need reproducibility.)
