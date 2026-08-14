# Source Build Flake: Bun

Use when the project does not have published binary releases and uses Bun with `bun build --compile` to produce a standalone binary. The compiled binary is self-contained — no Node runtime or `node_modules` needed at install time.

## Key challenge: dependency fetching in the Nix sandbox

Nix builds run in a sandbox without network access. `bun install` needs to fetch packages from the npm registry. There are two approaches:

1. **`buildBunPackage`** (preferred if available in your nixpkgs revision) — nixpkgs' native Bun builder that handles dependency fetching via a fixed-output derivation keyed on `bun.lock` hash, similar to `buildNpmPackage`'s `npmDepsHash`.
2. **Manual `stdenv.mkDerivation` with a deps FOD** — a fixed-output derivation that runs `bun install` and produces a `node_modules` store path, then the main derivation copies it in before `bun build --compile`.

## Template: `stdenv.mkDerivation` with deps FOD

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pin x86_64-darwin to a stable release branch for older macOS Intel
    # compatibility. See references/flake-templates/darwin-legacy-pin.md.
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs =
          if system == "x86_64-darwin"
          then nixpkgs-darwin-legacy.legacyPackages.${system}
          else nixpkgs.legacyPackages.${system};

        # Bun target triple mapping for cross-compilation
        bunTarget = {
          x86_64-linux = "bun-linux-x64";
          aarch64-linux = "bun-linux-arm64";
          x86_64-darwin = "bun-darwin-x64";
          aarch64-darwin = "bun-darwin-arm64";
        }.${system} or (throw "Unsupported platform: ${system}");

        # Fixed-output derivation: runs `bun install` with network access,
        # produces a node_modules store path. The hash is computed from
        # bun.lock — run `nix hash to-sri --type sha256 $(nix store prefetch --json --hash-type sha256 file:///dev/null 2>/dev/null || echo "REPLACE_WITH_HASH")` after first build attempt.
        # ponytail: FOD hash must be updated when bun.lock changes; no automation yet.
        deps = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>-deps";
          version = "<x.y.z>";
          # cleanSource filters out build artifacts, .git, .devbox, etc. so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;

          nativeBuildInputs = [ pkgs.bun ];

          impureEnvVars = [ "HOME" "XDG_CACHE_HOME" ];
          BUN_INSTALL_CACHE_DIR = "$TMPDIR/bun-cache";

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            runHook preInstall
            bun install --frozen-lockfile
            mkdir -p $out
            cp -r node_modules $out/node_modules
            runHook postInstall
          '';

          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = "<REPLACE_WITH_FOD_HASH>";
        };

        <pname> = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters out build artifacts, .git, .devbox, etc. so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;

          nativeBuildInputs = [ pkgs.bun ];

          BUN_INSTALL_CACHE_DIR = "$TMPDIR/bun-cache";

          dontConfigure = true;

          buildPhase = ''
            runHook preBuild

            # Use pre-fetched node_modules from the deps FOD
            cp -r ${deps}/node_modules ./node_modules

            # Run any pre-build code generation the project requires
            # (e.g. bundled defaults, build-time constants). Inspect the
            # project's build script (scripts/build-binaries.sh or similar)
            # and replicate the necessary steps here.
            # Example: bun run scripts/generate-bundled-defaults.ts

            # Build standalone binary via bun build --compile
            # Adjust entry point to match the project's actual CLI entry
            bun build --compile --target ${bunTarget} \
              --outfile <binary-name> \
              <entry-point.ts>

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 <binary-name> $out/bin/<binary-name>
            runHook postInstall
          '';

          meta = {
            description = "<Project description>";
            homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
            license = pkgs.lib.licenses.<spdx>;
            mainProgram = "<binary-name>";
            platforms = builtins.attrNames bunTarget;
          };
        };
      in
      {
        packages = {
          <pname> = <pname>;
          default = <pname>;
          source = <pname>;
        };

        apps = {
          <pname> = {
            type = "app";
            program = "${<pname>}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${<pname>}/bin/<binary-name>";
          };
        };

        checks = {
          build = <pname>;
        };
      }
    );
}
```

## Adapting to the project's build script

Most Bun projects that use `bun build --compile` have a build script (e.g. `scripts/build-binaries.sh`) that does more than just `bun build --compile`. Common extra steps:

- **Code generation**: `bun run scripts/generate-bundled-defaults.ts` or similar — replicate these in the `buildPhase` before the `bun build --compile` call.
- **Build-time constants**: rewriting a source file with version/commit info before compiling. In Nix, set these via environment variables or substitute the file in `preBuild`.
- **Multiple targets**: the build script may loop over targets. In the flake, each system handles its own target via the `bunTarget` mapping, so no loop is needed.

Read the project's build script carefully and replicate every step that affects the compiled binary. Steps that only affect packaging (checksums, uploading) are not needed.

## Getting the FOD hash

The `outputHash` for the deps derivation must be computed empirically:

1. Set `outputHash = pkgs.lib.fakeSha256` as a placeholder.
2. Run `nix build .#<pname>` — it will fail with a hash mismatch error showing the correct hash.
3. Replace the placeholder with the correct SRI hash.
4. Re-run to confirm.

