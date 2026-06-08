import fs from 'fs/promises';
import path from 'path';
import os from 'os';
import { createLogger, type Logger } from './logger.js';
import { createDefaultConfig, getConfigFilePath, getXDGConfigPath } from './config.js';

export interface InstallOptions {
    projectSlug: string;
    verbose?: boolean;
    force?: boolean;
    skipCompletions?: boolean;
}

export interface UninstallOptions {
    projectSlug: string;
    verbose?: boolean;
    force?: boolean;
    keepConfig?: boolean;
}

export interface InstallStatus {
    installed: boolean;
    version: string;
    installDate: string;
    completionScripts: string[];
    configInitialized: boolean;
}

const STATUS_FILE_NAME = 'install-status.json';

/**
 * Get install status file path
 */
function getStatusFilePath(projectSlug: string): string {
    return path.join(getXDGConfigPath(projectSlug), STATUS_FILE_NAME);
}

/**
 * Get shell completion directory paths
 */
function getCompletionDirs(projectSlug: string): Record<string, string> {
    const homeDir = os.homedir();
    return {
        bash: path.join(homeDir, '.bash_completion.d'),
        zsh: path.join(homeDir, '.zsh', 'completions'),
        fish: path.join(homeDir, '.config', 'fish', 'completions'),
    };
}

/**
 * Get completion script path for a shell
 */
function getCompletionScriptPath(projectSlug: string, shell: string): string {
    const dirs = getCompletionDirs(projectSlug);
    const dir = dirs[shell as keyof typeof dirs];
    if (!dir) {
        throw new Error(`Unsupported shell: ${shell}`);
    }
    return path.join(dir, projectSlug);
}

/**
 * Read install status
 */
export async function readInstallStatus(projectSlug: string, customConfigDir?: string): Promise<InstallStatus | null> {
    try {
        let statusPath = getStatusFilePath(projectSlug);
        if (customConfigDir) {
            statusPath = path.join(customConfigDir, STATUS_FILE_NAME);
        }
        const content = await fs.readFile(statusPath, 'utf-8');
        return JSON.parse(content) as InstallStatus;
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
            return null;
        }
        throw error;
    }
}

/**
 * Write install status
 */
async function writeInstallStatus(projectSlug: string, status: InstallStatus, customConfigDir?: string): Promise<void> {
    let statusPath = getStatusFilePath(projectSlug);
    if (customConfigDir) {
        statusPath = path.join(customConfigDir, STATUS_FILE_NAME);
    }
    const statusDir = path.dirname(statusPath);

    // Ensure directory exists (handle case where path might be a file)
    try {
        await fs.mkdir(statusDir, { recursive: true });
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code !== 'EEXIST') {
            throw error;
        }
    }
    await fs.writeFile(statusPath, JSON.stringify(status, null, 2), { mode: 0o644 });
}

/**
 * Generate shell completion script for bash
 */
function generateBashCompletion(projectSlug: string): string {
    return `# Bash completion for my-cli-tool
_my-cli-tool() {
    local cur prev words cword
    _init_completion || return

    case $prev in
        --color)
            COMPREPLY=($(compgen -W "auto always never" -- "$cur"))
            return
            ;;
        --config)
            COMPREPLY=($(compgen -f -- "$cur"))
            return
            ;;
        *)
            ;;
    esac

    if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-h --help -v --version -q --quiet --verbose --debug --usage --color --config --json --install --uninstall" -- "$cur"))
    else
        COMPREPLY=($(compgen -f -- "$cur"))
    fi
}

complete -F _my-cli-tool my-cli-tool
`;
}

/**
 * Generate shell completion script for zsh
 */
function generateZshCompletion(projectSlug: string): string {
    return `#compdef my-cli-tool
_my-cli-tool() {
    local -a arguments
    arguments=(
        {-h,--help}'[Display help for command]'
        {-v,--version}'[Output the version number]'
        {-q,--quiet}'[Suppress all output except errors]'
        {--verbose}'[Enable verbose output with extra details]'
        {--debug}'[Enable debug-level logging]'
        {--usage}'[Display usage information]'
        {--color}'[Color mode: auto, always, or never]: :(auto always never)'
        {-c,--config}'[Config file path]: :_files'
        {--json}'[Output results as JSON]'
        {--install}'[Install my-cli-tool]'
        {--uninstall}'[Uninstall my-cli-tool]'
    )

    _arguments -s $arguments && return 0
    _files && return 0
}

_my-cli-tool
`;
}

