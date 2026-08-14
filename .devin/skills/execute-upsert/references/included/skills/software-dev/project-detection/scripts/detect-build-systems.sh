#!/bin/bash
# Detect build systems and package managers in the repository
# Returns a list of detected systems for other scripts to use

set -euo pipefail

# Build system detection patterns
declare -A BUILD_SYSTEMS=(
    ["npm"]="package.json"
    ["pnpm"]="pnpm-lock.yaml"
    ["yarn"]="yarn.lock"
    ["bun"]="bun.lockb"
    ["deno"]="deno.json"
    ["cargo"]="Cargo.toml"
    ["rust"]="Cargo.toml"
    ["python"]="pyproject.toml"
    ["poetry"]="poetry.lock"
    ["pip"]="requirements.txt"
    ["conda"]="environment.yml"
    ["go"]="go.mod"
    ["golang"]="go.mod"
    ["java"]="pom.xml"
    ["maven"]="pom.xml"
    ["gradle"]="build.gradle"
    ["scala"]="build.sbt"
    ["ruby"]="Gemfile"
    ["bundler"]="Gemfile.lock"
    ["php"]="composer.json"
    ["composer"]="composer.lock"
    ["dotnet"]="*.csproj"
    ["nuget"]="packages.config"
    ["elixir"]="mix.exs"
    ["haskell"]="stack.yaml"
    ["cabal"]="*.cabal"
    ["clojure"]="deps.edn"
    ["lein"]="project.clj"
    ["r"]="DESCRIPTION"
    ["cpp"]="CMakeLists.txt"
    ["cmake"]="CMakeLists.txt"
    ["make"]="Makefile"
    ["just"]="Justfile"
    ["hermit"]="bin/hermit.hcl"
    ["bazel"]="WORKSPACE"
    ["pants"]="pants.toml"
    ["buck"]="BUCK"
    ["please"]="BUILD.plz"
    ["swift"]="Package.swift"
    ["xcode"]="*.xcodeproj"
    ["docker"]="Dockerfile"
    ["docker-compose"]="docker-compose.yml"
    ["kubernetes"]="k8s/"
    ["helm"]="Chart.yaml"
    ["terraform"]="*.tf"
    ["pulumi"]="Pulumi.yaml"
    ["ansible"]="playbook.yml"
    ["chef"]="Berksfile"
    ["puppet"]="Puppetfile"
    ["salt"]="requirements.txt"
    ["vagrant"]="Vagrantfile"
    ["packer"]="*.pkr.hcl"
    ["terragrunt"]="terragrunt.hcl"
    ["atlas"]="atlas.hcl"
    ["cdk"]="cdk.json"
    ["serverless"]="serverless.yml"
    ["sst"]="sst.config.ts"
    ["nextjs"]="next.config.js"
    ["gatsby"]="gatsby-config.js"
    ["remix"]="remix.config.js"
    ["svelte"]="svelte.config.js"
    ["vue"]="vue.config.js"
    ["angular"]="angular.json"
    ["nuxt"]="nuxt.config.js"
    ["astro"]="astro.config.mjs"
    ["solid"]="solid.config.js"
    ["qwik"]="qwik.config.ts"
    ["preact"]="preact.config.js"
    ["lit"]="tsconfig.json"
    ["stencil"]="stencil.config.ts"
    ["storybook"]=".storybook/"
    ["tailwind"]="tailwind.config.js"
    ["postcss"]="postcss.config.js"
    ["vite"]="vite.config.ts"
    ["webpack"]="webpack.config.js"
    ["rollup"]="rollup.config.js"
    ["esbuild"]="esbuild.config.js"
    ["swc"]=".swcrc"
    ["babel"]="babel.config.js"
    ["jest"]="jest.config.js"
    ["vitest"]="vitest.config.ts"
    ["cypress"]="cypress.config.ts"
    ["playwright"]="playwright.config.ts"
    ["testing-library"]="jest.config.js"
    ["eslint"]=".eslintrc.js"
    ["prettier"]=".prettierrc"
    ["typescript"]="tsconfig.json"
    ["rust-analyzer"]="rust-analyzer.toml"
    ["clippy"]="clippy.toml"
    ["rustfmt"]="rustfmt.toml"
    ["pylint"]="pylintrc"
    ["black"]="pyproject.toml"
    ["ruff"]="ruff.toml"
    ["mypy"]="mypy.ini"
    ["pytest"]="pytest.ini"
    ["tox"]="tox.ini"
    ["coverage"]=".coveragerc"
    ["sonarqube"]="sonar-project.properties"
    ["codecov"]="codecov.yml"
    ["coveralls"]=".coveralls.yml"
    ["snyk"]=".snyk"
    ["dependabot"]=".github/dependabot.yml"
    ["renovate"]="renovate.json"
    ["leak-detection"]="leaks.yml"
    ["security"]="security.md"
    ["license"]="LICENSE"
    ["contributing"]="CONTRIBUTING.md"
    ["changelog"]="CHANGELOG.md"
    ["readme"]="README.md"
    ["docs"]="docs/"
    ["wiki"]="wiki/"
    ["github-pages"]="docs/"
    ["netlify"]="netlify.toml"
    ["vercel"]="vercel.json"
    ["railway"]="railway.toml"
    ["heroku"]="Procfile"
    ["digitalocean"]="app.yaml"
    ["aws"]="aws.yml"
    ["azure"]="azure-pipelines.yml"
    ["gcp"]="cloudbuild.yaml"
    ["firebase"]="firebase.json"
    ["supabase"]="supabase/"
    ["planetscale"]="planetscale"
    ["neon"]="neon"
    ["render"]="render.yaml"
    ["fly"]="fly.toml"
    ["docker-hub"]="Dockerfile"
    ["github-container"]="Dockerfile"
    ["gitlab-container"]="Dockerfile"
    ["aws-ecr"]="Dockerfile"
    ["google-artifact"]="Dockerfile"
    ["azure-container"]="Dockerfile"
)

