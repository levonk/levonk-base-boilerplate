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
    ["bazel"]="WORKSPACE"
    ["pants"]="pants.toml"
    ["buck"]="BUCK"
    ["please"]="BUILD.plz"
    ["nix"]="flake.nix"
    ["nixpkgs"]="shell.nix"
    ["docker"]="Dockerfile"
    ["docker-compose"]="docker-compose.yml"
    ["kubernetes"]="k8s"
    ["helm"]="Chart.yaml"
    ["terraform"]="*.tf"
    ["pulumi"]="Pulumi.yaml"
    ["ansible"]="playbook.yml"
    ["chef"]="Berksfile"
    ["puppet"]="Puppetfile"
    ["salt"]="requirements.txt"
    ["vagrant"]="Vagrantfile"
    ["packer"]="*.pkr.hcl"
    ["terraform"]="*.tf"
    ["terragrunt"]="terragrunt.hcl"
    ["atlas"]="atlas.hcl"
    ["cdk"]="cdk.json"
    ["pulumi"]="Pulumi.yaml"
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
    ["storybook"]=".storybook"
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
    ["supabase"]="supabase"
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
    ["npm"]="package.json"
    ["yarn"]="yarn.lock"
    ["pnpm"]="pnpm-lock.yaml"
    ["bun"]="bun.lockb"
    ["deno"]="deno.json"
    ["cargo"]="Cargo.toml"
    ["python"]="pyproject.toml"
    ["go"]="go.mod"
    ["java"]="pom.xml"
    ["gradle"]="build.gradle"
    ["ruby"]="Gemfile"
    ["php"]="composer.json"
    ["dotnet"]="*.csproj"
    ["elixir"]="mix.exs"
    ["haskell"]="stack.yaml"
    ["clojure"]="deps.edn"
    ["cpp"]="CMakeLists.txt"
    ["make"]="Makefile"
    ["bazel"]="WORKSPACE"
    ["pants"]="pants.toml"
    ["nix"]="flake.nix"
    ["docker"]="Dockerfile"
    ["terraform"]="*.tf"
    ["kubernetes"]="k8s/"
    ["helm"]="Chart.yaml"
    ["ansible"]="playbook.yml"
    ["vagrant"]="Vagrantfile"
    ["packer"]="*.pkr.hcl"
    ["cdk"]="cdk.json"
    ["pulumi"]="Pulumi.yaml"
    ["serverless"]="serverless.yml"
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
    
    # Output detected systems as space-separated list
    echo "${detected[*]}"
}

main() {
    local repo_path="."
    local verbose=false
    
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
            -h|--help)
                echo "Usage: $0 [OPTIONS] [REPO_PATH]"
                echo "Detect build systems and package managers"
                echo
                echo "Options:"
                echo "  -v, --verbose    Show detailed detection output"
                echo "  -p, --path       Repository path (default: .)"
                echo "  -h, --help       Show this help message"
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
    
    detect_systems "$repo_path" "$verbose"
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
