/**
 * ESLint Configuration for MCP Server
 * 
 * Uses @job-aide/tools-lint-eslint-config with Node.js settings
 */
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";

export default jobAideEslintConfig({
  react: false, // MCP servers don't use React
  antfuOptions: {
    type: "app",
  },
});
