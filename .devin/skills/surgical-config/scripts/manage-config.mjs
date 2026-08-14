#!/usr/bin/env node

import { promises as fs } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { execSync } from 'node:child_process';

const DEFAULT_OPERATION = 'set';
const DEFAULT_FORMAT = 'json';
const SUPPORTED_FORMATS = new Set(['json', 'yaml', 'yml', 'toml']);
const SKIP_DIRECTORIES = new Set(['node_modules', '.git', 'templates', '.cache']);

const OPERATIONS = new Set([
  'set',
  'set-if-value',
  'array-add',
  'array-remove',
  'object-set',
  'object-remove',
  'validate',
  'schema-check',
]);

const DEPENDENCY_OPERATIONS = new Set(['add', 'remove']);

class SurgicalConfigManager {
  constructor(options = {}) {
    this.repoRoot = options.repoRoot || this.getRepoRoot();
    this.dryRun = options.dryRun || false;
    this.verbose = options.verbose || false;
  }

  getRepoRoot() {
    try {
      return execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();
    } catch {
      return process.cwd();
    }
  }

  createMirroredBackup(filePath) {
    const absPath = path.resolve(filePath);
    const relPath = path.relative(this.repoRoot, absPath);
    const cacheDir = path.join(this.repoRoot, '.cache', relPath);
    const timestamp = new Date().toISOString().replace(/[:.]/g, '').slice(0, -5);
    const backupPath = path.join(cacheDir, `${path.basename(filePath)}.${timestamp}`);

    fs.mkdir(cacheDir, { recursive: true });
    fs.copyFile(absPath, backupPath);

    if (this.verbose) {
      console.log(`📁 Created mirrored backup: ${backupPath}`);
    }

    return backupPath;
  }

  detectFileType(filePath) {
    const basename = path.basename(filePath);
    const ext = path.extname(filePath);

    // Templated structured files
    if (basename.endsWith('.jinja') || basename.endsWith('.json.jinja') ||
        basename.endsWith('.yaml.jinja') || basename.endsWith('.toml.jinja')) {
      return 'templated_structured';
    }

    // Structured formats
    if (SUPPORTED_FORMATS.has(ext.slice(1))) {
      return 'structured';
    }

    // Code files
    const codeExts = new Set(['rs', 'js', 'ts', 'py', 'go', 'java', 'c', 'cpp', 'hs']);
    if (codeExts.has(ext.slice(1))) {
      return 'code';
    }

    // Configuration files
    const configExts = new Set(['env', 'conf', 'ini', 'cfg']);
    if (configExts.has(ext.slice(1))) {
      return 'configuration';
    }

    return 'text';
  }