# Application type detection patterns (ordered by specificity)
declare -A APP_TYPES=(
    ["web"]="next.config.js|gatsby-config.js|remix.config.js|svelte.config.js|vue.config.js|angular.json|nuxt.config.js|astro.config.mjs|solid.config.js|qwik.config.ts|preact.config.js|vite.config.ts|webpack.config.js|rollup.config.js|index.html|public/|src/components/|src/pages/|src/App.tsx|src/App.jsx"
    ["cli"]="bin/|src/cli/|src/cmd/|commander|yargs|clap|structopt|argparse|click|typer|cobra|urfave-cli"
    ["api"]="src/api/|src/server/|src/routes/|app.py|main.go|server.js|app.js|fastapi|flask|express|koa|hapi|nest|spring|django|rails|grpc|graphql"
    ["desktop"]="electron|tauri|wails|gtk|qt|flutter-desktop|react-native|nativefier|electron-builder"
    ["mobile"]="react-native|flutter|ionic|cordova|capacitor|expo|mobile|ios|android"
    ["game"]="unity|unreal|godot|phaser|three|babylonjs|pygame|love2d|game|engine"
    ["ml"]="tensorflow|pytorch|scikit-learn|jupyter|notebook|pandas|numpy|ml|machine-learning|data-science"
    ["devops"]="Dockerfile|docker-compose.yml|k8s/|terraform|*.tf|ansible|pulumi|cdk|serverless|sst|helm|Chart.yaml|iac|infrastructure"
    ["docs"]="docs/|mkdocs.yml|docusaurus.config.js|vuepress.config.js|gitbook|sphinx|readthedocs|wiki"
    ["library"]="src/lib/|lib/|pyproject.toml|setup.py|pom.xml|build.gradle|Cargo.toml|go.mod"
)

# Project type patterns (more specific categorization)
declare -A PROJECT_TYPES=(
    ["frontend-web"]="nextjs|gatsby|remix|svelte|vue|angular|nuxt|astro|solid|qwik|preact|react|vite|webpack|rollup|esbuild|parcel|tailwind|postcss"
    ["fullstack-web"]="nextjs|nuxt|gatsby|remix|sveltekit|angular|express|fastapi|django|rails|spring|nest|api|server|routes"
    ["cli-tool"]="cli|bin|cmd|commander|yargs|clap|structopt|argparse|click|typer"
    ["library"]="lib|package|crate|module|component|utility|helper|sdk"
    ["api-service"]="api|server|routes|fastapi|flask|express|django|rails|spring|nest|grpc|graphql"
    ["desktop-app"]="electron|tauri|wails|gtk|qt|flutter-desktop|desktop"
    ["mobile-app"]="react-native|flutter|ionic|cordova|capacitor|expo|mobile"
    ["game-engine"]="unity|unreal|godot|phaser|three|babylonjs|pygame|love2d|game"
    ["ml-pipeline"]="tensorflow|pytorch|scikit-learn|jupyter|notebook|pandas|numpy|ml|machine-learning"
    ["infrastructure"]="docker|kubernetes|terraform|ansible|pulumi|cdk|devops|iac"
    ["documentation"]="docs|wiki|readthedocs|docusaurus|vuepress|mkdocs|gitbook"
)

