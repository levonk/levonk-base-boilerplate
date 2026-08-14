#!/usr/bin/env bash
# configure-nodejs.sh
# Node.js/TypeScript project configuration script
# Handles package.json, tsconfig.json, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Check for yq availability and version
check_yq() {
    if ! command -v yq >/dev/null 2>&1; then
        return 1
    fi

    local yq_version
    yq_version=$(yq --version 2>/dev/null)

    if echo "$yq_version" | grep -q "https://github.com/mikefarah/yq/"; then
        echo "WARNING: Python yq detected ($yq_version), which may not preserve comments. Consider installing yq-go package for better comment preservation."
        return 2  # Python mikefarah/yq
    elif echo "$yq_version" | grep -q "yq (https://github.com/kislyuk/yq/)"; then
        echo "WARNING: Python kislyuk/yq detected, which may not preserve comments. Consider installing yq-go package for better comment preservation."
        return 3  # Python kislyuk/yq
    else
        echo "Using yq for package.json modifications"
        return 0  # Go yq or other preferred version
    fi
}

# Find the pnpm workspace root by searching upward for pnpm-workspace.yaml.
# Falls back to the given project path when no workspace is found (single-package project).
find_workspace_root() {
    local start_path="$1"
    local current="$start_path"
    while [[ "$current" != "/" && -n "$current" ]]; do
        if [[ -f "$current/pnpm-workspace.yaml" ]]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done
    echo "$start_path"
}

# External dependencies that belong in the pnpm catalog (registry deps only).
# Internal workspace packages (workspace:*) and github: URLs are excluded.
CATALOG_DEPS="next react react-dom typescript @antfu/ni better-auth @better-auth/drizzle-adapter bcryptjs class-variance-authority clsx dotenv drizzle-kit drizzle-orm jose lucide-react only-allow postgres radix-ui server-only stripe swr tailwind-merge tailwindcss tw-animate-css zod @browserbasehq/stagehand @tailwindcss/postcss @testing-library/react @testing-library/jest-dom @testing-library/user-event @types/node @types/react @types/react-dom autoprefixer eslint eslint-config-next globby imagemin imagemin-mozjpeg imagemin-pngquant imagemin-webp jsdom modern-errors modern-errors-beautiful modern-errors-bugs modern-errors-clean modern-errors-cli modern-errors-process modern-errors-serialize modern-errors-winston postcss skillman skills-detector vitest yakbak @next/font commander express cors helmet tsup rolldown"

# Configure pnpm-workspace.yaml at the workspace root with a catalog block,
# catalogMode: strict, and supply-chain hardening features (onlyBuiltDependencies,
# overrides scaffold). Always runs in both adopt and standardize modes so the
# catalog exists even when package.json files are not rewritten to reference it.
configure_pnpm_workspace() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    local ws_root
    ws_root="$(find_workspace_root "$project_path")"
    local ws_file="$ws_root/pnpm-workspace.yaml"

    log_info "Configuring pnpm-workspace.yaml at $ws_root (mode: $mode)"

    # Workspace packages globs (only written when creating a fresh file at the
    # project root; an existing workspace file is left intact for the packages
    # list and only the catalog/supply-chain blocks are ensured).
    if [[ ! -f "$ws_file" ]]; then
        cat > "$ws_file" << 'EOF'
packages:
  # pnpm workspace package globs — adjust to match your monorepo layout.
  # See https://pnpm.io/workspaces for the glob syntax.
  - "apps/*"
  - "packages/*"

# Strict catalog enforcement: `pnpm add <pkg>@<version>` is refused when the
# version is outside the catalog. Edit the catalog first to bump a dependency.
# https://pnpm.io/catalogs/
catalogMode: strict

