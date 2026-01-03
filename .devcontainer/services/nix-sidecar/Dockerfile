FROM devcontainer-base-sidecar:latest

# 🤖 NIX-SIDECAR: Manage the shared Nix store and profile
# No additional packages needed - base-sidecar provides nix, bash, shadow

RUN mkdir -p /etc/nix
COPY nix.conf /etc/nix/nix.conf

RUN mkdir -p /usr/local/bin/healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/bin/env"]
CMD ["sleep", "infinity"]
