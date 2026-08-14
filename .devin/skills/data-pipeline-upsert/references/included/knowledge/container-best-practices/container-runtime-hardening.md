---
type: Practice
title: Container Runtime Hardening — least privilege at run time
description: Run containers as non-root, read-only, with all capabilities dropped and no-new-privileges set; layer resource limits, seccomp, and MAC on top.
tags: [docker, security, hardening, cap-drop, read-only, non-root, no-new-privileges, seccomp, user-namespaces, resource-limits]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: cis-docker-benchmark-v1-7-0
    resource: "https://www.cisecurity.org/benchmark/docker"
    title: "CIS Docker Benchmark v1.7.0"
  - id: docker-engine-security-isolate-containers-with-a-user-namespace
    resource: "https://docs.docker.com/engine/security/userns-remap/"
    title: "Docker Engine security — Isolate containers with a user namespace"
  - id: docker-engine-security-seccomp-profiles
    resource: "https://docs.docker.com/engine/security/seccomp/"
    title: "Docker Engine security — Seccomp profiles"
  - id: docker-engine-security-apparmor-profiles
    resource: "https://docs.docker.com/engine/security/apparmor/"
    title: "Docker Engine security — AppArmor profiles"
  - id: nist-sp-800-190-application-container-security-guide
    resource: "https://nvlpubs.nist.gov/nistpubs/specialpublications/nist.sp.800-190.pdf"
    title: "NIST SP 800-190 — Application Container Security Guide"
  - id: job-aide-docker-and-container-hardening-section
    resource: ".devin/rules/codeguard-0-devops-ci-cd-containers.md"
    title: "job-aide (Docker and container hardening section)"
---

# Container Runtime Hardening — least privilege at run time

## Failure Mode

Running containers with the default runtime profile: root user, writable root
filesystem, full default capability set, no privilege-escalation guard. A
single container-escape CVE (runc, containerd, kernel) becomes a full host
compromise because the process is already UID 0, holds capabilities like
`CAP_SYS_ADMIN`, and can write to its own filesystem to persist payloads. If a
host directory is bind-mounted in, root in the container is root on that path.

## Symptoms

- `docker inspect` shows `"User": ""` (root) and `"CapDrop": null`; `docker-bench-security` / kube-bench flag CIS 5.3, 5.10, 5.11, 5.12 as non-compliant.
- A compromised container drops a payload into `/usr/local/bin/` that survives a restart — the filesystem is writable.
- A setuid binary grants elevated capabilities because `no-new-privileges` was never set.
- One runaway container OOM-kills the host or starves neighbors — no `--memory` / `--cpus` / `--pids-limit` bound.

## Practice

Apply the four high-impact layers first — they stop the majority of container-escape and privilege-escalation paths — then layer defense-in-depth.

### 1. Non-root user

Set `USER` in the Dockerfile so the image is non-root by default; override at
run time with `--user`. A container escape gives the attacker a root-equivalent
process on the host syscall surface; with a bind-mounted host directory,
root-in-container is root on that path. Distroless images (see
[base-image-selection](/base-image-selection.md)) ship a preconfigured `nonroot`
user with no shell, making this trivial:

```dockerfile
FROM node:22-slim
RUN groupadd -r app && useradd -r -g app app
USER app
```

### 2. Read-only root filesystem

`--read-only` makes the container root immutable — an attacker with RCE cannot
drop a payload into `/usr/local/bin/` or modify binaries. Pair with
`--tmpfs /tmp:rw,noexec,nosuid,nodev` for scratch space; `noexec` prevents even
`/tmp` from running binaries (CIS 5.10).

### 3. Drop all capabilities, add back only what's needed

Docker's default grants a small set of capabilities (`CAP_NET_RAW`, etc.).
Dropping **all** and adding back only what the app needs (e.g.
`NET_BIND_SERVICE` for port 443) is CIS 5.3. Never use `--privileged` — it
grants every capability, disables seccomp/AppArmor, and exposes all devices.

### 4. No new privileges

`--security-opt no-new-privileges:true` sets `PR_SET_NO_NEW_PRIVS` so a setuid
binary inside can no longer grant elevated capabilities — the child inherits
the parent's privilege set and no more (CIS 2.14).

### Full hardened `docker run` example

```bash
docker run --rm --user 10001:10001 --read-only --tmpfs /tmp:rw,noexec,nosuid,nodev \
  --cap-drop ALL --cap-add NET_BIND_SERVICE --security-opt no-new-privileges:true \
  --security-opt seccomp=/etc/docker/seccomp-profile.json --security-opt apparmor=docker-default \
  --memory 512m --cpus 1.0 --pids-limit 100 --network internal \
  myapp@sha256:<digest>
```