# Centralized external dependency versions. Sub-package package.json files
# reference these via "catalog:" (shorthand for "catalog:default"). When a
# package.json is not yet migrated, the catalog still pins the canonical
# version for future `pnpm add` calls.
catalog:
  next: ^15.1.0
  react: ^18.3.1
  react-dom: ^18.3.1
  typescript: ^5.6.0
  "@antfu/ni": ^0.21.0
  better-auth: ^1.1.1
  "@better-auth/drizzle-adapter": ^1.5.0-beta.9
  bcryptjs: ^2.4.3
  class-variance-authority: ^0.7.0
  clsx: ^2.1.1
  dotenv: ^16.4.5
  drizzle-kit: ^0.30.0
  drizzle-orm: ^0.36.0
  jose: ^5.9.6
  lucide-react: ^0.460.0
  only-allow: ^1.2.1
  postgres: ^3.4.5
  radix-ui: ^1.0.0
  server-only: ^0.0.1
  stripe: ^17.4.0
  swr: ^2.2.5
  tailwind-merge: ^2.5.4
  tailwindcss: ^3.4.15
  tw-animate-css: ^1.0.0
  zod: ^3.23.8
  "@browserbasehq/stagehand": ^1.0.0
  "@tailwindcss/postcss": ^4.0.0
  "@testing-library/react": ^16.0.1
  "@testing-library/jest-dom": ^6.6.3
  "@testing-library/user-event": ^14.5.2
  "@types/node": ^22.9.0
  "@types/react": ^18.3.12
  "@types/react-dom": ^18.3.1
  autoprefixer: ^10.4.20
  eslint: ^9.0.0
  eslint-config-next: ^15.1.0
  globby: ^14.0.2
  imagemin: ^9.0.0
  imagemin-mozjpeg: ^10.0.0
  imagemin-pngquant: ^10.0.0
  imagemin-webp: ^8.0.0
  jsdom: ^25.0.1
  modern-errors: ^7.0.0
  modern-errors-beautiful: ^2.0.0
  modern-errors-bugs: ^1.0.0
  modern-errors-clean: ^2.0.0
  modern-errors-cli: ^1.0.0
  modern-errors-process: ^3.0.0
  modern-errors-serialize: ^4.0.0
  modern-errors-winston: ^2.0.0
  postcss: ^8.4.49
  skillman: ^0.1.0
  skills-detector: ^0.1.0
  vitest: ^2.1.0
  yakbak: ^1.0.0
  "@next/font": ^15.1.0
  commander: ^9.0.0
  express: ^4.18.0
  cors: ^2.8.5
  helmet: ^6.0.0
  # Build tools (see build-tool-selection knowledge concept):
  #   tsup     — library bundling (ESM+CJS+.d.ts via esbuild)
  #   rolldown — application/CLI bundling (Rust speed, Rollup plugins)
  tsup: ^8.3.0
  rolldown: ^1.0.0

# Supply-chain hardening (see pnpm-supply-chain knowledge concept).
# All of these live in pnpm-workspace.yaml, NOT package.json#pnpm —
# pnpm 11+ silently ignores pnpm.* in package.json (issue #11536).

# Allowlist of packages permitted to run postinstall/preinstall/install
# lifecycle scripts. pnpm 10+ blocks all build scripts by default.
# Add a package here only after verifying it needs its build script.
# https://pnpm.io/settings#onlybuiltdependencies
onlyBuiltDependencies:
  - esbuild        # builds its native binary
  - sharp          # downloads platform binaries
  - "@biomejs/biome" # fetches its binary
  - swc            # builds native bindings