/**
 * Generate shell completion script for fish
 */
function generateFishCompletion(projectSlug: string): string {
    return `# Fish completion for my-cli-tool
complete -c my-cli-tool -f

complete -c my-cli-tool -s h -l help -d 'Display help for command'
complete -c my-cli-tool -s v -l version -d 'Output the version number'
complete -c my-cli-tool -s q -l quiet -d 'Suppress all output except errors'
complete -c my-cli-tool -l verbose -d 'Enable verbose output with extra details'
complete -c my-cli-tool -l debug -d 'Enable debug-level logging'
complete -c my-cli-tool -l usage -d 'Display usage information'
complete -c my-cli-tool -l color -d 'Color mode: auto, always, or never' -x -a 'auto always never'
complete -c my-cli-tool -s c -l config -d 'Config file path' -r
complete -c my-cli-tool -l json -d 'Output results as JSON'
complete -c my-cli-tool -l install -d 'Install my-cli-tool'
complete -c my-cli-tool -l uninstall -d 'Uninstall my-cli-tool'
`;
}

/**
 * Install completion script for a specific shell
 */
async function installCompletionScript(
    projectSlug: string,
    shell: string,
    verbose: boolean,
    logger: Logger
): Promise<void> {
    const scriptPath = getCompletionScriptPath(projectSlug, shell);
    const scriptDir = path.dirname(scriptPath);

    let scriptContent: string;
    switch (shell) {
        case 'bash':
            scriptContent = generateBashCompletion(projectSlug);
            break;
        case 'zsh':
            scriptContent = generateZshCompletion(projectSlug);
            break;
        case 'fish':
            scriptContent = generateFishCompletion(projectSlug);
            break;
        default:
            logger.warn(`Skipping unsupported shell: ${shell}`);
            return;
    }

    try {
        await fs.mkdir(scriptDir, { recursive: true });
        await fs.writeFile(scriptPath, scriptContent, { mode: 0o644 });
        if (verbose) {
            logger.info(`Installed ${shell} completion script to ${scriptPath}`);
        }
    } catch (error) {
        logger.error(`Failed to install ${shell} completion script: ${error}`);
        throw error;
    }
}

/**
 * Remove completion script for a specific shell
 */
async function removeCompletionScript(
    projectSlug: string,
    shell: string,
    verbose: boolean,
    logger: Logger
): Promise<void> {
    const scriptPath = getCompletionScriptPath(projectSlug, shell);

    try {
        await fs.unlink(scriptPath);
        if (verbose) {
            logger.info(`Removed ${shell} completion script from ${scriptPath}`);
        }
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
            if (verbose) {
                logger.debug(`${shell} completion script not found, skipping`);
            }
        } else {
            logger.error(`Failed to remove ${shell} completion script: ${error}`);
            throw error;
        }
    }
}

/**
 * Detect available shells
 */
function detectAvailableShells(): string[] {
    const shells: string[] = [];
    const shell = process.env.SHELL;

    if (shell) {
        if (shell.includes('bash')) shells.push('bash');
        if (shell.includes('zsh')) shells.push('zsh');
        if (shell.includes('fish')) shells.push('fish');
    }

    // Default to bash if no shell detected
    if (shells.length === 0) {
        shells.push('bash');
    }

    return shells;
}

/**
 * Install my-cli-tool
 */
