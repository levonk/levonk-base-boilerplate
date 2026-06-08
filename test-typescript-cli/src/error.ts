/**
 * Error Types and Exit Code Definitions
 *
 * This module defines standard error types and exit codes according to CLI Tool Standards ADR requirement #8.
 * Exit codes follow Unix conventions:
 * - 0: Success
 * - 1: Generic error
 * - 2: Usage error (invalid arguments, missing required args)
 * - 3: Network error (connection failures, timeouts)
 * - 4: Validation error (invalid config, schema validation failures)
 * - 5: File not found error
 * - 6: Permission denied error
 * - 130: SIGINT (Ctrl+C)
 */

/**
 * Standard exit codes
 */
export const EXIT_CODES = {
    SUCCESS: 0,
    GENERIC_ERROR: 1,
    USAGE_ERROR: 2,
    NETWORK_ERROR: 3,
    VALIDATION_ERROR: 4,
    FILE_NOT_FOUND: 5,
    PERMISSION_DENIED: 6,
    SIGINT: 130,
} as const;

/**
 * Base CLI error class that includes exit code information
 */
export class CLIError extends Error {
    readonly exitCode: number;
    readonly context?: Record<string, unknown>;

    constructor(message: string, exitCode: number, context?: Record<string, unknown>) {
        super(message);
        this.name = this.constructor.name;
        this.exitCode = exitCode;
        this.context = context;
        Error.captureStackTrace(this, this.constructor);
    }

    /**
     * Get a formatted error message with exit code information
     */
    getFormattedMessage(): string {
        const contextStr = this.context
            ? ` ${JSON.stringify(this.context)}`
            : '';
        return `${this.name}: ${this.message} (exit code: ${this.exitCode})${contextStr}`;
    }
}

/**
 * Generic error for unspecified issues
 */
export class GenericError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.GENERIC_ERROR, context);
    }
}

/**
 * Usage error for invalid arguments or missing required arguments
 */
export class UsageError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.USAGE_ERROR, context);
    }
}

/**
 * Network error for connection failures, timeouts, etc.
 */
export class NetworkError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.NETWORK_ERROR, context);
    }
}

/**
 * Validation error for invalid config, schema validation failures
 */
export class ValidationError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.VALIDATION_ERROR, context);
    }
}

/**
 * File not found error
 */
export class FileNotFoundError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.FILE_NOT_FOUND, context);
    }
}

/**
 * Permission denied error
 */
export class PermissionDeniedError extends CLIError {
    constructor(message: string, context?: Record<string, unknown>) {
        super(message, EXIT_CODES.PERMISSION_DENIED, context);
    }
}

/**
 * Error handler that maps errors to appropriate exit codes
 * @param error - The error to handle
 * @param logger - Optional logger for error output
 */
export function handleError(error: unknown, logger?: { error: (message: string) => void }): never {
    let exitCode: number = EXIT_CODES.GENERIC_ERROR;
    let message = 'An unexpected error occurred';

    if (error instanceof CLIError) {
        exitCode = error.exitCode;
        message = error.getFormattedMessage();
    } else if (error instanceof Error) {
        message = `${error.name}: ${error.message}`;
    } else if (typeof error === 'string') {
        message = error;
    }

    if (logger) {
        logger.error(message);
    } else {
        console.error(message);
    }

    process.exit(exitCode);
}

/**
 * Determine if an error is a specific CLI error type
 */
export function isCLIError(error: unknown, errorClass: new (message: string, context?: Record<string, unknown>) => CLIError): error is CLIError {
    return error instanceof errorClass;
}

/**
 * Get exit code from any error
 */
export function getExitCode(error: unknown): number {
    if (error instanceof CLIError) {
        return error.exitCode;
    }
    return EXIT_CODES.GENERIC_ERROR;
}
