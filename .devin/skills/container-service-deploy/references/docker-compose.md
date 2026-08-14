# Branch A — docker-compose for Local Development & Isolated Testing

## When to Use

- Local development environments
- Isolated testing of a single service or small service group
- Single-host dev environments where orchestration is unnecessary
- Prototyping and iterative development

## When NOT to Use

- Production deployments across multiple hosts — use **Branch B (Ansible)** instead
- Environments requiring centralized secrets management — use Ansible + Vault
- Multi-host orchestration with rolling updates — use Ansible

## File Structure Convention

Every service follows this layout (generalized; do not hardcode service-specific names):

```
service-name/
├── .env.example
├── .dockerignore
├── docker-compose.yml
├── Makefile
├── README.md
├── assets/
│   └── entrypoint.sh
├── docker/
│   └── Dockerfile
├── healthcheck/
│   ├── healthcheck-internal-{service}.sh
│   └── healthcheck-external-{service}.sh
├── mounts/
│   ├── static.conf
│   └── templates/
│       └── dynamic.conf.template
└── tests/
    └── test-service.sh
```

## YAML Formatting

- All YAML files **must** start with `---`
- **Never** use the deprecated top-level `version:` key — modern docker compose ignores it and it triggers lint warnings

```yaml
---
services:
  service-name:
    # ...
```

## Environment Variable Naming

Follow the structured naming convention:

```
{CATEGORY}_{SERVICE}_{SUB}_{HOST|CONTAINER}_{PORT|IP}
```

Examples:

- `DNS_DNSCRYPT_ODOH_CONTAINER_PORT`
- `PROXY_TOR_MAIN_CONTAINER_IP`
- `WEB_NGINX_MAIN_HOST_PORT`

## Standard Config Variables

Define these in `.env.example` with sensible defaults:

| Variable | Default | Purpose |
|----------|---------|---------|
| `PUID`   | `1000`  | Run-as user ID |
| `PGID`   | `1000`  | Run-as group ID |
| `TZ`     | `UTC`   | Container timezone |

## Logging

Use a shared logging anchor so all services inherit the same rotation policy:

```yaml
---
x-logging: &logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

services:
  service-name:
    logging: *logging
```

## Makefile Targets

Every service `Makefile` should expose these targets:

| Target | Purpose |
|--------|---------|
| `build` | Build images |
| `up` | Start services (detached) |
| `down` | Stop and remove containers |
| `restart` | Restart services |
| `health-check` | Run health checks |
| `test` | Run automated tests from `tests/` |
| `lint` | Lint Dockerfile and compose |
| `security-scan` | Run container security scanner |
| `logs` | Tail service logs |
| `shell` | Exec shell into running container |
| `status` | Show container status |
| `clean` | Remove images, volumes, orphans |

## Security Hardening

Apply to every service:

- Run as **non-root** user (set `user:` or use PUID/PGID)
- `security_opt: ["no-new-privileges:true"]`
- `cap_drop: ["ALL"]` — add only capabilities the service actually needs
- **Never** mount `docker.sock`
- Use **read-only root filesystem** (`read_only: true`) where possible; mount writable volumes only where needed
- Define **custom networks** explicitly — never use the default bridge for production-like isolation
- **No host networking** (`network_mode: host`) — always use bridge or custom networks

```yaml
---
services:
  service-name:
    image: service-name:latest
    read_only: true
    user: "${PUID}:${PGID}"
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    networks:
      - service-net

networks:
  service-net:
    driver: bridge
```

## Health Checks

Every service **must** include a `HEALTHCHECK` (in the Dockerfile) and/or `healthcheck:` in compose:

```yaml
    healthcheck:
      test: ["CMD", "sh", "/healthcheck/healthcheck-internal-service.sh"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

## Documentation

- Every service **MUST** have a `README.md` describing purpose, configuration, and usage
- Document all environment variables from `.env.example`

## Testing

- Automated tests live in `tests/`
- Executable via `make test`
- Tests should validate service startup, health, and basic functionality

## Shell Scripts

All shell scripts (entrypoint, healthchecks, tests) must include:

```bash
#!/usr/bin/env bash
# shellcheck shell=bash
set -e -u -o pipefail
```
