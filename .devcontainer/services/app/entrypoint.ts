#!/usr/bin/env tsx
import { execSync, spawn } from 'child_process';
import { readFileSync, writeFileSync, existsSync, mkdirSync, chmodSync, readdirSync } from 'fs';
import { join, dirname } from 'path';

// --- Configuration ---
const HOME = process.env.HOME || '/home/developer';
const SETUP_MARKER = join(HOME, '.cache', '.container_initialized');
const PNPM_STORE_PATH = join(HOME, '.pnpm-store');
const PROJECT_ROOT = join(HOME, 'project');

// 🤖 MANDATORY NIX PACKAGES
// Moved from Dockerfile to Nix as requested by the user.
const MANDATORY_NIX_PACKAGES = [
    "zellij", 
    "jq", 
    "nodejs", 
    "pnpm", 
    "git", 
    "direnv", 
    "file", 
    "findutils", 
    "xz", 
    "procps",
    "curl",
    "devbox"
];

const MANDATORY_NPM_PACKAGES = ["openskills", "vibe-kanban", "ceviz", "@beads/bd", "opencode-ai", "oh-my-opencode", "@musistudio/claude-code-router", "@anthropic/claude-code"];
const MANDATORY_EXTENSIONS = ["ms-vscode-remote.remote-containers", "ms-azuretools.vscode-docker", "saoudrizwan.claude-dev", "google.gemini-cli"];
const MANDATORY_SCRIPTS = { "build": "pnpm build", "lint": "pnpm lint", "test": "pnpm test" };

const COLORS = {
    RED: '\x1b[31m',
    GREEN: '\x1b[32m',
    YELLOW: '\x1b[33m',
    BLUE: '\x1b[34m',
    NC: '\x1b[0m'
};

function log(color: string, msg: string) {
    console.log(color + msg + COLORS.NC);
}

function run(cmd: string, options: { silent?: boolean, cwd?: string, asRoot?: boolean } = {}) {
    try {
        const prefix = options.asRoot ? 'sudo ' : '';
        const fullCmd = prefix + cmd;
        if (!options.silent) log(COLORS.BLUE, "Executing: " + fullCmd);
        return execSync(fullCmd, { 
            stdio: options.silent ? 'pipe' : 'inherit', 
            cwd: options.cwd || PROJECT_ROOT, 
            shell: '/bin/bash',
            env: { ...process.env }
        });
    } catch (e: any) {
        if (!options.silent) log(COLORS.RED, "Command failed: " + cmd + "\nError: " + e.message);
        throw e;
    }
}

function fixPermissions() {
    log(COLORS.YELLOW, '🛠️ Fixing volume permissions...');
    try {
        // Ensure shared volumes and project root are owned by developer
        run('sudo chown -R developer:developer /nix/var/nix/profiles /nix/var/nix/db /nix/var/nix/gcroots', { silent: true });
        run('sudo chown -R developer:developer "' + PNPM_STORE_PATH + '"', { silent: true });
        run('sudo chown -R developer:developer "' + PROJECT_ROOT + '"', { silent: true });
    } catch (e) {
        log(COLORS.YELLOW, '⚠️ Permission fixups failed or partially failed');
    }
}

function sourceNix() {
    log(COLORS.BLUE, '🔍 Sourcing Nix environment...');
    
    const user = execSync('id -un').toString().trim();
    const potentialProfiles = [
        "/nix/var/nix/profiles/default/etc/profile.d/nix.sh",
        "/etc/profile.d/nix.sh",
        join(HOME, ".nix-profile", "etc", "profile.d", "nix.sh"),
        "/nix/var/nix/profiles/per-user/" + user + "/profile/etc/profile.d/nix.sh",
        "/nix/var/nix/profiles/per-user/root/profile/etc/profile.d/nix.sh"
    ];

    try {
        const foundNixScripts = execSync('find /nix -name nix.sh -path "*/etc/profile.d/nix.sh" 2>/dev/null | head -n 5').toString().split('\n').filter(Boolean);
        potentialProfiles.push(...foundNixScripts);
    } catch (e) {}

    let sourced = false;
    for (const profile of potentialProfiles) {
        if (sourced) break;
        if (existsSync(profile)) {
            log(COLORS.BLUE, "Attempting to source: " + profile);
            try {
                const envStr = execSync(". " + profile + " && env", { shell: '/bin/bash' }).toString();
                envStr.split('\n').forEach(line => {
                    const match = line.match(/^([^=]+)=(.*)$/);
                    if (match) {
                        const key = match[1];
                        const value = match[2];
                        process.env[key] = value;
                    }
                });
                sourced = true;
                log(COLORS.GREEN, "✅ Sourced " + profile);
            } catch (e) {
                log(COLORS.YELLOW, "⚠️ Failed to source " + profile);
            }
        }
    }

    if (!sourced) {
        log(COLORS.YELLOW, '⚠️ No standard profile found. Searching for Nix in /nix...');
        try {
            const nixBin = execSync('find /nix/store -maxdepth 3 -name nix -type f -executable 2>/dev/null | head -n 1').toString().trim();
            if (nixBin) {
                const binDir = dirname(nixBin);
                process.env.PATH = binDir + ":" + process.env.PATH;
                if (!process.env.NIX_PATH) {
                    process.env.NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs:nixpkgs=/nix/var/nix/profiles/default/channels/nixpkgs";
                }
                const cert = execSync('find /nix/store -maxdepth 4 -name ca-bundle.crt 2>/dev/null | head -n 1').toString().trim();
                if (cert) process.env.NIX_SSL_CERT_FILE = cert;
                sourced = true;
                log(COLORS.GREEN, '✅ Manual Nix setup complete');
            }
        } catch (e) {}
    }

    // Ensure common paths are in PATH
    const commonPaths = [
        join(HOME, '.nix-profile', 'bin'),
        '/nix/var/nix/profiles/default/bin'
    ];
    commonPaths.forEach(p => {
        if (existsSync(p) && !process.env.PATH?.includes(p)) {
            process.env.PATH = p + ":" + process.env.PATH;
        }
    });

    return sourced;
}

