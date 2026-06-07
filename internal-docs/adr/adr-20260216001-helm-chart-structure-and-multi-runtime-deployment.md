---
modeline: "vim: set ft=markdown:"
title: "ADR: Helm Chart Structure and Multi-Runtime Deployment"
adr-id: "20260216001"
slug: "20260216001-helm-chart-structure-and-multi-runtime-deployment"
url: "/internal-docs/adr/adr-20260216001-helm-chart-structure-and-multi-runtime-deployment.md"
synopsis: "Establishes a canonical Helm chart directory layout, DAG-based layering model, and conventions for rendering deployments across Kubernetes, k3s, and Docker Compose runtimes from a single source of truth."
author: "https://github.com/levonk"
date-created: "2026-02-16"
date-updated: "2026-02-16"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "helm", "kubernetes", "docker-compose", "deployment", "devops", "multi-runtime"]
supersedes: []
superseded-by: []
related-to:
  [
    "adr-20251106012-containerization-strategy",
    "adr-20251106014-cicd-strategy",
    "adr-20251218002-docker-service-standards",
    "adr-20251218001-container-isolation-and-docker-socket-hardening",
    "adr-20260109001-nix-container-architecture",
  ]
scope:
  impact-scope: ["deploy/", "apps/active/devops/", "CI/CD pipelines", "all deployable services"]
  excluded-scope: ["boilerplate templates (covered by their own ADRs)", "IaC provisioning (covered by Pulumi ADR)"]
---

# Decision Record: Helm Chart Structure and Multi-Runtime Deployment

- belongs in `internal-docs/adr/adr-20260216001-helm-chart-structure-and-multi-runtime-deployment.md`

---

## Context

The monorepo already adopts Docker for containerization, Docker Compose for local orchestration, and Kubernetes with Helm for production (ADR 20251106012). However, no standard exists for:

- **Chart directory layout** — where charts live, how files are named, and what goes in each directory.
- **Environment layering** — how dev, homelab (Proxmox/k3s), and cloud overrides are separated from defaults.
- **Multi-runtime rendering** — how a single Helm chart can produce both Kubernetes manifests and Docker Compose files without duplication or drift.

Without these conventions, each service invents its own structure, leading to Helm sprawl, environment-specific logic leaking into templates, and divergence between local and production deployments.

## Constraints

- Must work across the full deployment spectrum: local dev → Proxmox homelab (k3s) → cloud (GCP/AWS).
- Must integrate with existing CI/CD (GitHub Actions, ADR 20251106014) and IaC (Pulumi, ADR 20251106003).
- Must comply with container security standards (ADR 20251218001, ADR 20260106001).
- Must not require Helm-specific tooling beyond `helm` CLI and standard POSIX tools.
- Charts must be self-contained — no global values, no cross-chart implicit dependencies.

## Decision

Adopt a **canonical Helm chart structure** with a **DAG-based layering model** and **five governing conventions** for all deployable services in the monorepo.

## Rationale

- **Single source of truth**: One `values.yaml` defines the canonical configuration; environment overlays modify only what differs.
- **Zero drift**: Rendering to Docker Compose from the same chart eliminates the "works locally, breaks in prod" class of bugs.
- **Predictability**: Dumb templates + explicit overlays = no surprises. Environment logic never lives in Go templates.
- **Scalability**: The structure works identically whether the repo has 1 service or 50.
- **Alignment**: Extends the existing containerization strategy (ADR 20251106012) with the missing "how" for Helm.

## Technical Approach

### 1. Directory Layout

All deployment charts live under `deploy/charts/` at the repo root:

```text
deploy/
  charts/
    <service-name>/
      Chart.yaml
      values.yaml                # Defaults — safe, minimal, environment-agnostic
      values.dev.yaml            # Local development overrides
      values.proxmox.yaml        # Homelab / k3s cluster overrides
      values.cloud.yaml          # Cloud provider overrides
      values.compose.yaml        # Docker Compose generation overrides
      values.local.yaml          # Developer-specific tweaks (GITIGNORED)
      templates/
        deployment.yaml
        service.yaml
        ingress.yaml
        configmap.yaml
        secrets.yaml
        hpa.yaml
        _helpers.tpl
```