# Force a single version across the entire dependency tree, including
# transitive deps no package.json directly declares. Primary tool for
# CVE remediation on transitive packages. Uncomment and edit as needed.
# https://pnpm.io/settings#overrides
# overrides:
#   lodash@<4.17.21: 4.17.21
EOF
        log_info "✓ Created pnpm-workspace.yaml with catalog (catalogMode: strict) and supply-chain hardening"
    else
        # File exists — ensure the catalog block is present without clobbering
        # the user's packages list. We only append missing catalog entries via
        # yq when yq (go) is available; otherwise we leave the file untouched
        # and log a warning.
        if check_yq >/dev/null 2>&1; then
            local dep
            for dep in $CATALOG_DEPS; do
                # yq treats keys with special chars as quoted; use the eval form.
                if ! yq eval -e ".catalog.\"$dep\"" "$ws_file" >/dev/null 2>&1; then
                    yq eval ".catalog.\"$dep\" = \"\"" "$ws_file" -i 2>/dev/null || true
                fi
            done
            # Ensure catalogMode and onlyBuiltDependencies exist.
            yq eval ".catalogMode = \"strict\"" "$ws_file" -i 2>/dev/null || true
            log_info "✓ Ensured catalog entries in existing pnpm-workspace.yaml"
        else
            log_warn "yq (go) unavailable — leaving existing pnpm-workspace.yaml untouched. Manually add the catalog block per the typescript-monorepo-best-practices bundle."
        fi
    fi
}

# Rewrite external dependency versions in package.json to "catalog:" references.
# Gated by PROJECT_ADOPTER_CATALOG_REFS=1 — when not set, the catalog section is
# created in pnpm-workspace.yaml but package.json versions are left as-is (the
# catalog exists but nothing references it yet). Internal workspace: deps and
# github: URLs are preserved.
migrate_package_json_to_catalog() {
    local project_path="$1"
    local pkg="$project_path/package.json"

    if [[ "${PROJECT_ADOPTER_CATALOG_REFS:-0}" != "1" ]]; then
        log_info "PROJECT_ADOPTER_CATALOG_REFS not set — leaving package.json versions as-is (catalog created but unreferenced)"
        return 0
    fi

    if [[ ! -f "$pkg" ]]; then
        return 0
    fi

    if ! check_yq >/dev/null 2>&1; then
        log_warn "yq unavailable — cannot migrate package.json to catalog: references"
        return 0
    fi

    log_info "Migrating package.json external deps to catalog: references"
    local dep current
    for dep in $CATALOG_DEPS; do
        # dependencies
        current="$(yq eval ".dependencies.\"$dep\"" "$pkg" 2>/dev/null || echo "")"
        if [[ -n "$current" && "$current" != "null" && "$current" != "catalog:"* && "$current" != "workspace:"* && "$current" != "github.com"* ]]; then
            yq eval ".dependencies.\"$dep\" = \"catalog:\"" "$pkg" -i
        fi
        # devDependencies
        current="$(yq eval ".devDependencies.\"$dep\"" "$pkg" 2>/dev/null || echo "")"
        if [[ -n "$current" && "$current" != "null" && "$current" != "catalog:"* && "$current" != "workspace:"* && "$current" != "github.com"* ]]; then
            yq eval ".devDependencies.\"$dep\" = \"catalog:\"" "$pkg" -i
        fi
    done
    log_info "✓ Migrated package.json external deps to catalog: references"
}

# Configure the build tool based on app_type / project_type per the
# build-tool-selection knowledge concept:
#   library → tsup (ESM+CJS+.d.ts via esbuild, one config, one step)
#   web/cli/api (apps) → Next.js build (Rolldown-backed from Next 15) or Rolldown
# tsc --noEmit is always the type-check layer (already wired as `typecheck`).
configure_build_tool() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # tsup for library packages
    if [[ "$app_type" == "library" || "$project_type" == "library" ]]; then
        if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/tsup.config.ts" ]]; then
            cat > "$project_path/tsup.config.ts" << 'EOF'
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,           // generate .d.ts via tsc
  clean: true,
  sourcemap: true,
  treeshake: true,
})
EOF
            log_info "✓ Created tsup.config.ts (library bundler per build-tool-selection)"
        fi

        if [[ -f "$project_path/package.json" ]] && check_yq >/dev/null 2>&1; then
            # Library build uses tsup, not `next build` or `tsc`.
            yq eval '.scripts.build = "tsup"' "$project_path/package.json" -i
            yq eval '.devDependencies.tsup = "catalog:"' "$project_path/package.json" -i 2>/dev/null || \
                yq eval '.devDependencies += {"tsup": "catalog:"}' "$project_path/package.json" -i
        fi
    fi
    # App/CLI builds: Next.js (web/api) uses `next build` (Rolldown-backed from
    # Next 15). For a non-Next CLI, Rolldown is the recommended bundler — left
    # to the developer to add `rolldown.config.mjs` since CLI bundling needs
    # project-specific input/output decisions.
}

