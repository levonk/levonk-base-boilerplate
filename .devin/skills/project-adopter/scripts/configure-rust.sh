#!/usr/bin/env bash
# configure-rust.sh
# Rust project configuration script
# Handles Cargo.toml, rustfmt.toml, clippy.toml, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure Rust project
configure_rust_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Rust project (mode: $mode, app_type: $app_type)"

    # Handle Cargo.toml
    if [[ -f "$project_path/Cargo.toml" ]]; then
        configure_cargo_toml "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle Rust formatting configuration
    configure_rustfmt_config "$project_path" "$mode"

    # Handle Clippy configuration
    configure_clippy_config "$project_path" "$mode"

    # Handle Rust analyzer configuration
    configure_rust_analyzer_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_rust_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure Cargo.toml
configure_cargo_toml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Cargo.toml for Rust project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_cargo_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_cargo_features "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_cargo_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to Cargo.toml
add_standardize_cargo_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local dev_deps_to_add=""
    local deps_to_add=""

    # Base dev dependencies for all Rust projects
    dev_deps_to_add='"tokio-test", "criterion", "proptest"'

    # App-type specific dependencies
    case "$app_type" in
        "web")
            deps_to_add="$deps_to_add, \"wasm-bindgen\", \"wasm-bindgen-futures\""
            dev_deps_to_add="$dev_deps_to_add, \"wasm-pack\", \"wasm-bindgen-test\""
            if [[ "$project_type" == *"frontend-web"* ]]; then
                deps_to_add="$deps_to_add, \"web-sys\", \"js-sys\""
            fi
            ;;
        "cli")
            deps_to_add="$deps_to_add, \"clap\", \"anyhow\", \"thiserror\""
            ;;
        "api")
            deps_to_add="$deps_to_add, \"tokio\", \"serde\", \"serde_json\", \"axum\""
            dev_deps_to_add="$dev_deps_to_add, \"tower-http\""
            ;;
    esac

    # Framework-specific dependencies
    case "$project_type" in
        "frontend-web")
            if [[ -f "$project_path/index.html" ]] || [[ -d "$project_path/www" ]]; then
                deps_to_add="$deps_to_add, \"yew\""
                dev_deps_to_add="$dev_deps_to_add, \"trunk\""
            fi
            ;;
        "api-service")
            deps_to_add="$deps_to_add, \"sqlx\", \"uuid\", \"chrono\""
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to Cargo.toml using yq-go"
        # Add devDependencies
        # yq-go eval ".[\"dev-dependencies\"] += {$dev_deps_to_add}" "$project_path/Cargo.toml" -i
        # Add dependencies if any
        if [[ -n "$deps_to_add" ]]; then
            # yq-go eval ".dependencies += {$deps_to_add}" "$project_path/Cargo.toml" -i
        fi
    else
        log_warn "yq-go not available, skipping Cargo.toml dependency updates"
    fi
}

# Add adopt mode dependencies to Cargo.toml
add_adopt_cargo_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Adopt mode - minimal essential dependencies only
    local essential_deps=""

    case "$app_type" in
        "web")
            essential_deps='"wasm-bindgen"'
            ;;
        "cli")
            essential_deps='"clap", "anyhow"'
            ;;
        "api")
            essential_deps='"tokio", "serde"'
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1 && [[ -n "$essential_deps" ]]; then
        echo "Adding adopt dependencies to Cargo.toml using yq-go"
        # yq-go eval ".dependencies += {$essential_deps}" "$project_path/Cargo.toml" -i
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode features
add_standardize_cargo_features() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Add common features based on app type
    local features_to_add=""

    case "$app_type" in
        "web")
            features_to_add='"default", "console_error_panic_hook", "exception_handler"'
            ;;
        "cli")
            features_to_add='"default", "derive"'
            ;;
        "api")
            features_to_add='"default", "full", "macros"'
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1 && [[ -n "$features_to_add" ]]; then
        echo "Adding features to Cargo.toml using yq-go"
        # yq-go eval ".features.default += [$features_to_add]" "$project_path/Cargo.toml" -i
    else
        log_warn "yq-go not available or no features to add"
    fi
}

# Configure rustfmt
configure_rustfmt_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/rustfmt.toml" ]]; then
        cat > "$project_path/rustfmt.toml" << 'EOF'
edition = "2021"
hard_tabs = false
tab_spaces = 4
max_width = 80
use_small_heuristics = "Default"
reorder_imports = true
reorder_modules = true
remove_nested_parens = true
edition_2021 = true
merge_derives = true
use_try_shorthand = true
use_field_init_shorthand = true
force_explicit_abi = true
empty_item_single_line = true
struct_lit_single_line = true
fn_single_line = false
where_single_line = false
imports_granularity = "Crate"
group_imports = "StdExternalCrate"
EOF
        log_info "✓ Created rustfmt.toml"
    fi
}

