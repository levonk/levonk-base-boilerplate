---
story_id: "01-002"
story_title: "Create shared x86_64-darwin detection script"
branch: "feature/current/20260814-boilerplate-copier-fixes/story-01-002-x86-detection-script"
dependencies: []
parallel_safe: true
status: "[x] Done"
---

# Story 01-002: Create shared x86_64-darwin detection script

## Goal

Create a shared bash script at `_shared/scripts/ensure-devbox-x86-pin.sh` that detects x86_64-darwin (Intel Mac) at runtime and injects the nixpkgs commit pin into `devbox.json` if the pin is missing. This is a runtime fallback that works even when copier is invoked without the wrapper (and thus `nix_target_arch` is not passed as a copier data variable).

## Context

nixpkgs dropped x86_64-darwin support in the 26.11 release cycle. The `copier-wrapper.sh` already detects the Nix target architecture and passes it as `--data nix_target_arch=<triple>`, and most `devbox.json.jinja` templates conditionally pin nixpkgs when `nix_target_arch == "x86_64-darwin"`. However, if copier is invoked directly (without the wrapper), the pin is skipped and `devbox install` fails on Intel Macs.

The nixpkgs commit pin is `293d6abedf0478e681a4dfcfcb35b30fc796a32f` (already used in existing devbox.json.jinja templates).

## Tasks

- [ ] Create `_shared/scripts/ensure-devbox-x86-pin.sh`
- [ ] The script must:
  - Detect the platform: `uname -s` (darwin/linux) and `uname -m` (x86_64/arm64/aarch64)
  - If platform is x86_64-darwin:
    - Check if `devbox.json` exists in the current directory
    - Check if `devbox.json` already contains `nixpkgs` with a `commit` field
    - If no pin exists, inject the `nixpkgs.commit` field into `devbox.json`
    - Use a JSON-aware approach (python3 or jq if available, fallback to sed)
  - If platform is not x86_64-darwin, do nothing (exit 0)
  - Be non-destructive: if a pin already exists, do not overwrite it
  - Exit 0 on success or no-op, exit 1 on error
- [ ] Make the script executable (`chmod +x`)
- [ ] Add a comment header explaining the script's purpose and the nixpkgs x86_64-darwin issue

## Acceptance Criteria

- [ ] Script exists at `_shared/scripts/ensure-devbox-x86-pin.sh`
- [ ] Script is executable
- [ ] On x86_64-darwin with unpinned devbox.json: injects `nixpkgs.commit` = `293d6abedf0478e681a4dfcfcb35b30fc796a32f`
- [ ] On x86_64-darwin with already-pinned devbox.json: no-op (does not overwrite)
- [ ] On aarch64-darwin or linux: no-op (exit 0)
- [ ] Script handles missing devbox.json gracefully (exit 0, not error)

## Relevant Files

- `copier-wrapper.sh` — already has `detect_nix_target_arch()` function (reference for detection logic, lines 189-202)
- `repo/git-repo/files/devbox.json.jinja` — reference for nixpkgs pin pattern (lines 2-5)
- `packages/category/general/domain/package-name/go/devbox.json.jinja` — reference for nixpkgs pin pattern (lines 2-5)

## Tech Context (Binding Constraint)

This project uses the following tools. Use them, not alternatives.

- Package manager: none (template catalog, not a software project)
- Ad-hoc runner: devbox run -- <command> for system tools
- Build system: copier (template rendering)
- Template engine: Jinja2 (.jinja files)
- Scripts: Bash
- Environment: devbox + direnv + nix
- Validation: post-copy _tasks grep for unrendered Jinja artifacts

System tools run via: devbox run -- <command>
Never use: npm, npx, yarn, pip install (this is not a Node/Python project)
