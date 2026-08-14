# Exposing Flake Output Variants

Users may want to install the latest stable binary, a specific older version, or build from source. Support both mechanisms:

**1. Git refs (tags / branches) — the idiomatic Nix way:**

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO           # default branch
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3    # specific tag
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/feat-x     # feature branch
```

**2. Named flake outputs (`#`):**

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#<project-name>
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#latest
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
nix flake show github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

**CRITICAL — always expose `#<project-name>`: Users naturally try `nix run .#<project-name>` (and `nix build .#<project-name>`) before they reach for `#default` or `#latest`. Every flake template exposes the package under the project's own name alongside `default`. Omitting it is the most common "the flake works but users say it's broken" report — `nix run .#<project-name>` errors with `error: flake output 'packages.<system>.<project-name>' not found` even though `nix run .` works. When generating a flake, set `packages.<system>.<project-name>` and `apps.<system>.<project-name>` to the same derivation/app as `default`. The Prebuilt Tarball Flake already follows this pattern (`<project>` + `default`); the Binary Release, Source Build, and nixpkgs wrapper templates do too.**

| Use case | Recommended approach |
|---|---|
| Users want latest stable | `nix run github:...` (default or `#<project-name>`) |
| Users want a specific release (Source Build Flake) | `nix run github:.../v1.2.3` (git tag — flake exists at every tag) |
| Users want a specific release (Prebuilt Tarball Flake, prebuilt output) | Pin to a commit SHA after the bump PR merges; tag-pinning does NOT work (tags are cut before the bump workflow updates `flake.nix`) |
| Users want a specific release (Prebuilt Tarball Flake, source output) | `nix run github:.../v1.2.3#source` (git tag — the `#source` output builds from source and works at any tag) |
| Flake needs source + binary side-by-side | Named outputs (`#prebuilt`, `#source`) |
| Home-manager / module consumers | Named package reference (`#<project-name>`) |

**Recommendation:** For Source Build Flakes, use git refs as primary, expose `#<project-name>`, `#source`, and `#latest` for discoverability. For Prebuilt Tarball Flakes with a post-release bump workflow, expose `#prebuilt` (prebuilt binary, also `#default`), `#source` (from-source build), and `#<project-name>` (alias for `#prebuilt`). Document `github:.../` (tracks default branch) for the prebuilt output and `github:.../#source` for the from-source output — do not advertise tag-pinning for the prebuilt output (the `#source` output works at any tag since it builds from source).
