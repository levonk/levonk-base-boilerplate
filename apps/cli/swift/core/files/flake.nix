{
  description = "Dev shell for a Swift CLI project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        swiftPkg =
          if pkgs ? swift-bin then pkgs.swift-bin
          else if pkgs ? swift then pkgs.swift
          else null;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.gnumake
          ] ++ pkgs.lib.optional (swiftPkg != null) swiftPkg;
        };
      }
    );
}
