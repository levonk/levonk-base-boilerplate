# Kustomize GitOps Boilerplate (Copier)

Scaffolds a Kustomize-based GitOps repository with cluster and app separation.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/kustomize ./out/my-gitops
```

## Generated Structure

```
gitops/
  clusters/
    mycluster/
      kustomization.yaml
      apps/
      infra/
  apps/
    myapp/
      base/
        kustomization.yaml
        deployment.yaml
        service.yaml
      overlays/
        dev/
          kustomization.yaml
        prod/
          kustomization.yaml
        edge/
          kustomization.yaml
```

## Inputs

- `project_name`: GitOps project name
- `cluster_name`: Kubernetes cluster name
- `app_name`: Application name
- `description`: Short description
- `author_name`, `author_email`: Author info