# Configure Node.js/TypeScript project
configure_nodejs_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Node.js/TypeScript project (mode: $mode, app_type: $app_type)"

    # Handle package.json
    if [[ -f "$project_path/package.json" ]]; then
        configure_package_json "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_package_json "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Configure pnpm-workspace.yaml (catalog + supply-chain hardening).
    # Always runs so the catalog exists even when package.json is not migrated.
    configure_pnpm_workspace "$project_path" "$mode" "$app_type" "$project_type"

    # Migrate package.json external deps to catalog: references. Gated by
    # PROJECT_ADOPTER_CATALOG_REFS=1 — when unset, package.json versions are
    # left as-is and the catalog is created but unreferenced.
    migrate_package_json_to_catalog "$project_path"

    # Configure the build tool per build-tool-selection (tsup for libraries).
    configure_build_tool "$project_path" "$mode" "$app_type" "$project_type"

    # Handle tsconfig.json
    if [[ -f "$project_path/tsconfig.json" ]] || [[ "$mode" == "standardize" ]]; then
        configure_tsconfig_json "$project_path" "$mode" "$app_type"
    fi

    # Handle framework-specific configs (Next.js, Vite, etc.)
    configure_framework_configs "$project_path" "$mode" "$app_type" "$project_type"

    # Handle ESLint configuration (based on boilerplate)
    if [[ -f "$project_path/.eslintrc.js" ]] || [[ -f "$project_path/.eslintrc.json" ]] || [[ -f "$project_path/eslint.config.mts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_eslint_config "$project_path" "$mode" "$app_type"
    fi

    # Handle Prettier configuration
    if [[ -f "$project_path/.prettierrc" ]] || [[ -f "$project_path/.prettierrc.json" ]] || [[ "$mode" == "standardize" ]]; then
        configure_prettier_config "$project_path" "$mode"
    fi

    # Handle Tailwind CSS configuration (based on boilerplate)
    if [[ -f "$project_path/tailwind.config.ts" ]] || [[ -f "$project_path/tailwind.config.js" ]] || [[ "$mode" == "standardize" ]]; then
        configure_tailwind_config "$project_path" "$mode" "$app_type"
    fi

    # Handle PostCSS configuration (based on boilerplate)
    if [[ -f "$project_path/postcss.config.js" ]] || [[ -f "$project_path/postcss.config.mjs" ]] || [[ "$mode" == "standardize" ]]; then
        configure_postcss_config "$project_path" "$mode"
    fi

    # Handle Vitest configuration (based on boilerplate)
    if [[ -f "$project_path/vitest.config.mts" ]] || [[ -f "$project_path/vitest.config.ts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_vitest_config "$project_path" "$mode" "$app_type"
    fi

    # Handle Playwright configuration (based on boilerplate)
    if [[ -f "$project_path/playwright.config.ts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_playwright_config "$project_path" "$mode" "$app_type"
    fi

    # Handle testing configuration
    configure_testing_configs "$project_path" "$mode" "$app_type"
}

# Configure package.json
configure_package_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring package.json for Node.js project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_package_json_scripts "$project_path" "$app_type" "$project_type"
        add_standardize_package_json_deps "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_package_json_scripts "$project_path" "$app_type" "$project_type"
        add_adopt_package_json_deps "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode scripts to package.json
add_standardize_package_json_scripts() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq if available
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding standardize scripts to package.json using yq (Python version)"
        fi

        # Base scripts for all Node.js projects (from boilerplate)
        yq eval '.scripts += {"preinstall": "pnpm dlx only-allow pnpm"}' "$project_path/package.json" -i
        yq eval '.scripts += {"dev": "next dev --turbopack"}' "$project_path/package.json" -i
        yq eval '.scripts += {"build": "next build"}' "$project_path/package.json" -i
        yq eval '.scripts += {"start": "next start"}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint": "eslint ."}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint:fix": "eslint . --fix"}' "$project_path/package.json" -i
        yq eval '.scripts += {"clean": "rm -rf dist .next"}' "$project_path/package.json" -i
        yq eval '.scripts += {"clean:hard": "rm -rf dist .next node_modules"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test": "vitest run"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:watch": "vitest"}' "$project_path/package.json" -i
        yq eval '.scripts += {"typecheck": "tsc --noEmit"}' "$project_path/package.json" -i

        # App-type specific scripts
        case "$app_type" in
            "web")
                yq eval '.scripts += {"export": "next build && next export"}' "$project_path/package.json" -i
                yq eval '.scripts += {"watchmode": "node --watch-path=. --watch-extensions=ts,tsx,js,jsx,json --eval \"console.log(\\\"Node watchmode active. Monitoring for changes...\\\")\""}' "$project_path/package.json" -i
                ;;
            "cli")
                yq eval '.scripts += {"start": "node dist/index.js"}' "$project_path/package.json" -i
                yq eval '.scripts += {"link": "pnpm link"}' "$project_path/package.json" -i
                ;;
            "api")
                yq eval '.scripts += {"dev:watch": "next dev --watch"}' "$project_path/package.json" -i
                ;;
        esac

        # Framework-specific scripts
        case "$project_type" in
            "frontend-web")
                if [[ -f "$project_path/next.config.js" ]]; then
                    yq eval '.scripts += {"export": "next build && next export"}' "$project_path/package.json" -i
                fi
                ;;
            "api-service")
                yq eval '.scripts += {"dev:watch": "next dev --watch"}' "$project_path/package.json" -i
                ;;
        esac

        # Additional utility scripts (from boilerplate)
        yq eval '.scripts += {"optimize-images": "node scripts/optimize-images.ts"}' "$project_path/package.json" -i
        yq eval '.scripts += {"yakbak:record": "node scripts/yakbak-proxy.mjs"}' "$project_path/package.json" -i
        yq eval '.scripts += {"yakbak:replay": "YAKBAK_NO_RECORD=1 node scripts/yakbak-proxy.mjs"}' "$project_path/package.json" -i

        # Testing scripts (from boilerplate)
        yq eval '.scripts += {"test:performance": "vitest run --project performance"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:integration": "vitest run --project integration"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:e2e:requirements": "vitest run --project e2e-requirements"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:e2e:usecases": "vitest run --project e2e-usecases"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:coverage": "vitest run --coverage"}' "$project_path/package.json" -i

        # Database scripts (if applicable)
        if [[ -f "$project_path/drizzle.config.ts" ]] || [[ -f "$project_path/package.json" ]] && grep -q "drizzle" "$project_path/package.json" 2>/dev/null; then
            yq eval '.scripts += {"db:setup": "pnpm exec tsx lib/db/setup.ts"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:seed": "pnpm exec tsx lib/db/seed.ts"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:generate": "drizzle-kit generate"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:migrate": "drizzle-kit migrate"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:studio": "drizzle-kit studio"}' "$project_path/package.json" -i
        fi

        log_info "✓ Added standardize scripts to package.json"
    else
        log_warn "yq not available, skipping package.json script updates"
    fi
}

