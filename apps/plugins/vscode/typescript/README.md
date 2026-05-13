# VS Code Extension Boilerplate

A production-ready boilerplate for building VS Code extensions using TypeScript, Copier, and Nix.

## Features

- **Monorepo Ready**: Designed to work within the `job-aide` monorepo structure.
- **Nix Environment**: Fully reproducible development environment via `flake.nix`.
- **TypeScript & Vitest**: Modern tooling for type safety and testing.
- **Automated Publishing**: Scripts for publishing to both Microsoft Marketplace and Open VSX.
- **Linting & Formatting**: Pre-configured with ESLint.

## Usage

To create a new extension using this boilerplate:

1.  **Enter Development Environment**:
    Ensure you are in a Nix environment with Copier available (e.g. via `flake.nix`):
    ```bash
    direnv allow
    # or
    nix develop
    ```

2.  **Run Copier**:
    Navigate to your desired destination (e.g., repository root) and run:
    ```bash
    copier copy --trust boilerplate/apps/plugins/vscode/typescript .
    ```

3.  **Answer the Questions**:
    You will be prompted for:
    - **Extension Name**: (e.g., "My Awesome Extension")
    - **Extension ID**: (e.g., "my-awesome-extension")
    - **Publisher**: (e.g., "my-org")
    - **Description**: Short description.
    - **Author Details**: Name and email.

4.  **Get Started**:
    Navigate to the created directory:
    ```bash
    cd apps/active/plugin/vscode/my-awesome-extension
    direnv allow
    code .
    ```

## Directory Structure

The boilerplate creates the following structure:

```
apps/active/plugin/vscode/
└── <extension-id>/
    ├── src/
    ├── .envrc
    ├── flake.nix
    ├── Makefile
    ├── package.json
    └── ...
```

## Documentation

- [API](./docs/API.md)
- [Development](./docs/DEVELOPMENT.md)
- [Usage](./docs/USAGE.md)
