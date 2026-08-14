# Source Build Flake: PHP (Composer)

Use when the project does not have published binary releases and uses Composer.

For raw PHP projects without Composer, use
[`source-build/php-raw.md`](source-build/php-raw.md) instead.

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
        <pname> = pkgs.php83.buildComposerPackage {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          # composerHash is computed from composer.lock. Set to fakeSha256,
          # run the build, then copy the correct hash from the error output.
          composerHash = pkgs.lib.fakeSha256;
          # nativeBuildInputs carries the PHP toolchain used at build time.
          # Select the PHP version based on composer.json require.php:
          #   >=8.1 -> php81, >=8.2 -> php82, >=8.3 -> php83
          nativeBuildInputs = [ pkgs.php83 ];
          # buildInputs carries PHP extensions needed at runtime. Extensions
          # must match the PHP version (e.g. php83Extensions.* for PHP 8.3).
          buildInputs =
            [ pkgs.php83Extensions.pdo_pgsql
              pkgs.php83Extensions.redis
              pkgs.php83Extensions.mbstring
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
          buildInputs =
            [ pkgs.php83 pkgs.composer ]
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            # Common examples: pkgs.postgresql, pkgs.redis
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

## Composer lockfile

`php.buildComposerPackage` requires `composer.lock` to be present and committed
to the repository. The `composerHash` is computed from `composer.lock` — set it
to `pkgs.lib.fakeSha256`, run the build, and copy the correct hash from the
error output into the `composerHash` field.

## PHP version selection

Check the `composer.json` `require.php` field to determine the PHP version.
Common constraints:

| Constraint | nixpkgs attribute |
|------------|-------------------|
| `>=8.1`    | `pkgs.php81`      |
| `>=8.2`    | `pkgs.php82`      |
| `>=8.3`    | `pkgs.php83`      |

Extensions must match the PHP version: use `php83Extensions.*` for PHP 8.3,
`php82Extensions.*` for PHP 8.2, and so on.

## Composer install --no-dev

`buildComposerPackage` runs `composer install --no-dev` by default, so dev
dependencies are not included in the build. If the project needs dev
dependencies for building (e.g. test fixtures, code generators), override
`composerFlags`:

```nix
composerFlags = [ "install" "--no-dev" "--optimize-autoloader" ];
```

## Skip if

Skip this template if the project is a web application that needs a web server
(Apache/Nginx) at runtime — that requires a different packaging approach
(systemd services, NixOS modules) rather than a standalone binary or library
package.
