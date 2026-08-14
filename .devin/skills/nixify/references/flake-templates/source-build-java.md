# Source Build Flake: Java (Maven)

Use when the project does not have published binary releases and uses Maven.

> **Gradle projects:** `buildMavenPackage` only works for Maven. If the project
> uses `build.gradle`, use
> [gradle2nix](https://github.com/nix-community/gradle2nix) instead. See the
> Gradle note below.

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
        <pname> = pkgs.buildMavenPackage {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          # buildMavenPackage downloads dependencies offline, so it needs the
          # SHA256 of the Maven dependency tree. To obtain it:
          #   1. Set mvnHash = pkgs.lib.fakeSha256;
          #   2. Run: nix build .#<pname>
          #   3. Copy the correct hash from the error message.
          mvnHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          # Select the JDK version to match the project's pom.xml:
          #   <maven.compiler.release>11  → pkgs.jdk11
          #   <maven.compiler.release>17  → pkgs.jdk17
          #   <maven.compiler.release>21  → pkgs.jdk21
          # If pom.xml uses <java.version> instead, map the same way.
          nativeBuildInputs = [ pkgs.jdk21 pkgs.maven ];
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
            [ pkgs.jdk21 pkgs.maven ]
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            # Common examples: pkgs.surrealdb, pkgs.postgresql, pkgs.redis
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

## Maven offline build (`mvnHash`)

`buildMavenPackage` performs an **offline** build — it pre-fetches the entire
Maven dependency tree into the Nix store and then runs `mvn` with
`-o` (offline). Because the dependency tree is content-addressed, Nix requires
its SHA256 up front as `mvnHash`.

To obtain the correct hash:

1. Set `mvnHash = pkgs.lib.fakeSha256;` (or the placeholder string above).
2. Run `nix build .#<pname>`.
3. The build will fail with a hash mismatch error that prints the expected
   `sha256-...` value.
4. Copy that value into `mvnHash` and rebuild.

Whenever `pom.xml` or any dependency version changes, repeat this process — the
hash will change and the old `mvnHash` will fail with a mismatch.

## JDK version selection

Choose the `jdk` package to match the project's source/target level. Inspect
`pom.xml` for one of:

| `pom.xml` property | JDK package |
|--------------------|-------------|
| `<maven.compiler.release>11</maven.compiler.release>` | `pkgs.jdk11` |
| `<maven.compiler.release>17</maven.compiler.release>` | `pkgs.jdk17` |
| `<maven.compiler.release>21</maven.compiler.release>` | `pkgs.jdk21` |
| `<java.version>11</java.version>` | `pkgs.jdk11` |
| `<java.version>17</java.version>` | `pkgs.jdk17` |
| `<java.version>21</java.version>` | `pkgs.jdk21` |

If neither property is present, default to `pkgs.jdk21` (current LTS) unless the
project's CI matrix or README indicates otherwise. Use the same JDK in both
`nativeBuildInputs` (build) and `devShells.default` (dev) so the dev shell
matches the build environment.

## Gradle projects

If the project uses `build.gradle` (or `build.gradle.kts`) instead of
`pom.xml`, `buildMavenPackage` will not work. Use
[gradle2nix](https://github.com/nix-community/gradle2nix) instead, which
generates a Nix expression from the Gradle dependency lock file. An alternative
is `nixpkgs.gradle` (the `gradle` builder in nixpkgs), but `gradle2nix` is the
community-recommended approach for reproducible Gradle builds.

The `buildMavenPackage` template above is **Maven-only**.

## Skip if

**Skip if:** the project uses a custom build system that isn't Maven or Gradle
(e.g. Ant, Bazel, a bespoke shell-based build). Those require a hand-written
Nix derivation and do not fit this template.
