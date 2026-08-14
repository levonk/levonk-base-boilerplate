# Tooling Alignment

Ensure devbox.json, Justfile, CI, Dockerfile, and deployment tools all
reference the same tool versions from a single source of truth. Misalignment
causes "works on my machine" failures and non-reproducible builds.

## Single Source of Truth Pattern

`devbox.json` is the authority for tool versions. CI, Dockerfile, and Justfile
read from it rather than hardcoding versions.

```json
{
  "packages": {
    "go": "1.22.0", "just": "1.36.0", "jq": "1.7.1",
    "act": "0.2.62", "trivy": "0.50.0", "gitleaks": "8.18.0"
  }
}
```

```yaml
# CI uses devbox-install-action, which reads devbox.json
- uses: jetify-com/devbox-install-action@v0
  with: { enable-cache: true, devbox-path: devbox.json }
```

## Version Pinning Strategies

| Strategy | Example | Reproducibility | Notes |
|----------|---------|-----------------|-------|
| Exact version | `go: 1.22.0` | Full | Best for production |
| Minor range | `go: 1.22.x` | Partial | Allows patch updates |
| `:latest` | `go: latest` | None | Never use in CI |
| Lock file | `devbox.lock` | Full | Pins exact hashes |

Always pin to specific versions. Use lock files (`devbox.lock`,
`package-lock.json`, `go.sum`) for full reproducibility.## Tool Version Files

| File | Tool | Read by |
|------|------|---------|
| `.nvmrc` | Node.js | `actions/setup-node`, `nvm` |
| `.python-version` | Python | `actions/setup-python`, `pyenv` |
| `rust-toolchain.toml` | Rust | `rustup`, `dtolnay/rust-toolchain` |
| `go.mod` | Go | `actions/setup-go` with `go-version-file` |
| `devbox.json` | All tools | `devbox-install-action` |

```yaml
# CI reads from version files, not hardcoded versions
- uses: actions/setup-go@v5
  with:
    go-version-file: go.mod
- uses: actions/setup-node@v4
  with:
    node-version-file: .nvmrc
- uses: actions/setup-python@v5
  with:
    python-version-file: .python-version
```

## Justfile as Universal Task Runner

Justfile commands work identically locally and in CI. No duplicate logic.

```just
# justfile
test:
    go test ./...

build:
    go build -o bin/app ./cmd/app

lint:
    golangci-lint run

scan:
    trivy fs . && gitleaks detect
```

```yaml
# CI calls the same commands
- run: just test
- run: just build
- run: just scan
```

## Alignment Audit Checklist

| Check | Question |
|-------|----------|
| Go version | Does CI use same Go as `devbox.json`? |
| Node version | Does Dockerfile use same Node as `.nvmrc`? |
| Python version | Does CI use `.python-version` file? |
| Rust toolchain | Does CI use `rust-toolchain.toml`? |
| Justfile | Do CI commands match local `just` commands? |
| Lock files | Are `devbox.lock`, `go.sum`, `package-lock.json` committed? |
| CI tools | Are `act`, `trivy`, `gitleaks` in `devbox.json` for local testing? |

## Concrete Alignment Audit Example

```bash
# Extract Go version from devbox.json
DEVBOX_GO=$(jq -r '.packages.go' devbox.json)

# Extract Go version from CI workflow
CI_GO=$(grep -oP 'go-version:\s*\K[0-9.]+' .github/workflows/ci.yml)

# Extract Go version from Dockerfile
DOCKER_GO=$(grep -oP 'FROM golang:\K[0-9.]+' Dockerfile)

echo "devbox: $DEVBOX_GO | CI: $CI_GO | Docker: $DOCKER_GO"
if [ "$DEVBOX_GO" != "$CI_GO" ] || [ "$DEVBOX_GO" != "$DOCKER_GO" ]; then
  echo "MISALIGNMENT DETECTED — versions differ"
  exit 1
fi
echo "All Go versions aligned"
```

## Adding CI Tools to devbox.json

Add `act`, `trivy`, `gitleaks` to devbox.json so developers can run CI checks
locally before pushing.

```json
{
  "packages": {
    "act":      "0.2.62",
    "trivy":    "0.50.0",
    "gitleaks": "8.18.0"
  }
}
```

```bash
# Run GitHub Actions locally
devbox run -- act -j test

# Scan locally before CI catches it
devbox run -- trivy fs .
devbox run -- gitleaks detect
```

## Devbox PATH in Containers

After `devbox install` runs inside a Docker build, the tools are installed to
`.devbox/nix/profile/default/bin/` — which is **NOT** on `PATH` by default.
Subsequent `RUN` steps (and the final image's shell) won't find `just`, `go`,
or any other devbox-managed tool unless you export the path explicitly:

```dockerfile
RUN echo 'export PATH="/path/to/.devbox/nix/profile/default/bin:$PATH"' >> /root/.bashrc \
    && echo 'export PATH="/path/to/.devbox/nix/profile/default/bin:$PATH"' >> /etc/profile.d/devbox.sh
```

For non-interactive `RUN` steps, prefix each command with the full path or
`source /etc/profile.d/devbox.sh` first.

## Task Runner Unwrapping

When moving from `devbox run --` to direct commands inside a pre-built
container, the task runner (Justfile, Makefile) recipes themselves may still
call `devbox run` internally. This is a two-layer problem: (1) the workflow
removes `devbox run --` wrappers, (2) but the Justfile recipes themselves call
`devbox run` which makes network calls to ensure packages.

```makefile
# Bad — calls devbox run which makes network calls even when tools are on PATH
test:
    devbox run test

# Good — calls the implementation recipe directly, works with or without devbox
test:
    just test_impl
```

The `devbox run` wrapper is only needed when devbox isn't already active. Inside
the container, tools are on PATH — the wrapper is pure overhead and can fail on
network calls. Justfile recipes should call their `_impl` variants directly,
not through `devbox run`.

## Local CI Testing with act

`act` is the primary tool for testing GitHub Actions workflows locally before
pushing. Docker socket setup: act needs access to the Docker daemon. On macOS
with OrbStack, set `DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock`. On
Linux, default `/var/run/docker.sock` works.

- Use `--pull=false` to use local images instead of pulling from registry
  (essential when testing a locally-built CI image)
- Use `--reuse` to keep containers alive between runs for faster iteration
- Use `--container-architecture linux/amd64` on Apple Silicon to match CI runners
- Secret file: act's `--secret-file` only handles single-line `KEY=value` —
  base64-encode multi-line secrets (see prebuilt-images.md — Secret Format
  Differences)

```bash
act -W .github/workflows/build.yml \
    --secret-file secrets.txt \
    --container-architecture linux/amd64 \
    --pull=false \
    --reuse
```

## Container File Ownership

When act mounts host directories into containers, file ownership can mismatch
(host user UID vs container root). Build artifacts created inside the container
may be owned by root, causing permission errors on the host.

Fix: run `sudo chown -R $(id -u):$(id -g) build/ bin/` after act runs, or use
the `--user` container option. On macOS with OrbStack, this is handled
automatically — Linux users may need the chown fix.

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| devbox.json | Single source of truth for tool versions | Nix-based, reproducible |
| devbox-install-action | Install devbox in CI | `enable-cache: true` for speed |
| Justfile | Universal task runner | Works locally and in CI |
| jq | Audit version alignment | Parse JSON config files |
| act | Run GitHub Actions locally | Test CI before pushing |
