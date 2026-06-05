# Using This Boilerplate

## Quick Start

This boilerplate uses [Copier](https://copier.readthedocs.io/) to generate new VSCode extension projects.

### Prerequisites

- [Copier](https://copier.readthedocs.io/) (Available via `flake.nix`)
- [Nix](https://nixos.org/download.html)
- [direnv](https://direnv.net/)

### Generate a New Extension

```bash
# From the repository root
copier copy boilerplate/apps/plugins/vscode/typescript apps/active/plugin/vscode/your-extension

# Or from anywhere
copier copy gh:lrepo52/job-aide/boilerplate/apps/plugins/vscode/typescript apps/active/plugin/vscode/your-extension
```

### Answer the Prompts

Copier will ask you several questions:

1. **Extension name**: Human-readable name (e.g., `My Awesome Extension`)
2. **Extension ID**: kebab-case ID (e.g., `my-awesome-extension`)
3. **Publisher**: Your marketplace publisher ID
4. **Description**: Brief description of your extension
5. **Author name**: Your name
6. **Author email**: Your email
7. **Repository URL**: GitHub repository URL

### Post-Generation Steps

1. **Navigate to the new project**:
   ```bash
   cd apps/active/plugin/vscode/your-extension
   ```

2. **Initialize Environment**:
   ```bash
   direnv allow
   ```
   This will automatically install Node.js, pnpm, vsce, and other dependencies via Nix.

3. **Install dependencies**:
   ```bash
   pnpm install
   ```

4. **Build the extension**:
   ```bash
   pnpm run build
   ```

5. **Run tests**:
   ```bash
   pnpm test
   ```

6. **Start developing**:
   - Open the project in VSCode
   - Press `F5` to launch the Extension Development Host
   - Start adding your features!

## What's Included

### Project Structure

```
your-extension/
├── .vscode/              # VSCode configuration
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
└── README.md             # Project README
```

### Features

- ✅ **TypeScript**: Full TypeScript support with strict mode
- ✅ **Testing**: Vitest testing framework with example tests
- ✅ **Linting**: ESLint configuration for code quality
- ✅ **Nix**: Reproducible development environment
- ✅ **pnpm**: Fast, disk-efficient package manager
- ✅ **VSCode Integration**: Debug configurations and tasks
- ✅ **Documentation**: Comprehensive docs and examples
- ✅ **CI/CD Ready**: Structure ready for CI/CD pipelines

### Example Command

The boilerplate includes a "Hello World" command as an example:

- Command ID: `{{ extension_id }}.helloWorld`
- Shows an information message when executed
- Fully tested with unit tests
- Demonstrates command registration pattern

## Customization

### Adding Commands

See `docs/DEVELOPMENT.md` for detailed instructions on:
- Adding new commands
- Registering configuration options
- Creating custom views
- Working with the VSCode API

### Modifying the Template

If you need to customize the boilerplate itself:

1. Edit files in `boilerplate/apps/plugins/vscode/typescript/`
2. Use Jinja2 template syntax for dynamic content:
   - `{{ extension_name }}` - Extension name variable
   - `{{ extension_id }}` - Extension ID variable
   - `{{ author_name }}` - Author name variable
3. Update `copier.yml` to add new questions or defaults
4. Test your changes by generating a new project

## Best Practices

### Development Workflow

1. **Use watch mode** during development:
   ```bash
   pnpm run watch
   ```

2. **Run tests frequently**:
   ```bash
   pnpm run test:watch
   ```

3. **Lint before committing**:
   ```bash
   pnpm run lint:fix
   ```

### Code Organization

- Keep `extension.ts` minimal (just activation/deactivation)
- Put command handlers in `commands.ts`
- Create separate files for complex features
- Use `utils.ts` for shared utility functions
- Write tests alongside your code

### Testing Strategy

- Unit test all utility functions
- Mock VSCode API in tests
- Test command registration
- Test error handling
- Aim for >80% code coverage

## Troubleshooting

### Copier Issues

**Error: "copier: command not found"**
```bash
direnv allow
# or
nix develop
```

**Error: Template not found**
- Ensure the path to the boilerplate is correct
- Check that all template files exist

### Build Issues

**TypeScript compilation errors**
- Run `pnpm install` to ensure dependencies are installed
- Check `tsconfig.json` for configuration issues
- Verify Node.js version (20.x or higher required)

### Extension Issues

**Extension not loading in VSCode**
- Check `package.json` for syntax errors
- Verify `activationEvents` are correct
- Look at Output panel (View → Output → Extension Host)
- Ensure TypeScript is compiled (`pnpm run build`)

## Resources

- [Copier Documentation](https://copier.readthedocs.io/)
- [VSCode Extension API](https://code.visualstudio.com/api)
- [Vitest Documentation](https://vitest.dev/)
- [pnpm Documentation](https://pnpm.io/)
- [Nix Documentation](https://nixos.org/learn.html)

## Support

For issues with the boilerplate itself:
1. Check existing documentation
2. Review example projects
3. Open an issue in the repository

For VSCode extension development questions:
- [VSCode Extension Samples](https://github.com/microsoft/vscode-extension-samples)
- [VSCode API Reference](https://code.visualstudio.com/api/references/vscode-api)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/vscode-extensions)
