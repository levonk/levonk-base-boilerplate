# Helm Boilerplate (Copier)

Scaffolds a Helm chart for Kubernetes deployments.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/helm ./out/my-chart
```

## Generated Structure

```
my-helm-chart/
  Chart.yaml
  values.yaml
  templates/
    deployment.yaml
    service.yaml
    _helpers.tpl
```