### docker-compose equivalent

```yaml
services:
  app:
    image: myapp@sha256:<digest>
    user: "10001:10001"
    read_only: true
    tmpfs: ["/tmp:rw,noexec,nosuid,nodev"]
    cap_drop: [ALL]
    cap_add: [NET_BIND_SERVICE]
    security_opt: [no-new-privileges:true, seccomp:/etc/docker/seccomp-profile.json, apparmor=docker-default]
    mem_limit: 512m
    cpus: 1.0
    pids_limit: 100
    networks: [internal]
networks: { internal: { internal: true } }
```

### Defense-in-depth layers

| Layer | Flag / setting | What it stops |
|-------|----------------|---------------|
| User namespaces | `--userns-remap=default` (daemon) | Container root maps to unprivileged host UID; escape lands as nobody |
| Resource limits | `--memory`, `--cpus`, `--pids-limit` | Fork bombs, memory-exhaustion DoS vs host and neighbors |
| Network isolation | `--network none` / internal networks | Lateral movement, exfiltration; `none` for offline batch jobs |
| Seccomp | `--security-opt seccomp=profile.json` | Blocks ~44 syscalls by default; custom profiles block more |
| AppArmor / SELinux | `--security-opt apparmor=...` | MAC on top of DAC; confines even a root-in-container process |

User namespaces (`--userns-remap`) are the strongest control after non-root: even if the container runs as UID 0 *inside*, it maps to an unprivileged host UID, so an escape lands as nobody. Enable via `/etc/docker/daemon.json` (best on a fresh install, since it re-maps `/var/lib/docker/` ownership).

### Never mount the Docker socket

Mounting `/var/run/docker.sock` gives the container full control of the Docker
daemon — equivalent to host root access. This is a hard prohibition in both
`docker run` and `docker-compose`:

```bash
# FORBIDDEN — gives container full Docker daemon control
docker run -v /var/run/docker.sock:/var/run/docker.sock myimage
```

```yaml
# FORBIDDEN — same risk in compose
volumes:
  - "/var/run/docker.sock:/var/run/docker.sock"
```

If a container needs to interact with Docker, use a socket proxy (e.g.
`tecnativa/docker-socket-proxy`) that filters the allowed API endpoints.

### Do not enable TCP Docker daemon without TLS

```bash
# FORBIDDEN — unauthenticated remote Docker access
dockerd -H tcp://0.0.0.0:2375
```

Only enable the TCP daemon socket with TLS mutual authentication (`--tlsverify`,
`--tlscacert`, `--tlscert`, `--tlskey`).

### Image scanning

Scan images on build and on admission. Block high-severity vulnerabilities from
entering production. Tools: Trivy, Grype, Snyk. Integrate into CI so that a
failing scan breaks the build.

### Secret management

- Use Docker/Kubernetes secrets — never in layers or environment variables.
- Mount secrets at runtime; see
  [hardcoded-credentials-detection](../devsecops-codeguard/hardcoded-credentials-detection.md)
  for source-code credential detection patterns.
- For build-time secrets, use BuildKit `--mount=type=secret` — see
  [buildkit-secrets](/buildkit-secrets.md).

## Implementation Checklist

- [ ] Non-root `USER` set in Dockerfile
- [ ] `--security-opt=no-new-privileges` applied
- [ ] `--cap-drop all` applied (add back only what's needed)
- [ ] No `--privileged` flag
- [ ] No `/var/run/docker.sock` mounts
- [ ] Read-only root filesystem with `tmpfs` for writable dirs
- [ ] Resource limits (CPU/memory/pids) set
- [ ] Custom networks, no host network
- [ ] Minimal base image, pinned with tag + digest
- [ ] `HEALTHCHECK` defined
- [ ] No secrets in layers or environment variables
- [ ] Images scanned in CI and on admission

## Related

- [base-image-selection](/base-image-selection.md) — distroless images ship no shell and a preconfigured `nonroot` user, reducing runtime attack surface.
- [multi-stage-builds](/multi-stage-builds.md) — smaller images carry fewer setuid binaries and capabilities to abuse.
- [pin-image-digests](/pin-image-digests.md) — supply-chain integrity complements runtime hardening; a hardened runtime still runs attacker code if the image is tampered.
- [buildkit-secrets](/buildkit-secrets.md) — build-time secret mounts that prevent credentials from baking into image layers.
- [nodejs-in-containers](/nodejs-in-containers.md) — Node.js-specific production hardening (npm ci, NODE_ENV, dumb-init, multi-stage).
