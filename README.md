# Ansible Layered Development Template (mise + Nx + Docker)

This template provides a highly configurable and optimized development environment for building complex, agent-based systems. It leverages:

* **Copier:** For project templating and initialization.
* **mise (rtx):** For managing tool versions (Python, Node.js, Flutter, etc.).
* **Nx:** For build orchestration, code generation, and monorepo management.
* **Docker:** For containerization and environment isolation.
* **Ansible:** For build-time and runtime provisioning, ensuring consistent environments.
* **Zellij:** For terminal multiplexing and managing multiple agent containers in a single window.
* **VS Code Dev Containers:** For seamless remote development with a fully configured environment.
* **Git Worktrees:** For parallel agent development with feature branches.

## Why This Template?

This template aims to solve the challenges of developing complex multi-agent systems by providing:

* **Reproducible Environments:** Docker and Ansible ensure consistent environments across different machines and developers.
* **Scalable Architecture:** Nx provides a scalable architecture for managing a monorepo with multiple agents, controllers, and shared libraries.
* **Efficient Development Workflow:** Git worktrees, code hot reloading, and remote debugging streamline the development process.
* **Automated Provisioning:** Ansible automates the setup of the containers, ensuring that all dependencies are installed and configured correctly.
* **Simplified Management:** Nx CLI extensions provide a convenient way to manage agents and other project components.

## Minimum Tooling Requirements

Before you can use this template, you need to install the following tools:

* **Copier:** `pip install copier` (or `pip3 install copier`) - Used to generate new projects from this template.
* **Docker:** [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/) - Used to containerize the development environment.
* **mise (rtx):** [https://mise.jdx.gg/](https://mise.jdx.gg/) - Used to manage tool versions (Python, Node.js, etc.).
* **Nx Console (VS Code Extension):** (Optional but highly recommended) - Provides a graphical interface for interacting with the Nx CLI and visualizing the project structure.
* **Zellij:** [https://zellij.dev/](https://zellij.dev/) - Used to create a multiplexed terminal.

## Getting Started

### 1. Install Copier

```bash
pip install copier
```

### 2. Generate a New Project

Use Copier to generate a new project from this template:

```bash
copier copy gh:YOUR_GITHUB_USERNAME/ansible-layered-dev-template my-new-project
```

*   Replace `YOUR_GITHUB_USERNAME` with your GitHub username or organization.
*   Replace `ansible-layered-dev-template` with the name of this repository.
*   Replace `my-new-project` with the desired name of your project directory.

Copier will prompt you for a series of configuration options. Provide appropriate values based on your project requirements.

### 3. Explore the Generated Project

After Copier finishes generating the project, navigate to the project directory:

```bash
cd my-new-project
```

Explore the generated files and directories to understand the project structure.

### 4. Install Project Dependencies

Run the `setup_container.sh` script to install all the project dependencies:

```bash
./scripts/setup_container.sh
```

### 5. Start the Development Environment

Run the `launch.sh` script to:

* Create Git worktrees for each agent.
* Start the Docker containers using Docker Compose.
* Launch Zellij with a predefined layout.

```bash
./scripts/launch.sh
```

### 6. Access the Containers

Zellij will create a terminal multiplexer with panes to access each of the containers to run code, or view data.

### 7. Initial Commit

Run commands

```bash
git init
git add .
git commit -m "Initial Commit"
```

## Development Workflow

### I. Creating New Agents
Leverage Nx. By integrating Nx, the template provides a more robust and scalable foundation for building complex agent systems. To add an Agent use the command

```bash
nx generate @nx/workspace:library <agent-name>
```

### II. Remote Development with VS Code Dev Containers

This template is designed to work seamlessly with VS Code Dev Containers.

1. **Open the Project in VS Code:** Open the generated project directory in VS Code.
2. **Reopen in Container:** If you have the "Remote - Containers" extension installed, VS Code will prompt you to reopen the project in a container. Click "Reopen in Container" to build and start the development container.

    *If prompted select "From `docker-compose.yml`".*

3. **Develop Remotely:** VS Code will connect to the container and provide a fully configured development environment, including:

    * Access to all project files and dependencies.
    * A terminal with `mise` activated.
    * Support for debugging, code completion, and other IDE features.
    * Automatically forwarded ports

### III. Working with Multiple Agents and Zellij

The `launch.sh` script starts Zellij with a predefined layout that includes panes for:

* The main project directory (where you can run commands like `nx build` and `git`).
* Each agent container.

You can use Zellij to:

* Switch between panes using keyboard shortcuts.
* Create new panes.
* Rearrange panes.
* Run commands in multiple containers simultaneously.

### IV. Running Tests

This template is designed to use jest testing framework, and provides an out of box testing system that can be run with

```bash
nx test <project-name>
```

### V. Port Configuration

These projects are already configured to have the follow values:

* `base_ide_port` = 9229
* `agent_ide_port_increment` = 1
* `num_ide_ports` = 1
* `number_of_worktrees` = 2

By modifying the values you can adjust how many network configurations can run.

### VI. Network Port Configuration

To setup network ports, configure the `docker-compose.yml` to expose the `apps/agent/port`

```yaml
ports:
  - "${AGENT_PORT:-3000}:${AGENT_PORT:-3000}"
```

Then add to the specific `.envs/*/.env` to expose these correctly. For example create the `.envs/agent1/.env` with

```config
AGENT_PORT=3000
```

## Key Concepts and Rationale

* **Monorepo Structure (Nx):** The template uses a monorepo structure to organize the code for the controller, agents, and shared libraries. This simplifies dependency management, code sharing, and refactoring.
* **Git Worktrees:** Git worktrees allow you to work on multiple branches simultaneously without having to switch between branches. Each agent gets its own worktree, enabling parallel development with feature branches.
* **Docker Layering:** The template uses a layered Docker image approach to optimize build times and reduce image sizes. The base image contains the core OS and minimal dependencies, while the build image adds the necessary tools for building the application, and the run image contains the application code and runtime dependencies.
* **Ansible for Provisioning:** Ansible automates the setup of the containers, ensuring that all dependencies are installed and configured correctly. This provides a consistent and reproducible environment.
* **VS Code Dev Containers:** VS Code Dev Containers provide a fully configured development environment within a Docker container. This eliminates the need for manual configuration of the development environment and ensures that all developers are working with the same tools and dependencies.

## Nx CLI Extensions

The template includes Nx CLI extensions for simplifying agent management. These extensions allow you to:

* Create new agents with a single command:

    ```bash
    nx generate @MY_TEMPLATE:agent --name=my-new-agent --type=python
    ```

* You can then view the tasks to run from the NX graph

```bash
nx graph
```

## Understanding the Project Structure

* `.devcontainer/`: Contains the VS Code Dev Container configuration files.
* Peer worktrees: Sibling directories like `<repo>-01`, `<repo>-02`, ... created next to the main repo to isolate IDE/AI crawlers from parent config files.
* `apps/`: Contains the source code for the controller and agents.
* `libs/`: Contains shared libraries.
* `tools/`: Contains Nx-related tools (generators, executors).
* `scripts/`: Contains utility scripts (e.g., `launch.sh`, `setup_container.sh`).
* `ansible/`: Contains Ansible playbooks and roles.
* `docker-compose.yml`: Defines the Docker containers and their configurations.
* `.gitignore`: Specifies files and directories that should be ignored by Git.
* `README.md`: This file, providing instructions and documentation for the project.
* `.mise.toml`: Specifies the tool versions managed by `mise`.
* `nx.json`: Configures the Nx workspace.
* `package.json`: Contains project dependencies and scripts.

## External Tooling Documentation

* **Copier:** [https://copier.readthedocs.io/](https://copier.readthedocs.io/)
* **Docker:** [https://docs.docker.com/](https://docs.docker.com/)
* **Nx:** [https://nx.dev/](https://nx.dev/)
* **Mise (Rtx):** [https://mise.jdx.gg/](https://mise.jdx.gg/)
* **Ansible:** [https://www.ansible.com/](https://www.ansible.com/)
* **Zellij:** [https://zellij.dev/](https://zellij.dev/)
* **VS Code Dev Containers:** [https://code.visualstudio.com/docs/remote/containers](https://code.visualstudio.com/docs/remote/containers)
* **Git Worktrees:** [https://git-scm.com/docs/git-worktree](https://git-scm.com/docs/git-worktree)

## Contributor Quickstart

* Regenerate ignore files (autogenerated from `.config/filelists/`):

    ```bash
    node bin/generate-ignores.js
    ```

* Use conventional commits for grouped logical changes, e.g.:

    ```bash
    git commit -m "docs(readme): document peer worktrees (<repo>-NN)"
    ```

* Review `docs/developer/IGNORE_FILES.md` for guidance on ignore sources and regeneration.

## Contributing

Contributions to this template are welcome! Please submit a pull request with your changes.

## License

AGPL-3.0-or-later