# Base Boilerplate: Requirements for Ansible Layered Dev Template

This document outlines the requirements for the `ansible-layered-dev-template`, a Copier template designed to generate highly configurable and optimized development environments for complex, agent-based systems.

## I. Overall Goals

The primary goals of this template are to:

*   **Automate Environment Setup:** Streamline the process of creating new development environments with a single command.
*   **Ensure Reproducibility:** Guarantee consistent environments across different machines and developers.
*   **Promote Scalability:** Provide a scalable architecture for managing monorepos with multiple agents, controllers, and shared libraries.
*   **Optimize Development Workflow:** Enable efficient parallel development, code hot reloading, and remote debugging.
*   **Leverage Best Practices:** Incorporate industry best practices for containerization, provisioning, build orchestration, and dependency management.

## II. Core Technologies

The template should leverage the following core technologies:

*   **Copier:** For project templating and initialization.
*   **mise (rtx):** For managing tool versions (Python, Node.js, Flutter, etc.).
*   **Docker:** For containerization and environment isolation.
*   **Ansible:** For build-time and runtime provisioning.
*   **Zellij:** For terminal multiplexing and managing multiple agent containers.
*   **VS Code Dev Containers:** For seamless remote development with a fully configured environment.
*   **Git Worktrees:** For parallel agent development with feature branches.

## III. User Input Variables (Copier Questions)

The following variables should be configurable via Copier questions:

*   `project_name` (string): The name of the project. Default: "my-agentic-project"
*   `gh_namespace` (string): Your GitHub namespace (username or organization). Used for Docker image names and repository paths. Default: "my-gh-namespace"
*   `base_image` (string): The base Docker image to use for the containers. Default: "ubuntu:latest"
*   `number_of_worktrees` (integer): The number of worktrees to create. Default: 2
*   `worktree_prefix` (string): The prefix for worktree names. Default: "dev"
*    `container_user` (string): The username inside the container for development. Default: "devuser"
*    `container_group` (string): The group name inside the container for development. Default: "devgroup"
*   `container_user_id` (string): The user id inside the container. Default: "1000"
*    `container_group_id` (string): The group id inside the container. Default: "1000"
*   `project_type` (choice): The type of project (e.g., "python", "nodejs", "ansible", "dotfiles"). Options should be customizable.
    *   Example Options: `["python", "nodejs", "ansible", "dotfiles", "other"]`
*   `project_dependencies` (string, multiline): A list of project-specific dependencies to install (e.g., pip packages, npm modules), one per line.
*   `container_setup_ansible_roles` (string, multiline): A list of Ansible Galaxy roles to install and apply during container setup (before development), one per line.
*   `development_runtime_ansible_roles` (string, multiline): A list of Ansible Galaxy roles to install and apply when the development environment starts (e.g., for configuring dotfiles), one per line.
*   `dotfiles_repository` (string): URL of the dotfiles repository to clone (if `project_type` is "dotfiles").
*   `dotfiles_destination` (string): The destination directory inside the container to copy the dotfiles to.
*   `expose_ports` (string): Ports to expose from docker-compose.yml, e.g. "8000:8000,3000:3000"
*   `use_devcontainer` (boolean): Whether to include `.devcontainer` setup. Default: True
*   `create_feature_branches` (boolean): Whether to create a feature branch for each worktree. Default: True
*   `initial_commit` (boolean): Whether to perform an initial commit after setup. Default: True
*   `zellij_layout` (string): Content of the zellij layout.
*   `mise_languages` (string, multiline): A list of languages and versions to manage with `mise` (e.g., `python 3.11`, `nodejs 18`, `flutter 3.0`). One per line. If this is defined, it should generate the .mise.toml file.
*   `agent_os_repository` (string): URL of the Git repository containing the base "agent-os" configuration (e.g., a minimal Ubuntu image with common tools).
*   `agent_os_tag` (string): The tag or branch to use from the `agent_os_repository`. Default: "latest".
*   `build_time_ansible_roles` (string, multiline): Ansible Galaxy roles to apply during the *build* phase (image creation). One per line.
*   `runtime_ansible_roles` (string, multiline): Ansible Galaxy roles to apply at *runtime* (when the containers start). One per line.
*   `separate_test_container` (boolean): Whether to use a separate container for running tests. Default: `false`.
*   `ide_support` (choice): Specifies the IDE support to include in the container. Options: `["none", "vscode", "intellij"]`. Default: "vscode".
*   `base_ide_port` (integer): The base port number to use for IDE connections. Agent containers will increment from this port. Default: 9229.
*   `agent_ide_port_increment` (integer): The amount to increment the IDE port for each new agent. Default: `1`.
*   `num_ide_ports` (integer): The number of ports per agent to open. This may vary based on the IDE. Default `1`.
*   `container_share_package_cache` (boolean): Whether to share package manager cache directories between the host and container. Default: `true`

