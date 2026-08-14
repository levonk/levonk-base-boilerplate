# Adding a `#nixpkgs` Output to an In-Repo Flake

When `check-nixpkgs-superset.sh` (Step 11b) reports `add_nixpkgs_output: true`,
add a `#nixpkgs` output to the in-repo flake.nix alongside the existing
`#prebuilt` / `#source` / `#default` outputs. This gives users access to the
nixpkgs-packaged version, which may include patches, postInstall hooks,
makeWrapper setup, or runtime dependencies that a naive from-source flake
would miss.

## When to Add

Add the `#nixpkgs` output when ALL of the following are true:

1. `check-nixpkgs.sh` (Step 10) reported `project_in_nixpkgs: true`
2. `check-nixpkgs-superset.sh` (Step 11b) reported `is_superset: true` — the
   nixpkgs derivation has patches, postInstall hooks, makeWrapper, or runtime
   deps that a from-source flake would miss
3. The nixpkgs version is current enough to be useful (`version_current: true`
   is preferred, but the agent may add the output even when the version lags
   if the superset packaging is valuable enough — document the version lag
   in the PR body)

Do NOT add the `#nixpkgs` output when:
- The project is not in nixpkgs (`project_in_nixpkgs: false`)
- The nixpkgs packaging is trivial (no patches, no hooks, no wrappers — a
  from-source flake provides equivalent functionality)
- The nixpkgs version is severely outdated (multiple major versions behind)
  and the superset packaging does not justify the version lag

## Flake Structure

Add a `nixpkgs` input (if not already present) and a `packages.<system>.nixpkgs`
output. The `#nixpkgs` output wraps `nixpkgs.legacyPackages.${system}.<project-name>`.

### For Prebuilt Tarball Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # ... existing prebuilt/source outputs ...

        # nixpkgs output — wraps the nixpkgs-packaged version
        nixpkgsPkg = nixpkgs.legacyPackages.${system}.<project-name>;
      in
      {
        packages = {
          # ... existing prebuilt, source, default outputs ...
          nixpkgs = nixpkgsPkg;
        };

        apps = {
          # ... existing apps ...
          nixpkgs = {
            type = "app";
            program = "${nixpkgsPkg}/bin/<binary-name>";
          };
        };
      });
}
```

### For Source Build Flakes

Same pattern — add `nixpkgs` to the `packages` and `apps` attrsets alongside
the existing `default` and `<project-name>` outputs.

### Platform Scoping

When `platform_scope` is `darwin_only` or `linux_only` (Step 4a), the
`#nixpkgs` output should only be exposed on platforms in `target_platforms`.
Check `nixpkgs.legacyPackages.${system}.<project-name>` exists for each
target system — nixpkgs may not build it for all platforms.

```nix
# Only expose #nixpkgs on platforms where nixpkgs actually builds it
packages = {
  nixpkgs = nixpkgs.legacyPackages.${system}.<project-name> or (throw "nixpkgs#${<project-name>} not available on ${system}");
};
```

## Documentation

When the `#nixpkgs` output is added, the README and PR/issue templates must
document it. Add a "Nix (nixpkgs version)" section with the install commands:

    ### Nix (nixpkgs version)

    If you prefer the nixpkgs-packaged version (which may include distribution
    patches and runtime dependency setup):

    ```bash
    nix run github:<owner>/<repo>#nixpkgs
    nix profile install github:<owner>/<repo>#nixpkgs
    ```

## Relationship to Other Outputs

| Output | Source | Use When |
|--------|--------|----------|
| `#default` | Aliases `#prebuilt` or `#source` | General use |
| `#prebuilt` | GitHub release tarball | Fastest install, official binary |
| `#source` | From-source build | Reproducibility, auditability |
| `#nixpkgs` | nixpkgs package | Distribution patches, runtime deps, nixpkgs integration |
| `#<project-name>` | Alias for `#default` | Natural name discovery |

The `#nixpkgs` output does NOT replace `#prebuilt` or `#source` — it is an
additional option. Users who want the official release binary use `#prebuilt`;
users who want a from-source build use `#source`; users who want the nixpkgs
packaging (with its patches and runtime setup) use `#nixpkgs`.
