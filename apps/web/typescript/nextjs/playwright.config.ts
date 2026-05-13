import { defineJobAideConfig, desktopProjects, HOST, PORT, BASE_URL } from "@job-aide/tools-playwright-config";

export default defineJobAideConfig({
  projects: desktopProjects,
  webServer: {
    command: `pnpm run dev -- --host ${HOST} --port ${PORT}`,
    url: BASE_URL,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
