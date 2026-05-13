# Next.js TypeScript Boilerplate

This is a [Next.js](https://nextjs.org/) v16 project template with TypeScript and [Tailwind CSS](https://tailwindcss.com/), using the App Router by default.

## Project Structure

```text
.
├── src/
│   ├── app/            # App Router (layout.tsx, page.tsx, route handlers)
│   ├── pages/          # (Optional) Pages Router compatibility
│   └── components/     # UI components
├── public/             # Static assets (images, fonts, etc.)
├── dist/               # Build output directory
└── package.json
```

## Getting Started

### Installation

```bash
pnpm install
```

### Development

Run the development server:

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) to view your application.

### Building

Build the production application:

```bash
pnpm build
```

The build output will be in the `dist/` directory.

### Production

Start the production server:

```bash
pnpm start
```

### Other Commands

- `pnpm lint` - Run ESLint
- `pnpm typecheck` - Run TypeScript type checking
- `pnpm test` - Run tests
- `pnpm clean` - Remove build artifacts

## API recordings with yakbak

This boilerplate includes a tiny `yakbak` proxy helper for recording and replaying HTTP responses.

- Recordings are saved to `__test__/api/yakbak/`.
- The default upstream is `https://ipinfo.io`.
- The proxy listens on port `3030` by default.

Commands:

```bash
pnpm yakbak:record
```

Then hit the proxy to create recordings:

```bash
curl http://localhost:3030/json
```

Replay only (no new recordings will be created):

```bash
pnpm yakbak:replay
```

## Styling with Tailwind CSS

This template uses Tailwind CSS for styling. The configuration is in `tailwind.config.js`.

To customize your theme or add plugins, edit the Tailwind configuration file. See the [Tailwind CSS documentation](https://tailwindcss.com/docs) for more details.

## Next.js 16 Defaults

- Turbopack is used by default for `dev` and `build` (no flags needed)
- `cacheComponents` is enabled in `next.config.js`
- App Router files live under `src/app/`

## Path Aliases

This boilerplate avoids the ambiguous `@/*` alias and uses category- or project‑scoped aliases instead.
These are configured in `tsconfig.json` under `compilerOptions.paths`:

- `@/app/*` → `./src/*`
  - Use for App Router code: `src/app/**` pages, layouts, route handlers, and closely related server components.
  - Example: `import Layout from "@/app/app/layout"`
- `@/components/*` → `./src/components/*`
  - Reusable UI components; presentational or lightly stateful; no direct data access.
  - Example: `import { Button } from "@/components/button"`
- `@/lib/*` → `./src/lib/*`
  - Framework-agnostic modules and integration helpers: API clients, server utilities, adapters, env/config readers.
  - May include server-only modules (mark with `"use server"` when applicable) and wrappers around external SDKs.
  - Example: `import { fetchUser } from "@/lib/api/users"`
- `@/utils/*` → `./src/utils/*`
  - Pure functions and shared helpers: formatting, parsing, math, type guards; no side effects or I/O.
  - Example: `import { toTitleCase } from "@/utils/strings"`
- `@/types/*` → `./src/types/*`
  - Global and shared TypeScript types; DTOs; shared enums and constants. Type-only modules preferred.
  - Example: `import type { User } from "@/types/user"`

Why not `@/*`? It can conflict with npm-scoped packages and obscures intent. Category-scoped aliases make ownership and
boundaries clear and align with monorepo standards.

Import examples:

```ts
import type { User } from "@/types/user";
import { Button } from "@/components/button";
import { formatMoney } from "@/utils/currency";
import { getSession } from "@/lib/auth/session";
```

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
