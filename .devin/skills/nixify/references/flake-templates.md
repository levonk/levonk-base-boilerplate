# Flake Templates

## Table of Contents

- [Prebuilt Tarball Flake (Preferred)](#prebuilt-tarball-flake-preferred)
- [Binary Release Flake Template](#binary-release-flake-template)
- [Source Build Flake Templates](#source-build-flake-templates)
  - [Rust (Cargo)](#rust-cargo)
  - [Node.js (pnpm/npm)](#nodejs-pnpmnpm)
  - [Go](#go)
  - [Python](#python)
- [Darwin Framework Note](#darwin-framework-note)
- [Exposing Flake Output Variants](#exposing-flake-output-variants)
- [Using Upstream nixpkgs Packages](#using-upstream-nixpkgs-packages)

---

## Prebuilt Tarball Flake (Preferred)

Use when the project publishes prebuilt release tarballs. Preserves exact layout and avoids complex builds.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    version = "<version>";

    assets = {
      "x86_64-linux" = {
        file = "<project>-linux-x64.tar.gz";
        sha256 = "<sha256>";
      };
      "aarch64-linux" = {
        file = "<project>-linux-arm64.tar.gz";
        sha256 = "<sha256>";
      };
      "x86_64-darwin" = {
        file = "<project>-darwin-x64.tar.gz";
        sha256 = "<sha256>";
      };
      "aarch64-darwin" = {
        file = "<project>-darwin-arm64.tar.gz";
        sha256 = "<sha256>";
      };
    };

    systems = builtins.attrNames assets;
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    projectFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      asset = assets.${system};
    in pkgs.stdenv.mkDerivation {
      pname = "<project-name>";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/<owner>/<repo>/releases/download/v${version}/${asset.file}";
        sha256 = asset.sha256;
      };

      sourceRoot = ".";

      nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
      buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.stdenv.cc.cc.lib ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -r bin "$out/bin"
        cp -r runtime "$out/runtime"
        chmod +x "$out/bin/<binary-name>"
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "<project description>";
        homepage = "https://github.com/<owner>/<repo>";
        downloadPage = "https://github.com/<owner>/<repo>/releases";
        license = licenses.<license>;
        mainProgram = "<binary-name>";
        platforms = systems;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };
    };
  in {
    packages = forAllSystems (system: rec {
      <project> = projectFor system;
      default = <project>;
    });

    apps = forAllSystems (system: let
      # WARNING: do NOT replace this `let` binding with `rec` referencing the
      # `packages` attrset above. A `rec { default = { program = "${<project>}/bin/..."; }; }`
      # that names the binding `<project>` shadows the `let`-bound derivation, so
      # `${<project>}` interpolates the app attrset (a set, not a store path) and
      # throws "cannot coerce a set to a string" at `nix run` / `nix flake check`.
      # The separate `let <project>Pkg = projectFor system;` binding keeps the
      # derivation in scope as a store path. (Reference: nubjs/nub#169 fix commit.)
      <project>Pkg = projectFor system;
    in {
      <project> = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      default = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
    });
  };
}
```

Key details:
- Explicit SHA256 hashes per platform for reproducibility
- Preserves exact layout (bin/ + runtime/ as-is from tarball)
- Uses `autoPatchelfHook` for Linux glibc linking
- No wrapper scripts — binary is real file with runtime/ as sibling
- Uses `nixpkgs-unstable` for broader platform support
- **Target set is the 4 glibc+darwin systems** (`x86_64`/`aarch64` × `linux`/`darwin`). Exclude win32 (not a Nix target) and musl tarballs (the glibc tarballs already cover Linux Nix systems). See `references/flake-templates.md` — Darwin Framework Note for darwin-specific caveats.

---

## Binary Release Flake Template

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

---

## Source Build Flake Templates

Use when the project does not have published binary releases.

### Rust (Cargo)

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
        <pname> = pkgs.rustPlatform.buildRustPackage {
          pname = "<binary-name>";
          version = "<x.y.z>";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
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
      }
    );
}
```

### Node.js (pnpm/npm)

Use `buildNpmPackage` or `mkYarnPackage` from nixpkgs. Pin `package-lock.json` or `yarn.lock`.

**Important for npm-published packages:** `package-lock.json` is excluded from npm tarballs by default. Use `npm-shrinkwrap.json` instead (add `npm shrinkwrap` to your `prepublishOnly` hook).

### Go

Use `buildGoModule`. Pin `vendorHash`.

### Python

Use `buildPythonApplication` or `uv2nix` / `poetry2nix` depending on the lock file format.

---

## Darwin Framework Note

If the build fails with:

```
error: darwin.apple_sdk_11_0 has been removed as it was a legacy compatibility stub
```

Remove the deprecated `pkgs.darwin.apple_sdk.frameworks.Security` reference. Modern `rustPlatform` / `stdenv` handles Security framework linking automatically. Keep only `pkgs.libiconv` in `buildInputs` for Darwin.

---

## Exposing Flake Output Variants

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

**CRITICAL — always expose `#<project-name>`: Users naturally try `nix run .#<project-name>` (and `nix build .#<project-name>`) before they reach for `#default` or `#latest`. Every flake template in this file exposes the package under the project's own name alongside `default`. Omitting it is the most common "the flake works but users say it's broken" report — `nix run .#<project-name>` errors with `error: flake output 'packages.<system>.<project-name>' not found` even though `nix run .` works. When generating a flake, set `packages.<system>.<project-name>` and `apps.<system>.<project-name>` to the same derivation/app as `default`. The Prebuilt Tarball Flake already follows this pattern (`<project>` + `default`); the Binary Release, Source Build, and nixpkgs wrapper templates do too.**

| Use case | Recommended approach |
|---|---|
| Users want latest stable | `nix run github:...` (default or `#<project-name>`) |
| Users want a specific release (Source Build Flake) | `nix run github:.../v1.2.3` (git tag — flake exists at every tag) |
| Users want a specific release (Prebuilt Tarball Flake) | Pin to a commit SHA after the bump PR merges; tag-pinning does NOT work (tags are cut before the bump workflow updates `flake.nix`) |
| Flake needs source + binary side-by-side | Named outputs (`#source`, `#latest`) |
| Home-manager / module consumers | Named package reference (`#<project-name>`) |

**Recommendation:** For Source Build Flakes, use git refs as primary, expose `#<project-name>`, `#source`, and `#latest` for discoverability. For Prebuilt Tarball Flakes with a post-release bump workflow, document `github:.../` (tracks default branch) only — do not advertise tag-pinning.

---

## Using Upstream nixpkgs Packages

If the project or its dependencies are already in nixpkgs, prefer using them:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Users naturally try .#<package-name>, so expose it alongside default.
        packages = {
          <package-name> = pkgs.<package-name>;
          default = pkgs.<package-name>;
        };
        apps = {
          <package-name> = {
            type = "app";
            program = "${pkgs.<package-name>}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${pkgs.<package-name>}/bin/<binary-name>";
          };
        };
      }
    );
}
```

Decision tree:
1. **Project in nixpkgs?** -> Use `nixpkgs#<package>` (preferred)
2. **Not in nixpkgs but dependencies are?** -> Build from source, use nixpkgs for dependencies
3. **Dependency flakes exist?** -> Reference as flake inputs
4. **Nothing upstream?** -> Build everything from source (last resort)
