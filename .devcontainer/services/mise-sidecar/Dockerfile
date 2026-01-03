FROM devcontainer-base-sidecar:latest

RUN mkdir -p /root/.local/share/mise /root/.cache/mise

RUN mkdir -p /usr/local/bin/healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/bin/env"]
CMD ["sleep", "infinity"]
