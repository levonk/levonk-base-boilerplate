{
  "description": "VS Code Extension Monorepo Development Environment",

  "inputs": {
    "nixpkgs": {
      "url": "github:NixOS/nixpkgs/nixos-unstable"
    },
    "flake-utils": {
      "url": "github:numtide/flake-utils"
    }
  },

  "outputs": { "self", "nixpkgs", "flake-utils" }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        "devShells": {
          "default": pkgs.mkShell {
            "buildInputs": [
              pkgs.nodejs_20
              pkgs.nodePackages.pnpm
              pkgs.nodePackages.typescript
              # Tools for publishing
              pkgs.nodePackages.vsce      # Microsoft Marketplace
              pkgs.nodePackages.ovsx      # Open VSX (VSCodium/Cursor)
              # Template tools
              pkgs.python3Packages.copier
              pkgs.python3
              pkgs.gnumake
            ],

            "shellHook": ''
              echo "VS Code Extension Dev Environment Loaded"
              echo "Node: $(node -v) | PNPM: $(pnpm -v)"
            ''
          }
        }
      })
}
