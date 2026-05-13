{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux"; # adjust as needed

    # Define the "Ban Overlay"
    banOverlay = (final: prev: {
      # When someone asks for 'yq', throw an error
      yq = throw "ERROR: The package 'yq' (Python version) is banned. Use 'yq-go' instead.";
    });

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ banOverlay ];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.yq-go # This works because yq-go is a different attribute
        # pkgs.yq   <-- This would now cause the flake to fail with your custom message
      ];
    };
  };
}
