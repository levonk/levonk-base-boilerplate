---
type: Practice
title: Single-Container Multi-Process — supervisord when it pays
description: One process per container is a vibe, not a law. Use supervisord when a small app needs Nginx plus a backend and you're not at Kubernetes scale.
tags: [docker, supervisord, nginx, multi-process, process-management, kubernetes]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: supervisord
    resource: "http://supervisord.org/"
    title: "supervisord"
---

# Single-Container Multi-Process — supervisord when it pays

## Failure Mode

Splitting a small app (Python backend + Nginx frontend proxy) into two
containers with a sidecar network, because "one process per container" is
treated as an inviolable law. The operational complexity of two containers
exceeds the benefit for small deployments.

## Symptoms

- Two containers, one network, one compose file, one healthcheck per
  container — for an app that could be one process pair.
- "Complicated beast of a setup that needs five other engineers to just
  maintain."
- Small teams avoid containerizing small apps because the overhead feels
  disproportionate.

## Practice

> "One process per container is a vibe, not a law. If your app needs Nginx
> plus the application server, and you're not at Kubernetes scale, just use
> supervisor. The one-process dogma costs more complexity than it saves
> sometimes."

Use **[supervisord](http://supervisord.org/)** — a process control system /
watchdog — to run multiple processes under one controlling umbrella inside a
single container.

### When to use supervisord

- Small app needing Nginx (TLS, rate limiting, static assets) in front of a
  backend (Python, Node, Ruby).
- **Not** at Kubernetes scale — at k8s scale, split into separate pods.
- The alternative (two containers + sidecar network) costs more complexity
  than it saves.

### Pattern

```dockerfile
FROM python:3-slim
RUN apt-get update && apt-get install -y nginx supervisor
WORKDIR /app
COPY . .
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/app.conf
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
```

```ini
# supervisord.conf
[supervisord]
nodaemon=true

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true

[program:app]
command=gunicorn main:app --bind 127.0.0.1:8000
autostart=true
autorestart=true
```

### When NOT to use supervisord

- **Kubernetes scale**: split into separate pods — k8s handles process
  supervision, restarts, and networking natively.
- **Different scaling needs**: if Nginx and the backend scale independently,
  they must be separate containers.
- **Different update cadences**: if you update Nginx config weekly but the
  backend hourly, separate containers avoid rebuilding the whole image.

## Related

- [base-image-selection](/base-image-selection.md) — `slim` is the right base
  for a supervisord image (needs apt for nginx + supervisor).
