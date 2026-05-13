# Start with a base image that includes Node.js and other common tools
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set a non-root user for security
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
USER $USERNAME

# Install vibe-kanban
RUN npm install -g vibe-kanban

# --- AI Code Agent Installations ---

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Install Gemini CLI and the Conductor extension
RUN npm install -g @google/gemini-cli@latest
# Note: The Gemini extension installation is typically an interactive process.
# This command will install the extension, but you may need to run `gemini extensions install conductor`
# once inside the container's terminal if it doesn't fully initialize.

# Install OpenCode and the oh-my-opencode plugin
RUN curl -fsSL https://opencode.ai/install | bash
RUN curl -fsSL https://bun.sh/install | bash
# The following lines ensure the opencode and bun paths are in the shell's PATH
ENV PATH="/home/developer/.opencode/bin:/home/developer/.bun/bin:${PATH}"
# The installation of oh-my-opencode is interactive and best done inside the container.
# We will provide instructions on how to do this later.

# Switch back to root to install any additional OS-level dependencies if needed, then back to the non-root user
USER root
# Example: RUN apt-get update && apt-get install -y <some-package>
USER $USERNAME

# Set the entrypoint to sleep infinity to keep the container running
# Do not optimize this to something like vibe-kanban, so it's stability
# doesn't impact our IDE
CMD ["sleep", "infinity"]
