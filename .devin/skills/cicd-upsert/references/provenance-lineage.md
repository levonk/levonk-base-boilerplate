# Provenance and Lineage

Sign artifacts, generate SBOMs, and embed build metadata so that deployed
images can be traced back to a specific commit, build, and dependency set.
Verification before deployment closes the loop.

## SLSA Provenance Levels

| Level | Requirement | What it proves |
|-------|-------------|----------------|
| SLSA 1 | Build process documented | Build came from a script |
| SLSA 2 | Hosted build service, tamper-resistant provenance | Build ran on a trusted platform |
| SLSA 3 | Isolated build, provenance verified | Build was isolated from other builds |
| SLSA 4 | Hermetic build, two-party review | Build had no network access, reviewed |

Most projects target SLSA 3 using GitHub Actions + cosign + the
slsa-github-generator action.

## Cosign Keyless Signing

Keyless signing uses OIDC tokens from the CI provider — no private keys to
manage or rotate. The signing identity is tied to the workflow run.

```bash
# Sign an image keyless (run inside GitHub Actions with id-token: write)
cosign sign --yes ghcr.io/owner/app:${{ github.sha }}

# Verify before deployment
cosign verify ghcr.io/owner/app:${{ github.sha }} \
  --certificate-identity-regexp "https://github.com/owner/repo/.github/.+" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## SBOM Generation with Syft

Generate a Software Bill of Materials in SPDX or CycloneDX format. Attach the
SBOM as an OCI artifact alongside the image.

```bash
# SPDX format
syft ghcr.io/owner/app:${{ github.sha }} -o spdx-json > sbom.spdx.json

# CycloneDX format
syft ghcr.io/owner/app:${{ github.sha }} -o cyclonedx-json > sbom.cdx.json

# Attach SBOM as an attestation
cosign attest --yes --predicate sbom.spdx.json \
  --type spdxjson ghcr.io/owner/app:${{ github.sha }}
```

## OCI Labels for Lineage

Embed git metadata directly in the container image via OCI labels. These are
visible via `docker inspect` and any registry UI.

| Label | Value | Purpose |
|-------|-------|---------|
| `org.opencontainers.image.revision` | Git SHA | Trace to exact commit |
| `org.opencontainers.image.source` | Repo URL | Trace to source repo |
| `org.opencontainers.image.version` | Git tag | Trace to release |
| `org.opencontainers.image.created` | ISO timestamp | Build time |
| `org.opencontainers.image.title` | App name | Human-readable ID |

```dockerfile
LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.source="https://github.com/owner/repo" \
      org.opencontainers.image.version="${GIT_TAG}" \
      org.opencontainers.image.created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

## Build Attestations

Attestations bind claims (SBOM, provenance, vulnerability scan) to an artifact
cryptographically. Verify attestations before deployment to confirm the image
was built by the expected pipeline and passed required checks.

```bash
# Verify SBOM attestation
cosign verify-attestation \
  --certificate-identity-regexp "https://github.com/owner/repo/.github/.+" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --type spdxjson ghcr.io/owner/app:${{ github.sha }}
```

## Concrete Example: Sign + Attest + SBOM + Verify

```yaml
name: Release
on:
  push:
    branches: [main]
permissions:
  contents: read
  packages: write
  id-token: write   # required for keyless signing
jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push
        run: |
          docker build \
            --label org.opencontainers.image.revision=${{ github.sha }} \
            --label org.opencontainers.image.source=${{ github.server_url }}/${{ github.repository }} \
            -t ghcr.io/owner/app:${{ github.sha }} .
          echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push ghcr.io/owner/app:${{ github.sha }}
      - uses: sigstore/cosign-installer@v3
      - uses: anchore/sbom-action@v0
        with:
          image: ghcr.io/owner/app:${{ github.sha }}
          format: spdx-json
          output-file: sbom.spdx.json
      - name: Sign and attest
        run: |
          cosign sign --yes ghcr.io/owner/app:${{ github.sha }}
          cosign attest --yes --predicate sbom.spdx.json --type spdxjson \
            ghcr.io/owner/app:${{ github.sha }}
  deploy:
    needs: build-and-sign
    runs-on: ubuntu-latest
    steps:
      - uses: sigstore/cosign-installer@v3
      - name: Verify before deploy
        run: |
          cosign verify ghcr.io/owner/app:${{ github.sha }} \
            --certificate-identity-regexp "https://github.com/owner/repo/.github/.+" \
            --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
            || { echo "Signature verification failed"; exit 1; }
          cosign verify-attestation \
            --certificate-identity-regexp "https://github.com/owner/repo/.github/.+" \
            --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
            --type spdxjson ghcr.io/owner/app:${{ github.sha }} \
            || { echo "SBOM attestation missing"; exit 1; }
      - run: kubectl set image deployment/app app=ghcr.io/owner/app:${{ github.sha }}
```

For SLSA 3 provenance, use the `slsa-framework/slsa-github-generator` action
which produces a signed provenance attestation automatically.

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| cosign | Sign and verify images, attestations | Keyless via OIDC, no key management |
| Syft | SBOM generation | SPDX and CycloneDX output |
| slsa-github-generator | SLSA 3 provenance | GitHub Actions native |
| Grype | Vulnerability scanning from SBOM | Pairs with Syft |
| Trivy | Image scanning + SBOM | All-in-one alternative |
