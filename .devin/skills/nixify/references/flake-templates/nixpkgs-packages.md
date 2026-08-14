# Using Upstream nixpkgs Packages

If the project or its dependencies are already in nixpkgs, prefer using them:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Users naturally try .#<package-name>, so expose it alongside default.
        packages = {
          <package-name> = pkgs.<package-name>;
          default = pkgs.<package-name>;
        };
        apps = {
          <package-name> = {
            type = "app";
            program = "${pkgs.<package-name>}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${pkgs.<package-name>}/bin/<binary-name>";
          };
        };
      }
    );
}
```

Decision tree:
1. **Project in nixpkgs?** -> Use `nixpkgs#<package>` (preferred)
2. **Not in nixpkgs but dependencies are?** -> Build from source, use nixpkgs for dependencies
3. **Dependency flakes exist?** -> Reference as flake inputs
4. **Nothing upstream?** -> Build everything from source (last resort)
