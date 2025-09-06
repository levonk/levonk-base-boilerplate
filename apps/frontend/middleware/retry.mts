import { os } from "@orpc/server";

/**
 * Retry middleware factory
 *
 * Usage:
 * ```ts
 * import { retry } from "./middleware/retry";
 *
 * // retry up to 3 times with 100ms base backoff and jitter
 * const withRetry = retry(3, { backoffMs: 100, jitter: true });
 * os.procedure().use(withRetry).handler(/* ... */);
 * ```
 */
export type RetryOptions = {
  backoffMs?: number; // base backoff in ms (default 50)
  jitter?: boolean;   // add +/-50% jitter
  retryOn?: (error: unknown) => boolean; // default: always retry
};

export function retry(attempts: number, options: RetryOptions = {}) {
  const backoffMs = options.backoffMs ?? 50;
  const retryOn = options.retryOn ?? (() => true);

  return os.$context<{}>().middleware(async ({ next }) => {
    let lastErr: unknown;
    for (let i = 0; i < Math.max(1, attempts); i++) {
      try {
        return await next({});
      } catch (err) {
        lastErr = err;
        const shouldRetry = i < attempts - 1 && retryOn(err);
        if (!shouldRetry) break;
        const factor = i + 1;
        const base = backoffMs * factor;
        const delay = options.jitter ? jitter(base) : base;
        await sleep(delay);
      }
    }
    throw lastErr;
  });
}

function sleep(ms: number) { return new Promise((r) => setTimeout(r, ms)); }
function jitter(ms: number) {
  const delta = ms * 0.5;
  return ms - delta + Math.random() * (2 * delta);
}
