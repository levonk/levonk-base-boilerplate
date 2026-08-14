# Source Build Flake: Node.js — Complex (`stdenv.mkDerivation` + `fetchNpmDeps`)

Use when the project does not have published binary releases, uses Node.js,
AND has any of these complexity factors:

- **Monorepo with separate lockfiles** — root `package.json` + `cli/` (or
  other subdirectory) each with their own `package-lock.json`
- **Custom build scripts** — a script that drives `next build`, copies
  output, and bundles (e.g. `node scripts/build-cli.js`)
- **Postinstall complications** — `better-sqlite3`, systray, or other
  packages with postinstall scripts that write outside the build tree
- **Build-time network fetches** — `next/font/google`, telemetry, or other
  build steps that fetch from the network

For simple single-package Node.js projects, use
[`source-build/node.md`](source-build/node.md) (`buildNpmPackage`) instead.

## Template

`buildNpmPackage` assumes a single `package-lock.json` and a standard
build/install phase. When its assumptions don't fit, use raw
`stdenv.mkDerivation` with `fetchNpmDeps` to prefetch dependencies and
`npm ci --offline` to install them in the sandbox. This is the pattern
that works for real-world Node.js CLIs like 9router (Next.js dashboard +
`cli/` wrapper).

```nix
packages.default = pkgs.stdenv.mkDerivation {
  pname = "my-project";
  # Extract version from package.json rather than hardcoding
  version = (pkgs.lib.importJSON ./package.json).version;
  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = with pkgs; [
    nodejs_24
    python3        # needed by some native addons (node-gyp)
    makeWrapper    # for wrapping the node entry point in installPhase
  ];

  # Disable Next.js telemetry — it makes a network call during build
  # that fails in the Nix sandbox. Set for any Next.js project.
  env.NEXT_TELEMETRY_DISABLED = "1";

  buildPhase = ''
    runHook preBuild
    # Set HOME to the sandbox temp dir — prevents postinstall scripts
    # from writing to ~/.<project>/ (better-sqlite3, systray, etc.)
    export HOME=$TMPDIR

    # Install root dependencies from prefetched cache, offline
    ${npmOfflineEnv rootNpmDeps}
    npm ci --ignore-scripts
    patchShebangs node_modules

    # For monorepos: install each subdirectory's deps separately
    # (
    #   cd cli
    #   ${npmOfflineEnv cliNpmDeps}
    #   npm ci --ignore-scripts
    #   patchShebangs node_modules
    # )

    # Run the project's build script
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/my-project
    cp -r dist node_modules package.json $out/lib/my-project/

    # Wrap the node entry point so the binary is on PATH
    makeWrapper ${pkgs.nodejs_24}/bin/node $out/bin/my-project \
      --add-flags "$out/lib/my-project/dist/cli.js"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "My project description";
    homepage = "https://github.com/<owner>/<repo>";
    license = licenses.mit;
    # mainProgram makes `nix run .#my-project` work without an explicit
    # apps output — set it to the binary name in $out/bin/
    mainProgram = "my-project";
  };
};
```

## `fetchNpmDeps` + `npmOfflineEnv` helper

`fetchNpmDeps` prefetches the npm dependency tree into a FOD (fixed-output
derivation) so `npm ci` can install offline in the sandbox. For monorepos,
create one `fetchNpmDeps` per `package.json` that has its own lockfile:

```nix
# Root package deps
rootNpmDeps = pkgs.fetchNpmDeps {
  name = "my-project-root-npm-deps";
  src = ./.;
  hash = "sha256-...";
};

# cli/ subdirectory deps (separate package.json + lockfile)
cliNpmDeps = pkgs.fetchNpmDeps {
  name = "my-project-cli-npm-deps";
  src = ./cli;
  hash = "sha256-...";
};

# Reusable shell snippet that configures npm for offline install from
# a prefetched cache
npmOfflineEnv = cache: ''
  export npm_config_cache=${cache}
  export npm_config_offline=true
  export npm_config_progress=false
  export npm_config_audit=false
  export npm_config_fund=false
  export npm_config_update_notifier=false
'';
```

## When to use this over `buildNpmPackage`

- **Monorepo with separate lockfiles**: `buildNpmPackage` assumes a single
  `package-lock.json`; this template lets you create multiple `fetchNpmDeps`.
- **Custom build scripts**: If the build is driven by a script that runs
  `next build`, copies output, and bundles (e.g. `node scripts/build-cli.js`),
  this template gives you full control over `buildPhase`.
- **Postinstall complications**: `--ignore-scripts` + `HOME=$TMPDIR` +
  runtime fallbacks are easier to orchestrate in a raw derivation.
- **Build-time network fetches**: `postPatch` source patching (see
  `references/architecture-analysis.md` — Build-Time Network Fetches) is
  cleaner in a raw derivation where you control all phases.

## Common Requirements

See [`source-build/node.md`](source-build/node.md) — Common Requirements for
Darwin legacy pin, cleanSource, build-time network fetches, gitignored
lockfiles, postinstall home-directory writes, `patchShebangs`,
`meta.mainProgram`, and version from `package.json`. All apply equally to
this template.
