# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for macOS development environment. Uses GNU Stow for symlink management to deploy configs from this repo to `~/.config/`.

## Key Components

### Neovim (`.config/nvim/`)
- **Plugin manager**: lazy.nvim (auto-bootstrapped on first run)
- **Entry point**: `init.lua` loads config/keymaps → config/lazy → config/vscode
- **Structure**:
  - `lua/config/` - Core settings and keymaps (split into general, lsp, plugins, telescope)
  - `lua/plugins/editor/` - Editor features (autocompletion, telescope, formatting, linting, etc.)
  - `lua/plugins/lsp/` - Language server configuration
  - `lua/plugins/ui/` - UI components (file-tree/neo-tree, theme, tabs, statusline, which-key)
- **Plugin organization**: Each file in `plugins/` returns a lazy.nvim spec table

### Other Configs
- **ghostty** - Terminal emulator config (`.config/ghostty/config`)
- **fish** - Shell configuration (`.config/fish/`)
- **zellij** - Terminal multiplexer (`.config/zellij/`)
- **starship** - Cross-shell prompt (`.config/starship.toml`)

## Setup & Deployment

```bash
# Initial setup (installs homebrew, tools, changes shell to fish)
./setup.sh

# Deploy configs with stow
stow -t ~ .                    # Deploy all
stow -t ~ nvim zellij fish     # Deploy specific configs
```

## Common Tasks

When modifying neovim plugins:
- Add new plugins by creating files in appropriate `plugins/` subdirectory
- Keymaps are centralized in `config/keymaps/` and organized by category
- lazy.nvim auto-imports from `plugins.editor`, `plugins.lsp`, `plugins.ui`

When modifying configs:
- All configs live in `.config/` directory
- Changes here should be committed to repo, then re-stow'd if needed
