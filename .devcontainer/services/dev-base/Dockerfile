# =============================================================================
# DEV-BASE: Base development environment with Nix and essential tools
# =============================================================================
FROM debian:trixie-slim

# Install required system packages for Nix and basic functionality
RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	sudo \
	ca-certificates \
	gnupg2 \
	xz-utils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Nix package manager using multi-user installation (as root)
# Let the installer create the group with correct UID
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Install essential development tools into shared profile (as root for permissions)
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
	&& nix-env -p /nix/var/nix/profiles/default -iA \
    # Core Development Tools
    nixpkgs.nodejs \
    nixpkgs.devbox \
    nixpkgs.jq \
    nixpkgs.git \
    # Shell & Navigation
    nixpkgs.fzf \
    nixpkgs.ripgrep \
    nixpkgs.fd \
    nixpkgs.bat \
    nixpkgs.eza \
    nixpkgs.zoxide \
    nixpkgs.zsh \
    # Terminal Multiplexer & Shell Environment
    nixpkgs.zellij \
    nixpkgs.direnv \
    # Image & Document Processing
    nixpkgs.poppler-utils \
    nixpkgs.chafa \
    nixpkgs.jp2a \
    nixpkgs.imagemagick \
    # Advanced Diff & Comparison Tools
    nixpkgs.difftastic \
    nixpkgs.delta \
    nixpkgs.mergiraf \
    nixpkgs.odiff \
    # Development Infrastructure
    nixpkgs.chezmoi \
    nixpkgs.universal-ctags \
    nixpkgs.sqlite \
    # Diagramming & Visualization
    nixpkgs.graphviz \
    nixpkgs.plantuml \
    nixpkgs.mermaid-cli \
	# System Utilities
    nixpkgs.htop \
    nixpkgs.btop \
    nixpkgs.bottom \
    nixpkgs.procs \
    nixpkgs.dust \
    nixpkgs.duf \
    # File Management
    nixpkgs.yazi \
    nixpkgs.trash-cli \
    nixpkgs.p7zip \
    nixpkgs.unzip \
    nixpkgs.zip \
    nixpkgs.rsync \
    # Text Processing & Data
    nixpkgs.vim \
    nixpkgs.neovim \
    nixpkgs.yq-go \
    nixpkgs.gron \
    nixpkgs.fx \
    nixpkgs.tokei \
    # Network Tools
    nixpkgs.nmap \
    nixpkgs.tcpdump \
    nixpkgs.mtr \
    nixpkgs.whois \
    nixpkgs.rhash \
    # Terminal Enhancement
    nixpkgs.nerd-fonts.jetbrains-mono \
    nixpkgs.tlrc \
    #nixpkgs.tealdeer \
    nixpkgs.pay-respects \
    nixpkgs.atuin \
    nixpkgs.sd \
    # Version Control
    nixpkgs.gh \
    nixpkgs.glab \
    nixpkgs.lazygit \
    nixpkgs.git-extras \
    nixpkgs.git-lfs \
    nixpkgs.fzf-git-sh \
    # System Essentials
    nixpkgs.file \
    nixpkgs.findutils \
    nixpkgs.procps \
    nixpkgs.shadow

# Set up the non-root user using Docker Compose environment variables
ARG USERNAME=developer
ARG USER_UID=${PUID:-1000}
ARG USER_GID=${PGID:-1000}
RUN mkdir -p /etc/sudoers.d \
	&& groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# Set up working directory
WORKDIR /home/${USERNAME}/project

# Switch to non-root user first
USER $USERNAME

# Set up Nix environment for the user (must be set after switching user)
ENV PATH="/nix/var/nix/profiles/default/bin:/home/developer/.local/bin:/home/developer/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Healthcheck setup
RUN sudo mkdir -p /usr/local/bin/healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN sudo chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

# Override PATH in entrypoint to ensure Nix binaries are available
ENTRYPOINT ["/bin/sh", "-c", "export PATH=\"/nix/var/nix/profiles/default/bin:/home/developer/.local/bin:/home/developer/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\" && exec /usr/bin/env \"$@\"", "--"]
CMD ["sleep", "infinity"]