## IV. Template Structure (Generated Output)

The template should generate the following directory structure and files:

```text
{{ project_name }}/
├── .devcontainer/             (Conditional: if use_devcontainer)
│   ├── devcontainer.json
│   ├── Dockerfile.base       (Base image - Agent OS)
│   ├── Dockerfile.build      (Build-time provisioning)
│   └── Dockerfile.run        (Runtime image - Agents + Controller)
├── <peer worktrees>              (Created at runtime as sibling dirs to repo)
│   ├── <repo>-01
│   ├── <repo>-02
│   └── ...                (up to number_of_worktrees)
├── apps/                      (Controller and agents)
│   ├── controller/
│   │   ├── src/
│   │   │   ├── main.py
│   │   │   └── ...
│   │   └── ...
│   ├── agent1/
│   │   ├── src/
│   │   │   ├── agent.py
│   │   │   └── ...
│   │   └── ...
│   └── ...                (More agent projects based on number_of_worktrees)
├── libs/                      (Shared libraries)
│   ├── src/
│   │   ├── index.ts (or index.py)
│   │   └── ...
│   └── ...
├── tools/                     (Tools)
│   └── ...
├── scripts/
│   ├── launch.sh
│   ├── setup_container.sh
│   ├── setup_development.sh
│   └── ...
├── ansible/                 (Optional: if build_time_ansible_roles or runtime_ansible_roles)
│   ├── requirements.yml
│   ├── build_time.yml
│   └── runtime.yml
├── docker-compose.yml
├── .gitignore
├── README.md
├── .mise.toml         (Conditional: if mise_languages)
└── .envs/               (Environment Variables)
│    ├── agent1/.env      (Agent Specific Environment)
│    └── agent2/.env
```

## V. File Content Requirements

The following requirements apply to the content of specific files:

*   **`.devcontainer/Dockerfile.base` (Agent OS):**
    *   Set the base image from the user-provided `agent_os_repository` and `agent_os_tag`.
    *   Install Git.
    *   Create the development user and group with specified `container_user_id` and `container_group_id`.
    *   Set permissions to user and usergroup.
    *   Set the user for running the service.
*   **`.devcontainer/Dockerfile.build` (Build-Time Provisioning):**
    *   FROM your-base-image:latest  # Based on agent_os_repository
    *   Install Ansible.
    *   Copy Ansible playbooks and requirements.
    *   Run Ansible build-time provisioning.
*   **`.devcontainer/Dockerfile.run` (Runtime Image):**
    *   FROM your-build-image:latest # Based on the build image
    *   Copy the rest of the application code, etc.
    *   Set environment vars with source for mise
    *   CMD ["/bin/bash", "/home/devuser/app/scripts/setup_development.sh"]
*   **`docker-compose.yml`:**
    *   Dynamically generates container configurations based on `number_of_worktrees`.
    *   Uses the `base_image`.
    *   Mounts project directory.
    *   Sets user and group inside the container.
    *   Dynamically maps IDE ports based on `base_ide_port`, `agent_ide_port_increment`, and `num_ide_ports`.
    *   Loads environment variables from `.envs/agentX/.env`.
