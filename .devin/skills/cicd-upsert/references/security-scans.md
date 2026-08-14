# Security Scans

A layered scanning pipeline that catches vulnerabilities at the earliest stage
where they're detectable, before they reach production.

## Scan Pipeline Order

```
secret-detection → SAST → dependency scan → build → container scan → DAST
```

| Stage | Scans | What it catches | When |
|-------|-------|-----------------|------|
| 1. Secret detection | Gitleaks, TruffleHog | Leaked API keys, tokens | Pre-build, on source |
| 2. SAST | CodeQL, Semgrep | Injection, auth flaws | Pre-build, on source |
| 3. Dependency scan | Trivy, Grype, Dependabot | Known CVEs in deps | Pre-build, on lockfiles |
| 4. Build | — | Compiles artifact | — |
| 5. Container scan | Trivy, Grype | OS packages, image CVEs | Post-build, on image |
| 6. DAST | OWASP ZAP, Nuclei | Runtime vulnerabilities | Post-deploy, on running app |

## Tool Selection

| Category | Tool | Strengths | Output |
|----------|------|-----------|--------|
| Secret detection | Gitleaks | Fast, git history aware | JSON, SARIF |
| Secret detection | TruffleHog | Verified secrets (reduces FP) | JSON |
| SAST | CodeQL | Semantic analysis, GitHub native | SARIF |
| SAST | Semgrep | Custom rules, fast, multi-language | JSON, SARIF |
| Dep + Container | Trivy | Deps + containers, one tool | JSON, SARIF |
| Dep + Container | Grype | Fast, SBOM-focused | JSON, SARIF |
| DAST | OWASP ZAP | Comprehensive web app scanning | HTML, JSON |
| DAST | Nuclei | Template-based, fast | JSON |

## SARIF and GitHub Security Tab

```yaml
      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif
```

GitHub shows SARIF findings under **Security > Code scanning alerts**. Works for
any tool that emits SARIF, not just CodeQL.

## Gating Configuration

| Severity | Action | Config |
|----------|--------|--------|
| CRITICAL | Block merge | `exit-code: 1` |
| HIGH | Block merge | `exit-code: 1` |
| MEDIUM | Warn (comment on PR) | `exit-code: 0`, annotate |
| LOW | Report only | Log, no gate |
| INFO | Report only | Log, no gate |

```yaml
# Block on CRITICAL and HIGH
- uses: aquasecurity/trivy-action@master
  with:
    severity: CRITICAL,HIGH
    exit-code: '1'
```

## Baseline Suppression

Suppress known false positives so they don't block every PR:

```json
// .trivyignore.json
{ "ignoreUnfixed": true, "vulnerabilities": [
  { "id": "CVE-2023-1234", "reason": "Not exploitable in our config" }
]}
```

```python
# Semgrep inline suppression
# nosemgrep: python.lang.security.dangerous-subprocess-use
subprocess.run(user_input)  # reviewed, input is sanitized upstream
```

## Scheduling Full Scans

Run lightweight scans on every PR. Schedule comprehensive weekly scans to catch
newly disclosed CVEs in existing code:

```yaml
on:
  pull_request:
  schedule:
    - cron: '0 6 * * 1'   # Every Monday 06:00 UTC
```

## Concrete Example: Trivy + Gitleaks + CodeQL

```yaml
name: Security
on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    permissions: { contents: read, security-events: write }
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: gitleaks/gitleaks-action@v2
        env: { GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} }

  sast:
    runs-on: ubuntu-latest
    permissions: { contents: read, security-events: write }
    strategy:
      matrix:
        language: [go, javascript]
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with: { languages: ${{ matrix.language }} }
      - uses: github/codeql-action/analyze@v3

  dependency-scan:
    runs-on: ubuntu-latest
    permissions: { contents: read, security-events: write }
    steps:
      - uses: actions/checkout@v4
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          scan-ref: .
          format: sarif
          output: trivy-deps.sarif
          severity: CRITICAL,HIGH
          exit-code: '1'
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: trivy-deps.sarif }

  container-scan:
    needs: build   # assumes a build job that produces an image
    runs-on: ubuntu-latest
    permissions: { contents: read, security-events: write }
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ghcr.io/${{ github.repository }}:sha-${{ github.sha }}
          format: sarif
          output: trivy-image.sarif
          severity: CRITICAL,HIGH
          exit-code: '1'
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: trivy-image.sarif }
```

## Tool Recommendations

| Tool | Use case | Cost |
|------|----------|------|
| Gitleaks | Secret scanning in git history | Free (OSS) |
| CodeQL | Deep SAST, GitHub native | Free for public repos |
| Semgrep | Lightweight SAST + custom rules | Free tier, paid Pro |
| Trivy | All-in-one (deps + container + IaC) | Free (OSS) |
| OWASP ZAP | DAST for web apps | Free (OSS) |
