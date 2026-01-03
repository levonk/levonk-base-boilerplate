FROM nixpkgs/nix

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && nix-channel --update

# 🤖 BOOTSTRAP TOOLCHAIN: Install essentials into the shared default profile
# so the app container can pick them up from /nix/var/nix/profiles/default/bin.
RUN nix-env -p /nix/var/nix/profiles/default -iA \
    nixpkgs.bash \
    nixpkgs.nodejs \
    nixpkgs.devbox \
    nixpkgs.jq \
    nixpkgs.git \
    nixpkgs.file

# We avoid baking tsx here because the nix attribute may not exist in some channels.
# The app container will fallback to npm -g tsx using the nodejs installed above.

RUN mkdir -p /etc/nix
COPY nix.conf /etc/nix/nix.conf

RUN mkdir -p /usr/local/bin/healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/bin/env"]
CMD ["sleep", "infinity"]
