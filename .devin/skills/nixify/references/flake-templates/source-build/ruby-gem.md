# Source Build Flake: Ruby — Single Gem (`buildRubyGem`)

Use when the project does not have published binary releases, uses Ruby, and
ships as a single gem (`.gemspec`, no `Gemfile`).

For Bundler-based projects (`Gemfile` + `Gemfile.lock`), use
[`source-build/ruby.md`](source-build/ruby.md) (`bundlerEnv`) instead.

## Template

```nix
<pname> = pkgs.buildRubyGem {
  name = "<pname>-<x.y.z>";
  src = pkgs.lib.cleanSource ./.;
  ruby = pkgs.ruby_3_3;
  nativeBuildInputs = [ pkgs.ruby_3_3 pkgs.bundler pkgs.pkg-config ];
  buildInputs =
    [ pkgs.openssl pkgs.libxml2 pkgs.libxslt pkgs.zlib ]
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
      pkgs.libiconv
      pkgs.darwin.apple_sdk.frameworks.Security
      pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    ];
  meta = {
    description = "<Project description>";
    homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
    license = pkgs.lib.licenses.<spdx>;
    mainProgram = "<binary-name>";
  };
};
```

## Ruby version selection

Check `.ruby-version` or the `.gemspec` `required_ruby_version` for the
required Ruby version. Map to the matching nixpkgs attribute:

| `.ruby-version` | nixpkgs attribute |
|-----------------|-------------------|
| `3.1.x` | `pkgs.ruby_3_1` |
| `3.2.x` | `pkgs.ruby_3_2` |
| `3.3.x` | `pkgs.ruby_3_3` |

If the project does not pin a Ruby version, default to `pkgs.ruby_3_3`.

## Native extensions

Gems such as `nokogiri`, `pg`, `mysql2`, `sqlite3`, and `rmagick` compile C
extensions during install. They need their native build inputs available — see
[`source-build/ruby.md`](source-build/ruby.md) — Native extensions for the
full table of gems and their build inputs.

Set `BUNDLE_BUILD__NOKOGIRI=--use-system-libraries` (and analogous env vars for
other gems) to force use of system libraries instead of bundled ones.

## Skip if

Skip this template if the project is a **Rails web application** that needs a
database server and web server at runtime. That requires a different packaging
approach (NixOS modules, systemd services, or a container with `puma`/`sidekiq`
managed by a process supervisor). Source-build flakes are for libraries, CLI
tools, and standalone scripts — not long-running server apps.