Key points:

- **`values.yaml`** is always the canonical, minimal, safe-everywhere default.
- **`values.*.yaml`** files are environment overlays applied via `-f` flag.
- **`values.local.yaml`** is gitignored and exists for developer-specific tweaks (e.g., custom registry, debug ports). It is never committed.
- **`templates/`** contains only Kubernetes resource templates and helpers.
- **`_helpers.tpl`** handles naming, labels, and annotations — nothing else.

### 2. DAG-Based Layering Model

Deployments follow a strict four-layer DAG with no cross-contamination:

```text
artifact layer (container image — built by CI or Nix)
       ↓
deployment layer (Helm chart — defines resources)
       ↓
environment layer (values.*.yaml — configures per-target)
       ↓
runtime layer (k8s / k3s / rendered Compose)
```

- **Artifact**: The container image. Built once, tagged, pushed. Never rebuilt per environment.
- **Deployment**: The Helm chart. Defines what resources exist and how they reference values.
- **Environment**: The `values.*.yaml` overlay. Contains all environment-specific configuration.
- **Runtime**: The target platform. Consumes rendered manifests or Compose files.

### 3. Five Governing Conventions

#### Convention 1 — `values.yaml` Is Always Minimal

Only defaults that are safe and correct in every environment. No environment-specific values. If a value differs between environments, it belongs in an overlay.

#### Convention 2 — All Environment Differences Live in `values.*.yaml`

Never put environment branching logic (`if eq .Values.env "prod"`) in templates. Templates read values; overlays set them.

#### Convention 3 — Templates Must Be Dumb

No business logic. No conditional environment branching. No computed values beyond simple helper calls. Templates only read `.Values`, `.Chart`, and `.Release` and render resources.

#### Convention 4 — Helpers Handle Naming, Labels, and Annotations

`_helpers.tpl` provides `app.name`, `app.fullname`, standard labels, and standard annotations. Templates call helpers; they do not inline naming logic.

#### Convention 5 — Every Chart Is Self-Contained

No global values files. No implicit dependencies on other charts. No "umbrella chart" patterns. Each chart under `deploy/charts/<service>/` is independently installable and testable.

### 4. Minimal Production-Ready Chart Template

#### `Chart.yaml`

```yaml
apiVersion: v2
name: app
version: 0.1.0
appVersion: "1.0.0"
```

**Note**: `version` follows semver and is bumped by CI, not manually.

#### `values.yaml`

```yaml
image:
  repository: myregistry/app
  tag: latest
  pullPolicy: IfNotPresent

replicaCount: 1

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources: {}
```

