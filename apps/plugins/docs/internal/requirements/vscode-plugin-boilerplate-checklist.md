# VS Code Plugin Boilerplate Refactor Checklist

Based on requirements from `vscode-plugin-boilerplate.md`.

## 1. Project Structure
- [ ] **Restructure for Monorepo**: Move current extension files to a nested app structure.
  - Target structure: `apps/active/plugin/vscode/{{ extension_id }}/`
  - Move `src/`, `tsconfig.json`, `.vscodeignore`, `vitest.config.ts`, `eslint.config.mts` into the app directory.
  - Move and rename `package.json` to `apps/active/plugin/vscode/{{ extension_id }}/package.json`.

## 2. Root Configuration Files
- [ ] **Nix Environment**: Create `flake.nix` with the specified `devShell` (Node 20, PNPM, VSCE, OVSX, Copier, Make).
- [ ] **Direnv**: Create `.envrc` containing `use flake` with warning about needing nix with link to install it if missing.
- [ ] **Task Runner**: Create `Makefile` with targets:
  - `bootstrap`, `doctor`, `lint`, `build`, `test`, `clean`, `run`, `publish`.

## 3. Copier Configuration
- [ ] **Update `copier.yml`**:
  - Update variables to match requirements: `extension_name`, `extension_id`, `publisher`, `description`.
  - Remove/Update old variables (`plugin_name`, `display_name`, etc.) if replaced.
  - Set `_subdirectory: "template"` (or adjust based on final template layout).

## 4. Extension Package Updates
- [ ] **Update `apps/active/plugin/vscode/{{ extension_id }}/package.json`**:
  - Update variable placeholders to match new copier variable names (e.g., `[[ extension_id ]]`).
  - Update `scripts` to match requirements (`build`, `publish:ms`, `publish:ovsx`).
  - Ensure `vsce` and `ovsx` dependencies are handled (likely in root or devShell, but `package.json` scripts call them).

## 5. Cleanup & Documentation
- [ ] **Clean up root**: Remove old root-level config files that are now per-package or replaced.
- [ ] **Update `README.md`**: Document the new monorepo structure, Nix usage, and Makefile commands.
