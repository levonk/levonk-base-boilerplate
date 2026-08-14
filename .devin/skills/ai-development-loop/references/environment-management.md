# Environment Management Integration

The development loop automatically detects and integrates with your preferred environment management system:

**Supported Environments:**
- **Devbox**: Detected via `devbox.json` file (preferred)
- **Mise**: Detected via `mise.toml`, `.mise.toml`, or `.tool-versions` file
- **Nix**: Detected via `flake.nix` file
- **Native**: Fallback for projects without environment managers

**Preferred Environment Warning:**
The system will warn when Devbox is not detected, as it's the preferred environment for optimal experience:

```bash
⚠️  Preferred environment is Devbox, but detected: mise
Consider using Devbox for optimal experience:
  - Create devbox.json: devbox init
  - Add packages: devbox add rust cargo just
  - Run commands: devbox run -- <command>
```

**Environment-Aware Execution:**
All commands are automatically wrapped with the appropriate environment manager:

```bash
# The script detects the environment and wraps commands appropriately
./scripts/dev-loop-helper.sh loop     # Uses devbox/mise/nix automatically
./scripts/dev-loop-helper.sh smart-loop  # Language-aware + environment-aware
```

**Command Examples by Environment:**
```bash
# Devbox projects (preferred — just auto-detects devbox via _devbox helper)
just test
just build
direnv exec just test
direnv exec npm test

# Devbox projects (recommended — just auto-detects devbox)
just test
just build

# Mise projects (with warning)
mise exec -- just test
mise exec -- npm test

# Nix projects (with warning)
nix develop --command just test
nix develop --command cargo build

# Poetry projects (Python, with warning)
poetry run pytest
poetry install

# Docker Compose projects (with warning)
docker compose up
docker compose exec app npm test

# Native projects (with warning)
just test
cargo build
```

### Directory-Based Activation
**Direnv** automatically activates environments when you `cd` into directories containing `.envrc` or `.env` files, making it ideal for per-project configuration without manual activation commands. The security scan runs once per configuration hash, ensuring both safety and performance.
