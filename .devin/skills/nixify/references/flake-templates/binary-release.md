# Binary Release Flake Template

Use when the project has published binary releases on GitHub (single binaries, not tarballs).

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        platform = pkgs.stdenv.hostPlatform.system;
        selectBinary = {
          x86_64-linux = "<binary-name>-linux-x86_64";
          aarch64-linux = "<binary-name>-linux-aarch64";
          x86_64-darwin = "<binary-name>-macos-x86_64";
          aarch64-darwin = "<binary-name>-macos-aarch64";
        }.${platform} or (throw "Unsupported platform: ${platform}");

        mkBinaryPackage = { version, hash }:
          let
            bin = pkgs.fetchurl {
              url = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO/releases/download/${version}/${selectBinary}";
              inherit hash;
            };
          in
          pkgs.stdenv.mkDerivation {
            pname = "<binary-name>";
            inherit version;
            src = bin;

            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              install -Dm755 $src $out/bin/<binary-name>
            '';

            meta = {
              description = "<Project description>";
              homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
              license = pkgs.lib.licenses.<spdx>;
              mainProgram = "<binary-name>";
            };
          };

        <pname>-latest = mkBinaryPackage {
          version = "<latest-version>";
          hash = "<sha256-latest>";
        };

        <pname>-source = pkgs.<build-tool>.<build-function> {
          pname = "<binary-name>";
          version = "<dev-version>";
          src = ./.;
        };
      in
      {
        packages = {
          # Users naturally try .#<pname>, so expose it alongside default.
          <pname> = <pname>-latest;
          default = <pname>-latest;
          latest = <pname>-latest;
          source = <pname>-source;
        };

        apps = {
          <pname> = {
            type = "app";
            program = "${<pname>-latest}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${<pname>-latest}/bin/<binary-name>";
          };
          source = {
            type = "app";
            program = "${<pname>-source}/bin/<binary-name>";
          };
        };

        overlays.default = final: prev: {
          <pname> = <pname>-latest;
        };

        checks = {
          build = <pname>-latest;
        };
      }
    );
}
```
