# DevContainer Agent Standards & Architecture

This document defines the architectural standards and patterns for the "Self-Configuring Development Environment" (SCDE) used in this boilerplate.

## 1. Generic Identity (The `developer` Standard)

To remain tool-agnostic and avoid vendor lock-in (e.g., `vscode`, `node`), we standardise on a generic non-root identity:

- **Username**: `developer`
- **User ID (UID)**: `1000` (mapped to host for volume permission consistency)
- **Home Directory**: `/home/developer`
- **Standard Project Root**: `/home/developer/project`

**Rationale**: Ensures consistency across different IDEs (VS Code, Cursor, Zed) and CLI-only environments.

## 2. Service-Specific Directory Structure

The `.devcontainer` directory is modularised by service to avoid root-level clutter:

```text
.devcontainer/
├── services/
│   ├── app/              # Main development container
│   │   ├── Dockerfile
│   │   ├── devbox.json
│   │   ├── entrypoint.sh
│   │   ├── nix.conf
│   │   └── healthcheck/
│   ├── nix-sidecar/      # Nix store & substituter manager
│   │   ├── Dockerfile
│   │   └── healthcheck/
│   └── pnpm-sidecar/     # PNPM global store manager
│       ├── Dockerfile
│       └── healthcheck/
├── devcontainer.json     # Orchestration entrypoint
└── docker-compose.yml    # Multi-container orchestration
```

## 3. Self-Configuring Development Environment (SCDE)

The environment is designed to be fully operational with zero manual configuration after `docker compose up`.

### Idempotent Entrypoint
The `entrypoint.sh` in the `app` service handles initialization logic with the following guarantees:
- **Marker-Based**: Uses `~/.cache/.container_initialized` to prevent heavy setup on container restart.
- **Environment Awareness**: Detects if Nix is already sourced or needs initialization.
- **Clean Execution**: Uses non-polluting functions and `local` variables to prevent side-effects in the final shell.

### Declarative Manifest Injection
Standard tools and configurations are injected programmatically using `jq` during the first run:
- **`package.json`**: Ensures mandatory `devDependencies` (e.g., `openskills`) and standard scripts (`build`, `lint`, `test`) exist.
- **`devbox.json`**: Ensures essential Nix packages (e.g., `zellij`, `jq`, `pnpm`) are registered.
- **`devcontainer.json`**: Automatically registers mandatory IDE extensions.

## 4. Sidecar Architecture

We use a "Store-Sidecar" pattern to isolate persistent package registries:

- **Nix Sidecar**: Manages the `/nix` store volume. The `app` container mounts this volume to access shared Nix packages.
- **PNPM Sidecar**: Manages the `shared-pnpm-store` volume.
- **Persistence**: Both sidecars use `restart: unless-stopped` and `command: sleep infinity` to ensure the volumes remain available and permissions stay consistent.

## 5. Healthcheck & Integrity Verification

Healthchecks move beyond simple file existence to verify tool functionality and store integrity:

- **Nix**: Uses `nix-store --verify` and `nix flake --version`.
- **PNPM**: Uses `pnpm store status` to verify repository consistency.
- **App**: Performs its own internal marker check + `devbox run -- pnpm store status` to ensure full connectivity.
- **Healthy Dependencies**: The `app` service uses `condition: service_healthy` in its `depends_on` block to ensure sidecars are operational before initialization begins.

## 6. Async Validation & Background Workflows

To provide an immediate responsive shell while ensuring project correctness:

- **Background Zellij**: Heavy first-run tasks (install, build, test) are spawned in a detached Zellij session named `validation`.
- **Visibility**: Users can attach to the progress at any time via `zellij attach validation`, but the shell remains usable immediately.

## 7. Environment Hygiene

- **Standard Variables**: All services include `PUID`, `PGID`, and `TZ`.
- **Isolated Shell**: Commands should always be wrapped in `devbox run --` to ensure they use the project-defined toolchain rather than system defaults.
- **Explicit Store Paths**: PNPM is explicitly configured to use the mounted volume at `${HOME}/.pnpm-store`.
