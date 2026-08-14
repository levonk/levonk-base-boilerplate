## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake builds from source.

```bash
# Latest source from default branch
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Specific release (uses the flake at that git tag)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Named outputs (if the flake exposes them): #latest, #source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source

# Build / develop
nix build github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix develop github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake exposes `packages.<system>.default`, `apps.<system>.default`, `devShells.<system>.default`, and `overlays.default`.

Update through the same Nix workflow you used to install. For profile installs, run `nix profile list` and then `nix profile upgrade <index-or-name>`. For flake inputs, run `nix flake update <repo>` in your own flake and rebuild.
