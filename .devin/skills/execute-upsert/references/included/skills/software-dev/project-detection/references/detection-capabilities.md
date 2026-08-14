# Core Detection Capabilities

## Build Systems & Package Managers
- **JavaScript/TypeScript**: npm, pnpm, yarn, bun, deno
- **Rust**: Cargo, rust-analyzer, clippy, rustfmt
- **Python**: Poetry, pip, conda, setuptools, hatch
- **Go**: Go modules, golangci-lint, go-swagger
- **Java**: Maven, Gradle, SBT, Leiningen
- **.NET**: NuGet, MSBuild, dotnet CLI
- **Ruby**: Bundler, RubyGems
- **PHP**: Composer
- **Elixir**: Mix, Hex
- **Haskell**: Stack, Cabal
- **Clojure**: Leiningen, deps.edn
- **C/C++**: CMake, Make, Meson, Bazel
- **Swift**: Swift Package Manager (Package.swift), Xcode projects
- **Environment**: devbox (devbox.json), Nix (flake.nix, shell.nix), Hermit (bin/hermit.hcl)
- **Container**: Docker, Docker Compose, Buildah
- **Infrastructure**: Terraform, Pulumi, Ansible, Chef, Puppet

## CI/CD Platforms
- **GitHub Actions**: Workflows, actions, self-hosted runners
- **GitLab CI**: Pipelines, GitLab Runners
- **CircleCI**: Config, orbs, self-hosted
- **Travis CI**: Travis CI, Travis CI Pro
- **Jenkins**: Jenkinsfile, plugins, agents
- **Azure Pipelines**: Azure DevOps, hosted agents
- **AWS CodeBuild**: Build projects, CodePipeline
- **Google Cloud Build**: Cloud Build, Cloud Run
- **Bitbucket Pipelines**: Bitbucket CI/CD
- **Buildkite**: Buildkite agents, pipelines
- **Drone CI**: Drone servers, runners
- **Semaphore**: Semaphore 2.0
- **AppVeyor**: Windows CI/CD
- **Wercker**: Container-based CI/CD
- **Shippable**: Shippable CI/CD
- **Screwdriver**: Screwdriver.cd

## Workspace & Monorepo Tools
- **Nx**: nx.json, project graph (preferred per ADR 20260419001)
- **pnpm workspaces**: pnpm-workspace.yaml
- **npm workspaces**: package.json workspaces
- **yarn workspaces**: yarn workspaces config
- **Lerna**: lerna.json, lerna packages
- **Turbo**: turbo.json, pipeline config (superseded by NX per ADR 20260419001)
- **Rush**: rush.json, rush config
- **Bazel**: WORKSPACE, BUILD files
- **Pants**: pants.toml, BUILD files
- **Buck**: BUCK files, buck config
- **Please**: BUILD.plz files

## Development Tools
- **Linting**: ESLint, Prettier, Black, Ruff, Clippy
- **Testing**: Jest, Vitest, Pytest, Go test, JUnit
- **Type Checking**: TypeScript, MyPy, Go types
- **Code Quality**: SonarQube, CodeClimate, Codecov
- **Security**: Snyk, Dependabot, Renovate
- **Documentation**: MkDocs, Docusaurus, GitBook
