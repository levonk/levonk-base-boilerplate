/**
 * Error Types and Exit Code Definitions
 *
 * This module defines standard error types and exit codes according to CLI Tool Standards ADR requirements:
 * - Requirement #8: Standard exit codes
 * - Requirement #14: Error message formatting with suggestions
 *
 * Exit codes follow Unix conventions:
 * - 0: Success
 * - 1: Generic error
 * - 2: Usage error (invalid arguments, missing required args)
 * - 3: Network error (connection failures, timeouts)
 * - 4: Validation error (invalid config, schema validation failures)
 * - 5: File not found error
 * - 6: Permission denied error
 * - 130: SIGINT (Ctrl+C)
 *
 * Error message format (ADR #14):
 * ERROR: <description> - <suggestion>
 *
 * Where:
 * - <description>: Clear, concise description of what went wrong
 * - <suggestion>: Actionable suggestion for how to fix the issue
 */

import { formatErrorFileRef, type FileLocation } from './file-ref.js';
import { redactSecretsFromObject, detectSecrets } from './secrets.js';

/**
 * Error categories for suggestion generation
 */
export type ErrorCategory =
    | 'usage'
    | 'network'
    | 'validation'
    | 'file_not_found'
    | 'permission_denied'
    | 'generic';

/**
 * Suggestion generator for error messages
 * Provides contextual suggestions based on error type and context
 */
export class SuggestionGenerator {
    /**
     * Generate a suggestion based on error type and context
     * @param errorType - Type of error
     * @param context - Optional context information
     * @returns Actionable suggestion string
     */
    static generate(errorType: ErrorCategory, context?: Record<string, unknown>): string | undefined {
        switch (errorType) {
            case 'usage':
                return this.generateUsageSuggestion(context);
            case 'network':
                return this.generateNetworkSuggestion(context);
            case 'validation':
                return this.generateValidationSuggestion(context);
            case 'file_not_found':
                return this.generateFileNotFoundSuggestion(context);
            case 'permission_denied':
                return this.generatePermissionDeniedSuggestion(context);
            case 'generic':
                return this.generateGenericSuggestion(context);
            default:
                return undefined;
        }
    }

    private static generateUsageSuggestion(context?: Record<string, unknown>): string {
        if (context?.missing_arg) {
            return `Provide the required argument: ${context.missing_arg}`;
        }
        if (context?.invalid_arg) {
            return `Check the argument value: ${context.invalid_arg}`;
        }
        return 'Run with --help to see usage information';
    }

    private static generateNetworkSuggestion(context?: Record<string, unknown>): string {
        if (context?.url) {
            return `Check your network connection and verify the URL: ${context.url}`;
        }
        return 'Check your network connection and try again';
    }

    private static generateValidationSuggestion(context?: Record<string, unknown>): string {
        if (context?.field) {
            return `Fix the validation error in field: ${context.field}`;
        }
        if (context?.config_file) {
            return `Check your configuration file: ${context.config_file}`;
        }
        return 'Review your configuration and fix validation errors';
    }

    private static generateFileNotFoundSuggestion(context?: Record<string, unknown>): string {
        if (context?.path) {
            return `Verify the file exists at: ${context.path}`;
        }
        return 'Check that the file exists and the path is correct';
    }

    private static generatePermissionDeniedSuggestion(context?: Record<string, unknown>): string {
        if (context?.path) {
            return `Check permissions for: ${context.path}`;
        }
        return 'Check file permissions and try again with appropriate access';
    }

    private static generateGenericSuggestion(context?: Record<string, unknown>): string {
        return 'Try again or contact support if the issue persists';
    }
}

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
 * Base CLI error class that includes exit code information and suggestions
 */
export class CLIError extends Error {
    readonly exitCode: number;
    readonly context?: Record<string, unknown>;
    readonly fileLocation?: FileLocation;
    readonly suggestion?: string;

    constructor(
        message: string,
        exitCode: number,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message);
        this.name = this.constructor.name;
        this.exitCode = exitCode;
        this.context = context;
        this.fileLocation = fileLocation;
        this.suggestion = suggestion;
        Error.captureStackTrace(this, this.constructor);
    }

    /**
     * Get a formatted error message following ADR #14 format:
     * ERROR: <description> - <suggestion>
     */
    getFormattedMessage(): string {
        // Redact secrets from message and context
        const redactedMessage = this.redactSecrets(this.message);
        const redactedSuggestion = this.suggestion ? this.redactSecrets(this.suggestion) : undefined;
        const redactedContext = this.context ? redactSecretsFromObject(this.context) : undefined;

        // Build the error message in ADR #14 format
        let message = `ERROR: ${redactedMessage}`;

        // Add suggestion if available
        if (redactedSuggestion) {
            message += ` - ${redactedSuggestion}`;
        }

        // Add file reference if available
        if (this.fileLocation) {
            message += ` ${formatErrorFileRef(this.fileLocation)}`;
        }

        // Add context if available
        if (redactedContext) {
            message += ` ${JSON.stringify(redactedContext)}`;
        }

        return message;
    }

    /**
     * Redact secrets from a message string
     * @param message - Message to redact
     * @returns Redacted message
     */
    private redactSecrets(message: string): string {
        const secrets = detectSecrets(message);
        if (secrets.length === 0) {
            return message;
        }

        // Import redactSecrets dynamically to avoid circular dependency
        const { redactSecrets: redact } = require('./secrets.js');
        return redact(message, secrets);
    }
}

/**
 * Generic error for unspecified issues
 */
export class GenericError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.GENERIC_ERROR, context, fileLocation, suggestion);
    }
}

/**
 * Usage error for invalid arguments or missing required arguments
 */
export class UsageError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.USAGE_ERROR, context, fileLocation, suggestion);
    }
}

/**
 * Network error for connection failures, timeouts, etc.
 */
export class NetworkError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.NETWORK_ERROR, context, fileLocation, suggestion);
    }
}

/**
 * Validation error for invalid config, schema validation failures
 */
export class ValidationError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.VALIDATION_ERROR, context, fileLocation, suggestion);
    }
}

/**
 * File not found error
 */
export class FileNotFoundError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.FILE_NOT_FOUND, context, fileLocation, suggestion);
    }
}

/**
 * Permission denied error
 */
export class PermissionDeniedError extends CLIError {
    constructor(
        message: string,
        context?: Record<string, unknown>,
        fileLocation?: FileLocation,
        suggestion?: string
    ) {
        super(message, EXIT_CODES.PERMISSION_DENIED, context, fileLocation, suggestion);
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
