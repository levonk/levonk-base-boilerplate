# Devbox Templates

## Table of Contents

- [Rust (Cargo)](#rust-cargo)
- [Node.js (npm/pnpm/yarn/bun)](#nodejs-npmpnpyarnbun)
- [Go](#go)
- [Python](#python)
- [Darwin-Specific Notes](#darwin-specific-notes)
- [Version Pinning and devbox.lock (MANDATORY)](#version-pinning-and-devboxlock-mandatory)

---

## Version Pinning and devbox.lock (MANDATORY)

devbox.json sold as "reproducible" must actually be reproducible. Three requirements:

1. **Pin toolchain versions in `packages`** — bare package names like `"bun"` or `"nodejs_20"` resolve to whatever nixpkgs-unstable ships today, which drifts. If the project's CI pins a specific version (e.g. `bun 1.3.11` in GitHub Actions, `package.json#engines` says `^1.3.0`), the devbox `packages` array MUST pin the same major.minor. Use versioned package names where available (`bun_1_3`, `nodejs_20`, `python311`) or pin via `devbox.json`'s `packages` with version constraints. **The devbox toolchain is a second source of truth — it must not drift from CI and `engines`.**

2. **Commit `devbox.lock`** — `devbox.lock` is the lockfile that pins exact nixpkgs revisions for each package. Without it committed, every `devbox shell` resolves to a different nixpkgs revision and the environment is not reproducible. **Do NOT gitignore `devbox.lock`** — it must be committed alongside `devbox.json`. The `.gitignore` entries from `scripts/update-gitignore.sh` add `.devbox/` (generated artifacts) but NOT `devbox.lock` (the lockfile). This is intentional: `devbox.lock` belongs in git.

3. **Include `act` in `packages`** — `act` is required for Step 16b (local CI validation). It simulates the GitHub Actions workflow inside an **ubuntu container** — the same OS GitHub CI runs on. Without `act` in devbox, the test step falls back to `nix run nixpkgs#act` (slower on first invocation) or `--fallback` (runs nix on the host OS — darwin on macOS, which is NOT what CI runs on). Every template above includes `"act"` in the `packages` array; do not remove it.

This was a declining reason on Archon PR #2131: `devbox.json` had `"packages": ["bun"]` with no version and no committed `devbox.lock`, while CI pinned `bun 1.3.11` across five workflows and `package.json#engines` said `^1.3.0`. The devbox would hand the project a second toolchain source of truth that drifts from the one actually validated — the opposite of the reproducibility it's meant to buy.

---

## Rust (Cargo)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "rustc",
    "cargo",
    "rust-analyzer",
    "pkg-config",
    "openssl",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "build": "cargo build --release",
      "test": "cargo test",
      "run": "cargo run --"
    }
  }
}
```

**Detecting runtime service dependencies**: Before finalizing the devbox
template, run `scripts/detect-runtime-deps.sh <project-dir>` from the nixify
skill directory. It scans `Cargo.toml`, `package.json`, `pyproject.toml`,
`requirements.txt`, and `go.mod` for crates/packages that imply a runtime
service (database, message broker, cache, search engine, etc.) and outputs
the nix packages to add. For example, a project with the `surrealdb` crate
in any workspace member gets `surrealdb` in the output; a project with `sqlx`
gets `postgresql`; a project with `redis` gets `redis`.

Add the detected packages to the `packages` array so `devbox shell` provides
them. Example with a detected runtime dependency:

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "rustc",
    "cargo",
    "rust-analyzer",
    "pkg-config",
    "openssl",
    "act",
    "<detected-runtime-dep>"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "build": "cargo build --release",
      "test": "cargo test",
      "run": "cargo run --"
    }
  }
}
```

The same detection applies to the devShell in `flake.nix` — add detected
runtime packages to `devShells.default.buildInputs` as well. See
`references/flake-templates/source-build/rust.md` for the devShell pattern.

---

## Node.js (npm/pnpm/yarn/bun)

**MANDATORY — detect the package manager before selecting a template.** Run
`scripts/detect-package-manager.sh <project-dir>` to determine which package
manager the project uses (from lockfile presence or `package.json#packageManager`).
The script outputs JSON with `package_manager`, `install_cmd`, `build_cmd`,
`test_cmd`, `dev_cmd`, `devbox_package`, and `nix_builder`. Use the detected
values to fill in the template below — do NOT hardcode pnpm or npm by default.
This prevents the failure mode where a project uses npm (`package-lock.json`)
but the devbox template ships with pnpm commands (see OmniRoute PR #2806 —
the initial flake used `pnpm install` but the project uses npm, requiring a
fix-up commit).

### npm (package-lock.json)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "nodejs_20",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "npm install",
      "build": "npm run build",
      "test": "npm test",
      "dev": "npm run dev"
    }
  }
}
```

### pnpm (pnpm-lock.yaml)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "nodejs_20",
    "pnpm",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "pnpm install",
      "build": "pnpm build",
      "test": "pnpm test",
      "dev": "pnpm dev"
    }
  }
}
```

### yarn (yarn.lock)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "nodejs_20",
    "yarn",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "yarn install",
      "build": "yarn build",
      "test": "yarn test",
      "dev": "yarn dev"
    }
  }
}
```

### bun (bun.lock / bun.lockb)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "bun",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "bun install",
      "build": "bun run build",
      "test": "bun test",
      "dev": "bun run dev"
    }
  }
}
```

**Note on `nodejs_20` vs `bun`:** If the project uses `bun` as its runtime/package manager, verify whether `nodejs_20` is still required for any development tooling (e.g., linters, build scripts, or CI tooling that expect a `node` binary). If `bun` covers all runtime needs, remove `nodejs_20` to keep the devbox lean.

**Do NOT add install commands to `init_hook`** — the `init_hook` is for
welcome messages and environment setup, not for running `npm install` or
`pnpm install`. Install commands belong in the `scripts` section (where the
user runs `devbox run install`) or in the flake's `shellHook` (which runs
automatically on `nix develop`). Adding install to `init_hook` causes
redundant installs on every shell entry and was flagged as a review issue
on OmniRoute PR #2806.

---

## Go

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "go",
    "gopls",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "build": "go build ./...",
      "test": "go test ./...",
      "run": "go run ."
    }
  }
}
```

---

## Python

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "python311",
    "uv",
    "act"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "uv pip install -e .",
      "test": "uv run pytest",
      "run": "uv run python"
    }
  }
}
```

---

## Darwin-Specific Notes

For macOS, add platform-specific packages if needed:

```json
{
  "packages": [
    "rustc",
    "cargo",
    "pkg-config",
    "openssl"
  ],
  "shell": {
    "env": {
      "PKG_CONFIG_PATH": "${PKG_CONFIG_PATH}:${pkgs.openssl.dev}/lib/pkgconfig"
    }
  }
}
```