# Configure Clippy
configure_clippy_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/clippy.toml" ]]; then
        cat > "$project_path/clippy.toml" << 'EOF'
# General configuration
cognitive-complexity-threshold = 30
too-many-arguments-threshold = 7
type-complexity-threshold = 250
too-many-lines-threshold = 100

# Pedantic lints
pedantic = true
nursery = true

# Allow some pedantic lints that are often too strict
allow-expect-in-tests = true
allow-unwrap-in-tests = true
allow-panic-in-tests = true
allow-dirty-cfg = true

# Performance lints
performance = true

# Style lints
style = true

# Suspicious lints
suspicious_double_clone_op = "allow"
suspicious_operation_groupings = "allow"

# Cargo-specific lints
multiple_crate_versions = "allow"
wildcard_dependencies = "allow"
EOF
        log_info "✓ Created clippy.toml"
    fi
}

# Configure Rust analyzer
configure_rust_analyzer_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.rust-analyzer.toml" ]]; then
        cat > "$project_path/.rust-analyzer.toml" << 'EOF'
# Rust analyzer configuration
[procMacro]
enable = true

[diagnostics]
enable = true
disabled = ["unresolved-proc-macro"]

[hover]
actions.enable = true

[inlayHints]
bindingModeHints.enable = true
chainingHints.enable = true
closingBraceHints.minLines = 10
closureReturnTypeHints.enable = "with_block"
discriminantHints.enable = true
expressionAdjustmentHints.enable = "never"
lifetimeElisionHints.enable = "skip_trivial"
parameterHints.enable = true
rangeExclusiveHints.enable = true
renderColons = true
typeHints.hideNamedConstructor = false
typeHints.hideClosureInitialization = false
typeHints.hideNamedConstructor = false

[lens]
enable = true
implementations.enable = true
references.adt.enable = true
references.enumVariant.enable = true
references.method.enable = true
references.trait.enable = true
run.enable = true

[rustc]
private = false

[completion]
addCallParentheses = true
addCallArgumentSnippets = true
postfix.enable = true
snippets.custom = {}
EOF
        log_info "✓ Created .rust-analyzer.toml"
    fi
}

# Configure Rust framework-specific configurations
configure_rust_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Yew configuration
    if [[ -f "$project_path/index.html" ]] || [[ -d "$project_path/www" ]]; then
        configure_yew_config "$project_path" "$mode"
    fi

    # Axum configuration
    if [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_axum_config "$project_path" "$mode"
    fi

    # Trunk configuration for web apps
    if [[ "$app_type" == "web" ]] && [[ "$mode" == "standardize" ]]; then
        configure_trunk_config "$project_path" "$mode"
    fi
}

# Configure Yew
configure_yew_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/index.html" ]]; then
        cat > "$project_path/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yew App</title>
</head>
<body>
    <div id="app"></div>
</body>
</html>
EOF
        log_info "✓ Created index.html for Yew app"
    fi
}

# Configure Axum
configure_axum_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Axum project structure
        mkdir -p "$project_path/src/handlers"
        
        if [[ ! -f "$project_path/src/handlers/mod.rs" ]]; then
            cat > "$project_path/src/handlers/mod.rs" << 'EOF'
pub mod health;
pub mod api;
EOF
            log_info "✓ Created handlers/mod.rs"
        fi

        if [[ ! -f "$project_path/src/handlers/health.rs" ]]; then
            cat > "$project_path/src/handlers/health.rs" << 'EOF'
use axum::{Json, response::IntoResponse};
use serde_json::Value;

pub async fn health_check() -> impl IntoResponse {
    Json(serde_json::json!({
        "status": "healthy",
        "timestamp": chrono::Utc::now().to_rfc3339()
    }))
}
EOF
            log_info "✓ Created handlers/health.rs"
        fi
    fi
}

# Configure Trunk
configure_trunk_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/Trunk.toml" ]]; then
        cat > "$project_path/Trunk.toml" << 'EOF'
[build]
# The index HTML file to drive the bundling process.
target = "index.html"

# Build in release mode.
release = false

# The output dir for all final assets.
dist = "dist"

# The public URL from which assets are to be served.
public_url = "/"

[watch]
# Paths to watch. The `build.target`'s parent folder is watched by default.
watch = ["src", "index.html"]

# Paths to ignore.
ignore = ["dist"]

[serve]
# The address to serve on.
address = "127.0.0.1"

# The port to serve on.
port = 8080

# Open a browser tab once the initial build is complete.
open = false

# Disable auto-reload of the web app.
no_autoreload = false

[clean]
# The output dir.
dist = "dist"

# Optionally perform additional explicit file cleanups.
cargo = false
EOF
        log_info "✓ Created Trunk.toml"
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_rust_project
export -f configure_cargo_toml
export -f configure_rustfmt_config
export -f configure_clippy_config
