# Contributing a Package to nixpkgs

> **Knowledge base**: The canonical concept page for this practice is
> [`nixpkgs-contribution`](../included/knowledge/nix-build-practices/nixpkgs-contribution.md)
> in the `nix-build-practices` bundle. This section is the skill-specific
> operational guidance; the bundle page is the compounding reference.

When the nixify skill packages a project that is **not yet in nixpkgs**
(`check-nixpkgs.sh` reported `project_in_nixpkgs: false`), the skill should
also contribute the package upstream to nixpkgs. This makes the project
available to all Nix users via `nix profile add nixpkgs#<project>`, not just
those who know about the in-repo flake.

The nixpkgs contribution is prepared at Step 28b, **after** the in-repo flake
has been validated and the main PR (Step 27) has been created. The nixpkgs PR
references the working in-repo flake as evidence the package builds and runs.

## Key Departure from Project-Owner PRs

The nixpkgs PR body does **NOT** explain Nix concepts. The audience is nixpkgs
maintainers who already know Nix — they need to see the package definition,
dependencies, meta attributes, and test results, not a tutorial on what Nix is
or why flakes are useful. This is a departure from the project-owner PR/issue
templates (Steps 24 and 27) which educate project owners about Nix benefits.

## pkgs/by-name Convention

New packages in nixpkgs use the `pkgs/by-name` directory structure, which
auto-registers the package without needing to edit `all-packages.nix`:

```
pkgs
└── by-name
    ├── <prefix>           # first 2 chars of package name, lowercased
    │   └── <package-name> # the package name
    │       └── package.nix # the package definition
```

For example, `my-tool` goes to `pkgs/by-name/my/my-tool/package.nix`.

See the [nixpkgs Quick Start](https://nixos.org/manual/nixpkgs/stable/#chap-quick-start)
and the [pkgs/by-name README](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md)
for the full convention.

## package.nix Structure

The `package.nix` is a function that takes dependencies as arguments and
returns a derivation. The function arguments are auto-filled by `callPackage`
from the top-level package set.

```nix
{
  lib,
  stdenv,
  rustPlatform,    # for Rust projects — use the correct framework for the language
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "upstream-owner";
    repo = "my-tool";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = {
    description = "A tool that does things";
    homepage = "https://github.com/upstream-owner/my-tool";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.your-handle ];
    mainProgram = "my-tool";
    platforms = lib.platforms.unix;
  };
}
```

### Language-Specific Builders

Use the correct builder for the project's language. See the
[nixpkgs language support chapter](https://nixos.org/manual/nixpkgs/stable/#chap-language-support)
for the full list.

| Language | Builder | Notes |
|----------|---------|-------|
| Rust | `rustPlatform.buildRustPackage` | Set `cargoHash` (not `cargoSha256`) |
| Node.js (npm) | `buildNpmPackage` | Set `npmDepsHash` |
| Node.js (pnpm) | `buildPnpmPackage` | Set `pnpmDepsHash` |
| Python | `python3Packages.buildPythonApplication` | Set `pyproject` or `format` |
| Go | `buildGoModule` | Set `vendorHash` |
| Generic | `stdenv.mkDerivation` | For projects without a language-specific builder |

### Using the In-Repo Flake as Reference

The in-repo flake.nix (from Step 12) already has a working build. Use it as
the reference for the nixpkgs `package.nix`:

1. Copy the `buildInputs`, `nativeBuildInputs`, and build phases from the
   flake's `#source` output
2. Replace `src = ./.` with `fetchFromGitHub { ... }` pointing at the upstream
   release tag
3. Replace local toolchain pins (e.g., `pkgs.rustPlatform`) with the nixpkgs
   default (`rustPlatform` from the function arguments)
4. Add `meta` attributes (the in-repo flake may not have these — nixpkgs
   requires them)

## Maintainer Entry

Before the nixpkgs PR can be merged, you must add yourself to
`maintainers/maintainer-list.nix` in a **separate commit**. The entry format:

```nix
your-handle = {
  name = "Your Name";
  email = "you@example.com";
  github = "your-handle";
  githubId = 12345678;  # find via: curl -s https://api.github.com/users/your-handle | jq .id
};
```

See the [maintainer-list.nix](https://github.com/NixOS/nixpkgs/blob/master/maintainers/maintainer-list.nix)
for the full format and existing entries.

## Hash Discovery

The `src.hash` and dependency hashes (`cargoHash`, `npmDepsHash`, etc.) must
be set correctly. Use the fake-hash method:

1. Set a fake hash: `hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";`
2. Build: `nix-build -A <package>`
3. The build fails with the correct hash in the error output
4. Copy the correct hash into `package.nix`
5. Rebuild to confirm

See the [nixpkgs manual — Update source hash with the fake hash method](https://nixos.org/manual/nixpkgs/stable/#sec-source-hashes-fake-hash-method).

## PR Title

nixpkgs PR titles follow a convention: `<package>: <action> <version>`.

- New package: `my-tool: init at 1.2.3`
- Update: `my-tool: 1.2.3 -> 1.3.0`
- Fix: `my-tool: fix build on darwin`

## PR Body

The PR body should be concise and written for nixpkgs maintainers. See
`references/nixpkgs-pr.md.tmpl` for the template. Key points:

- **No Nix education** — maintainers know Nix
- **Description** — one-line description of the package
- **Testing** — how the package was built and tested
- **Checklist** — confirm the package builds, runs, and has correct meta
- **Maintainer** — confirm you added yourself to maintainer-list.nix

## Testing Before Submitting

```bash
# Build the package
nix-build -A <package>

# Test the binary
result/bin/<package> --version

# Run nixpkgs review (recommended)
nix run nixpkgs#nixpkgs-review -- pr <PR-number>
```

## Limitations of pkgs/by-name

Not all packages can use `pkgs/by-name`. Limitations:

- Only packages with simple `callPackage` calls (no custom arguments)
- Packages that need `override` support with custom arguments must still be
  declared in `all-packages.nix`
- Packages in special scopes (e.g., `haskellPackages`, `python3Packages`)
  cannot use `pkgs/by-name` — they stay in their scope's directory

If the package needs custom `callPackage` arguments, add it to
`pkgs/top-level/all-packages.nix` instead. See the
[pkgs/by-name README — Limitations](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md#limitations)
for the full list.