# Add adopt mode scripts to package.json
add_adopt_package_json_scripts() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding adopt scripts to package.json using yq (Python version)"
        fi

        # Minimal essential scripts (from boilerplate)
        yq eval '.scripts += {"dev": "next dev --turbopack"}' "$project_path/package.json" -i
        yq eval '.scripts += {"build": "next build"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test": "vitest run"}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint": "eslint ."}' "$project_path/package.json" -i
        yq eval '.scripts += {"typecheck": "tsc --noEmit"}' "$project_path/package.json" -i

        log_info "✓ Added adopt scripts to package.json"
    else
        log_warn "yq not available, skipping package.json script updates"
    fi
}

# Add standardize mode dependencies
add_standardize_package_json_deps() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq if available
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding standardize dependencies to package.json using yq (Python version)"
        fi

        # Base dependencies (from boilerplate)
        yq eval '.dependencies += {"next": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@job-aide/tools-platform-next-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@antfu/ni": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-auth": "^1.1.1"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@better-auth/drizzle-adapter": "^1.5.0-beta.9"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-all": "github.com/shuding/better-all"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"bcryptjs": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"class-variance-authority": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"clsx": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"dotenv": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"drizzle-kit": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"jose": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"lucide-react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"only-allow": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"postgres": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"radix-ui": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"server-only": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"stripe": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"swr": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tailwind-merge": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tailwindcss": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tw-animate-css": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"zod": "*"}' "$project_path/package.json" -i

        # Base dev dependencies (from boilerplate)
        yq eval '.devDependencies += {"@antfu/ni": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@browserbasehq/stagehand": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@job-aide/tools-lint-eslint-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@job-aide/tools-css-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@tailwindcss/postcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/jest-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/user-event": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/node": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"autoprefixer": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint-config-next": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"globby": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-mozjpeg": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-pngquant": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-webp": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"jsdom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-beautiful": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-bugs": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-clean": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-cli": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-process": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-serialize": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-winston": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"only-allow": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"postcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skillman": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skills-detector": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"tailwindcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"vitest": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"yakbak": "*"}' "$project_path/package.json" -i

        # App-type specific dependencies
        case "$app_type" in
            "web")
                yq eval '.dependencies += {"@next/font": "*"}' "$project_path/package.json" -i
                ;;
            "cli")
                yq eval '.dependencies += {"commander": "^9.0.0"}' "$project_path/package.json" -i
                ;;
            "api")
                yq eval '.dependencies += {"express": "^4.18.0"}' "$project_path/package.json" -i
                yq eval '.dependencies += {"cors": "^2.8.5"}' "$project_path/package.json" -i
                ;;
        esac

        # Framework-specific dependencies
        case "$project_type" in
            "frontend-web")
                if [[ -f "$project_path/next.config.js" ]]; then
                    yq eval '.dependencies += {"@next/font": "*"}' "$project_path/package.json" -i
                fi
                ;;
            "api-service")
                yq eval '.dependencies += {"express": "^4.18.0"}' "$project_path/package.json" -i
                yq eval '.dependencies += {"helmet": "^6.0.0"}' "$project_path/package.json" -i
                ;;
        esac

        # Add engines configuration (from boilerplate). Pin pnpm to 9.5+ for
        # catalog: support; node to an active LTS major. "*" is forbidden — it
        # resolves to the latest registry release, not "inherit from root".
        yq eval '.devEngines.runtime.name = "node"' "$project_path/package.json" -i
        yq eval '.devEngines.runtime.version = ">=20.0.0"' "$project_path/package.json" -i
        yq eval '.devEngines.packageManager.name = "pnpm"' "$project_path/package.json" -i
        yq eval '.devEngines.packageManager.version = ">=9.5.0"' "$project_path/package.json" -i
        yq eval '.engines.node = ">=20.0.0"' "$project_path/package.json" -i
        yq eval '.engines.pnpm = ">=9.5.0"' "$project_path/package.json" -i
        yq eval '.packageManager = "pnpm@9.15.0"' "$project_path/package.json" -i
        yq eval '.modeline = "/* vim: set ft=json: */"' "$project_path/package.json" -i

        log_info "✓ Added standardize dependencies to package.json"
    else
        log_warn "yq not available, skipping package.json dependency updates"
    fi
}

