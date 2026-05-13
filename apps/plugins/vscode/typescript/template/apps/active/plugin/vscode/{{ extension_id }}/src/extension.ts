import * as vscode from 'vscode';

/**
 * This method is called when the extension is activated.
 * The extension is activated the very first time a command is executed.
 */
export function activate(context: vscode.ExtensionContext): void {
  console.log('Extension "{{ plugin_name | slugify }}" is now active!');

  // Register the hello world command
  const disposable = vscode.commands.registerCommand(
    '{{ plugin_name | slugify }}.helloWorld',
    () => {
      vscode.window.showInformationMessage('Hello World from {{ display_name }}!');
    }
  );

  context.subscriptions.push(disposable);
}

/**
 * This method is called when the extension is deactivated.
 */
export function deactivate(): void {
  console.log('Extension "{{ plugin_name | slugify }}" is now deactivated.');
}
