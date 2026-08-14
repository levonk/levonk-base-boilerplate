# Configuration Options

## Modes

- **`--mode=compatible`** (default): Add missing tooling without overwriting
- **`--mode=enhance`**: Add tooling and enhance existing configurations
- **`--mode=minimal`**: Only add absolutely essential missing tooling

## Tool Categories

- **`--add-linting`**: Add ESLint, Prettier, or equivalent linting tools
- **`--add-ci`**: Add GitHub Actions or other CI configuration
- **`--add-dev-env`**: Add devbox.json and justfile (if compatible)
- **`--add-docs`**: Add documentation structure and tools
- **`--add-tests`**: Add testing framework and configuration

## Preservation Options

- **`--preserve-existing`**: Don't modify existing configuration files
- **`--preserve-workflows`**: Don't change existing scripts or commands
- **`--preserve-tools`**: Don't replace existing tools with alternatives
