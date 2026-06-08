#!/usr/bin/env node
import { Command } from 'commander';
import process from 'process';
import { glob } from 'glob';
import fs from 'fs/promises';
import { createLogger, LoggerOptions } from './logger.js';
import {
    UsageError,
    FileNotFoundError,
    PermissionDeniedError,
    GenericError,
    handleError,
    EXIT_CODES,
} from './error.js';
import {
    loadConfigWithPrecedence,
    initializeConfig,
    type Config,
    type ConfigOptions,
} from './config.js';
import {
    writeCompletionScript,
    getCompletionInstallInstructions,
    type CompletionOptions,
    type ShellType,
} from './completions.js';
import {
    writeManPage,
    getManPageInstallInstructions,
    type ManPageOptions,
} from './man.js';
import {
    install,
    uninstall,
    checkInstallStatus,
    type InstallOptions,
    type UninstallOptions,
} from './install.js';
import {
    initGlobalDryRunManager,
    getGlobalDryRunManager,
    isDryRunEnabled,
} from './dry-run.js';

// Handle Ctrl+C
process.on('SIGINT', () => {
    process.stderr.write('\nOperation cancelled.\n');
    process.exit(EXIT_CODES.SIGINT);
});

const program = new Command();

program
  .name('my-cli-tool')
  .description('A CLI tool')
  .version('1.0.0', '-v, --version', 'Output the version number')
  .helpOption('-h, --help', 'Display help for command')
  .addHelpText('after', 'Use "my-cli-tool help <command>" for more information on a command.')
  .addHelpText('after', '\nExit Codes:\n  0   Success\n  1   Generic error\n  2   Usage error (invalid arguments, missing required args)\n  3   Network error (connection failures, timeouts)\n  4   Validation error (invalid config, schema validation failures)\n  5   File not found\n  6   Permission denied\n  130 SIGINT (Ctrl+C)')
  .argument('[inputs...]', 'Input files or glob patterns. Use "-" for stdin.')
  .option('-q, --quiet', 'Suppress all output except errors')
  .option('--verbose', 'Enable verbose output with extra details')
  .option('--debug', 'Enable debug-level logging')
  .option('--usage', 'Display usage information')
  .option('--color <mode>', 'Color mode: auto, always, or never', 'auto')
  .option('--log-format <format>', 'Log format: text or json', 'text')
  .option('--json', 'Output results as JSON')
  .option('--install', 'Install CLI (generate completions, initialize config)')
  .option('--skip-completions', 'Skip shell completion generation during install')
  .option('--uninstall', 'Uninstall CLI (remove completions, clean up config)')
  .option('--force', 'Force operation without confirmation')
  .option('-c, --config <path>', 'Config file path (default: ~/.config/my-cli-tool/config.toml)', process.env.MY_CLI_TOOL_CONFIG)
  .addHelpText('after', '\nConfig Precedence (highest to lowest):\n  1. CLI arguments\n  2. Environment variables (_*)\n  3. Local project config (./.my-cli-tool/config.toml)\n  4. User config (~/.config/my-cli-tool/config.toml)\n  5. System config (/etc/my-cli-tool/config.toml)\n  6. Hardcoded defaults')
  .addHelpText('after', '\nLogging Options:\n  --debug       Enable debug-level logging\n  --log-format  Log format: text (default) or json\n  --quiet        Suppress all output except errors\n  --verbose      Enable verbose output with extra details\n  Environment Variables:\n  LOG_LEVEL      Set log level (debug, info, warn, error, fatal)\n  NODE_ENV       Set to "development" to enable debug mode')
  .addHelpText('after', '\nDry-Run Mode:\n  --dry-run     Preview changes without executing them\n                Shows what would be done without making any changes')
  .addHelpText('after', '\nInstallation:\n  --install      Install CLI (generate completions, initialize config)\n  --uninstall    Uninstall CLI (remove completions, clean up config)')
  .addHelpText('after', '\nShell Completion:\n  Generate completion scripts with: my-cli-tool --completion <shell>\n  Show installation instructions with: my-cli-tool --completion-install <shell>')
  .addHelpText('after', '\nMan Pages:\n  Generate man page with: my-cli-tool --man\n  Show installation instructions with: my-cli-tool --man-install')
  .option('--dry-run', 'Preview changes without executing them')
  .option('--completion <shell>', 'Generate shell completion script (bash, zsh, fish)')
  .option('--completion-install <shell>', 'Show shell completion installation instructions')
  .option('--output-dir <path>', 'Output directory for completion scripts', 'completions')
  .option('--stdout', 'Output completion script to stdout instead of file')
  .option('--man', 'Generate man page')
  .option('--man-install', 'Show man page installation instructions')
  .option('--man-output-dir <path>', 'Output directory for man pages', 'man')
  .action(async (inputs: string[], options) => {
      try {
          // Handle --usage flag
          if (options.usage) {
              program.helpInformation();
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --completion flag
          if (options.completion) {
              const shell = options.completion as ShellType;
              const completionOptions: CompletionOptions = {
                  shell,
                  outputDir: options.outputDir,
                  stdout: options.stdout,
              };
              const logger = createLogger({ quiet: false, verbose: options.verbose, color: 'auto', module: 'my-cli-tool' });
              await writeCompletionScript(program, completionOptions, logger);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --completion-install flag
          if (options.completionInstall) {
              const shell = options.completionInstall as ShellType;
              const instructions = getCompletionInstallInstructions(shell, 'my-cli-tool');
              console.log(instructions);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --man flag
          if (options.man) {
              const manOptions: ManPageOptions = {
                  outputDir: options.manOutputDir,
                  stdout: options.stdout,
              };
              const logger = createLogger({ quiet: false, verbose: options.verbose, color: 'auto', module: 'my-cli-tool' });
              await writeManPage(program, manOptions, logger);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --man-install flag
          if (options.manInstall) {
              const instructions = getManPageInstallInstructions('my-cli-tool');
              console.log(instructions);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --install flag
          if (options.install) {
              const installOptions: InstallOptions = {
                  projectSlug: 'my-cli-tool',
                  verbose: options.verbose,
                  force: options.force,
                  skipCompletions: options.skipCompletions,
              };
              const logger = createLogger({ quiet: false, verbose: options.verbose, color: 'auto', module: 'my-cli-tool' });
              await install(installOptions, logger);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Handle --uninstall flag
          if (options.uninstall) {
              const uninstallOptions: UninstallOptions = {
                  projectSlug: 'my-cli-tool',
                  verbose: options.verbose,
                  force: options.force,
                  keepConfig: false,
              };
              const logger = createLogger({ quiet: false, verbose: options.verbose, color: 'auto', module: 'my-cli-tool' });
              await uninstall(uninstallOptions, logger);
              process.exit(EXIT_CODES.SUCCESS);
          }

          // Initialize config with full precedence chain
          const configOptions: ConfigOptions = {
              projectSlug: 'my-cli-tool',
              configPath: options.config,
              debug: options.verbose,
          };

          // Build CLI args for config precedence
          const cliArgs: Partial<Config> = {};
          if (options.quiet !== undefined) cliArgs.quiet = options.quiet;
          if (options.verbose !== undefined) cliArgs.verbose = options.verbose;
          if (options.debug !== undefined) cliArgs.debug = options.debug;
          if (options.color !== undefined) cliArgs.color = options.color;
          if (options.logFormat !== undefined) cliArgs.log_format = options.logFormat;
          if (options.json !== undefined) cliArgs.json = options.json;

          const config = await loadConfigWithPrecedence(configOptions, cliArgs);

          // Use merged config (CLI args already applied via precedence)
          // For quiet and json, prefer CLI args directly to ensure they work as expected
          const mergedOptions = {
              quiet: options.quiet === true ? true : config.quiet,
              verbose: options.verbose === true ? true : config.verbose,
              debug: options.debug === true ? true : config.debug,
              color: options.color !== undefined ? options.color : config.color,
              logFormat: options.logFormat !== undefined ? options.logFormat : config.log_format,
              json: options.json === true ? true : config.json,
          };

          // Suppress all console output in JSON mode (only output final JSON result)
          // Do this BEFORE config initialization to suppress config creation logs
          let originalLog: any, originalError: any, originalWarn: any;
          if (mergedOptions.json) {
              originalLog = console.log;
              originalError = console.error;
              originalWarn = console.warn;
              console.log = () => {};
              console.error = () => {};
              console.warn = () => {};
          }

          // Create logger with merged options
          // For quiet and json, use CLI options directly to ensure they work
          const loggerOptions: LoggerOptions = {
              quiet: options.quiet === true || options.json === true,
              verbose: options.verbose === true,
              debug: options.debug === true,
              logLevel: config.log_level as any,
              color: options.color !== undefined ? options.color : config.color,
              logFormat: options.logFormat !== undefined ? options.logFormat : config.log_format,
              module: 'my-cli-tool',
          };
          const logger = createLogger(loggerOptions);

          // Initialize config (creates default if doesn't exist) - only when not installing/uninstalling
          // This ensures config is created on first run when CLI is invoked
          if (!options.install && !options.uninstall) {
              await initializeConfig(configOptions, options.verbose);
          }

          // Initialize dry-run manager
          initGlobalDryRunManager(logger, options.dryRun);

          // Input Processing
          const filesToProcess: string[] = [];
          let readStdin = false;

          if (inputs.length === 0) {
              // Check if stdin is a TTY
              if (process.stdin.isTTY) {
                  throw new UsageError('No inputs provided. Use "-" for stdin or provide file patterns.');
              } else {
                  readStdin = true;
              }
          } else {
              for (const input of inputs) {
                  if (input === '-') {
                      readStdin = true;
                  } else {
                      // Globbing
                      const matches = await glob(input, { nodir: true });
                      if (matches.length === 0) {
                          logger.warn(`No files found for pattern '${input}'`);
                      }
                      filesToProcess.push(...matches);
                  }
              }
          }

          const results: any[] = [];

          if (readStdin) {
              logger.info('Processing stdin...');
              const chunks = [];
              for await (const chunk of process.stdin) {
                  chunks.push(chunk);
              }
              const content = Buffer.concat(chunks).toString('utf-8');
              results.push({ source: 'stdin', length: content.length });
          }

          for (const file of filesToProcess) {
              try {
                  logger.info(`Processing ${file}...`);
                  const content = await fs.readFile(file, 'utf-8');
                  results.push({ source: file, length: content.length });
              } catch (error) {
                  if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
                      throw new FileNotFoundError(`File not found: ${file}`, { file });
                  } else if ((error as NodeJS.ErrnoException).code === 'EACCES') {
                      throw new PermissionDeniedError(`Permission denied: ${file}`, { file });
                  } else {
                      throw new GenericError(`Error processing ${file}: ${error}`, { file, error });
                  }
              }
          }

          if (mergedOptions.json) {
              const output = {
                  dryRun: isDryRunEnabled(),
                  results,
              };
              // Restore console functions temporarily to output JSON
              if (originalLog && originalError && originalWarn) {
                  console.log = originalLog;
                  console.error = originalError;
                  console.warn = originalWarn;
              }
              console.log(JSON.stringify(output, null, 2));
              // Re-suppress after output
              console.log = () => {};
              console.error = () => {};
              console.warn = () => {};
          } else {
              if (isDryRunEnabled()) {
                  logger.info('[DRY-RUN] Mode enabled - no changes were made');
              }
              logger.info(`Processed ${results.length} inputs.`);
          }

          // Restore console functions if they were suppressed
          if (mergedOptions.json && originalLog && originalError && originalWarn) {
              console.log = originalLog;
              console.error = originalError;
              console.warn = originalWarn;
          }
      } catch (error) {
          const logger = createLogger({ quiet: false, verbose: false, color: 'auto', module: 'my-cli-tool' });
          handleError(error, logger);
      }
  });

program.parse();
