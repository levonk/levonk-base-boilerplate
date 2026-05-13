/**
 * Utility functions for the extension
 */

/**
 * Format a message with a timestamp
 */
export function formatMessage(message: string): string {
  const timestamp = new Date().toISOString();
  return `[${timestamp}] ${message}`;
}

/**
 * Check if a string is empty or whitespace
 */
export function isEmptyOrWhitespace(str: string | undefined | null): boolean {
  return !str || str.trim().length === 0;
}

/**
 * Capitalize the first letter of a string
 */
export function capitalize(str: string): string {
  if (isEmptyOrWhitespace(str)) {
    return str || '';
  }
  return str.charAt(0).toUpperCase() + str.slice(1);
}
