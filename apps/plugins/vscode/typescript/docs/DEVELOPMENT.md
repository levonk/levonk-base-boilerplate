# Development Guide

## Prerequisites

- [Nix](https://nixos.org/download.html)
- [direnv](https://direnv.net/)
- VSCode ^1.85.0 or higher

## Setup

1. **Initialize Environment**:
   Allow direnv to load the Nix flake environment. This will install Node.js, pnpm, vsce, and other tools automatically.
   ```bash
   direnv allow
   ```

2. **Install dependencies**:
   ```bash
   pnpm install
   ```

3. **Build the extension**:
   ```bash
   pnpm run build
   ```
   Or using Make:
   ```bash
   make build
   ```

4. **Run in development mode**:
   - Press `F5` in VSCode to open a new Extension Development Host window
   - The extension will be loaded and ready to test

## Development Workflow

### TypeScript Compilation

The extension uses TypeScript for type safety and better development experience.

```bash
# Build (uses tsup)
pnpm run build

# Compile only (uses tsc)
pnpm run compile

# Watch mode (automatically recompile on changes)
pnpm run watch
```

### Testing

Tests are written using Vitest and can be run in multiple ways:

```bash
# Run all tests once
pnpm test

# Run tests in watch mode
pnpm run test:watch

# Run tests with coverage
pnpm run test:coverage
```

### Linting

ESLint is configured to maintain code quality:

```bash
# Check for linting errors
pnpm run lint

# Automatically fix linting errors
pnpm run lint:fix
```

### Debugging

1. Set breakpoints in your TypeScript code
2. Press `F5` to start debugging
3. The Extension Development Host will launch with the debugger attached
4. Execute commands to trigger your breakpoints

## Project Structure

```
.
├── .vscode/              # VSCode configuration
├── src/                  # Source code
│   ├── extension.ts      # Main entry point
│   ├── commands.ts       # Command handlers
│   └── utils.ts          # Utility functions
├── __tests__/            # Test files
├── docs/                 # Documentation
├── package.json          # Extension manifest
├── tsconfig.json         # TypeScript configuration
├── vitest.config.ts      # Vitest configuration
├── flake.nix             # Nix environment definition
└── Makefile              # Task runner
```

## Adding New Features

### Adding a Command

1. **Register the command in `package.json`**:
   ```json
   "contributes": {
     "commands": [
       {
         "command": "{{ extension_id }}.myCommand",
         "title": "My Command"
       }
     ]
   }
   ```

2. **Implement the command in `src/commands.ts`**:
   ```typescript
   import * as vscode from 'vscode';

   export function myCommand(): void {
     vscode.window.showInformationMessage('My command executed!');
   }
   ```

3. **Register the command in `src/extension.ts`**:
   ```typescript
   const disposable = vscode.commands.registerCommand(
     '{{ extension_id }}.myCommand',
     myCommand
   );
   context.subscriptions.push(disposable);
   ```

4. **Add tests in `__tests__/commands.test.ts`**:
   ```typescript
   import { describe, it, expect, vi } from 'vitest';
   import { myCommand } from '../src/commands';

   describe('myCommand', () => {
     it('should execute without errors', () => {
       expect(() => myCommand()).not.toThrow();
     });
   });
   ```

### Adding Configuration

1. **Define configuration in `package.json`**:
   ```json
   "contributes": {
     "configuration": {
       "title": "{{ extension_name }}",
       "properties": {
         "{{ extension_id }}.mySetting": {
           "type": "string",
           "default": "default value",
           "description": "Description of my setting"
         }
       }
     }
   }
   ```

2. **Access configuration in code**:
   ```typescript
   const config = vscode.workspace.getConfiguration('{{ extension_id }}');
   const mySetting = config.get<string>('mySetting');
   ```

## Building for Production

### Package the Extension

```bash
pnpm run package
```

This creates a `.vsix` file in the project root that can be:
- Installed manually in VSCode
- Shared with others
- Published to the marketplace

### Publishing to Marketplace

1. **Create a publisher account**:
   - Visit https://marketplace.visualstudio.com/
   - Sign in with your Microsoft account
   - Create a publisher profile

2. **Get a Personal Access Token (PAT)**:
   - Go to https://dev.azure.com/
   - Create a new PAT with `Marketplace (Manage)` scope

3. **Login with vsce**:
   ```bash
   npx vsce login {{ publisher }}
   ```

4. **Publish**:
   ```bash
   pnpm run publish:ms
   ```

## Best Practices

### Code Quality

- Write tests for all new features
- Maintain >80% code coverage
- Follow TypeScript strict mode
- Use ESLint rules consistently
- Document public APIs with JSDoc comments

### Performance

- Lazy load heavy dependencies
- Use activation events appropriately
- Avoid blocking the main thread
- Dispose of resources properly

### User Experience

- Provide clear error messages
- Use progress indicators for long operations
- Follow VSCode's UX guidelines
- Test with different themes and settings

## Troubleshooting

### Extension Not Loading

1. Check the Output panel (View → Output → Extension Host)
2. Verify `package.json` is valid JSON
3. Ensure all activation events are correct
4. Check for TypeScript compilation errors

### Tests Failing

1. Run `pnpm run compile` to ensure code is built
2. Check test output for specific errors
3. Verify mock configurations are correct
4. Ensure test environment matches runtime

### Build Errors

1. Clean build artifacts: `pnpm run clean`
2. Reinstall dependencies: `pnpm run clean:hard && pnpm install`
3. Verify Node.js and pnpm versions

## Resources

- [VSCode Extension API](https://code.visualstudio.com/api)
- [Extension Guidelines](https://code.visualstudio.com/api/references/extension-guidelines)
- [Publishing Extensions](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
- [Testing Extensions](https://code.visualstudio.com/api/working-with-extensions/testing-extension)