  async processTemplate(filePath) {
    const fileType = this.detectFileType(filePath);

    if (fileType !== 'templated_structured') {
      return filePath; // Not a template file
    }

    const content = await fs.readFile(filePath, 'utf8');
    const tempFile = path.join(path.dirname(filePath), `.temp.${path.basename(filePath)}.processed`);

    // Basic template processing - strip jinja2 variables and blocks
    const processed = content
      .replace(/\{\{[^}]*\}\}/g, '""') // Variables become empty strings
      .replace(/\{%[^%]*%\}/g, '') // Control blocks removed
      .replace(/\{#[^#]*#\}/g, ''); // Comments removed

    await fs.writeFile(tempFile, processed);

    if (this.verbose) {
      console.log(`🔄 Processed template: ${filePath} -> ${tempFile}`);
    }

    return tempFile;
  }

  async applySemanticEdit(filePath, operation) {
    try {
      // Use surgical-edit.sh as the intended abstraction layer
      const scriptPath = path.join(__dirname, 'surgical-edit.sh');
      const result = execSync(`'${scriptPath}' '${filePath}' '${operation}'`, {
        encoding: 'utf8',
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      if (this.verbose) {
        console.log(`✅ Applied semantic edit: ${operation}`);
      }

      return true;
    } catch (error) {
      console.error(`❌ Semantic edit failed: ${error.message}`);
      return false;
    }
  }

  async applyStructuralEdit(filePath, pattern, replacement) {
    try {
      // Use surgical-edit.sh for pattern-based edits
      const scriptPath = path.join(__dirname, 'surgical-edit.sh');
      const result = execSync(`'${scriptPath}' '${filePath}' '${pattern}' '${replacement}'`, {
        encoding: 'utf8',
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      if (this.verbose) {
        console.log(`✅ Applied structural edit: ${pattern} -> ${replacement}`);
      }

      return true;
    } catch (error) {
      console.error(`❌ Structural edit failed: ${error.message}`);
      return false;
    }
  }

  async applyTextEdit(filePath, pattern, replacement) {
    try {
      // Use surgical-edit.sh for text edits
      const scriptPath = path.join(__dirname, 'surgical-edit.sh');
      const result = execSync(`'${scriptPath}' '${filePath}' '${pattern}' '${replacement}'`, {
        encoding: 'utf8',
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      if (this.verbose) {
        console.log(`✅ Applied text edit: ${pattern} -> ${replacement}`);
      }

      return true;
    } catch (error) {
      console.error(`❌ Text edit failed: ${error.message}`);
      return false;
    }
  }

  async validateFile(filePath, fileType) {
    switch (fileType) {
      case 'structured':
      case 'templated_structured':
        try {
          // Use surgical-edit.sh for validation
          const scriptPath = path.join(__dirname, 'surgical-edit.sh');
          execSync(`'${scriptPath}' '${filePath}' '.' >/dev/null 2>&1`);
          return true;
        } catch {
          return false;
        }
      case 'code':
        // Would need language-specific validators
        return true;
      case 'configuration':
      case 'text':
        return true;
      default:
        return true;
    }
  }

  async executeInstruction(filePath, instruction) {
    const backup = this.createMirroredBackup(filePath);
    let processedFile = filePath;
    let success = false;

    try {
      // Process templates if needed
      if (this.detectFileType(filePath) === 'templated_structured') {
        processedFile = await this.processTemplate(filePath);
      }

      const fileType = this.detectFileType(processedFile);

      // Apply edit based on file type and operation
      if (instruction.operation && ['structured', 'templated_structured'].includes(fileType)) {
        success = await this.applySemanticEdit(processedFile, instruction.operation);
      } else if (instruction.pattern && instruction.replacement && fileType === 'code') {
        success = await this.applyStructuralEdit(processedFile, instruction.pattern, instruction.replacement);
      } else if (instruction.pattern && instruction.replacement && ['configuration', 'text'].includes(fileType)) {
        success = await this.applyTextEdit(processedFile, instruction.pattern, instruction.replacement);
      } else {
        throw new Error(`Unsupported operation for file type ${fileType}`);
      }

      // Validate result
      if (success && !await this.validateFile(processedFile, fileType)) {
        throw new Error('Validation failed after modification');
      }

      // Copy processed content back to original if template was processed
      if (processedFile !== filePath) {
        await fs.copyFile(processedFile, filePath);
        await fs.unlink(processedFile);
      }

      console.log(`✅ Successfully modified: ${filePath}`);
      return true;

    } catch (error) {
      console.error(`❌ Failed to modify ${filePath}: ${error.message}`);

      // Restore from backup
      try {
        await fs.copyFile(backup, filePath);
        console.log(`🔄 Restored from backup: ${backup}`);
      } catch (restoreError) {
        console.error(`❌ Failed to restore backup: ${restoreError.message}`);
      }

      return false;
    }
  }

  async manageConfigSettings(instructions, root = '.') {
    const results = {
      total: 0,
      modified: 0,
      failed: 0,
      details: []
    };

    const absRoot = path.resolve(this.repoRoot, root);

    for (const instruction of instructions) {
      const targets = await this.collectTargets(absRoot, instruction);

      for (const target of targets) {
        results.total++;

        const success = await this.executeInstruction(target, instruction);
        if (success) {
          results.modified++;
          results.details.push({ file: target, status: 'success' });
        } else {
          results.failed++;
          results.details.push({ file: target, status: 'failed', error: 'Modification failed' });
        }
      }
    }

    return results;
  }

  async manageDependencies(instructions, root = '.') {
    const results = {
      total: 0,
      modified: 0,
      failed: 0,
      details: []
    };

    const absRoot = path.resolve(this.repoRoot, root);

    for (const instruction of instructions) {
      const targets = await this.collectPackageTargets(absRoot, instruction);

      for (const target of targets) {
        results.total++;

        const success = await this.executeDependencyInstruction(target, instruction);
        if (success) {
          results.modified++;
          results.details.push({ file: target, status: 'success' });
        } else {
          results.failed++;
          results.details.push({ file: target, status: 'failed', error: 'Dependency operation failed' });
        }
      }
    }

    return results;
  }

  async executeDependencyInstruction(filePath, instruction) {
    const backup = this.createMirroredBackup(filePath);

    try {
      const content = await fs.readFile(filePath, 'utf8');
      const pkgJson = JSON.parse(content);

      const depKey = instruction.dependencyType === 'runtime' ? 'dependencies' : 'devDependencies';
      pkgJson[depKey] = pkgJson[depKey] || {};

      let modified = false;
      const current = pkgJson[depKey][instruction.package];

      if (instruction.action === 'add') {
        if (current !== instruction.version) {
          pkgJson[depKey][instruction.package] = instruction.version;
          modified = true;
          console.log(`📦 ${instruction.action} ${instruction.package}@${instruction.version} to ${filePath}`);
        }
      } else if (instruction.action === 'remove') {
        if (current !== undefined) {
          delete pkgJson[depKey][instruction.package];
          modified = true;
          console.log(`🗑️  ${instruction.action} ${instruction.package} from ${filePath}`);
        }
      }

      if (modified && !this.dryRun) {
        await fs.writeFile(filePath, JSON.stringify(pkgJson, null, 2) + '\n');
      }

      return modified;

    } catch (error) {
      console.error(`❌ Dependency operation failed for ${filePath}: ${error.message}`);

      // Restore from backup
      try {
        await fs.copyFile(backup, filePath);
      } catch (restoreError) {
        console.error(`❌ Failed to restore backup: ${restoreError.message}`);
      }

      return false;
    }
  }

  async collectTargets(root, instruction) {
    const targets = [];

    await this.walkDirectory(root, async (filePath) => {
      const basename = path.basename(filePath);
      const fileType = this.detectFileType(filePath);

      // Filter by file pattern if specified
      if (instruction.fileName) {
        if (basename === instruction.fileName || this.matchesPattern(basename, instruction.fileName)) {
          if (fileType === 'structured' || fileType === 'templated_structured') {
            targets.push(filePath);
          }
        }
      } else if (fileType === 'structured' || fileType === 'templated_structured') {
        targets.push(filePath);
      }
    });

    return targets;
  }

  async collectPackageTargets(root, instruction) {
    const targets = [];
    const packageFile = instruction.packageFile || 'package.json';

    await this.walkDirectory(root, async (filePath) => {
      if (path.basename(filePath) === packageFile) {
        targets.push(filePath);
      }
    });

    return targets;
  }

  matchesPattern(filename, pattern) {
    // Simple glob matching - could be enhanced with minimatch
    if (pattern.includes('*')) {
      const regex = new RegExp(pattern.replace(/\*/g, '.*'));
      return regex.test(filename);
    }
    return filename === pattern;
  }

  async walkDirectory(dirPath, callback) {
    try {
      const entries = await fs.readdir(dirPath, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(dirPath, entry.name);

        if (entry.isDirectory()) {
          if (!SKIP_DIRECTORIES.has(entry.name)) {
            await this.walkDirectory(fullPath, callback);
          }
        } else if (entry.isFile()) {
          await callback(fullPath);
        }
      }
    } catch (error) {
      if (error.code !== 'ENOTDIR') {
        console.warn(`⚠️ Skipping ${dirPath}: ${error.message}`);
      }
    }
  }
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);
  const options = parseArgs(args);

  if (options.help) {
    printHelp();
    return;
  }

  const manager = new SurgicalConfigManager({
    dryRun: options.dryRun,
    verbose: options.verbose
  });

  let results;

  if (options.config) {
    const config = await loadConfig(options.config);

    if (config.type === 'dependencies') {
      results = await manager.manageDependencies(config.instructions, config.root);
    } else {
      results = await manager.manageConfigSettings(config.instructions, config.root);
    }
  } else if (options.operation) {
    // Single operation mode
    const instruction = buildInstruction(options);
    results = await manager.manageConfigSettings([instruction], options.root);
  } else {
    console.error('❌ No operation specified. Use --help for usage.');
    process.exit(1);
  }

  // Print results
  const suffix = manager.dryRun ? ' (dry run)' : '';
  console.log(`\n✅ Processed ${results.total} file(s); ${results.modified} modified${suffix}`);

  if (results.failed > 0) {
    console.log(`❌ ${results.failed} file(s) failed`);
    if (manager.verbose) {
      results.details.filter(d => d.status === 'failed').forEach(d => {
        console.log(`   • ${d.file}: ${d.error}`);
      });
    }
  }
}

function parseArgs(argv) {
  const options = {
    dryRun: false,
    verbose: false,
    help: false
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    switch (arg) {
      case '--help':
      case '-h':
        options.help = true;
        break;
      case '--dry-run':
        options.dryRun = true;
        break;
      case '--verbose':
      case '-v':
        options.verbose = true;
        break;
      case '--config':
        options.config = argv[++i];
        break;
      case '--root':
        options.root = argv[++i];
        break;
      case '--operation':
        options.operation = argv[++i];
        break;
      case '--key-path':
        options.keyPath = argv[++i];
        break;
      case '--value':
        options.value = argv[++i];
        break;
      case '--pattern':
        options.pattern = argv[++i];
        break;
      case '--replacement':
        options.replacement = argv[++i];
        break;
      case '--file-name':
        options.fileName = argv[++i];
        break;
      case '--format':
        options.format = argv[++i];
        break;
    }
  }

  return options;
}

function buildInstruction(options) {
  return {
    operation: options.operation,
    keyPath: options.keyPath,
    value: options.value ? JSON.parse(options.value) : undefined,
    pattern: options.pattern,
    replacement: options.replacement,
    fileName: options.fileName,
    format: options.format || DEFAULT_FORMAT
  };
}

async function loadConfig(configPath) {
  const content = await fs.readFile(configPath, 'utf8');
  return JSON.parse(content);
}

function printHelp() {
  console.log(`
Surgical Configuration Manager

Usage: node manage-config.mjs [options]

Options:
  --help, -h              Show this help message
  --config <file>         Load configuration from JSON file
  --root <path>           Root directory to process (default: .)
  --dry-run              Preview changes without writing
  --verbose, -v          Show detailed output

Single Operation Mode:
  --operation <op>        Operation to perform (set, array-add, etc.)
  --key-path <path>       JSON key path (dot notation)
  --value <json>          JSON value to set
  --pattern <regex>       Pattern for text/code operations
  --replacement <text>    Replacement text
  --file-name <pattern>   File pattern to match
  --format <type>         File format (json, yaml, etc.)

Examples:
  # Set value in all package.json files
  node manage-config.mjs --operation set --key-path version --value '"1.0.0"' --file-name package.json

  # Add dependency using config file
  node manage-config.mjs --config deps-config.json --dry-run

  # Update templated configuration
  node manage-config.mjs --operation set --key-path database.host --value '"localhost"' --file-name config.json.jinja
`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => {
    console.error(`❌ ${error.message}`);
    process.exit(1);
  });
}
