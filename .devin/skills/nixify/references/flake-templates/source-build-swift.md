# Source Build Flake: Swift (Swift Package Manager)

Use when the project does not have published binary releases and uses Swift
Package Manager (`Package.swift`).

**Skip if:** the project uses Xcode projects (`.xcodeproj` or `.xcworkspace`)
instead of Swift Package Manager. Xcode projects require `xcodebuild` and a
different packaging approach (xcode-nix, or wrapping `xcodebuild` in a
derivation) that is out of scope for this template.

## Key challenge: SPM dependency fetching in the Nix sandbox

Nix builds run in a sandbox without network access. `swift build` fetches
dependencies declared in `Package.swift` at build time. There are two
approaches:

1. **`swiftPlatform.buildSwiftPackage`** (preferred if available in your
   nixpkgs revision) — nixpkgs' native Swift builder that handles dependency
   fetching via a fixed-output derivation keyed on `Package.resolved` hash.
2. **Manual `stdenv.mkDerivation` with `swift` in `nativeBuildInputs`** — a
   plain derivation that runs `swift build -c release`. Dependencies must be
   pre-fetched via `fetchFromGitHub` or a fixed-output derivation if SPM needs
   network access.

The template below uses `stdenv.mkDerivation` for maximum compatibility across
nixpkgs revisions. If `buildSwiftPackage` is available, prefer it and adapt the
`src`, `nativeBuildInputs`, and `buildInputs` fields.

## Template: `stdenv.mkDerivation` with Swift

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
        <pname> = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [
            pkgs.swift
            pkgs.swiftpm
          ];
          buildInputs =
            [ ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Foundation
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            ];
          # Deterministic builds: Swift 5.18+ respects these env vars to
          # avoid embedding non-deterministic timestamps and hashes.
          SWIFT_DETERMINISTIC_HASHING = "1";
          SWIFT_DETERMINISTIC_MODE = "1";
          dontConfigure = true;
          buildPhase = ''
            runHook preBuild
            swift build -c release
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            # swift build outputs to .build/release/<binary-name>
            install -Dm755 .build/release/<binary-name> $out/bin/<binary-name>
            runHook postInstall
          '';
          meta = {
            description = "<Project description>";
            homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
            license = pkgs.lib.licenses.<spdx>;
            mainProgram = "<binary-name>";
          };
        };
      in
      {
        packages = {
          # Users naturally try .#<pname>, so expose it alongside default.
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

        overlays.default = final: prev: {
          <pname> = <pname>;
        };

        checks = {
          build = <pname>;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.swift pkgs.swiftpm ];
          buildInputs =
            [ ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Foundation
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            ]
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            # Common examples: pkgs.surrealdb, pkgs.postgresql, pkgs.redis
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

## Package.resolved

Swift Package Manager needs `Package.swift` and optionally `Package.resolved`.
The `Package.resolved` should be committed to the repo for reproducible builds.
If it's missing, `swift build` will generate it but the Nix build may fail due
to network sandbox — SPM tries to resolve dependency versions online.

If the project has external dependencies (declared in `Package.swift` under
`dependencies:`), you must either:

1. **Commit `Package.resolved`** and ensure all dependencies are already
   vendored or cached — SPM will use the resolved versions without network
   access.
2. **Use `fetchFromGitHub` or a fixed-output derivation** to pre-fetch
   dependencies into the Nix store, then point SPM at them via
   `SWIFTPM_PACKAGE_CACHE_DIR` or by vendoring into `.build/`.

For projects with no external dependencies (only local targets), the template
above works as-is — `swift build` does not need network access.

## Linux Swift

Swift on Linux uses `swift-lang` from nixpkgs (the `pkgs.swift` attribute maps
to it on Linux). The build may need additional libraries since Linux does not
have the Apple frameworks:

- **`pkgs.dispatch`** (libdispatch) — Grand Central Dispatch runtime, needed if
  the project uses `Dispatch`.
- **`pkgs.foundation`** (Swift Corelibs Foundation) — the open-source
  Foundation implementation, needed if the project uses `Foundation`.

Add these to `buildInputs` conditionally for Linux:

```nix
buildInputs =
  [ ]
  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Foundation
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.dispatch
    pkgs.foundation
  ];
```

On Darwin, `Foundation`, `Security`, and `CoreFoundation` are system
frameworks provided by the macOS SDK — Swift links against them natively, so
no separate runtime package is needed.

## Deterministic builds

Set `SWIFT_DETERMINISTIC_HASHING=1` and `SWIFT_DETERMINISTIC_MODE=1` in the
derivation environment. These environment variables (Swift 5.18+) ensure:

- **`SWIFT_DETERMINISTIC_HASHING`** — Swift uses a deterministic hash function
  instead of a randomized one, so module ordering and internal data structures
  are stable across builds.
- **`SWIFT_DETERMINISTIC_MODE`** — Disables embedding non-deterministic
  timestamps and build paths into the binary.

Without these, the Nix sandbox may produce binaries that differ between builds
due to randomized hashing or embedded timestamps, breaking reproducibility.
