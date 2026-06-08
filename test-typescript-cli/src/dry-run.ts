import fs from 'fs';
import path from 'path';
import { createLogger, Logger } from './logger.js';

export type DryRunOperationType = 'file' | 'network' | 'state' | 'config';

export interface DryRunOperation {
  type: DryRunOperationType;
  action: string;
  target?: string;
  details?: Record<string, unknown>;
}

export interface DryRunContext {
  enabled: boolean;
  operations: DryRunOperation[];
  logger: Logger;
}

export class DryRunManager {
  private context: DryRunContext;

  constructor(logger: Logger, enabled: boolean = false) {
    this.context = {
      enabled,
      operations: [],
      logger,
    };
  }

  /**
   * Check if dry-run mode is enabled
   */
  isEnabled(): boolean {
    return this.context.enabled;
  }

  /**
   * Enable dry-run mode
   */
  enable(): void {
    this.context.enabled = true;
    this.context.logger.info('Dry-run mode enabled');
  }

  /**
   * Disable dry-run mode
   */
  disable(): void {
    this.context.enabled = false;
    this.context.logger.info('Dry-run mode disabled');
  }

  /**
   * Log an operation that would be executed in dry-run mode
   */
  logOperation(operation: DryRunOperation): void {
    if (this.context.enabled) {
      this.context.operations.push(operation);
      const { type, action, target, details } = operation;
      const message = `[DRY-RUN] ${type.toUpperCase()}: ${action}${target ? ` -> ${target}` : ''}`;
      this.context.logger.info(message, details);
    }
  }

  /**
   * Get all logged operations
   */
  getOperations(): DryRunOperation[] {
    return [...this.context.operations];
  }

  /**
   * Clear all logged operations
   */
  clearOperations(): void {
    this.context.operations = [];
  }

  /**
   * Get operation count by type
   */
  getOperationCount(type?: DryRunOperationType): number {
    if (type) {
      return this.context.operations.filter(op => op.type === type).length;
    }
    return this.context.operations.length;
  }

  /**
   * Wrapper for file write operations
   */
  async writeFile(filePath: string, content: string): Promise<void> {
    this.logOperation({
      type: 'file',
      action: 'write',
      target: filePath,
      details: { size: content.length },
    });

    if (!this.context.enabled) {
      await fs.promises.writeFile(filePath, content, 'utf-8');
    }
  }

  /**
   * Wrapper for file delete operations
   */
  async deleteFile(filePath: string): Promise<void> {
    this.logOperation({
      type: 'file',
      action: 'delete',
      target: filePath,
    });

    if (!this.context.enabled) {
      await fs.promises.unlink(filePath);
    }
  }

  /**
   * Wrapper for directory creation operations
   */
  async createDirectory(dirPath: string): Promise<void> {
    this.logOperation({
      type: 'file',
      action: 'create-directory',
      target: dirPath,
    });

    if (!this.context.enabled) {
      await fs.promises.mkdir(dirPath, { recursive: true });
    }
  }

  /**
   * Wrapper for network requests (placeholder for actual implementation)
   */
  async networkRequest(url: string, method: string = 'GET', data?: unknown): Promise<unknown> {
    this.logOperation({
      type: 'network',
      action: method,
      target: url,
      details: { hasData: !!data },
    });

    if (this.context.enabled) {
      return { status: 'dry-run', url, method };
    }

    // Actual network request would go here
    // This is a placeholder - implement based on your HTTP client
    throw new Error('Network requests not implemented in dry-run wrapper');
  }

  /**
   * Wrapper for state changes
   */
  setState(key: string, value: unknown): void {
    this.logOperation({
      type: 'state',
      action: 'set',
      target: key,
      details: { value },
    });

    if (!this.context.enabled) {
      // Actual state change would go here
      // This is a placeholder - implement based on your state management
    }
  }

  /**
   * Wrapper for config changes
   */
  setConfig(key: string, value: unknown): void {
    this.logOperation({
      type: 'config',
      action: 'set',
      target: key,
      details: { value },
    });

    if (!this.context.enabled) {
      // Actual config change would go here
      // This is a placeholder - implement based on your config management
    }
  }

  /**
   * Get a summary of all operations
   */
  getSummary(): string {
    const summary: Record<string, number> = {
      file: 0,
      network: 0,
      state: 0,
      config: 0,
    };

    this.context.operations.forEach(op => {
      summary[op.type]++;
    });

    const lines = [
      'Dry-run Summary:',
      `  Total operations: ${this.context.operations.length}`,
      `  File operations: ${summary.file}`,
      `  Network operations: ${summary.network}`,
      `  State changes: ${summary.state}`,
      `  Config changes: ${summary.config}`,
    ];

    return lines.join('\n');
  }
}

/**
 * Create a new dry-run manager
 */
export function createDryRunManager(logger: Logger, enabled: boolean = false): DryRunManager {
  return new DryRunManager(logger, enabled);
}

/**
 * Global dry-run context (for use across modules)
 */
let globalDryRunManager: DryRunManager | null = null;

/**
 * Initialize global dry-run manager
 */
export function initGlobalDryRunManager(logger: Logger, enabled: boolean = false): void {
  globalDryRunManager = createDryRunManager(logger, enabled);
}

/**
 * Get global dry-run manager
 */
export function getGlobalDryRunManager(): DryRunManager | null {
  return globalDryRunManager;
}

/**
 * Check if global dry-run is enabled
 */
export function isDryRunEnabled(): boolean {
  return globalDryRunManager?.isEnabled() ?? false;
}
