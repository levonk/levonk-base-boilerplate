#!/bin/bash
# Detect CI/CD systems and deployment platforms
# Returns a list of detected CI/CD systems for other scripts to use

set -euo pipefail

# CI/CD system detection patterns
declare -A CI_CD_SYSTEMS=(
    ["github-actions"]=".github/workflows"
    ["gitlab-ci"]=".gitlab-ci.yml"
    ["gitlab-ci-include"]=".gitlab-ci/"
    ["travis-ci"]=".travis.yml"
    ["travis-ci-matrix"]=".travis"
    ["circleci"]=".circleci"
    ["circleci-config"]=".circleci/config.yml"
    ["jenkins"]="Jenkinsfile"
    ["jenkins-multibranch"]="Jenkinsfile"
    ["jenkins-declarative"]="Jenkinsfile"
    ["azure-pipelines"]="azure-pipelines.yml"
    ["azure-pipelines-include"]=".azure/"
    ["aws-codebuild"]="buildspec.yml"
    ["aws-codepipeline"]=".aws/"
    ["google-cloud-build"]="cloudbuild.yaml"
    ["google-cloud-run"]="cloudbuild.yaml"
    ["google-cloud-functions"]="cloudbuild.yaml"
    ["bitbucket-pipelines"]="bitbucket-pipelines.yml"
    ["bitbucket-pipelines-include"]=".bitbucket/"
    ["buildkite"]=".buildkite/"
    ["buildkite-pipeline"]=".buildkite/pipeline.yml"
    ["buildkite-agent"]=".buildkite/"
    ["drone-ci"]=".drone.yml"
    ["drone-ci-starlark"]=".drone.star"
    ["semaphore"]=".semaphore"
    ["semaphore-config"]=".semaphore/semaphore.yml"
    ["appveyor"]="appveyor.yml"
    ["appveyor-config"]="appveyor.yml"
    ["codeship"]="codeship-services.yml"
    ["codeship-steps"]="codeship-steps.yml"
    ["wercker"]="wercker.yml"
    ["wercker-steps"]="wercker.yml"
    ["shippable"]="shippable.yml"
    ["shippable-config"]="shippable.yml"
    ["screwdriver"]="screwdriver.yaml"
    ["screwdriver-config"]="screwdriver.yaml"
    ["tox-ci"]="tox.ini"
    ["tox-ci-config"]="tox.ini"
    ["bazel-ci"]=".bazelci/"
    ["bazel-ci-config"]=".bazelci/presubmit.yml"
    ["pants-ci"]="pants.toml"
    ["pants-ci-config"]="pants.toml"
    ["github-actions-workflow"]=".github/workflows/*.yml"
    ["github-actions-action"]=".github/actions/"
    ["github-actions-reusable"]=".github/workflows/reusable/"
    ["github-actions-matrix"]=".github/workflows/*matrix*.yml"
    ["github-actions-deploy"]=".github/workflows/*deploy*.yml"
    ["github-actions-ci"]=".github/workflows/*ci*.yml"
    ["github-actions-test"]=".github/workflows/*test*.yml"
    ["github-actions-build"]=".github/workflows/*build*.yml"
    ["github-actions-release"]=".github/workflows/*release*.yml"
    ["github-actions-security"]=".github/workflows/*security*.yml"
    ["github-actions-dependency"]=".github/workflows/*dependency*.yml"
    ["github-actions-codecov"]=".github/workflows/*codecov*.yml"
    ["github-actions-sonar"]=".github/workflows/*sonar*.yml"
    ["github-actions-docker"]=".github/workflows/*docker*.yml"
    ["github-actions-k8s"]=".github/workflows/*k8s*.yml"
    ["github-actions-helm"]=".github/workflows/*helm*.yml"
    ["github-actions-terraform"]=".github/workflows/*terraform*.yml"
    ["github-actions-serverless"]=".github/workflows/*serverless*.yml"
    ["github-actions-nextjs"]=".github/workflows/*nextjs*.yml"
    ["github-actions-react"]=".github/workflows/*react*.yml"
    ["github-actions-node"]=".github/workflows/*node*.yml"
    ["github-actions-python"]=".github/workflows/*python*.yml"
    ["github-actions-rust"]=".github/workflows/*rust*.yml"
    ["github-actions-go"]=".github/workflows/*go*.yml"
    ["github-actions-java"]=".github/workflows/*java*.yml"
    ["github-actions-dotnet"]=".github/workflows/*dotnet*.yml"
    ["github-actions-ruby"]=".github/workflows/*ruby*.yml"
    ["github-actions-php"]=".github/workflows/*php*.yml"
    ["github-actions-elixir"]=".github/workflows/*elixir*.yml"
    ["github-actions-scala"]=".github/workflows/*scala*.yml"
    ["github-actions-clojure"]=".github/workflows/*clojure*.yml"
    ["github-actions-haskell"]=".github/workflows/*haskell*.yml"
    ["github-actions-r"]=".github/workflows/*r*.yml"
    ["github-actions-cpp"]=".github/workflows/*cpp*.yml"
    ["github-actions-c"]=".github/workflows/*c*.yml"
    ["github-actions-bash"]=".github/workflows/*bash*.yml"
    ["github-actions-powershell"]=".github/workflows/*powershell*.yml"
    ["github-actions-docker"]=".github/workflows/*docker*.yml"
    ["github-actions-kubernetes"]=".github/workflows/*kubernetes*.yml"
    ["github-actions-helm"]=".github/workflows/*helm*.yml"
    ["github-actions-terraform"]=".github/workflows/*terraform*.yml"
    ["github-actions-pulumi"]=".github/workflows/*pulumi*.yml"
    ["github-actions-serverless"]=".github/workflows/*serverless*.yml"
    ["github-actions-sst"]=".github/workflows/*sst*.yml"
    ["github-actions-nextjs"]=".github/workflows/*nextjs*.yml"
    ["github-actions-remix"]=".github/workflows/*remix*.yml"
    ["github-actions-svelte"]=".github/workflows/*svelte*.yml"
    ["github-actions-vue"]=".github/workflows/*vue*.yml"
    ["github-actions-angular"]=".github/workflows/*angular*.yml"
    ["github-actions-nuxt"]=".github/workflows/*nuxt*.yml"
    ["github-actions-astro"]=".github/workflows/*astro*.yml"
    ["github-actions-solid"]=".github/workflows/*solid*.yml"
    ["github-actions-qwik"]=".github/workflows/*qwik*.yml"
    ["github-actions-preact"]=".github/workflows/*preact*.yml"
    ["github-actions-lit"]=".github/workflows/*lit*.yml"
    ["github-actions-stencil"]=".github/workflows/*stencil*.yml"
    ["github-actions-storybook"]=".github/workflows/*storybook*.yml"
    ["github-actions-tailwind"]=".github/workflows/*tailwind*.yml"
    ["github-actions-postcss"]=".github/workflows/*postcss*.yml"
    ["github-actions-vite"]=".github/workflows/*vite*.yml"
    ["github-actions-webpack"]=".github/workflows/*webpack*.yml"
    ["github-actions-rollup"]=".github/workflows/*rollup*.yml"
    ["github-actions-esbuild"]=".github/workflows/*esbuild*.yml"
    ["github-actions-swc"]=".github/workflows/*swc*.yml"
    ["github-actions-babel"]=".github/workflows/*babel*.yml"
    ["github-actions-jest"]=".github/workflows/*jest*.yml"
    ["github-actions-vitest"]=".github/workflows/*vitest*.yml"
    ["github-actions-cypress"]=".github/workflows/*cypress*.yml"
    ["github-actions-playwright"]=".github/workflows/*playwright*.yml"
    ["github-actions-testing-library"]=".github/workflows/*testing-library*.yml"
    ["github-actions-eslint"]=".github/workflows/*eslint*.yml"
    ["github-actions-prettier"]=".github/workflows/*prettier*.yml"
    ["github-actions-typescript"]=".github/workflows/*typescript*.yml"
    ["github-actions-rust-analyzer"]=".github/workflows/*rust-analyzer*.yml"
    ["github-actions-clippy"]=".github/workflows/*clippy*.yml"
    ["github-actions-rustfmt"]=".github/workflows/*rustfmt*.yml"
    ["github-actions-pylint"]=".github/workflows/*pylint*.yml"
    ["github-actions-black"]=".github/workflows/*black*.yml"
    ["github-actions-ruff"]=".github/workflows/*ruff*.yml"
    ["github-actions-mypy"]=".github/workflows/*mypy*.yml"
    ["github-actions-pytest"]=".github/workflows/*pytest*.yml"
    ["github-actions-tox"]=".github/workflows/*tox*.yml"
    ["github-actions-coverage"]=".github/workflows/*coverage*.yml"
    ["github-actions-sonarqube"]=".github/workflows/*sonarqube*.yml"
    ["github-actions-codecov"]=".github/workflows/*codecov*.yml"
    ["github-actions-coveralls"]=".github/workflows/*coveralls*.yml"
    ["github-actions-snyk"]=".github/workflows/*snyk*.yml"
    ["github-actions-dependabot"]=".github/workflows/*dependabot*.yml"
    ["github-actions-renovate"]=".github/workflows/*renovate*.yml"
    ["github-actions-leak-detection"]=".github/workflows/*leak-detection*.yml"
    ["github-actions-security"]=".github/workflows/*security*.yml"
    ["github-actions-license"]=".github/workflows/*license*.yml"
    ["github-actions-contributing"]=".github/workflows/*contributing*.yml"
    ["github-actions-changelog"]=".github/workflows/*changelog*.yml"
    ["github-actions-readme"]=".github/workflows/*readme*.yml"
    ["github-actions-docs"]=".github/workflows/*docs*.yml"
    ["github-actions-wiki"]=".github/workflows/*wiki*.yml"
    ["github-actions-github-pages"]=".github/workflows/*github-pages*.yml"
    ["github-actions-netlify"]=".github/workflows/*netlify*.yml"
    ["github-actions-vercel"]=".github/workflows/*vercel*.yml"
    ["github-actions-railway"]=".github/workflows/*railway*.yml"
    ["github-actions-heroku"]=".github/workflows/*heroku*.yml"
    ["github-actions-digitalocean"]=".github/workflows/*digitalocean*.yml"
    ["github-actions-aws"]=".github/workflows/*aws*.yml"
    ["github-actions-azure"]=".github/workflows/*azure*.yml"
    ["github-actions-gcp"]=".github/workflows/*gcp*.yml"
    ["github-actions-firebase"]=".github/workflows/*firebase*.yml"
    ["github-actions-supabase"]=".github/workflows/*supabase*.yml"
    ["github-actions-planetscale"]=".github/workflows/*planetscale*.yml"
    ["github-actions-neon"]=".github/workflows/*neon*.yml"
    ["github-actions-render"]=".github/workflows/*render*.yml"
    ["github-actions-fly"]=".github/workflows/*fly*.yml"
    ["github-actions-docker-hub"]=".github/workflows/*docker-hub*.yml"
    ["github-actions-github-container"]=".github/workflows/*github-container*.yml"
    ["github-actions-gitlab-container"]=".github/workflows/*gitlab-container*.yml"
    ["github-actions-aws-ecr"]=".github/workflows/*aws-ecr*.yml"
    ["github-actions-google-artifact"]=".github/workflows/*google-artifact*.yml"
    ["github-actions-azure-container"]=".github/workflows/*azure-container*.yml"
    ["github-actions-npm"]=".github/workflows/*npm*.yml"
    ["github-actions-yarn"]=".github/workflows/*yarn*.yml"
    ["github-actions-pnpm"]=".github/workflows/*pnpm*.yml"
    ["github-actions-bun"]=".github/workactions/*bun*.yml"
    ["github-actions-deno"]=".github/workflows/*deno*.yml"
    ["github-actions-cargo"]=".github/workflows/*cargo*.yml"
    ["github-actions-python"]=".github/workflows/*python*.yml"
    ["github-actions-go"]=".github/workflows/*go*.yml"
    ["github-actions-java"]=".github/workflows/*java*.yml"
    ["github-actions-gradle"]=".github/workflows/*gradle*.yml"
    ["github-actions-maven"]=".github/workflows/*maven*.yml"
    ["github-actions-scala"]=".github/workflows/*scala*.yml"
    ["github-actions-sbt"]=".github/workflows/*sbt*.yml"
    ["github-actions-ruby"]=".github/workflows/*ruby*.yml"
    ["github-actions-bundler"]=".github/workflows/*bundler*.yml"
    ["github-actions-php"]=".github/workflows/*php*.yml"
    ["github-actions-composer"]=".github/workflows/*composer*.yml"
    ["github-actions-dotnet"]=".github/workflows/*dotnet*.yml"
    ["github-actions-nuget"]=".github/workflows/*nuget*.yml"
    ["github-actions-elixir"]=".github/workflows/*elixir*.yml"
    ["github-actions-mix"]=".github/workflows/*mix*.yml"
    ["github-actions-haskell"]=".github/workflows/*haskell*.yml"
    ["github-actions-stack"]=".github/workflows/*stack*.yml"
    ["github-actions-cabal"]=".github/workflows/*cabal*.yml"
    ["github-actions-clojure"]=".github/workflows/*clojure*.yml"
    ["github-actions-leiningen"]=".github/workflows/*leiningen*.yml"
    ["github-actions-r"]=".github/workflows/*r*.yml"
    ["github-actions-cpp"]=".github/workflows/*cpp*.yml"
    ["github-actions-cmake"]=".github/workflows/*cmake*.yml"
    ["github-actions-c"]=".github/workflows/*c*.yml"
    ["github-actions-bash"]=".github/workflows/*bash*.yml"
    ["github-actions-powershell"]=".github/workflows/*powershell*.yml"
    ["github-actions-docker"]=".github/workflows/*docker*.yml"
    ["github-actions-kubernetes"]=".github/workflows/*kubernetes*.yml"
    ["github-actions-helm"]=".github/workflows/*helm*.yml"
    ["github-actions-terraform"]=".github/workflows/*terraform*.yml"
    ["github-actions-pulumi"]=".github/workflows/*pulumi*.yml"
    ["github-actions-serverless"]=".github/workflows/*serverless*.yml"
    ["github-actions-sst"]=".github/workflows/*sst*.yml"
    ["github-actions-nextjs"]=".github/workflows/*nextjs*.yml"
    ["github-actions-remix"]=".github/workflows/*remix*.yml"
    ["github-actions-svelte"]=".github/workflows/*svelte*.yml"
    ["github-actions-vue"]=".github/workflows/*vue*.yml"
    ["github-actions-angular"]=".github/workflows/*angular*.yml"
    ["github-actions-nuxt"]=".github/workflows/*nuxt*.yml"
    ["github-actions-astro"]=".github/workflows/*astro*.yml"
    ["github-actions-solid"]=".github/workflows/*solid*.yml"
    ["github-actions-qwik"]=".github/workflows/*qwik*.yml"
    ["github-actions-preact"]=".github/workflows/*preact*.yml"
    ["github-actions-lit"]=".github/workflows/*lit*.yml"
    ["github-actions-stencil"]=".github/workflows/*stencil*.yml"
    ["github-actions-storybook"]=".github/workflows/*storybook*.yml"
    ["github-actions-tailwind"]=".github/workflows/*tailwind*.yml"
    ["github-actions-postcss"]=".github/workflows/*postcss*.yml"
    ["github-actions-vite"]=".github/workflows/*vite*.yml"
    ["github-actions-webpack"]=".github/workflows/*webpack*.yml"
    ["github-actions-rollup"]=".github/workflows/*rollup*.yml"
    ["github-actions-esbuild"]=".github/workflows/*esbuild*.yml"
    ["github-actions-swc"]=".github/workflows/*swc*.yml"
    ["github-actions-babel"]=".github/workflows/*babel*.yml"
    ["github-actions-jest"]=".github/workflows/*jest*.yml"
    ["github-actions-vitest"]=".github/workflows/*vitest*.yml"
    ["github-actions-cypress"]=".github/workflows/*cypress*.yml"
    ["github-actions-playwright"]=".github/workflows/*playwright*.yml"
    ["github-actions-testing-library"]=".github/workflows/*testing-library*.yml"
    ["github-actions-eslint"]=".github/workflows/*eslint*.yml"
    ["github-actions-prettier"]=".github/workflows/*prettier*.yml"
    ["github-actions-typescript"]=".github/workflows/*typescript*.yml"
    ["github-actions-rust-analyzer"]=".github/workflows/*rust-analyzer*.yml"
    ["github-actions-clippy"]=".github/workflows/*clippy*.yml"
    ["github-actions-rustfmt"]=".github/workflows/*rustfmt*.yml"
    ["github-actions-pylint"]=".github/workflows/*pylint*.yml"
    ["github-actions-black"]=".github/workflows/*black*.yml"
    ["github-actions-ruff"]=".github/workflows/*ruff*.yml"
    ["github-actions-mypy"]=".github/workflows/*mypy*.yml"
    ["github-actions-pytest"]=".github/workflows/*pytest*.yml"
    ["github-actions-tox"]=".github/workflows/*tox*.yml"
    ["github-actions-coverage"]=".github/workflows/*coverage*.yml"
    ["github-actions-sonarqube"]=".github/workflows/*sonarqube*.yml"
    ["github-actions-codecov"]=".github/workflows/*codecov*.yml"
    ["github-actions-coveralls"]=".github/workflows/*coveralls*.yml"
    ["github-actions-snyk"]=".github/workflows/*snyk*.yml"
    ["github-actions-dependabot"]=".github/workflows/*dependabot*.yml"
    ["github-actions-renovate"]=".github/workflows/*renovate*.yml"
    ["github-actions-leak-detection"]=".github/workflows/*leak-detection*.yml"
    ["github-actions-security"]=".github/workflows/*security*.yml"
    ["github-actions-license"]=".github/workflows/*license*.yml"
    ["github-actions-contributing"]=".github/workflows/*contributing*.yml"
    ["github-actions-changelog"]=".github/workflows/*changelog*.yml"
    ["github-actions-readme"]=".github/workflows/*readme*.yml"
    ["github-actions-docs"]=".github/workflows/*docs*.yml"
    ["github-actions-wiki"]=".github/workflows/*wiki*.yml"
    ["github-actions-github-pages"]=".github/workflows/*github-pages*.yml"
    ["github-actions-netlify"]=".github/workflows/*netlify*.yml"
    ["github-actions-vercel"]=".github/workflows/*vercel*.yml"
    ["github-actions-railway"]=".github/workflows/*railway*.yml"
    ["github-actions-heroku"]=".github/workflows/*heroku*.yml"
    ["github-actions-digitalocean"]=".github/workflows/*digitalocean*.yml"
    ["github-actions-aws"]=".github/workflows/*aws*.yml"
    ["github-actions-azure"]=".github/workflows/*azure*.yml"
    ["github-actions-gcp"]=".github/workflows/*gcp*.yml"
    ["github-actions-firebase"]=".github/workflows/*firebase*.yml"
    ["github-actions-supabase"]=".github/workflows/*supabase*.yml"
    ["github-actions-planetscale"]=".github/workflows/*planetscale*.yml"
    ["github-actions-neon"]=".github/workflows/*neon*.yml"
    ["github-actions-render"]=".github/workflows/*render*.yml"
    ["github-actions-fly"]=".github/workflows/*fly*.yml"
    ["github-actions-docker-hub"]=".github/workflows/*docker-hub*.yml"
    ["github-actions-github-container"]=".github/workflows/*github-container*.yml"
    ["github-actions-gitlab-container"]=".github/workflows/*gitlab-container*.yml"
    ["github-actions-aws-ecr"]=".github/workflows/*aws-ecr*.yml"
    ["github-actions-google-artifact"]=".github/workflows/*google-artifact*.yml"
    ["github-actions-azure-container"]=".github/workflows/*azure-container*.yml"
)

detect_ci_cd_systems() {
    local repo_path="${1:-.}"
    local verbose="${2:-false}"
    
    cd "$repo_path"
    
    local detected=()
    
    for system in "${!CI_CD_SYSTEMS[@]}"; do
        local pattern="${CI_CD_SYSTEMS[$system]}"
        
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
                echo "Detect CI/CD systems and deployment platforms"
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
    
    detect_ci_cd_systems "$repo_path" "$verbose"
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