detect_systems() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"

    cd "$repo_path"

    local detected=()

    for system in "${!BUILD_SYSTEMS[@]}"; do
        local pattern="${BUILD_SYSTEMS[$system]}"

        if [[ "$pattern" == *"*"* ]]; then
            # Handle glob patterns
            if ls $pattern 2>/dev/null | grep -q .; then
                detected+=("$system")
                if [[ "$verbose" == "true" ]]; then
                    echo "✓ $system (via $pattern)"
                fi
            fi
        else
            # Handle exact file/directory matches
            if [[ -f "$pattern" ]] || [[ -d "$pattern" ]]; then
                detected+=("$system")
                if [[ "$verbose" == "true" ]]; then
                    echo "✓ $system (via $pattern)"
                fi
            fi
        fi
    done

    # Package manager — refine the lockfile-based detection above by consulting
    # the shared detect-package-manager.sh (materialized into this skill's
    # scripts/ dir at build time). It honors the `packageManager` field in
    # package.json, which is more authoritative than lockfile presence alone
    # (e.g. a pnpm repo may not yet have committed pnpm-lock.yaml).
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local pkg_manager_script="$script_dir/detect-package-manager.sh"
    if [[ -f "package.json" ]] && [[ -x "$pkg_manager_script" ]]; then
        local pm_resolved
        pm_resolved="$("$pkg_manager_script" "$repo_path" 2>/dev/null || true)"
        if [[ -n "$pm_resolved" ]]; then
            # Remove any conflicting package managers already detected via
            # lockfile (npm/pnpm/yarn/bun/deno) so the final list reflects
            # the authoritative answer.
            local conflicting="npm pnpm yarn bun deno"
            local c
            local filtered=()
            for s in "${detected[@]}"; do
                local keep=1
                for c in $conflicting; do
                    if [[ "$s" == "$c" && "$c" != "$pm_resolved" ]]; then
                        keep=0
                        break
                    fi
                done
                [[ "$keep" -eq 1 ]] && filtered+=("$s")
            done
            detected=("${filtered[@]}")
            # Ensure the resolved manager is present
            local already=0
            for s in "${detected[@]}"; do
                [[ "$s" == "$pm_resolved" ]] && already=1 && break
            done
            if [[ "$already" -eq 0 ]]; then
                detected+=("$pm_resolved")
                if [[ "$verbose" == "true" ]]; then
                    echo "✓ $pm_resolved (via detect-package-manager.sh)"
                fi
            fi
        fi
    fi

    # Environment wrappers (devbox, mise, flox, direnv, nix) — detected by
    # cli-tool-discovery.sh, the single source of truth. It walks up from cwd
    # and checks "already inside" env vars. No duplicate file checks here.
    # Hermit is NOT listed here because it doesn't use a wrapper command —
    # its tools auto-bootstrap from bin/ and are detected via BUILD_SYSTEMS
    # (bin/hermit.hcl marker) and cli-tool-discovery.sh's repo-root bin/ fallback.
    local cli_discovery="$script_dir/cli-tool-discovery.sh"
    if [[ -f "$cli_discovery" ]]; then
        local result
        result="$(bash "$cli_discovery" __wrapper_probe__ 2>/dev/null || true)"
        case "$result" in
            WRAPPER:\ *)
                local wrapper_full="${result#WRAPPER: }"
                local prefix="${wrapper_full% __wrapper_probe__}"
                case "$prefix" in
                    "devbox run --")        detected+=("devbox") ;;
                    "mise exec --")         detected+=("mise") ;;
                    "flox activate --")     detected+=("flox") ;;
                    "direnv export &&")     detected+=("direnv") ;;
                    "nix develop --command") detected+=("nix") ;;
                    "nix-shell --run")      detected+=("nixpkgs") ;;
                esac
                if [[ "$verbose" == "true" ]]; then
                    echo "✓ ${detected[-1]} (via cli-tool-discovery.sh)"
                fi
                ;;
        esac
    fi

    # Output detected systems as space-separated list
    echo "${detected[*]}"
}

