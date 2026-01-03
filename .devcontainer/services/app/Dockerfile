# =============================================================================
# APP: Application-specific development environment
# Inherits from dev-base which includes Nix and essential development tools
# =============================================================================
FROM devcontainer-dev-base:latest

# =============================================================================
# APPLICATION-SPECIFIC PACKAGES
# These packages are specific to this application's development needs
# =============================================================================
USER root

# =============================================================================
# APPLICATION SETUP
# =============================================================================
# Copy entrypoint scripts as root but run as user
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY entrypoint.ts /usr/local/bin/entrypoint.ts
RUN chmod 755 /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.ts

# Healthcheck setup
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Switch to non-root user
USER $USERNAME

# Healthcheck configuration
HEALTHCHECK --interval=60s --timeout=30s --start-period=60s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