This hash changes whenever `bun.lock` changes. For release-based repos, the hash automation workflow (see `references/advanced-features.md` — Release-Triggered Hash Automation) should be adapted to also bump the FOD hash.

## Per-platform FOD hashes (MANDATORY when bun.lock has platform-gated optionals)

`bun.lock` carries platform-gated optional dependencies (`@esbuild/darwin-arm64`, `@esbuild/linux-x64`, `@esbuild/darwin-x64`, etc.). The installed `node_modules` tree differs per system, so **a single `outputHash` cannot be valid across all four platforms**. If the project's `bun.lock` contains any platform-specific optional packages (check with `grep -E '@esbuild/(darwin|linux)' bun.lock` or `grep 'optionalDependencies' package.json`), you MUST use per-platform FOD hashes instead of a single shared one.

**Pattern**: Make the deps derivation a function of `system` and compute a separate `outputHash` per platform:

```nix
# Per-platform FOD hashes — one per system. Compute each by building on
# that platform (or by cross-building) and reading the hash mismatch error.
# A single outputHash CANNOT be shared across platforms when bun.lock
# carries platform-gated optionals like @esbuild/darwin-arm64.
fodHashes = {
  x86_64-linux = "<SRI_HASH_LINUX_X64>";
  aarch64-linux = "<SRI_HASH_LINUX_ARM64>";
  x86_64-darwin = "<SRI_HASH_DARWIN_X64>";
  aarch64-darwin = "<SRI_HASH_DARWIN_ARM64>";
};

deps = pkgs.stdenv.mkDerivation {
  # ... same as above ...
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = fodHashes.${system} or (throw "no FOD hash for ${system}");
};
```

If the project's `bun.lock` has NO platform-gated optionals (rare for projects with native addons), a single shared `outputHash` is safe. When in doubt, use per-platform hashes — they are always correct.

This was a declining reason on Archon PR #2131: a single `outputHash` was used across four platforms while `bun.lock` carried `@esbuild/darwin-arm64`, `@esbuild/linux-x64`, and `@esbuild/darwin-x64` — the installed tree differed per system, so the hash was only valid on one platform.

## Toolchain version pinning (MANDATORY)

The `#source` build uses `pkgs.bun` from nixpkgs, which tracks nixpkgs-unstable's version. If the project's CI pins a specific Bun version (e.g. `bun 1.3.11` in GitHub Actions workflows) or `package.json#engines` declares a version constraint, the flake's `#source` build MUST use the same pinned version, not whatever nixpkgs-unstable happens to ship. A version mismatch means the `#source` build and CI validate against different toolchains — the flake can pass while CI fails, or vice versa.

**Pattern**: Pin Bun to the project's declared version using `pkgs.bun_1_3` or an overlay:

```nix
# If the project pins bun 1.3.x in CI or package.json#engines, pin it here too.
# Check .github/workflows/*.yml for the exact version the project validates against.
# nixpkgs may name the package bun_1_3, bun_1_4, etc. — match the major.minor.
nativeBuildInputs = [ pkgs.bun_1_3 ];  # not pkgs.bun (unstable, drifts)
```

If nixpkgs doesn't ship the exact version, use `pkgs.bun` and document the version constraint in a comment. The key principle: **the source-build toolchain version must match what the project actually validates against**, not what nixpkgs-unstable happens to ship today.

This was a declining reason on Archon PR #2131: `#source` built with `pkgs.bun` from nixpkgs-unstable while CI pinned `bun 1.3.11` across five workflows and `package.json#engines` said `^1.3.0` — a second toolchain source of truth that drifted from the one actually validated.