detect_app_type() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"

    cd "$repo_path"

    local detected_app_type=""
    local max_matches=0

    for app_type in "${!APP_TYPES[@]}"; do
        local patterns="${APP_TYPES[$app_type]}"
        local match_count=0

        # Split patterns by | and check each
        IFS='|' read -ra pattern_array <<< "$patterns"
        for pattern in "${pattern_array[@]}"; do
            if [[ "$pattern" == *"*"* ]]; then
                # Handle glob patterns
                if ls $pattern 2>/dev/null | grep -q .; then
                    ((match_count++))
                fi
            else
                # Handle exact file/directory matches
                if [[ -f "$pattern" ]] || [[ -d "$pattern" ]]; then
                    ((match_count++))
                fi
            fi
        done

        if [[ $match_count -gt $max_matches ]]; then
            max_matches=$match_count
            detected_app_type="$app_type"
        fi

        if [[ "$verbose" == "true" ]] && [[ $match_count -gt 0 ]]; then
            echo "✓ $app_type type: $match_count matches"
        fi
    done

    echo "$detected_app_type"
}

detect_project_type() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"

    cd "$repo_path"

    local detected_project_type=""
    local max_matches=0

    for project_type in "${!PROJECT_TYPES[@]}"; do
        local patterns="${PROJECT_TYPES[$project_type]}"
        local match_count=0

        # Split patterns by | and check each
        IFS='|' read -ra pattern_array <<< "$patterns"
        for pattern in "${pattern_array[@]}"; do
            if [[ "$pattern" == *"*"* ]]; then
                # Handle glob patterns
                if ls $pattern 2>/dev/null | grep -q .; then
                    ((match_count++))
                fi
            else
                # Handle exact file/directory matches
                if [[ -f "$pattern" ]] || [[ -d "$pattern" ]]; then
                    ((match_count++))
                fi
            fi
        done

        if [[ $match_count -gt $max_matches ]]; then
            max_matches=$match_count
            detected_project_type="$project_type"
        fi

        if [[ "$verbose" == "true" ]] && [[ $match_count -gt 0 ]]; then
            echo "✓ $project_type: $match_count matches"
        fi
    done

    echo "$detected_project_type"
}

detect_project_characteristics() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"

    cd "$repo_path"

    local build_systems
    build_systems=$(detect_systems "$repo_path" "$verbose")

    local app_type
    app_type=$(detect_app_type "$repo_path" "$verbose")

    local project_type
    project_type=$(detect_project_type "$repo_path" "$verbose")

    if [[ "$verbose" == "true" ]]; then
        echo "Build Systems: $build_systems"
        echo "Application Type: $app_type"
        echo "Project Type: $project_type"
    fi

    # Return all characteristics as a structured string
    echo "build_systems:$build_systems|app_type:$app_type|project_type:$project_type"
}

main() {
    local repo_path="."
    local verbose=false
    local detection_type="systems"  # Default to build systems detection

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -p|--path)
                repo_path="$2"
                shift 2
                ;;
            -t|--type)
                detection_type="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS] [REPO_PATH]"
                echo "Detect build systems, application types, and project characteristics"
                echo
                echo "Options:"
                echo "  -v, --verbose       Show detailed detection output"
                echo "  -p, --path          Repository path (default: .)"
                echo "  -t, --type TYPE     Detection type: systems, app, project, characteristics"
                echo "  -h, --help          Show this help message"
                echo
                echo "Detection Types:"
                echo "  systems          - Build systems and package managers (default)"
                echo "  app              - Application type (web, cli, library, etc.)"
                echo "  project          - Project type (frontend-web, api-service, etc.)"
                echo "  characteristics  - All characteristics combined"
                exit 0
                ;;
            *)
                if [[ "$repo_path" == "." ]]; then
                    repo_path="$1"
                else
                    echo "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ ! -d "$repo_path" ]]; then
        echo "Repository path does not exist: $repo_path"
        exit 1
    fi

    case $detection_type in
        "systems")
            detect_systems "$repo_path" "$verbose"
            ;;
        "app")
            detect_app_type "$repo_path" "$verbose"
            ;;
        "project")
            detect_project_type "$repo_path" "$verbose"
            ;;
        "characteristics")
            detect_project_characteristics "$repo_path" "$verbose"
            ;;
        *)
            echo "Invalid detection type: $detection_type"
            echo "Use -h to see available options"
            exit 1
            ;;
    esac
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
