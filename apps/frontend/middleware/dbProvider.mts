import { os } from "@orpc/server";

/**
 * Drizzle DB provider middleware
 *
 * Usage:
 * ```ts
 * import { drizzle } from "drizzle-orm/*";
 * import { createDbProvider } from "./middleware/dbProvider";
 *
 * const db = drizzle(/* ... */);
 * export const withDb = createDbProvider(db);
 *
 * export const getProducts = os
 *   .procedure()
 *   .use(withDb)
 *   .handler(async ({ context }) => {
 *     const rows = await context.db.select().from(/* ... */);
 *     return rows;
 *   });
 * ```
 */
export type DbInContext<DB> = { db: DB };

export function createDbProvider<DB>(db: DB) {
  return os
    .$context<{}>()
    .middleware(async ({ next }) => {
      return next({ context: { db } as DbInContext<DB> });
    });
}
