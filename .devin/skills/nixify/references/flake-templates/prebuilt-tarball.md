# Prebuilt Tarball Flake

Use when the project publishes prebuilt release tarballs. Preserves exact layout and avoids complex builds. Exposes prebuilt as `#default` and from-source as `#source` so users get the fast path by default and the reproducible-from-source path on demand.

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

    # Prebuilt binary from release tarball
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

    # From-source build — fill in using the appropriate language-specific
    # template from references/flake-templates/source-build-*.md (Rust, Bun,
    # Node, Go, Python). The source build gives users a reproducible-from-source
    # path via `nix run .#source` / `nix build .#source` alongside the prebuilt
    # default. If the project cannot be built from source in Nix (e.g. complex
    # native addon setup with no nixpkgs support), remove the `source` outputs
    # from packages/apps below and document why in the PR body.
    sourceFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      # === REPLACE THIS BLOCK with the language-specific source build ===
      # Example for Bun (see references/flake-templates/source-build/bun.md):
      #   pkgs.stdenv.mkDerivation { ... bun build --compile ... }
      # Example for Rust (see references/flake-templates/source-build/rust.md):
      #   pkgs.rustPlatform.buildRustPackage { ... }
      # Example for Go (see references/flake-templates/source-build/go.md):
      #   pkgs.buildGoModule { ... }
      throw "sourceFor not implemented — fill in from source-build-<lang>.md";
  in {
    packages = forAllSystems (system: rec {
      <project> = projectFor system;
      prebuilt = <project>;
      default = prebuilt;
      source = sourceFor system;
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
      sourcePkg = sourceFor system;
    in {
      <project> = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      prebuilt = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      default = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      source = {
        type = "app";
        program = "${sourcePkg}/bin/<binary-name>";
      };
    });

    checks = forAllSystems (system: {
      # CI exercises both the prebuilt and source outputs
      prebuilt = projectFor system;
      source = sourceFor system;
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
- **Target set is the 4 glibc+darwin systems** (`x86_64`/`aarch64` × `linux`/`darwin`). Exclude win32 (not a Nix target) and musl tarballs (the glibc tarballs already cover Linux Nix systems). See `references/flake-templates/darwin-framework-note.md` for darwin-specific caveats.
- **Platform scope narrowing**: When Step 4a's `detect-platform-scope.sh` reports `platform_scope=darwin_only` or `linux_only`, remove the `assets` entries and `systems` for the excluded OS family. Do NOT add outputs for platforms the project doesn't support by design — a macOS menu-bar app's flake should only have `x86_64-darwin` and `aarch64-darwin` entries. The `meta.platforms` list should match `target_platforms`. See `references/architecture-analysis.md` — Inherent Platform Scope.
- **Named outputs**: The flake exposes four outputs: `#prebuilt` (prebuilt binary, fast), `#source` (from-source build, reproducible), `#default` (alias for `#prebuilt`), and `#<project-name>` (alias for `#prebuilt`). Users can `nix run .#prebuilt` or `nix run .#source` explicitly, or just `nix run .` for the default (prebuilt). Fill in `sourceFor` using the appropriate language-specific template from `references/flake-templates/source-build-*.md`. The `checks` attrset exercises both `prebuilt` and `source` so CI catches breakage in either path.
- **If source build is not feasible** (e.g. complex native addon setup with no nixpkgs support), remove the `source` outputs from `packages`, `apps`, and `checks`, and document why in the PR body. The prebuilt-only flake is still acceptable when accompanied by hash automation + CI.

---

## Hybrid Fallback Variant (Partial Platform Coverage)

Use when `check-releases.sh` reports `partial_platform_coverage: true` — the
project ships prebuilt binaries for **some** but not all 4 target Nix systems,
AND source build is feasible for the missing platforms. This variant makes
`#default` fall back to a from-source build on platforms that lack a prebuilt
binary, so `nix run github:...` works on every buildable platform instead of
failing on the ones the project didn't ship a binary for.

**When to use this variant:**
- `partial_platform_coverage=true` (at least one but fewer than 4 of the target
  systems has a prebuilt asset)
- Source build is feasible in Nix for the project's language (Rust, Go, Node,
  Bun, Python, etc. all have source-build templates)
- `force_source_build=false` (the maintainer did not request a pure source build)

**When NOT to use this variant:**
- All 4 target systems have prebuilt assets → use the standard template above
- No prebuilt assets at all → use a pure source-build flake (Step 12 source-build branch)
- Source build is infeasible for the missing platform(s) → use the standard
  prebuilt-only template and document the platform gap in the PR body. The flake
  correctly only supports platforms the project ships binaries for; that is the
  project's release policy, not a flake bug.
- `force_source_build=true` → use a pure source-build flake (the maintainer
  explicitly rejected prebuilt binaries)

**Key differences from the standard template:**
- `systems` = union of prebuilt-asset platforms and source-build-capable
  platforms (not just `builtins.attrNames assets`)
- `#prebuilt` = prebuilt binary, only on platforms that have a release asset.
  Omitted on platforms without a prebuilt asset, so `nix run .#prebuilt`
  correctly errors "package not available" on unsupported platforms instead of
  silently building from source.
- `#source` = source build on **all** buildable platforms (the union).
- `#default` = `if assets ? ${system} then prebuilt else source` — prebuilt
  where available, source fallback where not.
- `#<project-name>` = alias for `#default` (not `#prebuilt`).
- The `checks` attrset exercises `#source` on all systems and `#prebuilt` only
  on systems that have a prebuilt asset.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    version = "<version>";

    # Prebuilt release assets — ONLY for platforms the project ships a binary
    # for. Omit platforms with no release asset; they get the source fallback.
    assets = {
      "x86_64-linux" = {
        file = "<project>-linux-x64.tar.gz";
        sha256 = "<sha256>";
      };
      "aarch64-linux" = {
        file = "<project>-linux-arm64.tar.gz";
        sha256 = "<sha256>";
      };
      # x86_64-darwin OMITTED — project does not ship a prebuilt binary for it.
      "aarch64-darwin" = {
        file = "<project>-darwin-arm64.tar.gz";
        sha256 = "<sha256>";
      };
    };

    # The 4 standard Nix target systems. The flake supports all of them —
    # prebuilt where a release asset exists, source build where it doesn't.
    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f system);

    # Prebuilt binary from release tarball — only defined for systems in `assets`.
    prebuiltFor = system: let
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
        platforms = builtins.attrNames assets;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };
    };

    # From-source build — fill in using the appropriate language-specific
    # template from references/flake-templates/source-build-*.md (Rust, Bun,
    # Node, Go, Python). Defined for ALL systems in allSystems, not just the
    # ones missing a prebuilt asset — this lets users explicitly choose
    # `nix run .#source` on any platform for a reproducible-from-source path.
    sourceFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      # === REPLACE THIS BLOCK with the language-specific source build ===
      # Example for Rust (see references/flake-templates/source-build/rust.md):
      #   pkgs.rustPlatform.buildRustPackage { ... }
      # Example for Go (see references/flake-templates/source-build/go.md):
      #   pkgs.buildGoModule { ... }
      throw "sourceFor not implemented — fill in from source-build-<lang>.md";

    # The default output: prebuilt where available, source fallback where not.
    # This is what `nix run github:...` and `nix profile add github:...` resolve
    # to. Users on platforms with a prebuilt binary get the fast path; users on
    # platforms the project doesn't ship a binary for get a from-source build
    # instead of a "package not available" error.
    defaultFor = system:
      if assets ? ${system}
      then prebuiltFor system
      else sourceFor system;
  in {
    packages = forAllSystems (system: let
      defaultPkg = defaultFor system;
    in rec {
      <project> = defaultPkg;
      default = defaultPkg;
      source = sourceFor system;
    } // nixpkgs.lib.optionalAttrs (assets ? ${system}) {
      prebuilt = prebuiltFor system;
    });

    apps = forAllSystems (system: let
      defaultPkg = defaultFor system;
      sourcePkg = sourceFor system;
    in rec {
      <project> = {
        type = "app";
        program = "${defaultPkg}/bin/<binary-name>";
      };
      default = {
        type = "app";
        program = "${defaultPkg}/bin/<binary-name>";
      };
      source = {
        type = "app";
        program = "${sourcePkg}/bin/<binary-name>";
      };
    } // nixpkgs.lib.optionalAttrs (assets ? ${system}) {
      prebuilt = {
        type = "app";
        program = "${prebuiltFor system}/bin/<binary-name>";
      };
    });

    checks = forAllSystems (system:
      { source = sourceFor system; }
      // nixpkgs.lib.optionalAttrs (assets ? ${system}) {
        prebuilt = prebuiltFor system;
      });
  };
}
```

Key details (hybrid variant):
- `allSystems` is the fixed 4-system target set, NOT `builtins.attrNames assets`.
  This ensures `#source` and `#default` are instantiated on every buildable
  platform, including ones without a prebuilt asset. **When Step 4a's
  `detect-platform-scope.sh` reports `platform_scope=darwin_only` or
  `linux_only`, replace `allSystems` with `target_platforms` from Step 4a** —
  the hybrid fallback fills gaps within the project's inherent scope, not
  beyond it. A darwin-only project with partial darwin coverage uses the
  hybrid variant with `allSystems = ["x86_64-darwin" "aarch64-darwin"]`; it
  does NOT add Linux systems. See `references/architecture-analysis.md` —
  Inherent Platform Scope.
- `assets` only contains entries for platforms with a prebuilt binary. The
  `assets ? ${system}` check gates `#prebuilt` availability per-platform.
- `defaultFor` is the per-system fallback: prebuilt if present, source otherwise.
- `#<project-name>` aliases `#default` (not `#prebuilt`) so
  `nix run .#<project-name>` works on every platform.
- `optionalAttrs` keeps `#prebuilt` out of the outputs attrset on platforms
  that don't have a prebuilt asset — `nix run .#prebuilt` on those platforms
  correctly errors "package not available" instead of silently falling back.
- The hash automation workflow (Step 16) only bumps hashes for platforms in
  `ASSET_MAP` (the prebuilt platforms). The `#source` output on fallback
  platforms tracks the git tag, not release assets — it is NOT hash-automated.
  See `references/advanced-features.md` — Release-Triggered Hash Automation.
- **If source build is not feasible** for the missing platform(s), do NOT use
  this variant. Use the standard prebuilt-only template and document the
  platform gap in the PR body. The flake correctly only supports platforms the
  project ships binaries for.
