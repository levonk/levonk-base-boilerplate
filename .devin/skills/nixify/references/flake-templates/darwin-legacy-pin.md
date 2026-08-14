# Darwin Legacy Pin (x86\_64-darwin)

## Problem

`nixpkgs-unstable` periodically drops support for older macOS versions or
introduces SDK requirements that break builds on Intel Macs running older
macOS (e.g. macOS 11 Big Sur, macOS 12 Monterey). A flake that pins only to
`nixpkgs-unstable` may work on `aarch64-darwin` (Apple Silicon, usually running
the latest macOS) but fail on `x86_64-darwin` (Intel, often running older macOS).

## Solution

Add a second `nixpkgs` input pinned to a named release branch
(`nixpkgs-<version>-darwin`) and use it **only** for `x86_64-darwin`. The
`-darwin` branches are maintained by the nix-darwin community and receive
security and compatibility updates without the breaking churn of unstable.

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # Pin x86_64-darwin to a stable release branch for older macOS Intel
  # compatibility. The -darwin branches receive security updates without
  # the breaking churn of nixpkgs-unstable.
  nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
  flake-utils.url = "github:numtide/flake-utils";
};

outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs =
        if system == "x86_64-darwin"
        then nixpkgs-darwin-legacy.legacyPackages.${system}
        else nixpkgs.legacyPackages.${system};
    in
    ...
  );
```

## Choosing the branch

| Branch | Use when |
|--------|----------|
| `nixpkgs-24.05-darwin` | Default — supports macOS 11+ (Big Sur), receives security updates |
| `nixpkgs-23.11-darwin` | If the project must support macOS 10.15 (Catalina) |
| `nixpkgs-24.11-darwin` | When a newer stable branch is needed and 24.05 is too old |

The `-darwin` suffix branches are distinct from `nixos-<version>` branches —
they are specifically for non-NixOS Darwin systems and track the nix-darwin
community's tested nixpkgs revision.

## When to apply

Apply to **all source-build flake templates** (Rust, Node, Bun, Go, Python).
The pinning is language-agnostic — it affects the nixpkgs revision used for
`stdenv`, `darwin.apple_sdk.frameworks`, and all build dependencies.

**Skip if:** the project explicitly only targets `aarch64-darwin` (Apple
Silicon) and does not need Intel Mac support. In that case, use
`flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]`
instead of `eachDefaultSystem` and skip the legacy pin.

## CI implications

The `nix flake check --all-systems --no-build` step in the generated
`.github/workflows/nix.yml` evaluates outputs for every system, including
`x86_64-darwin`. With the legacy pin, `x86_64-darwin` outputs evaluate against
the pinned nixpkgs, not unstable — so the check validates that the legacy pin
actually works, not just that unstable works. This is the whole point: CI
catches a build that passes on unstable but breaks on the legacy pin.

## Updating the pin

Bump the legacy pin when:
- The current `-darwin` branch reaches end-of-life (check
  <https://nixos.org/manual/nixpkgs/stable/#sec-release-lifecycle>)
- A dependency in the project requires a newer nixpkgs than the pinned branch
  provides
- Security advisories affect packages in the pinned branch that haven't been
  backported

To bump, change the branch name in `inputs.nixpkgs-darwin-legacy.url` and run
`nix flake update nixpkgs-darwin-legacy`.
