import { os } from "@orpc/server";

/**
 * Sentry monitor middleware
 * - No-ops if DSN is missing and no custom captureException is provided.
 * - Optionally accepts a captureException function to avoid requiring @sentry/node.
 *
 * Usage with @sentry/node (if installed):
 * ```ts
 * import * as Sentry from "@sentry/node";
 * import { createSentryMonitor } from "./middleware/sentryMonitor";
 *
 * Sentry.init({ dsn: process.env.SENTRY_DSN });
 * export const sentry = createSentryMonitor({ captureException: Sentry.captureException });
 *
 * os.procedure().use(sentry).handler(/* ... */);
 * ```
 */
export type SentryMonitorOptions = {
  dsn?: string; // optional; for documentation purposes
  captureException?: (error: unknown, context?: Record<string, any>) => void;
  tagContext?: (args: { context: any; meta: any; path: string }) => Record<string, any>;
};

export function createSentryMonitor(opts: SentryMonitorOptions = {}) {
  const hasCapture = typeof opts.captureException === "function";
  return os.$context<{}>().middleware(async ({ context, meta, path, next }) => {
    try {
      return await next({});
    } catch (error) {
      if (hasCapture) {
        const extra = opts.tagContext?.({ context, meta, path }) ?? {
          path,
          userId: context?.user?.id,
        };
        try {
          opts.captureException?.(error, extra);
        } catch {
          // ignore capture errors
        }
      }
      throw error;
    }
  });
}