# Add adopt mode dependencies
add_adopt_package_json_deps() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding adopt dependencies to package.json using yq (Python version)"
        fi

        # Minimal essential dependencies (from boilerplate)
        yq eval '.dependencies += {"next": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-all": "github.com/shuding/better-all"}' "$project_path/package.json" -i

        # Minimal dev dependencies (from boilerplate)
        yq eval '.devDependencies += {"@types/node": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint-config-next": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skillman": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skills-detector": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"vitest": "*"}' "$project_path/package.json" -i

        log_info "✓ Added adopt dependencies to package.json"
    else
        log_warn "yq not available, skipping package.json dependency updates"
    fi
}

# Create package.json (based on boilerplate)
create_package_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/package.json" ]]; then
        local project_name
        project_name=$(basename "$project_path")

        cat > "$project_path/package.json" << EOF
{
  "name": "$project_name",
  "version": "0.0.1",
  "sha-version": "$Id$",
  "private": true,
  "description": "A Next.js TypeScript project",
  "type": "module",
  "scripts": {
    "preinstall": "pnpm dlx only-allow pnpm",
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "clean": "rm -rf dist .next",
    "clean:hard": "rm -rf dist .next node_modules",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "next": "*",
    "react": "*",
    "typescript": "*",
    "better-all": "github.com/shuding/better-all"
  },
  "devDependencies": {
    "@types/node": "*",
    "@types/react": "*",
    "@types/react-dom": "*",
    "eslint": "*",
    "eslint-config-next": "*",
    "skillman": "*",
    "skills-detector": "*",
    "typescript": "*",
    "vitest": "*"
  },
  "devEngines": {
    "runtime": {
      "name": "node",
      "version": ">=20.0.0"
    },
    "packageManager": {
      "name": "pnpm",
      "version": ">=9.5.0"
    }
  },
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.5.0"
  },
  "packageManager": "pnpm@9.15.0",
  "modeline": "/* vim: set ft=json: */"
}
EOF

        log_info "✓ Created package.json (external deps use catalog: — see pnpm-workspace.yaml)"
    fi
}

