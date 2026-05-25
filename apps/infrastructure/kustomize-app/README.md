# Kustomize App Addon (Copier)

Adds a new application to an existing Kustomize GitOps repository.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/kustomize-app ./gitops
```

## Generated Structure

```
gitops/apps/myapp/
  base/
    kustomization.yaml
    deployment.yaml
    service.yaml
  overlays/
    dev/
    prod/
    edge/
```
