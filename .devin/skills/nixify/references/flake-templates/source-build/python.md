# Source Build Flake: Python

Use when the project does not have published binary releases and uses Python.

Use `buildPythonApplication` or `uv2nix` / `poetry2nix` depending on the lock file format.

**Darwin legacy pin**: Add a `nixpkgs-darwin-legacy` input and use it for
`x86_64-darwin` to support older macOS Intel. See
`references/flake-templates/darwin-legacy-pin.md` for the pattern.

**cleanSource**: Use `src = pkgs.lib.cleanSource ./.;` instead of `src = ./.;` to filter build artifacts, `.git`, `.devbox`, etc., so trivial local changes do not invalidate the Nix build cache.
