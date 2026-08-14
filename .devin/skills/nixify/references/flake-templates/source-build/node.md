# Source Build Flake: Node.js — Simple (`buildNpmPackage`)

Use when the project does not have published binary releases, uses Node.js,
and has a single `package-lock.json` with no build-time network fetches or
postinstall complications.

For monorepos with separate lockfiles, custom build scripts, or
postinstall complications, use
[`source-build/node-complex.md`](source-build/node-complex.md) instead.

## Template

```nix
pkgs.buildNpmPackage {
  pname = "my-project";
  version = "1.0.0";
  src = pkgs.lib.cleanSource ./.;
  npmDepsHash = "sha256-...";
  # ...
}
```

Pin `package-lock.json` or `yarn.lock`.

**Important for npm-published packages:** `package-lock.json` is excluded from npm tarballs by default. Use `npm-shrinkwrap.json` instead (add `npm shrinkwrap` to your `prepublishOnly` hook). See `references/architecture-analysis.md` — Ensure Lockfiles in npm Tarballs for details.

## Common Requirements

**Darwin legacy pin**: Add a `nixpkgs-darwin-legacy` input and use it for
`x86_64-darwin` to support older macOS Intel. See
`references/flake-templates/darwin-legacy-pin.md` for the pattern.

**cleanSource**: Use `src = pkgs.lib.cleanSource ./.;` instead of `src = ./.;` to filter build artifacts, `.git`, `.devbox`, etc., so trivial local changes do not invalidate the Nix build cache.

**Build-time network fetches**: Nix builds run in a sandbox with no network
access. Detect and neutralize build-time fetches — `next/font/google` is the
most common offender in Next.js projects (fetches Google Fonts at build time).
Scope the fix to the Nix derivation only (e.g. `postPatch` source patching);
do NOT touch the Docker/npm build path. See
`references/architecture-analysis.md` — Build-Time Network Fetches.

**Gitignored lockfiles**: If `package-lock.json` is gitignored (project uses
pnpm/yarn, or has no lockfile), `fetchNpmDeps` cannot compute the dependency
hash. Generate the lockfile in a `preConfigure` step (`npm install
--package-lock-only`) or document the need. For monorepos with multiple
`package.json` files, generate lockfiles for each subdirectory. See
`references/architecture-analysis.md` — Gitignored Lockfiles.

**Postinstall home-directory writes**: If the project has `postinstall`
scripts that write to `~/.<project>/runtime/` (e.g. `better-sqlite3`,
systray), skip them with `npm ci --ignore-scripts` and set `export
HOME=$TMPDIR` in `buildPhase`. Rely on runtime fallbacks (e.g. `sql.js`
instead of native SQLite). See `references/architecture-analysis.md` —
Postinstall Home-Directory Writes.

**`patchShebangs`**: After `npm ci --offline`, scripts in `node_modules`
may have shebangs pointing to paths that don't exist in the Nix store. Run
`patchShebangs node_modules` after each `npm ci` to fix them.

**`meta.mainProgram`**: Set `mainProgram = "<binary-name>"` in `meta` so
`nix run .#<project-name>` works without an explicit `apps` output. The
value must match the binary installed in `$out/bin/`.

**Version from `package.json`**: Use
`version = (pkgs.lib.importJSON ./package.json).version;` instead of
hardcoding the version. This keeps the flake in sync with the project's
version automatically.
