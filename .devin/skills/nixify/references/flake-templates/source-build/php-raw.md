# Source Build Flake: PHP — Raw (no Composer)

Use when the project does not have published binary releases, uses PHP, but
does NOT use Composer (raw PHP scripts, no `composer.json`).

For Composer-based projects, use
[`source-build/php.md`](source-build/php.md) (`buildComposerPackage`) instead.

## Template

```nix
<pname> = pkgs.stdenv.mkDerivation {
  pname = "<binary-name>";
  version = "<x.y.z>";
  src = pkgs.lib.cleanSource ./.;
  nativeBuildInputs = [ pkgs.php83 ];
  buildInputs = [ pkgs.php83 ];
  buildPhase = ''
    # Custom build steps (e.g. lint, copy assets)
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out/share/<pname>
    cat > $out/bin/<binary-name> <<EOF
    #!${pkgs.bash}/bin/bash
    exec ${pkgs.php83}/bin/php $out/share/<pname>/index.php "\$@"
    EOF
    chmod +x $out/bin/<binary-name>
  '';
  meta = {
    description = "<Project description>";
    homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
    license = pkgs.lib.licenses.<spdx>;
    mainProgram = "<binary-name>";
  };
};
```

## PHP version selection

Check the project's PHP version requirement (README, `.php-version`, or CI
config). Map to the matching nixpkgs attribute:

| Version | nixpkgs attribute |
|---------|-------------------|
| 8.1.x   | `pkgs.php81`      |
| 8.2.x   | `pkgs.php82`      |
| 8.3.x   | `pkgs.php83`      |

If the project does not pin a PHP version, default to `pkgs.php83`.

## Skip if

Skip this template if the project is a web application that needs a web server
(Apache/Nginx) at runtime — that requires a different packaging approach
(systemd services, NixOS modules) rather than a standalone binary or library
package.
