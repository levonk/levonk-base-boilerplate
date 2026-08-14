# Source Build Flake: Rust (Cargo)

Use when the project does not have published binary releases and uses Cargo.

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
        <pname> = pkgs.rustPlatform.buildRustPackage {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            [ pkgs.openssl ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];
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
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            [ pkgs.openssl pkgs.rustc pkgs.cargo ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
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

**Platform scope narrowing**: When Step 4a's `detect-platform-scope.sh` reports
`platform_scope=darwin_only` or `linux_only`, replace
`flake-utils.lib.eachDefaultSystem` with `flake-utils.lib.eachSystem target_platforms`
where `target_platforms` is the JSON array from Step 4a converted to a Nix list.
For example, a darwin-only project:

```nix
  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-darwin" "aarch64-darwin" ] (system:
      ...
```

This ensures the flake only instantiates outputs for platforms the project
actually supports. Do NOT attempt cross-compilation to the excluded family.
See `references/architecture-analysis.md` — Inherent Platform Scope.
