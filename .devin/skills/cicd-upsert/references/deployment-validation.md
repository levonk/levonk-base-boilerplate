# Deployment Validation

Validate deployments after they happen. The rollback path is defined before
the first deploy — never deploy without knowing how to undo it.

## Deployment Strategies

| Strategy | When appropriate | When overkill |
|----------|-----------------|---------------|
| Rolling update | Stateless services, backward-compatible changes | Breaking schema changes, high-traffic services |
| Blue-green | Zero-downtime required, instant rollback, enough resources | Low-traffic services, resource-constrained environments |
| Canary | High-risk changes, high-traffic services, measurable metrics | Low-traffic services, trivial changes, no metrics pipeline |
| Recreate | Breaking changes requiring old version to stop first | Any service that needs zero downtime |

## Rolling Updates

Default for most Kubernetes Deployments. Gradually replaces old pods with new
ones. No extra tooling needed.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 0   # never reduce capacity below 100%
```

## Blue-Green Deployments

Two identical environments. Switch traffic all at once. Instant rollback by
switching back.

```bash
kubectl set image deployment/app-green app=ghcr.io/owner/app:${SHA}
kubectl rollout status deployment/app-green   # wait for healthy
kubectl patch service app -p '{"spec":{"selector":{"version":"green"}}}'  # switch
# Rollback: patch selector back to "blue"
```

## Canary Deployments

Gradual traffic shift with automatic rollback on error. Use Argo Rollouts or
Flagger for progressive delivery.

```yaml
# Argo Rollouts canary example
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: app
spec:
  strategy:
    canary:
      steps:
        - setWeight: 10
        - pause: { duration: 5m }
        - analysis:
            templates:
              - templateName: error-rate-check
        - setWeight: 30
        - pause: { duration: 5m }
        - setWeight: 50
        - pause: { duration: 5m }
        - setWeight: 100
  template:
    spec:
      containers:
        - name: app
          image: ghcr.io/owner/app:latest
```

## Smoke Tests

Run smoke tests immediately after deployment. Retry transient failures before
declaring the deploy broken.

```bash
#!/usr/bin/env bash
# smoke-test.sh — run after deploy, fail fast on real errors
URL="${1:-https://app.example.com/health}"
MAX_RETRIES=10
WAIT=5
for i in $(seq 1 $MAX_RETRIES); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "Health check passed (attempt $i)"; exit 0
  fi
  echo "Attempt $i: got $STATUS, retrying in ${WAIT}s..."; sleep $WAIT
done
echo "Health check failed after $MAX_RETRIES attempts"; exit 1
```

```yaml
# GitHub Actions smoke test after deploy
- name: Smoke test
  run: ./scripts/smoke-test.sh https://app.example.com/health
```

## Health Checks

Kubernetes liveness and readiness probes detect unhealthy pods automatically.

```yaml
livenessProbe:
  httpGet: { path: /healthz, port: 8080 }
  initialDelaySeconds: 10
  periodSeconds: 10
readinessProbe:
  httpGet: { path: /readyz, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 5
```

- **Liveness** — restart the pod if it fails (deadlocked, hung)
- **Readiness** — remove from service pool if it fails (warming up, overloaded)
- Keep them separate — readiness should be more sensitive

## Rollback-First Principle

Define the rollback path before deploying. If you cannot describe the rollback
in one sentence, you are not ready to deploy.

| Strategy | Rollback action |
|----------|----------------|
| Rolling | `kubectl rollout undo deployment/app` |
| Blue-green | Switch selector back to previous color |
| Canary | Promote previous stable version to 100% |
| Recreate | Redeploy previous image tag |## Monitoring During Rollout

Watch these metrics during any deployment. Set up alerts that auto-rollback or
page on-call.

| Metric | Threshold | Tool |
|--------|-----------|------|
| Error rate (5xx) | > 1% of requests | Prometheus, Datadog |
| P99 latency | > 2x baseline | Prometheus, Datadog |
| Deployment success | < 95% | Argo Rollouts, Flagger |
| Pod restarts | > 3 in 5 min | Kubernetes alerts |

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| Argo Rollouts | Canary/blue-green on Kubernetes | CRD-based, analysis hooks |
| Flagger | Progressive delivery with Istio/Linkerd | Auto-rollback on metrics |
| kubectl rollout | Basic rolling update rollback | Built-in, no extra tooling |
| curl | Simple smoke tests | Universal, no dependencies |

