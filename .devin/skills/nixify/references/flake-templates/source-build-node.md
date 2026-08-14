# Source Build Flake: Node.js (pnpm/npm)

Use when the project does not have published binary releases and uses Node.js.

Use `buildNpmPackage` or `mkYarnPackage` from nixpkgs. Pin `package-lock.json` or `yarn.lock`.

**Important for npm-published packages:** `package-lock.json` is excluded from npm tarballs by default. Use `npm-shrinkwrap.json` instead (add `npm shrinkwrap` to your `prepublishOnly` hook). See `references/architecture-analysis.md` — Ensure Lockfiles in npm Tarballs for details.

**Darwin legacy pin**: Add a `nixpkgs-darwin-legacy` input and use it for
`x86_64-darwin` to support older macOS Intel. See
`references/flake-templates/darwin-legacy-pin.md` for the pattern.

**cleanSource**: Use `src = pkgs.lib.cleanSource ./.;` instead of `src = ./.;` to filter build artifacts, `.git`, `.devbox`, etc., so trivial local changes do not invalidate the Nix build cache.

**Build-time network fetches**: Nix builds run in a sandbox with no network
access. Detect and neutralize build-time fetches — `next/font/google` is the
most common offender in Next.js projects (fetches Google Fonts at build time).
Scope the fix to the Nix derivation only (e.g. environment variable that
disables the fetch); do NOT touch the Docker/npm build path. See
`references/architecture-analysis.md` — Build-Time Network Fetches.

**Gitignored lockfiles**: If `package-lock.json` is gitignored (project uses
pnpm/yarn, or has no lockfile), `fetchNpmDeps` cannot compute the dependency
hash. Generate the lockfile in a `preConfigure` step (`npm install
--package-lock-only`) or document the need. For monorepos with multiple
`package.json` files, generate lockfiles for each subdirectory. See
`references/architecture-analysis.md` — Gitignored Lockfiles.

**Postinstall home-directory writes**: If the project has `postinstall`
scripts that write to `~/.<project>/runtime/` (e.g. `better-sqlite3`,
systray), skip them in the Nix build with `npmFlags = [ "--ignore-scripts" ]`
and rely on runtime fallbacks (e.g. `sql.js` instead of native SQLite). See
`references/architecture-analysis.md` — Postinstall Home-Directory Writes.