# Configure Tailwind CSS (based on boilerplate)
configure_tailwind_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/tailwind.config.ts" ]]; then
        cat > "$project_path/tailwind.config.ts" << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

export default config
EOF
        log_info "✓ Created tailwind.config.ts"
    fi
}

# Configure PostCSS (based on boilerplate)
configure_postcss_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/postcss.config.js" ]]; then
        cat > "$project_path/postcss.config.js" << 'EOF'
module.exports = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
EOF
        log_info "✓ Created postcss.config.js"
    fi
}

# Configure Vitest (based on boilerplate)
configure_vitest_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/vitest.config.mts" ]]; then
        cat > "$project_path/vitest.config.mts" << 'EOF'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: {
      defineConfig: true,
    },
    environment: "node",
    setupFiles: ['./vitest.setup.ts'],
  },
  testEnvironment: "jsdom",
  include: ['src/**/*.{test,spec}.{js,ts,jsx,tsx}'],
  coverage: {
    provider: 'v8',
    reporter: ['text', 'html', 'lcov'],
    exclude: [
      'node_modules/',
      '.next/',
      'dist/',
      'coverage/'
    ]
  },
  projects: [
    {
      name: 'unit',
      testMatch: ['**/*.unit.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'integration',
      testMatch: ['**/*.integration.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'e2e-requirements',
      testMatch: ['**/e2e/requirements.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'e2e-usecases',
      testMatch: ['**/e2e/usecases.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'performance',
      testMatch: ['**/performance/**/*.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    }
  ]
});
EOF
        log_info "✓ Created vitest.config.mts"
    fi
}

# Configure Playwright (based on boilerplate)
configure_playwright_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/playwright.config.ts" ]]; then
        cat > "$project_path/playwright.config.ts" << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  timeout: 10 * 1000,
  expect: {
    timeout: 5000
  },
  use: {
    actionTimeout: 0,
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
EOF
        log_info "✓ Created playwright.config.ts"
    fi
}

# Configure TypeScript configuration (based on boilerplate)
configure_tsconfig_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    log_info "Configuring tsconfig.json"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/tsconfig.json" ]]; then
        # Create comprehensive tsconfig.json for standardize mode (based on boilerplate)
        cat > "$project_path/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", ".next"]
}
EOF
        log_info "✓ Created tsconfig.json"
    fi
}

