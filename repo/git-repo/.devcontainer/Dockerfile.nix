FROM nixpkgs/nix-flakes
COPY nix.conf /etc/nix/nix.conf
CMD ["sleep", "infinity"]
