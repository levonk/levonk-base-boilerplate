.PHONY: help bootstrap clean doctor lint build test run deploy publish

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Install dependencies and setup environment
	direnv allow
	pnpm install

doctor: ## Check if all required tools are installed
	@command -v pnpm >/dev/null 2>&1 || echo "Missing pnpm"
	@command -v node >/dev/null 2>&1 || echo "Missing node"
	@command -v vsce >/dev/null 2>&1 || echo "Missing vsce"

lint: ## Lint this package
	pnpm run lint

build: ## Build this package
	pnpm run compile

test: ## Run tests
	pnpm run test

clean: ## Clean build artifacts
	rm -rf out dist node_modules

run: ## Run the extension
	code --extensionDevelopmentPath=$(PWD)

publish: build ## Publish to both stores
	@echo "Publishing to Microsoft Marketplace..."
	pnpm exec vsce publish
	@echo "Publishing to Open VSX..."
	pnpm exec ovsx publish