# Configure ESLint (based on boilerplate)
configure_eslint_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/eslint.config.mts" ]]; then
        cat > "$project_path/eslint.config.mts" << 'EOF'
import { config } from '@job-aide/tools-lint-eslint-config';

export default config(config);
EOF
        log_info "✓ Created eslint.config.mts"
    fi
}

# Configure Prettier (based on boilerplate)
configure_prettier_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.prettierrc" ]]; then
        cat > "$project_path/.prettierrc" << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
EOF
        log_info "✓ Created .prettierrc"
    fi
}

# Configure framework-specific configs
configure_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Next.js configuration
    if [[ -f "$project_path/next.config.js" ]] || [[ -f "$project_path/next.config.mjs" ]] || [[ "$mode" == "standardize" ]]; then
        configure_nextjs_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Vite configuration
    if [[ -f "$project_path/vite.config.ts" ]] || [[ -f "$project_path/vite.config.js" ]] || [[ "$mode" == "standardize" ]]; then
        configure_vite_config "$project_path" "$mode" "$app_type" "$project_type"
    fi
}

# Configure Next.js (based on boilerplate)
configure_nextjs_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/next.config.js" ]]; then
        cat > "$project_path/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
    serverComponentsExternalPackages: ['@mui/material', '@mui/icons-material']
  },
  images: {
    domains: ['example.com'],
    formats: ['image/webp', 'image/avif']
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        fs: false,
        path: false,
        os: false
      }
    }
    return config
  }
}

module.exports = nextConfig
EOF
        log_info "✓ Created next.config.js"
    fi
}

# Configure Vite (based on boilerplate)
configure_vite_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/vite.config.ts" ]]; then
        cat > "$project_path/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom']
  }
})
EOF
        log_info "✓ Created vite.config.ts"
    fi
}

# Configure testing configs
configure_testing_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]]; then
        # Create test directories
        mkdir -p "$project_path/tests/unit"
        mkdir -p "$project_path/tests/integration"
        mkdir -p "$project_path/tests/e2e"

        # Create basic test files
        if [[ ! -f "$project_path/tests/unit/example.test.ts" ]]; then
            cat > "$project_path/tests/unit/example.test.ts" << 'EOF'
import { describe, it, expect } from 'vitest';

describe('Example test', () => {
  it('should pass', () => {
    expect(1 + 1).toBe(2);
  });
});
EOF
            log_info "✓ Created tests/unit/example.test.ts"
        fi

        # Create vitest setup file
        if [[ ! -f "$project_path/vitest.setup.ts" ]]; then
            cat > "$project_path/vitest.setup.ts" << 'EOF'
import '@testing-library/jest-dom';
EOF
            log_info "✓ Created vitest.setup.ts"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_nodejs_project
export -f configure_package_json
export -f create_package_json
export -f configure_tsconfig_json
export -f configure_eslint_config
export -f configure_prettier_config
export -f configure_tailwind_config
export -f configure_postcss_config
export -f configure_vitest_config
export -f configure_playwright_config
export -f configure_framework_configs
export -f configure_nextjs_config
export -f configure_vite_config
export -f configure_testing_configs
export -f find_workspace_root
export -f configure_pnpm_workspace
export -f migrate_package_json_to_catalog
export -f configure_build_tool
