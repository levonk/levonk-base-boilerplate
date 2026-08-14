## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake exposes the prebuilt release binary as `#prebuilt` (on platforms that have one), a from-source build as `#source` (on all buildable platforms), and `#default` which uses the prebuilt binary where available and falls back to the from-source build on platforms the project does not ship a prebuilt binary for.

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

The flake tracks the default branch and is auto-bumped to the latest release by a
daily [workflow](.github/workflows/nix-release.yml), so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO`
is updated daily when the version-bump PR is merged. (Release tags are cut before
the bump lands, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` is not a valid
pin — use the nixpkgs package or a specific commit SHA if you need reproducibility.)

**Platform coverage**: The prebuilt binary is available on
`<list-prebuilt-platforms>`. On `<list-fallback-platforms>`, `#default` and
`#<project-name>` build from source via `#source`. Use `nix run .#prebuilt` to
explicitly require the prebuilt binary (this errors on platforms without one)
or `nix run .#source` to explicitly build from source on any platform.