export async function install(options: InstallOptions, logger: Logger): Promise<void> {
    const { projectSlug, verbose = false, force = false, skipCompletions = false } = options;

    logger.info(`Installing my-cli-tool...`);

    // Get custom config directory from XDG_CONFIG_HOME if set
    // If XDG_CONFIG_HOME is set, it should already include the project slug in the test context
    const customConfigDir = process.env.XDG_CONFIG_HOME;

    // Check if already installed
    const existingStatus = await readInstallStatus(projectSlug, customConfigDir);
    if (existingStatus && !force) {
        logger.warn('my-cli-tool is already installed. Use --force to reinstall.');
        logger.info(`Installed on: ${existingStatus.installDate}`);
        return;
    }

    const completionScripts: string[] = [];

    // 1. Initialize default config
    try {
        const configPath = getConfigFilePath(projectSlug, customConfigDir);
        await createDefaultConfig(configPath, verbose);
        if (verbose) {
            logger.info(`Initialized config file at ${configPath}`);
        }
    } catch (error) {
        logger.error(`Failed to initialize config: ${error}`);
        throw error;
    }

    // 2. Install shell completion scripts
    if (!skipCompletions) {
        const shells = detectAvailableShells();
        for (const shell of shells) {
            try {
                await installCompletionScript(projectSlug, shell, verbose, logger);
                completionScripts.push(shell);
            } catch (error) {
                logger.warn(`Failed to install ${shell} completion: ${error}`);
            }
        }
    }

    // 3. Write install status
    const status: InstallStatus = {
        installed: true,
        version: '1.0.0',
        installDate: new Date().toISOString(),
        completionScripts,
        configInitialized: true,
    };

    await writeInstallStatus(projectSlug, status, customConfigDir);

    logger.info('my-cli-tool installed successfully!');
    logger.info('Next steps:');
    logger.info('  1. Restart your shell to enable completion scripts');
    logger.info('  2. Run "my-cli-tool --help" to see available commands');
    logger.info('  3. Edit config file to customize settings');
}

/**
 * Uninstall my-cli-tool
 */
export async function uninstall(options: UninstallOptions, logger: Logger): Promise<void> {
    const { projectSlug, verbose = false, force = false, keepConfig = false } = options;

    logger.info(`Uninstalling my-cli-tool...`);

    // Get custom config directory from XDG_CONFIG_HOME if set
    const customConfigDir = process.env.XDG_CONFIG_HOME;

    // Check if installed
    const status = await readInstallStatus(projectSlug, customConfigDir);
    if (!status) {
        logger.warn('my-cli-tool is not installed.');
        return;
    }

    // 1. Remove completion scripts
    for (const shell of status.completionScripts) {
        try {
            await removeCompletionScript(projectSlug, shell, verbose, logger);
        } catch (error) {
            logger.warn(`Failed to remove ${shell} completion: ${error}`);
        }
    }

    // 2. Remove config files (unless keepConfig is true)
    if (!keepConfig) {
        if (!force) {
            logger.warn('This will remove your configuration files.');
            logger.warn('Use --force to proceed without confirmation.');
            logger.info('Or use --keep-config to preserve configuration.');
            return;
        }

        try {
            const configPath = getConfigFilePath(projectSlug, customConfigDir);
            await fs.unlink(configPath);
            if (verbose) {
                logger.info(`Removed config file from ${configPath}`);
            }
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
                logger.warn(`Failed to remove config file: ${error}`);
            }
        }

        try {
            let statusPath = getStatusFilePath(projectSlug);
            if (customConfigDir) {
                statusPath = path.join(customConfigDir, STATUS_FILE_NAME);
            }
            await fs.unlink(statusPath);
            if (verbose) {
                logger.info(`Removed install status from ${statusPath}`);
            }
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
                logger.warn(`Failed to remove install status: ${error}`);
            }
        }
    } else {
        // Even if keeping config, remove the install status file
        try {
            let statusPath = getStatusFilePath(projectSlug);
            if (customConfigDir) {
                statusPath = path.join(customConfigDir, STATUS_FILE_NAME);
            }
            await fs.unlink(statusPath);
            if (verbose) {
                logger.info(`Removed install status from ${statusPath}`);
            }
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
                logger.warn(`Failed to remove install status: ${error}`);
            }
        }
    }

    logger.info('my-cli-tool uninstalled successfully!');
    if (keepConfig) {
        logger.info('Configuration files preserved as requested.');
    }
}

/**
 * Check installation status
 */
export async function checkInstallStatus(projectSlug: string, logger: Logger): Promise<void> {
    const status = await readInstallStatus(projectSlug);

    if (!status) {
        logger.info('my-cli-tool is not installed.');
        logger.info('Run "my-cli-tool --install" to install.');
        return;
    }

    logger.info('my-cli-tool installation status:');
    logger.info(`  Version: ${status.version}`);
    logger.info(`  Installed: ${status.installDate}`);
    logger.info(`  Config initialized: ${status.configInitialized}`);
    logger.info(`  Completion scripts: ${status.completionScripts.join(', ') || 'none'}`);
}
