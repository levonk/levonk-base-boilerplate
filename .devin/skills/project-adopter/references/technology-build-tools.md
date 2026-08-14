# Technology-Specific Build Tools

**Technology-Specific Build Tools**:
| Technology | Build | Test | Lint | Dev |
|------------|-------|------|------|-----|
| **Rust** | `cargo build` | `cargo test` | `cargo clippy` | `cargo run` |
| **Node.js** | `nx build` | `nx test` | `nx lint` | `nx dev` |
| **Python** | `python -m build` | `pytest` | `ruff check` | `uv run python src/main.py` |
| **Go** | `go build` | `go test` | `golangci-lint run` | `go run` |
| **Java** | `mvn compile` | `mvn test` | `checkstyle` | `mvn exec:java` |

> **Node.js/TypeScript build-tool selection** (per the `build-tool-selection`
> knowledge concept in `typescript-monorepo-best-practices`): `nx build` is the
> orchestrator entry point, but the actual bundler depends on the project type:
> `tsc --noEmit` for type-checking (always in CI, never for bundling), **tsup**
> for library packages (ESM+CJS+`.d.ts` via esbuild), **Rolldown** for
> applications/CLIs (Rust speed, Rollup plugins, powers Vite 8+). Never use
> `tsc` for bundling; never use a bundler for type-checking. `configure-nodejs.sh`
> wires tsup automatically for `library` app_type.
