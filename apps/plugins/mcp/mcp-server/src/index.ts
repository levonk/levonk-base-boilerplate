import { startServer } from '@job-aide/mcp-server-kit';

async function main() {
  const port = Number(process.env.PORT || '__PORT__');
  const server = await startServer({ port });
  // eslint-disable-next-line no-console
  console.log(`[__APP_NAME__] MCP server listening on :${server.port}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

// vim: set ft=typescript:
