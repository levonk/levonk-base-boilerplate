# Advanced Features

## Table of Contents

- [Home-Manager Module](#home-manager-module)
- [NixOS Service Module](#nixos-service-module)
- [Modular Nix Structure](#modular-nix-structure)
- [Flake-Compat Shims (Legacy Nix)](#flake-compat-shims-legacy-nix)
- [treefmt Configuration](#treefmt-configuration)
- [GitHub Actions CI for Nix](#github-actions-ci-for-nix)
- [Garnix CI (Hosted Alternative)](#garnix-ci-hosted-alternative)
- [Release-Triggered Hash Automation](#release-triggered-hash-automation)
- [Cachix Integration (Binary Caching)](#cachix-integration-binary-caching)
- [Upstream Cache Consumption (nixConfig)](#upstream-cache-consumption-nixconfig)
- [Input Follows for nixpkgs Deduplication](#input-follows-for-nixpkgs-deduplication)
- [forAllSystems / perSystem Pattern (No flake-utils)](#forallsystems--persystem-pattern-no-flake-utils)

---

## Home-Manager Module

For projects that benefit from declarative user configuration, add a home-manager module.

**Create the module structure:**

```bash
mkdir -p nix/modules/hm
```

**Create `nix/modules/hm-module.nix`:**

```nix
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.<binary-name>;
in
{
  options.programs.<binary-name> = {
    enable = mkEnableOption "<project name>";

    package = mkOption {
      type = types.package;
      default = pkgs.<binary-name>;
      description = "Package to use for <project name>.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration for <project name>.";
      example = {
        theme.name = "catppuccin";
        terminal.default_shell = "${pkgs.zsh}/bin/zsh";
      };
    };

    shellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."<binary-name>/config.toml".source =
      pkgs.formats.toml {}.generate "config.toml" cfg.settings;

    programs.zsh.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for zsh
    '';

    programs.bash.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for bash
    '';

    programs.fish.interactiveShellInit = mkIf cfg.shellIntegration ''
      # Add shell integration for fish
    '';
  };
}
```

**Skip if:** The project is a library, not a CLI tool, or configuration is simple enough for manual management.

---

## NixOS Service Module

For projects that run as a long-running service (web server, API, daemon,
bot), add a NixOS module so users can deploy the service declaratively on
NixOS via `services.<project-name>.enable = true`. This is the gap between
"installable via `nix run`" (the flake's `packages` output) and "deployable
as a native NixOS service" (a `nixosModules` output with systemd service,
user/group, data dirs, and auto-configured dependencies). See OmniRoute
issue #3738 — a user requested "nix native packages and nix service
configuration options" after the dev-environment-only PR #2806 landed.

**Canonical examples** (referenced by issue #3738):
- [authentik-nix](https://github.com/nix-community/authentik-nix) — NixOS
  module for authentik with systemd service, redis, and postgresql
  auto-configuration
- [hermes-agent nix](https://github.com/NousResearch/hermes-agent/tree/main/nix)
  — NixOS module for a long-running AI agent service

### Create the module structure

```bash
mkdir -p nix/modules/nixos
```

### Create `nix/modules/nixos/default.nix`

```nix
{ pkgs, lib, config, options, ... }:

with lib;

let
  cfg = config.services.<project-name>;
  pkg = self.packages.${pkgs.system}.default;
in
{
  options.services.<project-name> = {
    enable = mkEnableOption "<project-name> service";

    package = mkOption {
      type = types.package;
      default = pkg;
      description = "Package to use for <project-name>.";
    };

    user = mkOption {
      type = types.str;
      default = "<project-name>";
      description = "User to run <project-name> as.";
    };

    group = mkOption {
      type = types.str;
      default = "<project-name>";
      description = "Group to run <project-name> as.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/<project-name>";
      description = "Data directory for <project-name>.";
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = ''
        Path to an environment file loaded by the systemd service.
        Useful for projects that strictly read `.env` files (see
        `.env`-strict projects below). The file should contain
        KEY=value lines; it is passed to systemd via EnvironmentFile=.
      '';
    };

    # ── Auto-configured runtime service dependencies ───────────────────
    # These options are generated from detect-runtime-deps.sh output.
    # Each detected runtime dep (redis, postgresql, mongodb, etc.) gets
    # an `enable<Dep>` option that defaults to true, so the service
    # auto-configures its dependencies when enabled — like Nextcloud.
    enableRedis = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to auto-configure Redis for <project-name>.";
    };

    enablePostgresql = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to auto-configure PostgreSQL for <project-name>.";
    };

    # Add more enable<Dep> options as detected by detect-runtime-deps.sh.
    # Common ones: enableMongodb, enableRabbitmq, enableElasticsearch,
    # enableMeilisearch, enableClickhouse.
  };

  config = mkIf cfg.enable {
    # ── User and group ─────────────────────────────────────────────────
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.${cfg.group} = {};

    # ── Auto-configured runtime dependencies ───────────────────────────
    # Each enable<Dep> option maps to the corresponding NixOS service.
    # This is the "auto configure redis service just like Nextcloud"
    # pattern from issue #3738.
    services.redis = mkIf cfg.enableRedis {
      enable = true;
      # Bind to a unix socket or localhost for security
      bind = "127.0.0.1";
      port = 6379;
    };

    services.postgresql = mkIf cfg.enablePostgresql {
      enable = true;
      ensureDatabases = [ "<project-name>" ];
      ensureUsers = [
        {
          name = cfg.user;
          ensurePermissions = { "DATABASE \"<project-name>\"" = "ALL PRIVILEGES"; };
        }
      ];
    };

    # Add more service auto-configurations as detected:
    # services.mongodb = mkIf cfg.enableMongodb { enable = true; };
    # services.rabbitmq = mkIf cfg.enableRabbitmq { enable = true; };
    # services.elasticsearch = mkIf cfg.enableElasticsearch { enable = true; };

    # ── Systemd service ────────────────────────────────────────────────
    systemd.services.<project-name> = {
      description = "<project-name> service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ] ++ optionals cfg.enableRedis [ "redis.service" ]
        ++ optionals cfg.enablePostgresql [ "postgresql.service" ];

      environment = {
        # Pass config via environment variables. For projects that read
        # environment variables directly (not strictly .env files), this
        # is sufficient. See ".env-strict projects" below for the
        # EnvironmentFile pattern.
        NODE_ENV = "production";
        # Add project-specific env vars here:
        # DATABASE_URL = "postgresql:///project-name?host=/run/postgresql";
        # REDIS_URL = "redis://127.0.0.1:6379";
      };

      # For .env-strict projects: load the env file via systemd
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/<binary-name>";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        StateDirectory = "<project-name>";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      } // (optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      });
    };
  };
}
```

### Expose the module as a flake output

Add `nixosModules.<project-name>` to `flake.nix` alongside the existing
`packages` and `devShells` outputs:

```nix
nixosModules.<project-name> = import ./nix/modules/nixos;
nixosModules.default = self.nixosModules.<project-name>;
```

Users deploy the service in their NixOS configuration (`configuration.nix`
or a flake):

```nix
{
  inputs.<project-name>.url = "github:<owner>/<repo>";
  outputs = { self, <project-name>, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        <project-name>.nixosModules.<project-name>
        {
          services.<project-name>.enable = true;
          # Redis and PostgreSQL are auto-configured by default.
          # Override if you manage them separately:
          # services.<project-name>.enableRedis = false;
        }
      ];
    };
  };
}
```

### Consuming `detect-runtime-deps.sh` output

Before generating the module, run
`scripts/detect-runtime-deps.sh <project-dir>` (Step 12b). The script
outputs `devbox_packages` and `devshell_packages` arrays — map each
detected service to a `mkIf`-guarded NixOS service block:

| Detected package | NixOS service option | NixOS service block |
|------------------|---------------------|---------------------|
| `redis` | `enableRedis` | `services.redis = mkIf cfg.enableRedis { ... }` |
| `postgresql` | `enablePostgresql` | `services.postgresql = mkIf cfg.enablePostgresql { ... }` |
| `mongodb` | `enableMongodb` | `services.mongodb = mkIf cfg.enableMongodb { ... }` |
| `rabbitmq` | `enableRabbitmq` | `services.rabbitmq = mkIf cfg.enableRabbitmq { ... }` |
| `elasticsearch` | `enableElasticsearch` | `services.elasticsearch = mkIf cfg.enableElasticsearch { ... }` |
| `meilisearch` | `enableMeilisearch` | `services.meilisearch = mkIf cfg.enableMeilisearch { ... }` |
| `clickhouse` | `enableClickhouse` | `services.clickhouse = mkIf cfg.enableClickhouse { ... }` |

Only add `enable<Dep>` options for services that
`detect-runtime-deps.sh` actually detected — do not add all possible
options speculatively. Each option defaults to `true` so the service
auto-configures its dependencies when enabled, matching the Nextcloud
pattern requested in issue #3738.

### `.env`-strict projects

Some projects strictly read configuration from a `.env` file at startup
and do not honor environment variables set in the process environment
(e.g. they use `dotenv/config` which only reads from the file, not the
environment). This is a common pattern in Node.js projects. For NixOS
deployment, there are two approaches:

1. **`EnvironmentFile` (preferred, no source changes)**: Pass the env
   file path via the `environmentFile` option (shown in the template
   above). The systemd service loads it via `EnvironmentFile=`. The user
   creates the file at the specified path (e.g.
   `/var/lib/<project-name>/.env`) with the required `KEY=value` lines.
   This works without any source code changes — the project reads its
   `.env` file as usual, and systemd provides the file.

2. **Source patch (if the project cannot use a file)**: If the project
   reads `.env` from a hardcoded relative path that cannot be overridden,
   a `postPatch` in the Nix derivation can patch the path to read from
   `$HOME/.env` or an absolute path. This is a source change in the Nix
   derivation only — do NOT modify the upstream source code in a
   Nix-only PR (see Step 8). Document the patch in the orientation issue
   so a follow-up PR can address the root cause (making the project read
   from the environment directly, as requested in issue #3738).

**When the user requests environment-variable reading instead of `.env`
files**: This is a source code change (e.g. replacing `dotenv/config`
with direct `process.env` reads, or adding `dotenv` with
`override: true`). It is out of scope for a nixify PR — the nixify PR
packages and deploys the project as-is. Document the request in the
orientation issue as a follow-up suggestion for the upstream project.

### Skip if

- The project is a CLI tool, not a long-running service (use the
  Home-Manager Module instead)
- The project is a library (no service to run)
- The project only runs in a container and has no native service mode
  (document the container deployment in the orientation issue instead)

---

## Modular Nix Structure

For larger projects requiring complex Nix logic, use a modular structure instead of a monolithic `flake.nix`.

**Create `nix/modules/packages.nix`:**

```nix
{ pkgs, system, ... }:
{
  default = pkgs.<binary-name>;
}
```

**Create `nix/modules/overlays.nix`:**

```nix
final: prev: {
  <binary-name> = final.<binary-name>;
}
```

**Create `nix/modules/devshells.nix`:**

```nix
{ pkgs, ... }:
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      rustc
      cargo
      rust-analyzer
      pkg-config
      openssl
    ];
  };
}
```

**Create `nix/modules/treefmt.nix`:**

```nix
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.formatter.nixfmt = {
    command = "${pkgs.nixfmt}/bin/nixfmt";
    includes = [ "*.nix" ];
  };
}
```

**Update `flake.nix` to use modules:**

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = import ./nix/modules/packages.nix { inherit pkgs system; };
        overlays = import ./nix/modules/overlays.nix;
        devshells = import ./nix/modules/devshells.nix { inherit pkgs; };
        treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
      in
      {
        inherit packages overlays devshells;
        packages.default = packages.default;
        devShells.default = devshells.default;
        formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
      }
    );
}
```

**Skip if:** The project is simple and a monolithic `flake.nix` is sufficient.

---

## Flake-Compat Shims (Legacy Nix)

Create `default.nix` and `shell.nix` for users who don't have flakes enabled.

**`default.nix`:**

```nix
(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  }
) {
  src = ./.;
}).defaultNix
```

**`shell.nix`:**

```nix
(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  }
) {
  src = ./.;
}).shellNix
```

**Skip if:** The project only targets users with Nix flakes enabled.

---

## treefmt Configuration

Add treefmt for automated Nix formatting.

**Add treefmt-nix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  treefmt-nix.url = "github:numtide/treefmt-nix";
};
```

**Add formatter output:**

```nix
outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
    in
    {
      formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
    }
  );
```

**Usage:**

```bash
nix fmt          # Format all Nix files
nix fmt --check  # Check formatting without modifying
```

**Skip if:** The project has no Nix files beyond `flake.nix` or the team prefers other tools.

---

## GitHub Actions CI for Nix

**Create `.github/workflows/nix.yml`:**

```yaml
name: Nix flake

# Validates the flake (flake.nix). For most nixify targets Nix is a side
# concern and the full build can take 10+ minutes, so this workflow runs
# only on manual dispatch or when a release is published — not on every
# push or PR. If the project wants per-PR validation, add a `pull_request`
# trigger with `paths:` filtered to flake files (see customization notes).
#
# Steps, in order of what they catch:
#   1. nix flake check --all-systems  — every system's outputs evaluate
#      (including darwin on an ubuntu runner).
#   2. nix build .#default            — fetchurl + autoPatchelf + install
#      layout actually realises for the runner's system.
#   3. nix run .#default -- --version — the patched binary actually execs.
#      This is the only step that catches the `let ... in rec` shadowing
#      class of bug (passes flake check, fails nix run). Do NOT drop it.
#   4. nix build .#source (if #source output exists) — the from-source
#      build path realises for the runner's system. Skip if the flake
#      does not expose a #source output.

on:
  # Manual trigger — run before cutting a release or after significant
  # flake changes.
  workflow_dispatch: {}
  # Auto-run on published releases only.
  release:
    types: [published]

permissions:
  contents: read

concurrency:
  group: nix-{{{ printf "%s" "${{{ github.workflow }}}" }}}-{{{ printf "%s" "${{{ github.event.pull_request.number || github.ref }}}" }}}
  cancel-in-progress: true

jobs:
  check:
    name: nix flake check
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        # DeterminateSystems/nix-installer-action installs Nix natively on the
        # runner so `nix build` / `nix run` work directly (a Docker-container
        # approach can run `nix flake check` but is awkward for build+smoke).
        uses: DeterminateSystems/nix-installer-action@v16

      - name: nix flake check --all-systems
        # --no-build: evaluate every system's outputs (including darwin on
        # ubuntu) without realising them. Without --no-build, `nix flake
        # check` builds every derivation in `checks`, which fails for
        # non-native systems (darwin stdenv can't run on linux). The
        # build/run steps below handle realisation for the runner's system.
        run: nix flake check --all-systems --no-build

      - name: nix build .#default
        run: nix build .#default --print-build-logs

      - name: nix run .#default -- --version
        run: nix run .#default -- --version

      - name: nix build .#source (if exists)
        # Exercises the from-source build path. Skip if the flake does not
        # expose a #source output (source-build-only flakes use #default).
        run: |
          if nix flake show --json 2>/dev/null | jq -e 'any(.packages[]?; has("source"))' >/dev/null 2>&1; then
            nix build .#source --print-build-logs
          else
            echo "No #source output — skipping"
          fi
```

**Customization notes:**
- **Trigger policy**: The default is `workflow_dispatch` + `release: published` only — Nix is usually a side concern and the full build takes 10+ minutes. If the project wants per-PR validation, add a `pull_request` trigger with `paths:` filtered to flake files:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
  ```
  Adjust `branches: [main]` to match the project's default branch.
- **Lockfile path-filter (source-build flakes — MANDATORY)**: When the flake exposes a `#source` output that builds from source via a fixed-output derivation (FOD) keyed on a lockfile hash, **the lockfile MUST be in the `paths:` filter**. A lockfile change invalidates the FOD's `outputHash`, but if the lockfile isn't in the path filter, the Nix CI never runs on dependency bumps and the breakage reaches users instead of being caught in CI. Add the project's lockfile(s) to the `paths:` list:
  - Bun: `bun.lock`
  - npm: `package-lock.json`
  - pnpm: `pnpm-lock.yaml`
  - Cargo: `Cargo.lock`
  - Go: `go.sum`
  - Python (uv): `uv.lock`
  - Python (pip): `requirements.txt`
  - Maven: `pom.xml`
  Example with Bun:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
      - "bun.lock"
  ```
  This was a declining reason on Archon PR #2131: `bun.lock` changed 16 times in 60 days but was not in the nix.yml path filter, so dependency bumps never triggered Nix CI and the `#source` FOD hash rot reached users silently.
- **Cross-platform matrix (recommended for prebuilt tarball flakes)**: The default workflow runs on `ubuntu-latest` only. `nix flake check --all-systems --no-build` evaluates every system's outputs without realising fetchurl derivations, so a fetch-hash mismatch on `x86_64-darwin` or `aarch64-darwin` is invisible. To catch cross-platform hash mismatches and Darwin-specific build failures, add a matrix that builds on multiple runners:
  ```yaml
  strategy:
    matrix:
      runner: [ubuntu-latest, macos-13, macos-14]
  runs-on: ${{ matrix.runner }}
  ```
  `macos-13` is Intel (x86_64-darwin), `macos-14` is ARM (aarch64-darwin). This is the only way CI can catch the class of hash mismatch that the Archon PR #2131 ASSET_MAP omission caused.
- Replace `--version` with the project's actual smoke command (e.g. `--help`, `--version`, or a no-op subcommand). The point is to exec the patched binary end-to-end.
- The `#source` build step uses `jq` to detect whether the output exists before building. If the project's runner doesn't have `jq`, install it first or replace the check with `nix build .#source 2>/dev/null || true` (less precise but functional).
- Pin `actions/checkout` and `nix-installer-action` to commit SHAs (with `# vX.Y.Z` comments) if the project's existing workflows do so — match the repo's convention.

**DO NOT add `DeterminateSystems/magic-nix-cache-action`.** Its hosted backend was sunset in February 2025 and the step now degrades to a silent no-op; it adds noise and a dead dependency for no benefit. If binary caching is actually needed, use Cachix (see [Cachix Integration](#cachix-integration-binary-caching)).

**Skip if:** The project does not use GitHub Actions for CI.

---

## Garnix CI (Hosted Alternative)

[Garnix](https://garnix.io) is a hosted CI service for Nix flake repos. After
installing the Garnix GitHub App on a repository, every push automatically
builds all flake outputs (`packages`, `checks`, `devShells`,
`nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`) and
reports results back as GitHub commit/PR checks. Build outputs are cached on
Garnix's side, so subsequent builds and local `nix run` fetches are fast.

### Relationship to the required `.github/workflows/nix.yml`

Garnix is a **complement**, not a replacement, for the required GitHub Actions
workflow (see [GitHub Actions CI for Nix](#github-actions-ci-for-nix)):

- **`nix.yml`** is the **contributor-controlled** CI. The nixify PR adds it,
  and it works immediately on any repo — no maintainer action needed. It is
  the only CI the contributor can guarantee.
- **Garnix** is the **maintainer-opt-in** CI. The contributor cannot install
  the Garnix GitHub App on a repo they don't own. Adding a `garnix.yaml` to
  the PR makes the repo Garnix-ready the moment the maintainer enables the
  app, but it does nothing until then.

Keep `nix.yml` in every PR. Add `garnix.yaml` as an optional artifact when the
maintainer has expressed interest in hosted Nix CI, or when the project's
cross-platform coverage needs exceed what a single-runner GitHub Actions
workflow provides.

### The maintainer-opt-in constraint

nixify PRs go to **upstream third-party repos**. The contributor does not have
permission to install the Garnix GitHub App on the target repo — that requires
the repo owner to visit [app.garnix.io](https://app.garnix.io), install the
app, and authorize it for the repository. Therefore:

1. **`garnix.yaml` in the PR** configures build scope *if* the maintainer later
   enables the app. It is inert until the app is installed — no side effects,
   no broken checks.
2. **The PR body** should mention Garnix as an optional complement, not as
   something the PR activates. Phrase it as: "A `garnix.yaml` is included so
   the repo is ready for [Garnix CI](https://garnix.io) if the maintainer
   chooses to enable it."
3. **Do not** add Garnix badges to the README unless the maintainer has already
   enabled the app — a badge that links to a non-existent Garnix project page
   is worse than no badge.

### `garnix.yaml` configuration

Garnix's **default** build scope is **linux-only**:
`*.x86_64-linux.*`, `defaultPackage.x86_64-linux`, `devShell.x86_64-linux`,
plus all `homeConfigurations.*`, `darwinConfigurations.*`, and
`nixosConfigurations.*`. Mac (`aarch64-darwin`, `x86_64-darwin`) and ARM-linux
(`aarch64-linux`) builds are **opt-in** via the `builds.include` list.

This is the exact cross-platform gap the nixify skill cares about — the
`target_platforms` from Step 4a determines which systems to include. Run
`scripts/detect-garnix-scope.sh` to generate the correct `garnix.yaml` from
the Step 4a output.

**For `platform_scope=all` (all 4 systems):**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=darwin_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=linux_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
```

### FOD checks (hash-rot detection)

For source-build flakes, enable FOD (fixed-output derivation) checks to catch
hash rot — the exact failure mode the lockfile path-filter section documents
(Archon PR #2131: `bun.lock` changed but Nix CI never ran, so the FOD hash rot
reached users silently):

```yaml
fodChecks: true
```

Garnix's FOD checks verify that all fixed-output derivations in the flake
produce the expected hashes. When a lockfile bump invalidates a FOD hash,
Garnix catches it on the next push — before it reaches users. This is
complementary to the `nix.yml` lockfile path-filter: the path-filter ensures
`nix.yml` *runs* on lockfile changes; Garnix's `fodChecks` provides an
independent hosted verification layer.

Enable `fodChecks: true` for `flake_type=source_build` and
`flake_type=prebuilt_tarball` (the `#source` output in prebuilt tarball flakes
also uses FODs). Skip if the flake has no FOD outputs (rare — most source
builds use `fetchurl`/`fetchFromGitHub`/`fetchNpmDeps`/`bun2nix` which are
FODs).

### Full `garnix.yaml` example (all 4 systems, FOD checks on)

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
fodChecks: true
```

### When to add `garnix.yaml` to the PR

- **Add it** when the maintainer has expressed interest in hosted Nix CI, or
  when the project would benefit from cross-platform build coverage that
  exceeds the single-runner `nix.yml` (e.g., the project has darwin-specific
  outputs that `nix.yml` only evaluates via `--no-build`).
- **Skip it** when the project already has a robust GitHub Actions matrix
  (ubuntu + macos-13 + macos-14) and the maintainer hasn't mentioned Garnix.
  Adding an inert config file the maintainer didn't ask for is presumptuous.
- **Never** add it without the `nix.yml` — `nix.yml` is the contributor's
  guarantee; `garnix.yaml` is a bonus that only activates on maintainer opt-in.

### GitHub Actions integration

Garnix is not a GitHub Action (it avoids consuming GitHub Actions minutes).
If the project has existing GitHub Actions workflows that need to gate on
Garnix checks, use the `check_suite` event:

```yaml
on:
  check_suite:
    types: [completed]
```

This fires once per non-GitHub-Actions check-suite completion (i.e., when
Garnix finishes all builds for a commit). See the
[Garnix GitHub Actions Integration docs](https://garnix.io/docs/ci/gh-actions)
for details.

**Skip if:** The maintainer has not expressed interest in hosted Nix CI, or
the project already has a robust cross-platform GitHub Actions matrix.

---

## Release-Triggered Hash Automation

For the **Prebuilt Tarball Flake** path, every release requires bumping `version` and refreshing the
per-platform `sha256` hashes in `flake.nix`. Doing this by hand is the #1 objection maintainers raise
to accepting a repo-owned flake ("I don't know Nix and this adds per-release maintenance"). Automation
removes that burden entirely: it prefetches the new release assets, rewrites `flake.nix`, and opens a
PR — zero Nix knowledge required from the maintainer.

**This is a required deliverable for release-based repos using the Prebuilt Tarball Flake, not an
optional extra.** Without it, the flake rots one release after merge.

### CRITICAL: the `GITHUB_TOKEN` trap (why `release: published` often does not work)

Before choosing a trigger, **inspect how the project creates its releases**. If the release workflow
uses `secrets.GITHUB_TOKEN` to run `gh release create` (common with cargo-dist, release-please, and
many autogenerated release pipelines), then a `release: published` workflow **will never fire**.
GitHub deliberately does not start new workflow runs from events created by `GITHUB_TOKEN` (to
prevent recursive loops). This is a documented limitation:
https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#triggering-a-workflow-from-a-fork

**Decision tree:**
1. Inspect the project's release workflow (e.g. `.github/workflows/release.yml`). Find the
   `gh release create` step and check its `GH_TOKEN` / `GITHUB_TOKEN` env.
2. If it uses a **PAT or GitHub App token** -> `release: published` works. Use the
   `release: published` template below.
3. If it uses **`secrets.GITHUB_TOKEN`** (the common case, including all cargo-dist setups) ->
   `release: published` will NOT fire. Use the **scheduled lag-check** template below instead. It
   runs daily, compares `flake.nix`'s `version` to the latest GitHub release, and only acts when
   they differ. Fully decoupled from how releases are created; needs no PAT and no edits to the
   release pipeline.

### Template A: scheduled lag-check (recommended for `GITHUB_TOKEN`-created releases)

Runs daily (and on manual dispatch). When the latest GitHub release outpaces `flake.nix`'s pinned
`version`, prefetches new SRI hashes and opens a PR. No dependency on the release event, no PAT, no
edits to the release pipeline.

**Create `.github/workflows/nix-release.yml`:**

```yaml
name: Update Nix flake

# Checks whether flake.nix lags behind the latest GitHub release. If it does,
# prefetches the new release's per-platform SRI hashes, rewrites flake.nix,
# and opens a PR.
#
# Runs on a schedule instead of release: published because releases are created
# with GITHUB_TOKEN, which does not start new workflow runs. A daily lag-check
# is fully decoupled from how releases are created and needs no PAT.

on:
  schedule:
    - cron: "17 6 * * *"
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: nix-flake-release
  cancel-in-progress: true

jobs:
  update-flake:
    name: Bump flake version + hashes if lagging
    runs-on: ubuntu-latest
    if: github.repository == '<owner>/<repo>'
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        uses: cachix/install-nix-action@v31

      - name: Check for lag and rewrite flake.nix
        env:
          # system|asset-substring — one per line. The substring must uniquely
          # match the release asset filename for that system (including the
          # .tar.gz suffix so it does not match the sibling .sha256 files).
          ASSET_MAP: |
            x86_64-linux|x86_64-unknown-linux-musl
            aarch64-linux|aarch64-unknown-linux-musl
            x86_64-darwin|x86_64-apple-darwin
            aarch64-darwin|aarch64-apple-darwin
        run: |
          set -euo pipefail
          tag=$(curl -fsSL -H "Accept: application/vnd.github+json" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest" \
            | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
          latest="${tag#v}"
          current=$(python3 -c 'import re; s=open("flake.nix").read(); m=re.search(r"version = \"([^\"]*)\";", s); print(m.group(1))')
          echo "flake.nix version: $current  |  latest release: $latest (tag $tag)"
          if [ "$current" = "$latest" ]; then
            echo "flake.nix is up to date; nothing to do."
            echo "LAGGING=no" >> "$GITHUB_ENV"
            exit 0
          fi
          echo "LAGGING=yes" >> "$GITHUB_ENV"
          echo "VERSION=$latest" >> "$GITHUB_ENV"
          export TAG="$tag"
          python3 <<'PYEOF'
          import json, os, re, subprocess, urllib.request
          tag = os.environ["TAG"]
          version = tag.lstrip("v")
          repo = os.environ["GITHUB_REPOSITORY"]
          with urllib.request.urlopen(
              f"https://api.github.com/repos/{repo}/releases/latest") as r:
              release = json.load(r)
          # Drop sibling checksum files (.sha256) so a tarball substring does
          # not also match its "<tarball>.sha256" companion (cargo-dist etc.).
          names = {a["name"] for a in release["assets"]
                   if not a["name"].endswith(".sha256")}
          asset_map = {}
          for line in os.environ["ASSET_MAP"].splitlines():
              line = line.strip()
              if not line or line.startswith("#"):
                  continue
              sys_, sub = line.split("|", 1)
              asset_map[sys_.strip()] = sub.strip()
          # Reverse-check guard: detect release assets that look like platform
          # binaries but are NOT in ASSET_MAP. If a project ships for 4 platforms
          # but ASSET_MAP only lists 3, the omitted platform's hash goes stale
          # while its URL still gets the version bump — users on that platform
          # get a hash mismatch. This catches the omission class of bug that
          # CI cannot see (nix flake check --all-systems --no-build evaluates
          # without realising fetchurl derivations, and nix build only runs on
          # the runner's own system). See Archon PR #2131 feedback.
          known_platforms = {"x86_64-linux", "aarch64-linux",
                             "x86_64-darwin", "aarch64-darwin"}
          matched_subs = set(asset_map.values())
          unmatched = []
          for name in names:
              # Skip non-binary assets (checksums, source tarballs, .deb, .rpm, etc.)
              if not (name.endswith(".tar.gz") or name.endswith(".zip")):
                  continue
              if any(sub in name for sub in matched_subs):
                  continue
              # Check if the asset name contains a platform identifier
              for plat in known_platforms:
                  # Match common platform naming patterns in asset filenames
                  plat_patterns = {
                      "x86_64-linux": ["x86_64-linux", "x86_64-unknown-linux", "linux-x64", "linux-x86_64", "x64-linux"],
                      "aarch64-linux": ["aarch64-linux", "aarch64-unknown-linux", "linux-arm64", "linux-aarch64", "arm64-linux"],
                      "x86_64-darwin": ["x86_64-darwin", "x86_64-apple-darwin", "darwin-x64", "darwin-x86_64", "macos-x64", "x64-darwin", "x64-macos"],
                      "aarch64-darwin": ["aarch64-darwin", "aarch64-apple-darwin", "darwin-arm64", "darwin-aarch64", "macos-arm64", "arm64-darwin", "arm64-macos"],
                  }
                  if any(p in name.lower() for p in plat_patterns[plat]):
                      if plat not in asset_map:
                          unmatched.append((plat, name))
                      break
          if unmatched:
              plats = ", ".join(f"{p} ({n})" for p, n in unmatched)
              raise SystemExit(
                  f"RELEASE ASSET COMPLETENESS CHECK FAILED: release {tag} has "
                  f"binary assets for platforms not in ASSET_MAP: {plats}. "
                  f"Add them to ASSET_MAP or the hash for those platforms will "
                  f"go stale while the URL gets the version bump — users on the "
                  f"omitted platform get a hash mismatch. ASSET_MAP currently "
                  f"covers: {sorted(asset_map.keys())}")
          src = open("flake.nix").read()
          src, n = re.subn(r'version = "[^"]*";', f'version = "{version}";', src, count=1)
          if n != 1:
              raise SystemExit('could not find version = "..." in flake.nix')
          for sys_, sub in asset_map.items():
              match = next((n for n in names if sub in n), None)
              if not match:
                  raise SystemExit(f"no asset for {sys_} ({sub}) in {tag}; have: {sorted(names)}")
              url = f"https://github.com/{repo}/releases/download/{tag}/{match}"
              out = json.loads(subprocess.check_output(
                  ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url]))
              sri = out["hash"]
              pat = re.compile(r'("' + re.escape(sys_) + r'" = \{[^}]*\})', re.S)
              def repl(m):
                  b = m.group(1)
                  b = re.sub(r'file = "[^"]*";', f'file = "{match}";', b, count=1)
                  b = re.sub(r'sha256 = "[^"]*";', f'sha256 = "{sri}";', b, count=1)
                  return b
              src, n = pat.subn(repl, src, count=1)
              if n != 1:
                  raise SystemExit(f"could not find assets block for {sys_} in flake.nix")
          open("flake.nix", "w").write(src)
          print(f"bumped flake.nix to {version}: {list(asset_map)}")
          PYEOF

      - name: Open PR
        if: env.LAGGING == 'yes'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          title: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          branch: chore/nix-flake-v{{{ printf "%s" "${{{ env.VERSION }}}" }}}
          base: master
          body: |
            Auto-generated by the `Update Nix flake` workflow (daily lag-check).
            The latest GitHub release is v{{{ printf "%s" "${{{ env.VERSION }}}" }}} but `flake.nix` was
            pinned to an older version. This PR bumps `version` and refreshes the per-platform SRI
            hashes by prefetching the new release assets.

            Note: PRs opened by `GITHUB_TOKEN` do not trigger downstream workflow runs (e.g. CI),
            so this PR will show no checks. Review the diff before merging — it should be a
            version bump plus per-platform hash refresh with no source changes.
```

### Template B: `release: published` (only if releases are created with a PAT/App token)

Use this only when Step 1 of the decision tree confirmed the release is created with a PAT or
GitHub App token (not `secrets.GITHUB_TOKEN`). Otherwise this workflow will silently never fire.

```yaml
name: Update Nix flake

on:
  release:
    types: [published]

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: nix-flake-release
  cancel-in-progress: true

jobs:
  update-flake:
    name: Bump flake version + hashes
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        uses: cachix/install-nix-action@v31

      - name: Rewrite flake.nix with new release
        env:
          ASSET_MAP: |
            x86_64-linux|x86_64-unknown-linux-musl
            aarch64-linux|aarch64-unknown-linux-musl
            x86_64-darwin|x86_64-apple-darwin
            aarch64-darwin|aarch64-apple-darwin
        run: |
          version="${GITHUB_REF_NAME#v}"
          echo "VERSION=$version" >> "$GITHUB_ENV"
          python3 <<'PYEOF'
          import json, os, re, subprocess
          tag = os.environ["GITHUB_REF_NAME"]
          version = tag.lstrip("v")
          event = json.load(open(os.environ["GITHUB_EVENT_PATH"]))
          asset_map = {}
          for line in os.environ["ASSET_MAP"].splitlines():
              line = line.strip()
              if not line or line.startswith("#"):
                  continue
              sys_, sub = line.split("|", 1)
              asset_map[sys_.strip()] = sub.strip()
          names = {a["name"] for a in event["release"]["assets"]
                   if not a["name"].endswith(".sha256")}
          # Reverse-check guard: detect release assets that look like platform
          # binaries but are NOT in ASSET_MAP. See Template A for full rationale.
          known_platforms = {"x86_64-linux", "aarch64-linux",
                             "x86_64-darwin", "aarch64-darwin"}
          matched_subs = set(asset_map.values())
          unmatched = []
          for name in names:
              if not (name.endswith(".tar.gz") or name.endswith(".zip")):
                  continue
              if any(sub in name for sub in matched_subs):
                  continue
              for plat in known_platforms:
                  plat_patterns = {
                      "x86_64-linux": ["x86_64-linux", "x86_64-unknown-linux", "linux-x64", "linux-x86_64", "x64-linux"],
                      "aarch64-linux": ["aarch64-linux", "aarch64-unknown-linux", "linux-arm64", "linux-aarch64", "arm64-linux"],
                      "x86_64-darwin": ["x86_64-darwin", "x86_64-apple-darwin", "darwin-x64", "darwin-x86_64", "macos-x64", "x64-darwin", "x64-macos"],
                      "aarch64-darwin": ["aarch64-darwin", "aarch64-apple-darwin", "darwin-arm64", "darwin-aarch64", "macos-arm64", "arm64-darwin", "arm64-macos"],
                  }
                  if any(p in name.lower() for p in plat_patterns[plat]):
                      if plat not in asset_map:
                          unmatched.append((plat, name))
                      break
          if unmatched:
              plats = ", ".join(f"{p} ({n})" for p, n in unmatched)
              raise SystemExit(
                  f"RELEASE ASSET COMPLETENESS CHECK FAILED: release {tag} has "
                  f"binary assets for platforms not in ASSET_MAP: {plats}. "
                  f"Add them to ASSET_MAP or the hash for those platforms will "
                  f"go stale while the URL gets the version bump. ASSET_MAP "
                  f"currently covers: {sorted(asset_map.keys())}")
          repo = os.environ["GITHUB_REPOSITORY"]
          src = open("flake.nix").read()
          src, n = re.subn(r'version = "[^"]*";', f'version = "{version}";', src, count=1)
          if n != 1:
              raise SystemExit('could not find version = "..." in flake.nix')
          for sys_, sub in asset_map.items():
              match = next((n for n in names if sub in n), None)
              if not match:
                  raise SystemExit(f"no asset for {sys_} ({sub}) in {tag}; have: {sorted(names)}")
              url = f"https://github.com/{repo}/releases/download/{tag}/{match}"
              out = json.loads(subprocess.check_output(
                  ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url]))
              sri = out["hash"]
              pat = re.compile(r'("' + re.escape(sys_) + r'" = \{[^}]*\})', re.S)
              def repl(m):
                  b = m.group(1)
                  b = re.sub(r'file = "[^"]*";', f'file = "{match}";', b, count=1)
                  b = re.sub(r'sha256 = "[^"]*";', f'sha256 = "{sri}";', b, count=1)
                  return b
              src, n = pat.subn(repl, src, count=1)
              if n != 1:
                  raise SystemExit(f"could not find assets block for {sys_} in flake.nix")
          open("flake.nix", "w").write(src)
          print(f"bumped flake.nix to {version}: {list(asset_map)}")
          PYEOF

      - name: Open PR
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          title: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          branch: chore/nix-flake-v{{{ printf "%s" "${{{ env.VERSION }}}" }}}
          base: master
          body: |
            Auto-generated by the `Update Nix flake` workflow on release publication.
            Bumps `version` and refreshes per-platform SRI hashes in `flake.nix` by
            prefetching the new release assets. No manual editing required.
```

**Customization notes (both templates):**
- `ASSET_MAP`: one `system|substring` per line. The substring must uniquely match the release asset filename for that system (e.g. `x86_64-unknown-linux-musl`). **Inspect the project's release assets to fill this in — it is the only project-specific input.** Sibling checksum files ending in `.sha256` are filtered out automatically, so a `foo.tar.gz` substring will not also match its `foo.tar.gz.sha256` companion (common with cargo-dist releases). **The ASSET_MAP MUST include every platform the project ships a binary asset for.** The script includes a reverse-check guard that fails the workflow if it detects binary assets (`.tar.gz`/`.zip`) for a platform not in ASSET_MAP — this prevents the omission class of bug where a platform's hash goes stale while its URL gets the version bump (see Archon PR #2131 feedback: omitting `x86_64-darwin` from ASSET_MAP broke Intel Macs with a hash mismatch that CI could not catch).
- `base: master`: change to `main` if the project's default branch is `main`.
- `if: github.repository == '<owner>/<repo>'` (Template A): prevents the scheduled job from running on forks. Replace with the upstream owner/repo.
- The script targets the `assets = { "<system>" = { file = ...; sha256 = ...; }; }` shape from the Prebuilt Tarball Flake template. For other flake shapes, adapt the regex.
- Hashes are written in SRI form (`sha256-...=`), which modern Nix accepts in the `sha256` field.
- `nix store prefetch-file` requires Nix >= 2.20; `cachix/install-nix-action@v31` installs a recent release.
- PRs opened by `GITHUB_TOKEN` (both templates) do not trigger downstream CI workflows. The diff is a version bump plus per-platform hash refresh with no source changes. **Review the diff before merging** — do not self-declare "safe to merge as-is" in the PR body. If CI on the bump PR is required, use a PAT for `peter-evans/create-pull-request` (but that reintroduces secret-management burden).
- To make it fully hands-off, add a final `gh pr merge --merge --auto` step (with `env: GH_TOKEN: ${{{ "{{" }}} secrets.GITHUB_TOKEN {{{ "}}" }}}`) or enable auto-merge on the branch via repository settings. **Only do this if the project explicitly accepts auto-merged hash bumps** — some maintainers consider unreviewed merges a security concern (Archon PR #2131 feedback cited the `contents: write` + `pull-requests: write` self-declared unreviewed-merge path as a declining reason).
- Pin actions to commit SHAs (with `# vX.Y.Z` comments) if the project's existing workflows do so — match the repo's convention.

**Hybrid fallback interaction (partial platform coverage):** When the flake uses the Hybrid Fallback Variant from `references/flake-templates/prebuilt-tarball.md` (`hybrid_fallback=true` from Step 12), the hash automation workflow only bumps hashes for platforms in `ASSET_MAP` — the platforms that have prebuilt release assets. The `#source` output on fallback platforms (platforms without a prebuilt binary) is NOT hash-automated: it builds from source at the git tag, so it tracks the commit, not release assets. This is correct and requires no special handling — the `ASSET_MAP` simply lists only the prebuilt platforms, and the reverse-check guard ensures no prebuilt platform is omitted. The `#source` outputs on fallback platforms are validated by the Nix CI workflow (`nix build .#source`), not by the hash automation. If a project later adds a prebuilt binary for a previously-missing platform, add that platform to `ASSET_MAP` and to the flake's `assets` attrset — the next hash automation run will populate its hash.

**CI blind spot — cross-platform hash validation:** `nix flake check --all-systems --no-build` evaluates every system's outputs without realising fetchurl derivations, so a fetch-hash mismatch is invisible at evaluation time. `nix build .#default` only runs on the runner's own system (typically `ubuntu-latest`), so it cannot catch a hash mismatch on `x86_64-darwin` or `aarch64-darwin`. The reverse-check guard in the hash automation script is the primary defense against omitted platforms. For projects that need stronger cross-platform validation, add a matrix build to `nix.yml` that runs `nix build .#default` on `macos-13` (Intel) and `macos-14` (ARM) in addition to `ubuntu-latest`. This catches hash mismatches and Darwin-specific build failures that `--all-systems --no-build` cannot see.

**How it addresses maintainer objections:** the maintainer cuts a release exactly as they do today; the workflow opens a PR with the bumped `flake.nix`. Reviewing a 5-line diff (version + 4 hashes) needs no Nix knowledge. Merge -> `nix run github:<owner>/<repo>` serves the new release. The scheduled variant (Template A) adds no PAT, no release-pipeline edits, and no per-release manual step of any kind.

**Verification (do this before opening the PR):** the automation workflow itself is not exercised by the PR's CI (it mutates `main` post-publish and runs on a schedule, not on push). Confirm it evaluates by triggering it manually on the PR branch:

```bash
# From the PR branch, after pushing:
gh workflow run "Update Nix flake" --ref <pr-branch-name>
# Then watch the run — it should report "flake.nix is up to date; nothing to do."
# (because the flake version already matches the latest release on the PR branch).
gh run watch
```

A clean "up to date, nothing to do" run proves the workflow's Nix install, GitHub API call, version comparison, and `ASSET_MAP` parsing all work. The actual hash-rewrite path is only exercised when a real new release outpaces the flake, but the manual run catches config/parse errors before merge. (This is the "can't be exercised by this PR's CI" gap that led nubjs/nub#169 to defer automation — the manual `workflow_dispatch` run closes it.)

**Skip if:** the project does not publish release tarballs (use a source-build flake instead), or already automates flake updates via another mechanism (e.g. `update-flake-lock` action).

---

## Cachix Integration (Binary Caching)

1. **Create a Cachix cache:** Visit https://cachix.org and create a new cache.

2. **Add Cachix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  cachix = {
    url = "github:cachix/cachix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

3. **Add CI workflow to push to Cachix** (`.github/workflows/cachix.yml`):

```yaml
name: Cachix

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      - uses: cachix/cachix-action@v12
        with:
          name: <your-cache-name>
          authToken: '${{{ "{{" }}} secrets.CACHIX_AUTH_TOKEN {{{ "}}" }}}'
```

4. **Add `CACHIX_AUTH_TOKEN` secret** to GitHub repository from https://cachix.org/api/token

**Skip if:** The project is small and build times are acceptable, or uses a different caching solution.

---

## Upstream Cache Consumption (nixConfig)

When a flake depends on other flakes (e.g., `bun2nix`, `rust-overlay`, `naersk`), those dependencies may have pre-built binaries in their own Cachix caches. Declare the upstream caches directly in `flake.nix` via `nixConfig` so that anyone using the flake automatically fetches pre-built artifacts instead of compiling downstream dependencies locally.

**Add `nixConfig` to `flake.nix`:**

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { self, nixpkgs, ... }: {
    # ...
  };
}
```

Key details:
- Uses `extra-substituters` (additive) not `substituters` (replacement) so user-configured caches are preserved
- `extra-trusted-public-keys` must match the substituter URLs — get keys from the upstream project's documentation or `cachix.org/<cache-name>`
- Requires the user to have `trusted-users` or `trusted-substituters` configured in their Nix settings, or to accept the flake's nix config on first use
- This is complementary to the Cachix Integration section above — that section covers pushing YOUR builds to a cache; this section covers consuming OTHERS' caches

**When to use:**
- The flake has inputs that publish to Cachix (e.g., `nix-community`, `rust-overlay`, `nixpkgs-wayland`)
- Build times are slow because downstream dependencies compile from source
- You want users to have a fast `nix run` / `nix build` experience without manual cache configuration

**Skip if:** The flake has no external flake inputs, or all inputs are already in the official `cache.nixos.org`.

---

## Input Follows for nixpkgs Deduplication

When a flake has multiple inputs that each depend on nixpkgs, each input will pin its own copy of nixpkgs by default. This causes:
- Duplicate nixpkgs evaluations (slower builds, more memory)
- Potential version mismatches between inputs
- Larger `flake.lock` files

Use `follows` to make all inputs use the same nixpkgs revision:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # These inputs will use the same nixpkgs as the main flake
  bun2nix = {
    url = "github:nix-community/bun2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  naersk = {
    url = "github:nix-community/naersk";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

**When to use:** Always, when inputs have a `nixpkgs` input. This is a best practice for all flakes with multiple inputs.

**Skip if:** An input deliberately pins a different nixpkgs version (rare — usually for compatibility testing).

---

## forAllSystems / perSystem Pattern (No flake-utils)

Instead of depending on `flake-utils` for multi-system support, use a lightweight `forAllSystems` / `perSystem` pattern. This eliminates an external dependency and gives full control over which systems are supported.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = lib.genAttrs supportedSystems;
    perSystem = forAllSystems (
      system: let
        pkgs = import nixpkgs { inherit system; };
        <pname> = pkgs.callPackage ./nix/package.nix { };
      in {
        packages = {
          inherit <pname>;
          default = <pname>;
        };
        devShells.default = pkgs.callPackage ./nix/devShell.nix { };
      }
    );
    systemOutput = name: lib.mapAttrs (_: value: value.${name}) perSystem;
  in {
    packages = systemOutput "packages";
    devShells = systemOutput "devShells";
  };
}
```

Key details:
- `supportedSystems` is explicit — only build for systems you actually support, not every possible system
- `perSystem` defines all per-system outputs in one block (packages, devShells, apps, checks)
- `systemOutput` extracts a named key from each system's attribute set into the top-level flake output
- `pkgs.callPackage` for devShell and package definitions enables clean separation into `./nix/` files
- No `flake-utils` input means one fewer entry in `flake.lock` and no dependency on an external maintainer

**When to use:**
- You want to minimize external flake inputs
- You need explicit control over supported systems (not all systems via `eachDefaultSystem`)
- The project has a modular `./nix/` directory structure

**Skip if:** The project already uses `flake-utils` and migration would add complexity, or `eachDefaultSystem` behavior (all systems) is desired.