*   **`ansible/requirements.yml`:**
    *   Defines Ansible Galaxy roles for both build-time and runtime provisioning.
*   **`ansible/build_time.yml`:**
    *   Defines tasks to be executed during the build phase (image creation).
*   **`ansible/runtime.yml`:**
    *   Defines tasks to be executed at runtime (when the containers start).
*   **`scripts/setup_container.sh`:**
    *   Installs `mise` and configures it.
    *   Installs project dependencies based on `project_type` and `project_dependencies`.
    *   Installs and runs Ansible roles from `container_setup_ansible_roles`.
*   **`scripts/setup_development.sh`:**
    *   Clones the dotfiles repository (if `project_type` is "dotfiles").
    *   Installs and runs Ansible roles from `development_runtime_ansible_roles`.
*   **`.gitignore`:**
    *   `node_modules/` (if NodeJS project)
    *   `__pycache__/` (if Python project)
    *   `.venv/`
    *   `.local/`
*   **`.mise.toml`:**
    *   Specifies the tool versions managed by `mise`, based on the user-provided `mise_languages`.

## VI. Workflow

1.  **Generate Project:** Use the Copier template to generate the project.
2.  **Install Project Dependencies:**
      Run the `setup_container.sh` script to install all the project dependencies:

    ```bash
       ./scripts/setup_container.sh
    ```
4.  **Start the Development Environment:** Run the `launch.sh` script
    ```bash
       ./scripts/launch.sh
    ```
5.   **Access the Containers:**
    Zellij will create a terminal multiplexer with panes to access each of the containers to run code, or view data.
6.  **Develop Code:** Develop within a Remote Container on VSCode or an editor of choice.

## VIII. Key Considerations

*   **Security:**
    *   Minimize container privileges.
    *   Use Docker user namespaces.
    *   Integrate security scanning.
    *   Implement secure secrets management.
    *   Configure firewall rules.
    *   Keep dependencies up-to-date.
*   **Monitoring and Logging:**
    *   Implement centralized logging.
    *   Collect metrics for performance monitoring.
    *   Define health checks.
    *   Set up alerting for potential issues.
*   **Scalability and Performance:**
    *   Set resource limits for containers.
    *   Design for horizontal scaling.
    *   Implement load balancing and caching.
*   **User Experience:**
    *   Provide clear documentation and examples.
    *   Generate informative error messages.
    *   Streamline the setup process.
* **Directory Naming Conventions:** Ensure consistant naming and organization across the entire project.

## IX. Eliminating Redundancy

*   The template must eliminate the need to manually edit `docker-compose.yml` for port configuration. All port mappings should be automatically generated based on the Copier variables.
*   The ideal development cycle must be as seemless as possible.

This comprehensive list of requirements will help guide the development of a robust, scalable, and user-friendly template for building complex, agent-based systems. This outline also helps organize each aspect of the tech stack used.

## X. Removing Peer Worktrees Safely

When using peer worktrees (e.g., `<repo>-01`, `<repo>-02`), remove them safely to avoid corrupting the main repository:

1. Ensure the worktree has no uncommitted changes.
2. Identify the worktree path and branch:

    ```bash
    git worktree list
    ```

3. Remove the worktree from Git, which also cleans internal references:

    ```bash
    git worktree remove <path-to-worktree>
    # If the worktree is busy or has issues, use --force
    # git worktree remove --force <path-to-worktree>
    ```

4. Optionally delete the associated branch if it is no longer needed:

    ```bash
    git branch -d <branch-name>
    # Or force if not merged: git branch -D <branch-name>
    ```

5. If the directory still exists (e.g., due to external files), remove it from the filesystem:

    ```bash
    rm -rf <path-to-worktree>
    ```

Notes:

* Never delete the `.git` directory inside the main repository.
* Always run `git worktree remove` first so Git unregisters the worktree cleanly.
