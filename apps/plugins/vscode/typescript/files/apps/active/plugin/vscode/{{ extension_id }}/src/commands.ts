import * as vscode from 'vscode';

/**
 * Example command handler
 */
export function helloWorld(): void {
  vscode.window.showInformationMessage('Hello World from {{ display_name }}!');
}

/**
 * Register all commands for the extension
 */
export function registerCommands(context: vscode.ExtensionContext): void {
  const commands = [
    vscode.commands.registerCommand('{{ plugin_name | slugify }}.helloWorld', helloWorld),
  ];

  commands.forEach((command) => context.subscriptions.push(command));
}
