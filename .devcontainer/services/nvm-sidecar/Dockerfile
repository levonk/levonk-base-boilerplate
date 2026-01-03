FROM devcontainer-base-sidecar:latest

RUN nix-env -iA nixpkgs.nodejs \
  && mkdir -p /root/.nvm /usr/local/bin/healthcheck /home/developer/.nvm
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/bin/env"]
CMD ["sleep", "infinity"]
