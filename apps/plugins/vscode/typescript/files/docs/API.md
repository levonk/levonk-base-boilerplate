# API Documentation

## Extension API

### `activate(context: vscode.ExtensionContext): void`

Called when the extension is activated. This is the main entry point for the extension.

**Parameters:**
- `context`: The extension context provided by VSCode

**Example:**
```typescript
export function activate(context: vscode.ExtensionContext): void {
  console.log('Extension activated');
  // Register commands, providers, etc.
}
```

### `deactivate(): void`

Called when the extension is deactivated. Use this to clean up resources.

**Example:**
```typescript
export function deactivate(): void {
  console.log('Extension deactivated');
  // Clean up resources
}
```

## Commands

### `{{ extension_id }}.helloWorld`

Displays a "Hello World" information message.

**Usage:**
- Command Palette: Type "Hello World"
- Programmatically: `vscode.commands.executeCommand('{{ extension_id }}.helloWorld')`

## Utilities

### `formatMessage(message: string): string`

Formats a message with an ISO timestamp prefix.

**Parameters:**
- `message`: The message to format

**Returns:**
- A formatted string with timestamp: `[2024-01-01T12:00:00.000Z] message`

**Example:**
```typescript
const formatted = formatMessage('User action completed');
console.log(formatted);
// Output: [2024-01-01T12:00:00.000Z] User action completed
```

### `isEmptyOrWhitespace(str: string | undefined | null): boolean`

Checks if a string is empty, null, undefined, or contains only whitespace.

**Parameters:**
- `str`: The string to check

**Returns:**
- `true` if the string is empty or whitespace, `false` otherwise

**Example:**
```typescript
isEmptyOrWhitespace('');        // true
isEmptyOrWhitespace('   ');     // true
isEmptyOrWhitespace(null);      // true
isEmptyOrWhitespace(undefined); // true
isEmptyOrWhitespace('hello');   // false
```

### `capitalize(str: string): string`

Capitalizes the first letter of a string.

**Parameters:**
- `str`: The string to capitalize

**Returns:**
- The string with the first letter capitalized

**Example:**
```typescript
capitalize('hello');  // 'Hello'
capitalize('Hello');  // 'Hello'
capitalize('');       // ''
```

## Extension Context

The extension context provides access to:

- `subscriptions`: Array of disposables that will be disposed when the extension deactivates
- `workspaceState`: Workspace-specific state storage
- `globalState`: Global state storage across workspaces
- `extensionPath`: Absolute path to the extension directory
- `storagePath`: Workspace-specific storage path
- `globalStoragePath`: Global storage path

**Example:**
```typescript
export function activate(context: vscode.ExtensionContext): void {
  // Store data
  context.globalState.update('myKey', 'myValue');
  
  // Retrieve data
  const value = context.globalState.get<string>('myKey');
  
  // Register disposable
  const disposable = vscode.commands.registerCommand('myCommand', () => {});
  context.subscriptions.push(disposable);
}
```

## Configuration

Access extension configuration using the VSCode configuration API:

```typescript
const config = vscode.workspace.getConfiguration('{{ extension_id }}');
const value = config.get<string>('settingName');

// Update configuration
config.update('settingName', 'newValue', vscode.ConfigurationTarget.Global);
```

## Events

Subscribe to VSCode events:

```typescript
// Document changes
vscode.workspace.onDidChangeTextDocument((event) => {
  console.log('Document changed:', event.document.uri);
});

// Configuration changes
vscode.workspace.onDidChangeConfiguration((event) => {
  if (event.affectsConfiguration('{{ extension_id }}')) {
    console.log('Extension configuration changed');
  }
});

// Window state changes
vscode.window.onDidChangeActiveTextEditor((editor) => {
  console.log('Active editor changed:', editor?.document.uri);
});
```

## Error Handling

Best practices for error handling:

```typescript
try {
  // Your code
} catch (error) {
  if (error instanceof Error) {
    vscode.window.showErrorMessage(`Error: ${error.message}`);
    console.error('Detailed error:', error);
  } else {
    vscode.window.showErrorMessage('An unknown error occurred');
  }
}
```

## Testing

Mock VSCode API in tests:

```typescript
import { vi } from 'vitest';

vi.mock('vscode', () => ({
  commands: {
    registerCommand: vi.fn(),
  },
  window: {
    showInformationMessage: vi.fn(),
  },
}));
```

## Type Definitions

The extension uses TypeScript with strict mode enabled. All VSCode API types are available through the `@types/vscode` package.

```typescript
import * as vscode from 'vscode';

// Use VSCode types
const editor: vscode.TextEditor | undefined = vscode.window.activeTextEditor;
const document: vscode.TextDocument = editor.document;
const position: vscode.Position = new vscode.Position(0, 0);
```
