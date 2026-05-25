# Kustomize Cluster Addon (Copier)

Adds a new cluster to an existing Kustomize GitOps repository.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/kustomize-cluster ./gitops
```

## Generated Structure

```
gitops/clusters/mycluster/
  kustomization.yaml
  apps/
  infra/
```

After generation, add `clusters/{{ cluster_name }}` to your root `kustomization.yaml` resources.
