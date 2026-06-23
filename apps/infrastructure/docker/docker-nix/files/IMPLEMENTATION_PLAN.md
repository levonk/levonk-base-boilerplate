# Implementation Plan: Nix-based Docker Boilerplate (Prod/Debug Variants)

## Goal

Create a `copier` based boilerplate for generating Nix-based Docker images that supports two variants:

1.  **Production (Default)**: A minimal, "distroless"-style image containing _only_ the application and its runtime closure.
2.  **Debug**: The exact same application layer, but with an additional layer containing interactive tools (zsh, curl, coreutils, procps, ps, strace, htop, ntop, lsof, tee, strings, vim, etc.) for troubleshooting.

## Rationale

Running barebones containers is secure and efficient but difficult to debug. By using Nix's `buildLayeredImage`, we can ensure the `prod` and `debug` images share the exact same application binary and library paths. The `debug` image simply mounts tools _around_ the existing application, minimizing the risk of "it works in debug but fails in prod" scenarios.

## Architecture

### 1. `flake.nix` (The Core)

We will use a `flake.nix` to define the build outputs.

- **Input**: `nixpkgs`.
- **Output**:
  - `packages.x86_64-linux.default`: The application derivation.
  - `packages.x86_64-linux.docker-prod`: The minimal image (named `{{ _service_name_slug }}`).
  - `packages.x86_64-linux.docker-debug`: The debug image (named `{{ _service_name_slug }}-debug`).

### 2. Image Composition (`dockerTools.buildLayeredImage`)

- **Naming**: The `name` and `tag` attributes of the image will be dynamically set using the `_service_name_slug` variable from Copier.
- **Base Layer**: Common to both. Contains the application binary.
- **Prod Image**:
  - `config.Cmd`: Entrypoint to the app.
  - `contents`: Only the app derivation.
- **Debug Image**:
  - `contents`: App derivation + `[ zsh curl coreutils procps ps strace htop ntop lsof tee binutils vim ]`.
  - `config.Env`: Sets `PATH` to include these tools.

## File Structure Changes

### Rename/Cleanup

- [x] Rename `prototype-boilerplate` to `docker-nix`.
- [ ] Adapt `healthcheck/` and `scripts/` for Nix (ensure scripts are compatible with the minimal environment).

### New Files

- `flake.nix.jinja2`: The Nix definition template.
- `docker-compose.yml.jinja2`: Docker Compose configuration (parity with `docker-linux`).
- `Makefile.jinja2`: Build commands (build, up, down, logs, health-check, test, lint, clean).

### Modified Files

- `copier.yml`:
  - Remove `base_os` (implied Nix).
  - Add `nix_system` (e.g., `x86_64-linux`, `aarch64-linux`).
  - match missing devux components like docker-compose.yml from /home/micro/p/gh/lrepo52/job-aide/boilerplate/apps/infrastructure/docker/docker-linux
  - encode build, up, down, logs, health-check, test, lint, clean targets into Makefile
- `README.md.jinja2`: Explain the Prod/Debug workflow.

## Workflow

### User Experience

1.  **Generate**: `copier copy ...`
2.  **Build Prod**: `nix build .#docker-prod` (or `make build`)
    - Result: `result` symlink to a Docker tarball.
    - Load: `docker load < result`
3.  **Build Debug**: `nix build .#docker-debug` (or `make debug`)
    - Result: Docker tarball with shell access.
4.  **Run**: `docker run ...`

## Step-by-Step Execution

1.  **Clean**: Remove old Debian artifacts from `docker-nix`.
2.  **Scaffold**: Create `flake.nix.jinja2` with the dual-image logic.
3.  **Config**: Update `copier.yml` for Nix inputs.
4.  **Docs**: Update `README.md` to document the "Twist" (Prod vs Debug).
5.  **Verify**: Test the generation of both images.