#### `templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "app.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "app.name" . }}
    spec:
      containers:
        - name: {{ include "app.name" . }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

#### `templates/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
  selector:
    app: {{ include "app.name" . }}
```

#### `templates/_helpers.tpl`

```text
{{- define "app.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "app.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
```

### 5. Multi-Runtime: Rendering to Docker Compose

To produce a Docker Compose file from the same chart:

```bash
helm template app ./deploy/charts/app \
  -f deploy/charts/app/values.compose.yaml \
  > rendered.yaml
```

The rendered Kubernetes manifests are then converted to a Compose file by a **compose-generator** tool (to be specified in a separate ADR or ticket when implemented).

This gives:

- **One source of truth** — the Helm chart.
- **Multiple runtimes** — k8s, k3s, or Compose.
- **Zero drift** — all environments derive from the same templates.
- **Zero duplication** — no separate Compose files maintained by hand.

### 6. Secrets Management

The `secrets.yaml` template defines the shape of Kubernetes Secret resources. **Actual secret values never live in `values.*.yaml` files.** Secrets are injected at deploy time via:

- **SOPS** — for encrypted values committed to the repo (dev/homelab).
- **External Secrets Operator** or **Sealed Secrets** — for Kubernetes-native secret management.
- **Vault** — for production environments requiring dynamic secrets.

The specific secrets backend per environment is configured in the environment overlay, but the secret data itself is never stored in the chart.

### 7. CI Integration

The following checks run in CI for every chart change:

- **`helm lint`** — validates chart structure and template syntax.
- **`helm template --validate`** — renders templates and validates against the Kubernetes API schema.
- **`helm unittest`** (via [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin) — runs chart unit tests.
- **Chart version bump** — CI enforces that `Chart.yaml` `version` is bumped on every change to a chart.

## Consequences

### Positive

- **Predictable deployments**: Every service follows the same structure; no snowflakes.
- **Environment parity**: Dev, homelab, and cloud all derive from the same chart with explicit, auditable differences.
- **Reduced cognitive load**: "Templates are dumb" means anyone can read them without understanding complex Go template logic.
- **Multi-runtime without duplication**: Docker Compose users get the same configuration as Kubernetes users.
- **Composable with existing ADRs**: Fits cleanly with container security (ADR 20251218001), Docker standards (ADR 20251218002), and CI/CD (ADR 20251106014).

### Negative

- **Compose-generator tooling**: The Kubernetes-to-Compose rendering step requires a tool that does not yet exist in the repo. Until implemented, Compose files may need manual maintenance.
- **Chart boilerplate**: Each new service requires scaffolding a chart directory. This should be addressed by a copier template.
- **Learning curve**: Contributors unfamiliar with Helm need onboarding, though the "dumb templates" convention reduces this significantly.

### Neutral

- This ADR governs chart structure and conventions, not the specific Kubernetes resources each service requires. Services may add additional templates (CronJob, PersistentVolumeClaim, NetworkPolicy, etc.) as needed.

## Alternatives Considered

1. **Kustomize instead of Helm**
   - *Pros*: No templating language; pure YAML overlays; built into `kubectl`.
   - *Cons*: Less expressive for parameterization; no built-in packaging/versioning; weaker ecosystem for chart distribution. Helm is already adopted (ADR 20251106012).

2. **Umbrella chart with global values**
   - *Pros*: Single `helm install` for the entire stack.
   - *Cons*: Creates tight coupling between services; global values become a shared mutable state; harder to test and deploy independently. Violates Convention 5.

3. **Separate Compose files maintained independently**
   - *Pros*: Simple; no rendering step.
   - *Cons*: Guaranteed drift between Compose and Kubernetes definitions; double maintenance burden. Directly contradicts the "single source of truth" goal.

4. **Pulumi for all deployment definitions (no Helm)**
   - *Pros*: TypeScript-native; full programming language for infrastructure.
   - *Cons*: Pulumi is already adopted for IaC provisioning (clusters, networks, DNS). Using it for application deployment definitions would conflate provisioning and deployment layers. Helm charts are the standard for Kubernetes application packaging and are more portable.

## Rollout / Migration

1. Create `deploy/charts/` directory structure at the repo root.
2. Create a copier boilerplate template for new Helm charts that enforces this structure.
3. Migrate the existing Airflow Helm values (`specs/005-airflow-layered-images-spec/helm/`) to the canonical location.
4. Add `helm lint` and `helm template --validate` to CI pipeline.
5. Add `values.local.yaml` to the repo root `.gitignore`.
6. Create a ticket/spec for the compose-generator tool.
7. Document the chart creation workflow in `docs/` or the developer guide.

## Validation

This ADR is successful when:

- All new deployable services use the canonical chart structure under `deploy/charts/`.
- No environment-specific logic exists in Helm templates (enforceable via code review and linting).
- CI runs `helm lint` and `helm template --validate` on every chart change.
- At least one service is successfully rendered to both Kubernetes manifests and Docker Compose from the same chart.

## References

- [Helm](https://helm.sh/) — Kubernetes package manager
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/) — Official chart conventions
- [helm-unittest](https://github.com/helm-unittest/helm-unittest) — Chart unit testing plugin
- ADR 20251106012: Containerization Strategy
- ADR 20251106014: CI/CD Strategy
- ADR 20251218001: Container Isolation and Docker Socket Hardening
- ADR 20251218002: Docker Service Standards
- ADR 20260109001: Nix Container Architecture

<!-- vim: set ft=markdown: -->
