FROM devcontainer-base-sidecar:latest

# Install pnpm/node via nix into shared profile
RUN nix-env -p /nix/var/nix/profiles/default -iA nixpkgs.nodePackages.pnpm

RUN mkdir -p /usr/local/bin/healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

USER $USERNAME
ENTRYPOINT ["/usr/bin/env"]
CMD ["sleep", "infinity"]
