# {{ extension_name }}

{{ description }}

## Features

- **Command Palette Integration**: Access extension commands via the command palette
- **TypeScript Support**: Fully typed with TypeScript for better development experience
- **Testing**: Comprehensive test suite with Vitest
- **Linting**: ESLint configuration for code quality
- **Nix Environment**: Reproducible development environment

## Requirements

- VSCode ^1.85.0 or higher
- Node.js 20.x or higher
- pnpm package manager

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone {{ repository_url }}
   cd {{ extension_id }}
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

3. Build the extension:
   ```bash
   pnpm run build
   ```

4. Press `F5` to open a new VSCode window with the extension loaded

## Development

### Environment Setup

This project uses [Nix](https://nixos.org/) and [direnv](https://direnv.net/) to provide a consistent development environment.

```bash
direnv allow
```

This will automatically install `node`, `pnpm`, `vsce`, `ovsx`, and other tools.

### Building

```bash
# Build the extension (uses tsup)
pnpm run build

# Compile TypeScript only
pnpm run compile

# Watch mode for development
pnpm run watch
```

### Testing

```bash
# Run tests
pnpm test

# Run tests in watch mode
pnpm run test:watch

# Run tests with coverage
pnpm run test:coverage
```

### Linting

```bash
# Lint code
pnpm run lint

# Fix linting issues
pnpm run lint:fix
```

## Usage

1. Open the Command Palette (`Cmd+Shift+P` on macOS or `Ctrl+Shift+P` on Windows/Linux)
2. Type "Hello World" to see the example command
3. Select the command to execute it

## Extension Commands

This extension contributes the following commands:

- `{{ extension_id }}.helloWorld`: Display a Hello World message

## Project Structure

```
.
├── .vscode/              # VSCode configuration
│   ├── launch.json       # Debug configuration
│   ├── tasks.json        # Build tasks
│   ├── extensions.json   # Recommended extensions
│   └── settings.json     # Workspace settings
├── src/                  # Source code
│   ├── extension.ts      # Extension entry point
│   ├── commands.ts       # Command handlers
│   └── utils.ts          # Utility functions
├── __tests__/            # Test files
├── docs/                 # Documentation
├── package.json          # Extension manifest
├── tsconfig.json         # TypeScript configuration
├── vitest.config.ts      # Vitest configuration
├── flake.nix             # Nix environment definition
├── Makefile              # Task runner
└── README.md             # This file
```

## Publishing

### Package the Extension

```bash
pnpm run package
```

This creates a `.vsix` file that can be installed manually or published to the marketplace.

### Publish to Marketplace

1. Create a publisher account at https://marketplace.visualstudio.com/
2. Get a Personal Access Token (PAT)
3. Publish the extension:

```bash
pnpm run publish:ms
```

### Publish to Open VSX

```bash
pnpm run publish:ovsx
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT

## Author

{{ author_name }} <{{ author_email }}>

## Links

- [Repository]({{ repository_url }})
- [Issues]({{ repository_url }}/issues)
- [VSCode Extension API](https://code.visualstudio.com/api)

---

**Enjoy!**
