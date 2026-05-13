# Paperclip Docker Boilerplate

Generates a Docker-based deployment of [Paperclip](https://github.com/paperclipai/paperclip), an open-source orchestration platform for autonomous AI companies.

## Usage

Generate a new Paperclip deployment:

```bash
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  apps/infrastructure/docker/paperclip \
  /path/to/paperclip-deployment \
  --defaults
```

Or customize the configuration:

```bash
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  apps/infrastructure/docker/paperclip \
  /path/to/paperclip-deployment \
  --data base_os=alpine \
  --data service_port=3100 \
  --data include_postgres=true
```

## Template Inputs

- `project_name`: Project name (kebab-case, default: "paperclip")
- `service_name`: Service name for container names (default: "paperclip")
- `service_description`: Brief description (default: "Open-source orchestration for zero-human companies")
- `base_os`: Base OS - alpine or debian (default: alpine)
- `node_version`: Node.js version, paperclip requires 20+ (default: "20")
- `pnpm_version`: pnpm version, paperclip requires 9.15+ (default: "9.15.0")
- `service_port`: Port for Paperclip API (default: "3100")
- `postgres_port`: Port for PostgreSQL (default: "5432")
- `postgres_version`: PostgreSQL version (default: "15")
- `include_postgres`: Include PostgreSQL container (default: true)
- `include_dev_tools`: Include dev tools like curl, git, vim (default: false)

## Generated Files

- `Dockerfile`: Multi-stage Dockerfile for Paperclip
- `docker-compose.yml`: Docker Compose configuration with optional PostgreSQL
- `README.md`: Project documentation
- `.dockerignore`: Docker ignore patterns
- `.envrc`: Direnv configuration
- `.env.example`: Environment variable template

## Requirements

- Docker
- Docker Compose
- Node.js 20+ (for local development)
- pnpm 9.15+ (for local development)

## Quick Start After Generation

```bash
cd /path/to/paperclip-deployment
docker-compose up -d
```

Access Paperclip at http://localhost:3100

## Notes

- The template uses Alpine Linux by default for smaller image size
- PostgreSQL is included by default but can be disabled
- The container runs as a non-root user for security
- Health checks are configured for the Paperclip API

## References

- [Paperclip GitHub](https://github.com/paperclipai/paperclip)
- [Paperclip Documentation](https://github.com/paperclipai/paperclip/blob/master/doc/DEVELOPING.md)
