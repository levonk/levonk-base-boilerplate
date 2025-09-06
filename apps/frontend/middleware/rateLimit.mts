import { ORPCError, os } from "@orpc/server";

/**
 * Rate limiter middleware (pluggable strategies)
 *
 * Strategies supported:
 * - fixedWindow: simplest; uses INCR + PEXPIRE.
 * - slidingWindow: accurate smoothing; uses ZADD/ZREMRANGEBYSCORE/ZCARD.
 * - tokenBucket: steady refill; uses GET/SET/PEXPIRE atomically (MULTI or EVAL recommended).
 *
 * Provide a Redis client or adapters exposing the minimal commands needed per strategy.
 *
 * Usage (fixed window):
 * ```ts
 * import Redis from "ioredis";
 * import { createRateLimiter, FixedWindowOptions } from "./middleware/rateLimit";
 * const redis = new Redis(process.env.REDIS_URL!);
 * const rateLimit = createRateLimiter({
 *   strategy: "fixedWindow",
 *   key: ({ context, meta }) => context.user?.id ?? meta.ip ?? "anon",
 *   redis,
 *   windowMs: 60_000,
 *   max: 100,
 * });
 * os.procedure().use(rateLimit);
 * ```
 *
 * Usage (sliding window):
 * ```ts
 * import { createRateLimiter } from "./middleware/rateLimit";
 * const rateLimit = createRateLimiter({
 *   strategy: "slidingWindow",
 *   key: ({ context, meta }) => context.user?.id ?? meta.ip ?? "anon",
 *   redis, // must support zadd, zremrangebyscore, zcard
 *   windowMs: 60_000,
 *   max: 100,
 *   prefix: "rl",
 * });
 * ```
 *
 * Usage (token bucket):
 * ```ts
 * const rateLimit = createRateLimiter({
 *   strategy: "tokenBucket",
 *   key: ({ context, meta }) => context.user?.id ?? meta.ip ?? "anon",
 *   redis, // must support get, set, pexpire (or expire), and ideally multi()
 *   capacity: 100,
 *   refillTokens: 100,   // tokens added per interval
 *   refillIntervalMs: 60_000,
 *   prefix: "rl:tb",
 * });
 * ```
 */

// Minimal Redis command sets for each strategy
export type RedisFixedWindow = {
  incr: (key: string) => Promise<number> | number;
  pexpire?: (key: string, ms: number) => Promise<any> | any;
  expire?: (key: string, seconds: number) => Promise<any> | any;
};

export type RedisSlidingWindow = {
  zadd: (key: string, score: number, member: string) => Promise<any> | any;
  zremrangebyscore: (key: string, min: number, max: number) => Promise<any> | any;
  zcard: (key: string) => Promise<number> | number;
};

export type RedisTokenBucket = {
  get: (key: string) => Promise<string | null> | string | null;
  set: (key: string, value: string) => Promise<any> | any;
  pexpire?: (key: string, ms: number) => Promise<any> | any;
  expire?: (key: string, seconds: number) => Promise<any> | any;
};

export type BaseLimiterOptions = {
  key: (args: { context: any; meta: any; path: string }) => string | Promise<string>;
  prefix?: string;
};

export type FixedWindowOptions = BaseLimiterOptions & {
  strategy: "fixedWindow";
  redis: RedisFixedWindow;
  windowMs: number;
  max: number;
};

export type SlidingWindowOptions = BaseLimiterOptions & {
  strategy: "slidingWindow";
  redis: RedisSlidingWindow;
  windowMs: number;
  max: number;
};

export type TokenBucketOptions = BaseLimiterOptions & {
  strategy: "tokenBucket";
  redis: RedisTokenBucket;
  capacity: number; // max tokens in the bucket
  refillTokens: number; // tokens added per interval
  refillIntervalMs: number; // interval to add refillTokens
};

export type RateLimiterOptions = FixedWindowOptions | SlidingWindowOptions | TokenBucketOptions;

