import { ORPCError, os } from "@orpc/server";
import { User } from "../schemas/user";

/**
 * Auth middleware for oRPC (frontend layer)
 *
 * What it does:
 * - Ensures a signed-in user exists, otherwise throws an `ORPCError("Unauthorized", ...)`.
 * - Attaches `context.user` for downstream handlers once authenticated.
 * - Uses `??` to avoid calling `getSession()` when `context.session` was already provided upstream.
 *
 * How to use in a procedure:
 *
 * ```ts
 * import { os } from "@orpc/server";
 * import { requiredAuthMiddleware, AuthedContext } from "./middleware/auth";
 *
 * export const getProfile = os
 *   .procedure()
 *   .use(requiredAuthMiddleware)
 *   .handler(({ context }) => {
 *     // `context.user` is guaranteed to exist here
 *     const user = (context as AuthedContext).user;
 *     return { name: user.name, email: user.email };
 *   });
 * ```
 *
 * Providing a session upstream (optional optimization):
 * If your framework (e.g., Next.js, SvelteKit) already resolved a session for the request,
 * you can inject it once so this middleware doesn’t call `getSession()` again:
 *
 * ```ts
 * // Somewhere in your request bootstrap
 * const app = os.$context<{ session?: { user?: User } }>();
 *
 * app.middleware(async ({ context, next }) => {
 *   const session = await myFrameworkSessionResolver();
 *   return next({ context: { session } });
 * });
 * ```
 *
 * Replace `getSession()` below with your real session source when ready (cookie/JWT/provider).
 */
export type AuthedContext = { user: User };

/**
 * Ensures `context.user` is present for downstream handlers.
 * Input context:  `{ session?: { user?: User } }`
 * Output context: `{ user: User }`
 */
export const requiredAuthMiddleware = os
  .$context<{ session?: { user?: User } }>()
  .middleware(async ({ context, next }) => {
    /**
     * Why we should ?? here?
     * Because it can avoid `getSession` being called when unnecessary.
     * {@link https://orpc.unnoq.com/docs/best-practices/dedupe-middleware}
     */
    const session = context.session ?? (await getSession());

    if (!session.user) {
      throw new ORPCError("Unauthorized", "User not found in session");
    }

    return next({
      context: { user: session.user }
    });
  });

async function getSession() {
  // TODO: Replace with your real session resolver
  // Example implementations:
  // - Read and verify a JWT from cookies/headers and load the user
  // - Call an auth provider SDK to fetch the current session
  // - Query a session store (e.g., Redis) keyed by a cookie
  return {
    user: {
      id: "1",
      name: "John Doe",
      email: "john.doe@example.com",
    },
  };
}

// Export an alias for convenience when attaching to procedures/routers:
// Example: os.procedure().use(authed).handler(...)
export const authed = requiredAuthMiddleware;

// Optional helper: apply auth to any builder that supports `.use()`.
// Usage: withAuth(os.procedure()).handler(...)
export const withAuth = <B extends { use: (mw: typeof requiredAuthMiddleware) => B }>(builder: B) =>
  builder.use(requiredAuthMiddleware);
