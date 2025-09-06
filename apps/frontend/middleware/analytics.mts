import { os } from "@orpc/server";

/**
 * Google Analytics (GA4) middleware via Measurement Protocol.
 * Sends a non-blocking event per RPC call. Avoid sending PII.
 *
 * Usage:
 * ```ts
 * import { createGoogleAnalytics } from "./middleware/analytics";
 *
 * const ga = createGoogleAnalytics({
 *   measurementId: process.env.GA_MEASUREMENT_ID!,
 *   apiSecret: process.env.GA_API_SECRET!,
 *   clientId: ({ context, meta }) => context.user?.id ?? meta.ip ?? "anon",
 * });
 *
 * os.procedure().use(ga).handler(/* ... */);
 * ```
 */
export type GoogleAnalyticsOptions = {
  measurementId: string;
  apiSecret: string;
  clientId: (args: { context: any; meta: any }) => string | Promise<string>;
  endpoint?: string; // override for testing
};

export function createGoogleAnalytics(opts: GoogleAnalyticsOptions) {
  const endpoint =
    opts.endpoint ??
    `https://www.google-analytics.com/mp/collect?measurement_id=${encodeURIComponent(
      opts.measurementId,
    )}&api_secret=${encodeURIComponent(opts.apiSecret)}`;

  return os.$context<{}>().middleware(async ({ context, meta, path, next }) => {
    const start = Date.now();
    try {
      const res = await next({});
      void sendEvent({ endpoint, context, meta, path, start, success: true });
      return res;
    } catch (err) {
      void sendEvent({ endpoint, context, meta, path, start, success: false, error: err });
      throw err;
    }
  });
}

async function sendEvent({ endpoint, context, meta, path, start, success }: any) {
  try {
    const clientId =
      typeof context?.user?.id === "string"
        ? context.user.id
        : typeof meta?.ip === "string"
        ? meta.ip
        : "anon";
    const duration = Date.now() - start;
    const body = {
      client_id: clientId,
      events: [
        {
          name: "rpc_call",
          params: {
            path,
            success,
            duration_ms: duration,
          },
        },
      ],
    } as const;

    await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  } catch {
    // swallow analytics errors
  }
}