export function createRateLimiter(opts: RateLimiterOptions) {
  switch (opts.strategy) {
    case "fixedWindow":
      return fixedWindowMiddleware(opts);
    case "slidingWindow":
      return slidingWindowMiddleware(opts);
    case "tokenBucket":
      return tokenBucketMiddleware(opts);
  }
}

function fixedWindowMiddleware(opts: FixedWindowOptions) {
  const prefix = opts.prefix ?? "rl:fw";
  return os.$context<{}>().middleware(async ({ context, meta, path, next }) => {
    const id = await opts.key({ context, meta, path });
    const now = Date.now();
    const window = Math.floor(now / opts.windowMs);
    const key = `${prefix}:${id}:${window}`;

    const count = await opts.redis.incr(key);
    if (count === 1) {
      const msRemaining = (window + 1) * opts.windowMs - now;
      if (typeof opts.redis.pexpire === "function") await opts.redis.pexpire(key, msRemaining);
      else if (typeof opts.redis.expire === "function") await opts.redis.expire(key, Math.ceil(msRemaining / 1000));
    }

    if (count > opts.max) {
      throw new ORPCError("TooManyRequests", `Rate limit exceeded for key: ${id}`);
    }

    return next({});
  });
}

function slidingWindowMiddleware(opts: SlidingWindowOptions) {
  const prefix = opts.prefix ?? "rl:sw";
  return os.$context<{}>().middleware(async ({ context, meta, path, next }) => {
    const id = await opts.key({ context, meta, path });
    const key = `${prefix}:${id}`;
    const now = Date.now();
    const windowStart = now - opts.windowMs;

    // Remove old entries, add current timestamp, count remaining
    await opts.redis.zremrangebyscore(key, 0, windowStart);
    await opts.redis.zadd(key, now, `${now}`);
    const count = await opts.redis.zcard(key);

    if (count > opts.max) {
      throw new ORPCError("TooManyRequests", `Rate limit exceeded for key: ${id}`);
    }

    return next({});
  });
}

function tokenBucketMiddleware(opts: TokenBucketOptions) {
  const prefix = opts.prefix ?? "rl:tb";
  return os.$context<{}>().middleware(async ({ context, meta, path, next }) => {
    const id = await opts.key({ context, meta, path });
    const key = `${prefix}:${id}`;
    const now = Date.now();

    // State record: { tokens: number, updatedAt: number }
    const raw = await opts.redis.get(key);
    let tokens = opts.capacity;
    let updatedAt = now;

    if (raw) {
      try {
        const parsed = JSON.parse(raw) as { tokens: number; updatedAt: number };
        tokens = Math.min(opts.capacity, refill(parsed.tokens, parsed.updatedAt, now, opts.refillTokens, opts.refillIntervalMs));
        updatedAt = now;
      } catch {
        // ignore parse errors; reset bucket
        tokens = opts.capacity;
        updatedAt = now;
      }
    }

    if (tokens <= 0) {
      throw new ORPCError("TooManyRequests", `Rate limit exceeded for key: ${id}`);
    }

    // Consume one token and persist
    tokens -= 1;
    const value = JSON.stringify({ tokens, updatedAt });
    await opts.redis.set(key, value);
    // Optional TTL to avoid stale keys
    if (typeof (opts.redis as any).pexpire === "function") {
      await (opts.redis as any).pexpire(key, opts.refillIntervalMs * 2);
    } else if (typeof (opts.redis as any).expire === "function") {
      await (opts.redis as any).expire(key, Math.ceil((opts.refillIntervalMs * 2) / 1000));
    }

    return next({});
  });
}

function refill(tokens: number, last: number, now: number, refillTokens: number, refillIntervalMs: number) {
  if (now <= last) return tokens;
  const intervals = Math.floor((now - last) / refillIntervalMs);
  if (intervals <= 0) return tokens;
  return tokens + intervals * refillTokens;
}