function updateManifests() {
    log(COLORS.BLUE, '📋 Phase: MANIFEST INJECTION');
    
    // package.json
    const pkgPath = join(PROJECT_ROOT, 'package.json');
    let pkg: any = { name: 'project', version: '0.1.0', private: true, type: 'module' };
    if (existsSync(pkgPath)) {
        try {
            pkg = JSON.parse(readFileSync(pkgPath, 'utf8'));
        } catch (e) {}
    }
    pkg.devDependencies = { ...(pkg.devDependencies || {}), ...Object.fromEntries(MANDATORY_NPM_PACKAGES.map(p => [p, 'latest'])) };
    pkg.scripts = { ...MANDATORY_SCRIPTS, ...(pkg.scripts || {}) };
    writeFileSync(pkgPath, JSON.stringify(pkg, null, 2));
    log(COLORS.GREEN, '✅ package.json updated');
    
    // devbox.json (Crucially in PROJECT_ROOT)
    const dbxPath = join(PROJECT_ROOT, 'devbox.json');
    let dbx: any = { packages: [], shell: { init_hook: [] } };
    if (existsSync(dbxPath)) {
        try {
            dbx = JSON.parse(readFileSync(dbxPath, 'utf8'));
        } catch (e) {}
    }
    dbx.packages = Array.from(new Set([...(dbx.packages || []), ...MANDATORY_NIX_PACKAGES]));
    writeFileSync(dbxPath, JSON.stringify(dbx, null, 2));
    log(COLORS.GREEN, '✅ devbox.json updated in project root');
}

async function main() {
    log(COLORS.BLUE, '🚀 Container initialization starting (TS)...');
    
    if (!existsSync(SETUP_MARKER)) {
        log(COLORS.YELLOW, '🛠️ First-time container initialization...');
        
        fixPermissions();
        sourceNix();
        updateManifests();
        
        if (existsSync(join(PROJECT_ROOT, 'devbox.json'))) {
            log(COLORS.YELLOW, '📦 Installing Devbox packages...');
            try {
                // Devbox is now in MANDATORY_NIX_PACKAGES, so we use it to install others
                run('devbox install');
            } catch (e) {
                log(COLORS.RED, '⚠️ devbox install failed');
            }
        }
        
        log(COLORS.YELLOW, '🚚 Installing project dependencies...');
        try {
            sourceNix();
            run('pnpm install');
        } catch (e) {
            log(COLORS.RED, '⚠️ pnpm install failed');
        }
        
        mkdirSync(dirname(SETUP_MARKER), { recursive: true });
        writeFileSync(SETUP_MARKER, new Date().toISOString());
    } else {
        log(COLORS.GREEN, '✨ Container already initialized. Sourcing environment...');
        sourceNix();
    }
    
    log(COLORS.GREEN, '✅ Initialization complete!');
    
    const args = process.argv.slice(2);
    if (args.length === 0) {
        spawn('sleep', ['infinity'], { stdio: 'inherit' });
    } else {
        const cmd = args[0];
        const cmdArgs = args.slice(1);
        spawn(cmd, cmdArgs, { stdio: 'inherit', shell: '/bin/bash' });
    }
}

main().catch(err => {
    log(COLORS.RED, "💥 Fatal error: " + err.message);
    process.exit(1);
});
