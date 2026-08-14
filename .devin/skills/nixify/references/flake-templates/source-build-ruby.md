# Source Build Flake: Ruby (Bundler)

Use when the project does not have published binary releases and uses Bundler
(`Gemfile` + `Gemfile.lock`) or ships as a single gem (`.gemspec`).

## Ruby version selection

Check `Gemfile` (look for `ruby "x.y.z"`) or `.ruby-version` for the required
Ruby version. Map it to the matching nixpkgs attribute:

| `.ruby-version` | nixpkgs attribute |
|-----------------|-------------------|
| `3.1.x` | `pkgs.ruby_3_1` |
| `3.2.x` | `pkgs.ruby_3_2` |
| `3.3.x` | `pkgs.ruby_3_3` |

Use `pkgs.ruby_3_3` (or the appropriate version attribute) in `nativeBuildInputs`
and `devShells`. If the project does not pin a Ruby version, default to
`pkgs.ruby_3_3`.

## Gemfile.lock requirement

`bundlerEnv` requires `Gemfile.lock` to be present and committed. The gemset
(the full dependency closure with exact versions and hashes) is computed from
the lockfile — without it, `bundlerEnv` cannot determine which gems to fetch.
If the project only has a `Gemfile`, run `bundle lock` locally and commit the
resulting `Gemfile.lock` before packaging with Nix.

## Native extensions

Gems such as `nokogiri`, `pg`, `mysql2`, `sqlite3`, and `rmagick` compile C
extensions during install. They need their native build inputs available:

| Gem | Build input |
|-----|-------------|
| `nokogiri` | `pkgs.libxml2`, `pkgs.libxslt` |
| `pg` | `pkgs.postgresql` |
| `mysql2` | `pkgs.mysql` or `pkgs.mariadb` |
| `sqlite3` | `pkgs.sqlite` |
| `rmagick` | `pkgs.imagemagick` |

Set `BUNDLE_BUILD__NOKOGIRI=--use-system-libraries` (and analogous env vars for
other gems) to force use of system libraries instead of bundled ones. This
avoids vendored-source build failures and ensures the Nix-provided libraries
are used.

## bundlerEnv vs bundlerApp

- **`bundlerEnv`** creates a Ruby environment with all gems from the `Gemfile`
  installed and available. Use for libraries, tools, or projects where the
  consumer needs the full bundle on `PATH`.
- **`bundlerApp`** creates a wrapper that runs a specific executable from the
  bundle (e.g. `bundle exec <binary-name>`). Use for CLI tools with a single
  entry point where the consumer only needs to run one command.

The template below uses `bundlerEnv`. For a single-entry-point CLI, swap to
`bundlerApp` and set `exes = [ "<binary-name>" ];`.

## Skip if

Skip this template if the project is a **Rails web application** that needs a
database server and web server at runtime. That requires a different packaging
approach (NixOS modules, systemd services, or a container with `puma`/`sidekiq`
managed by a process supervisor). Source-build flakes are for libraries, CLI
tools, and standalone scripts — not long-running server apps.

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
        <pname> = pkgs.bundlerEnv {
          name = "<pname>-<x.y.z>";
          # Select the Ruby version matching Gemfile/.ruby-version.
          # Common attributes: ruby_3_1, ruby_3_2, ruby_3_3.
          ruby = pkgs.ruby_3_3;
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          gemdir = pkgs.lib.cleanSource ./.;
          # Force nokogiri (and similar gems) to use system libraries
          # instead of bundled sources.
          BUNDLE_BUILD__NOKOGIRI = "--use-system-libraries";
          nativeBuildInputs = [
            pkgs.ruby_3_3
            pkgs.bundler
            pkgs.pkg-config
          ];
          buildInputs =
            [ pkgs.openssl pkgs.libxml2 pkgs.libxslt pkgs.zlib ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              # Add macOS frameworks if the gem uses keychain/TLS:
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
          nativeBuildInputs = [
            pkgs.ruby_3_3
            pkgs.bundler
            pkgs.pkg-config
          ];
          buildInputs =
            [ pkgs.openssl pkgs.libxml2 pkgs.libxslt pkgs.zlib ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ]
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            # Common examples: pkgs.postgresql, pkgs.redis, pkgs.mysql
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

## Single-gem projects (buildRubyGem)

If the project ships as a single gem (`.gemspec`, no `Gemfile`), use
`buildRubyGem` instead of `bundlerEnv`:

```nix
<pname> = pkgs.buildRubyGem {
  name = "<pname>-<x.y.z>";
  src = pkgs.lib.cleanSource ./.;
  ruby = pkgs.ruby_3_3;
  nativeBuildInputs = [ pkgs.ruby_3_3 pkgs.bundler pkgs.pkg-config ];
  buildInputs =
    [ pkgs.openssl pkgs.libxml2 pkgs.libxslt pkgs.zlib ]
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
```
