# Language Templates

Canonical templates for embedded CLI scripts. Each template includes the AXI
output contract (quiet by default, `--verbose`, `--dry-run`), structured
errors, and XDG path resolution.

## Table of Contents

1. [Bash Embedded Template](#bash-embedded-template)
2. [Python Embedded Template](#python-embedded-template)
3. [Rust Full Tool Template](#rust-full-tool-template)

## Bash Embedded Template

For tiny scripts (<50 lines), glue code, no external deps.

```bash
#!/usr/bin/env bash
set -euo pipefail

# <one-line description>
#
# Usage:
#   ./<name>.sh <args>
#   bash <name>.sh <args>
#
# Quiet by default; --verbose prints full detail; --dry-run prints what would
# happen without making changes.

# --- XDG paths ---
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/<tool>"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/<tool>"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/<tool>"

# --- Helpers ---
fail() {
    echo "error: $1"
    if [[ -n "${2:-}" ]]; then
        echo "help: $2"
    fi
    exit "${3:-1}"
}

# --- Args ---
VERBOSE=0
DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v) VERBOSE=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--verbose] [--dry-run] <args>"
            echo ""
            echo "Options:"
            echo "  --verbose, -v  Print full detail"
            echo "  --dry-run      Print what would happen without making changes"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        --*)
            fail "unknown flag $1" "Run with --help to see valid flags" 2
            ;;
        *)
            break
            ;;
    esac
done

# --- Main ---
mkdir -p "$CACHE_DIR" "$DATA_DIR"

# TODO: Implement script logic
echo "ok"
```

## Python Embedded Template

For substantive scripts, needs a library, >50 lines. Includes PEP 723 header,
devbox/rtk detection, argparse, and AXI output contract.

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     # "requests>=2.31.0",  # uncomment and list third-party deps here
# ]
# ///
"""
<one-line description>

Usage:
    uv run --script <name>.py <args>
    ./<name>.py <args>          # if uv is on PATH

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Devbox detection
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK detection
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


# ---------------------------------------------------------------------------
# XDG paths
# ---------------------------------------------------------------------------
def cache_dir(tool: str) -> Path:
    base = os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))
    return Path(base) / tool

def data_dir(tool: str) -> Path:
    base = os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local" / "share"))
    return Path(base) / tool

def config_dir(tool: str) -> Path:
    base = os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))
    return Path(base) / tool


# ---------------------------------------------------------------------------
# AXI output helpers
# ---------------------------------------------------------------------------
def fail(msg: str, suggestion: str = "", exit_code: int = 1) -> None:
    """Print structured error to stdout and exit."""
    print(f"error: {msg}")
    if suggestion:
        print(f"help: {suggestion}")
    sys.exit(exit_code)

def empty_state(context: str) -> None:
    """Print definitive empty state to stdout."""
    print(f"items: 0 {context}")

def truncate(text: str, limit: int = 1000) -> str:
    """Truncate text with metadata."""
    if len(text) <= limit:
        return text
    return f"{text[:limit]}...\n  ... (truncated, {len(text)} chars total)"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="<one-line description>",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Print full detail")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would happen without making changes")
    # TODO: Add command-specific arguments

    args = parser.parse_args()

    # Ensure XDG dirs exist
    cache_dir("<tool>").mkdir(parents=True, exist_ok=True)
    data_dir("<tool>").mkdir(parents=True, exist_ok=True)

    # TODO: Implement script logic
    if args.dry_run:
        print("Would do: <action>")
        return

    print("ok")


if __name__ == "__main__":
    main()
```

## Rust Full Tool Template

For full CLI tools scaffolded from `levonk-base-boilerplate/apps/cli/rust/`.
The boilerplate provides `Cargo.toml.jinja`, `clap` setup, `devbox.json`,
`Dockerfile`, `justfile`, and Nx `project.json`. The skill adds AXI compliance
on top.

### AXI module (add to `src/axi.rs`)

```rust
use std::fmt;
use std::process::ExitCode;

/// AXI-compliant error that prints to stdout in structured format.
pub struct AxiError {
    pub message: String,
    pub help: Option<String>,
    pub exit_code: ExitCode,
}

impl AxiError {
    pub fn new(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
            help: None,
            exit_code: ExitCode::from(1),
        }
    }

    pub fn usage(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
            help: None,
            exit_code: ExitCode::from(2),
        }
    }

    pub fn with_help(mut self, help: impl Into<String>) -> Self {
        self.help = Some(help.into());
        self
    }

    pub fn print_and_exit(self) -> ! {
        println!("error: {}", self.message);
        if let Some(h) = self.help {
            println!("help: {}", h);
        }
        std::process::exit(self.exit_code.into());
    }
}

/// Print a definitive empty state to stdout.
pub fn empty_state(context: &str) {
    println!("items: 0 {}", context);
}

/// Truncate text with metadata.
pub fn truncate(text: &str, limit: usize) -> String {
    if text.len() <= limit {
        text.to_string()
    } else {
        format!("{}...\n  ... (truncated, {} chars total)", &text[..limit], text.len())
    }
}

/// XDG cache directory.
pub fn cache_dir(tool: &str) -> std::path::PathBuf {
    let base = std::env::var("XDG_CACHE_HOME")
        .unwrap_or_else(|_| {
            dirs::cache_dir()
                .map(|p| p.to_string_lossy().into_owned())
                .unwrap_or_else(|| "~/.cache".to_string())
        });
    std::path::PathBuf::from(base).join(tool)
}

/// XDG data directory.
pub fn data_dir(tool: &str) -> std::path::PathBuf {
    let base = std::env::var("XDG_DATA_HOME")
        .unwrap_or_else(|_| {
            dirs::data_dir()
                .map(|p| p.to_string_lossy().into_owned())
                .unwrap_or_else(|| "~/.local/share".to_string())
        });
    std::path::PathBuf::from(base).join(tool)
}
```

### Usage in main.rs

```rust
mod axi;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "mytool", version, about = "A CLI tool for X")]
struct Cli {
    /// Verbose output
    #[arg(short, long)]
    verbose: bool,

    /// Dry run — print what would happen
    #[arg(long)]
    dry_run: bool,

    /// JSON output mode
    #[arg(long)]
    json: bool,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// List items
    List {
        /// Filter by status
        #[arg(long)]
        status: Option<String>,

        /// Maximum items to return
        #[arg(long, default_value = "100")]
        limit: usize,
    },
    /// View a single item
    View {
        /// Item ID
        id: String,
        /// Show full content (no truncation)
        #[arg(long)]
        full: bool,
    },
}

fn main() {
    let cli = Cli::parse();

    // Ensure XDG dirs exist
    std::fs::create_dir_all(axi::cache_dir("mytool")).ok();
    std::fs::create_dir_all(axi::data_dir("mytool")).ok();

    match cli.command {
        Commands::List { status, limit } => {
            let items = fetch_items(&status, limit);
            if items.is_empty() {
                let ctx = status
                    .map(|s| format!("items with status {}", s))
                    .unwrap_or_else(|| "items found".to_string());
                axi::empty_state(&ctx);
                return;
            }
            // Output with pre-computed aggregate
            println!("count: {} of {} total", items.len(), total_count());
            for item in &items {
                println!("{},{},{}", item.id, item.title, item.status);
            }
            // Contextual disclosure
            println!("help[2]:");
            println!("  Run `mytool view <id>` for details");
            println!("  Run `mytool create --title \"...\"` to add an item");
        }
        Commands::View { id, full } => {
            let item = match fetch_item(&id) {
                Some(i) => i,
                None => {
                    axi::AxiError::new(format!("item {} not found", id))
                        .with_help("Run `mytool list` to see available items")
                        .print_and_exit();
                }
            };
            if full {
                println!("{}", item.body);
            } else {
                println!("{}", axi::truncate(&item.body, 1000));
            }
        }
    }
}
```
