# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for macOS development environment. Uses GNU Stow for symlink management (via `xdg-config-stow` and `stow`) to deploy configs from this repo to `~/.config/` and `~`.

**Recent Changes:**
- Removed VSCode configuration (formerly in `.vscode/`)
- Reorganized Fish config (moved functions out of `conf.d/` into `functions/`)
- Added diffview plugin for Git diff viewing in Neovim
- Expanded Neovim keymaps with more telescope and LSP bindings
- Added type annotations to Lua configurations

## Key Components

### Neovim (`.config/nvim/`)
- **Plugin manager**: lazy.nvim (auto-bootstrapped on first run)
- **Entry point**: `init.lua` loads config/keymaps → config/lazy → config/vscode
- **Structure**:
  - `lua/config/` - Core settings and keymaps (split into general, lsp, plugins, telescope)
  - `lua/plugins/editor/` - Editor features:
    - autocompletion.lua - nvim-cmp with LSP, buffer, path completions
    - autopairs.lua - Auto-close brackets/quotes
    - comment.lua - Smart commenting (Comment.nvim)
    - flash.lua - Quick navigation with labeled jumps
    - formatting.lua - Code formatting with conform.nvim
    - linting.lua - Linting with nvim-lint
    - markdown.lua - Markdown preview
    - multiple-cursors.lua - VSCode-like multiple cursors (vim-visual-multi)
    - session.lua - Session management
    - syntax-highlighting.lua - Treesitter-based highlighting
    - telescope.lua - Fuzzy finder
  - `lua/plugins/lsp/` - Language server configuration:
    - init.lua - LSP setup and configuration
    - lazydev.lua - Lua development enhancements
  - `lua/plugins/ui/` - UI components:
    - diffview.lua - Git diff viewer
    - dropbar.lua - IDE-like breadcrumbs winbar with context navigation
    - file-tree.lua - Neo-tree file explorer
    - git-blame.lua - Git blame annotations
    - statusline.lua - Lualine status bar
    - tabs.lua - Buffer/tab line (barbar.nvim)
    - theme.lua - Color scheme configuration
    - which-key.lua - Keybinding hints
  - `colors/` - Custom color schemes (rouge2.lua)
- **Plugin organization**: Each file in `plugins/` returns a lazy.nvim spec table
- **Formatting**: Uses `.stylelua.toml` for Lua code formatting

### Fish Shell (`.config/fish/`)
- **Main config**: `config.fish` - Shell initialization and environment setup
- **Custom functions**: `functions/`
  - `cd.fish` - Enhanced directory navigation
  - `fish_greeting.fish` - Custom greeting on shell start
  - `la.fish` - List all files (likely using eza)
  - `loadenv.fish` - Environment variable loading utility
  - `zj.fish` - Zellij integration
- **Config scripts**: `conf.d/` - Additional configuration loaded at startup
- **Stow config**: `.stowignore` - Controls which files are stowed

### Git (`git/`)
- `.gitignore_global` - Global gitignore patterns
- Deployed via `stow git` to home directory
- Configured with `git config --global core.excludesfile ~/.gitignore_global`

### Other Configs
- **ghostty** - Terminal emulator config (`.config/ghostty/config`)
- **zellij** - Terminal multiplexer (`.config/zellij/config.kdl`)
- **starship** - Cross-shell prompt (`.config/starship.toml`)

## Dependencies (Brewfile)

### CLI Tools
- **Package managers**: homebrew, fnm (Node.js), uv (Python)
- **Development**: awscli, copilot-cli, git-secrets, luarocks, neovim
- **Utilities**: bat, fzf, gh, httpie, jq, lazygit, ripgrep, stow, tree
- **Database**: sqld (libSQL server)
- **Shells**: fish, starship

### GUI Applications
- 1password-cli
- warp (terminal)

### Cargo packages
- eza (modern ls replacement)
- jj-cli (Jujutsu VCS)
- rustlings (Rust learning)
- stylua (Lua formatter)
- xdg-config-stow (XDG-aware stow wrapper)

### Taps
- 1password/tap
- aws/tap
- homebrew/services
- libsql/sqld

## Setup & Deployment

```bash
# Initial setup (installs homebrew, dependencies, changes shell to fish)
./setup.sh

# The setup script:
# 1. Installs Homebrew if not present
# 2. Runs `brew bundle` to install all dependencies
# 3. Sets fish as default shell
# 4. Configures macOS defaults (show hidden files, dock settings, etc.)
# 5. Creates ~/github.com/josefaidt directory
# 6. Clones dotfiles repo
# 7. Stows git config
# 8. Stows fish, nvim, ghostty, zellij configs using xdg-config-stow
# 9. Symlinks starship.toml

# Manual deployment of specific configs
xdg-config-stow fish        # Deploy fish config
xdg-config-stow nvim        # Deploy neovim config
xdg-config-stow ghostty     # Deploy ghostty config
xdg-config-stow zellij      # Deploy zellij config
stow git                    # Deploy git config to ~
```

## Common Tasks

### When modifying neovim plugins:
- Add new plugins by creating files in appropriate `plugins/` subdirectory (editor/, lsp/, or ui/)
- Keymaps are centralized in `config/keymaps/` and organized by category (general, lsp, plugins, telescope)
- lazy.nvim auto-imports from `plugins.editor`, `plugins.lsp`, `plugins.ui`
- Format Lua code with stylua using the provided `.stylelua.toml` config

### When modifying configs:
- All configs live in `.config/` directory
- Git config lives in `git/` directory (stowed to home)
- Changes should be committed to repo, then re-stowed to apply
- Use `xdg-config-stow <name>` for .config items
- Use `stow git` for git configuration

### When adding fish functions:
- Place new functions in `.config/fish/functions/`
- Follow existing naming pattern (e.g., `functionname.fish`)
- Functions are auto-loaded by fish

### When updating dependencies:
- Edit `Brewfile` to add/remove packages
- Run `brew bundle` to install new dependencies
- Run `brew bundle cleanup` to remove unlisted packages

### When working through notes.md items:
- When addressing items line by line from `notes.md`, mark each item as complete by changing `[ ]` to `[x]` after successfully implementing/addressing it
- If asked to skip or ignore an item, use strikethrough formatting (e.g., `~~- [ ] item text~~`) to indicate it should be skipped
- This keeps the notes file as an accurate tracking document of what's been accomplished vs. what's pending
