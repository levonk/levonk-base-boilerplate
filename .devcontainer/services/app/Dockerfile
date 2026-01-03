# Start with our minimal Debian "Trixie" base.
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

# BOOTSTRAP LAYER: Absolute bare minimum for Nix/Devbox bootstrap.
RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	sudo \
	procps \
	ca-certificates \
	xz-utils \
	findutils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up the non-root user.
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

WORKDIR /home/${USERNAME}/project

# Copy entrypoint scripts as root but run as user
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY entrypoint.ts /usr/local/bin/entrypoint.ts
RUN chmod 755 /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.ts

# Healthcheck setup
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

USER $USERNAME

# Basic environment setup
ENV PATH="/usr/local/bin:/home/developer/.local/bin:/home/developer/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
