# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## Overview

Personal macOS dotfiles. Configs live in `.config/` (and a couple of top-level
dirs) and are deployed as symlinks via [GNU Stow](https://www.gnu.org/software/stow/):

- `xdg-config-stow <name>` — for `.config/<name>/` packages (fish, nvim, ghostty, zellij, aerospace)
- `stow <name>` — for top-level packages that target `$HOME` (`git`, `claude`)

`xdg-config-stow` is a cargo-installed, XDG-aware wrapper around stow. Editing a
config here does nothing until it's stowed (or already symlinked). After a
`git pull`, the git hooks re-stow changed packages automatically (see below).

## Repository Layout

| Path              | Purpose                                                              | Deploy                     |
| ----------------- | ------------------------------------------------------------------- | -------------------------- |
| `.config/nvim/`   | Neovim (lazy.nvim). See [Neovim](#neovim) below.                    | `xdg-config-stow nvim`     |
| `.config/fish/`   | Fish shell — `config.fish`, `conf.d/`, `functions/`                 | `xdg-config-stow fish`     |
| `.config/ghostty/`| Ghostty terminal — `config` + `themes/`                            | `xdg-config-stow ghostty`  |
| `.config/zellij/` | Zellij multiplexer — `config.kdl` + `layouts/`                     | `xdg-config-stow zellij`   |
| `.config/aerospace/`| AeroSpace tiling WM — `aerospace.toml`                            | `xdg-config-stow aerospace`|
| `.config/lazygit/`| lazygit — `config.yml` + `themes/` (not stowed by setup.sh)        | —                          |
| `.config/starship.toml` | Starship prompt (symlinked manually, not stowed)             | —                          |
| `.config/.bunfig.toml` | Bun config                                                     | —                          |
| `git/`            | `.gitignore_global` → `~` via stow                                  | `stow git`                 |
| `claude/`         | `~/.claude/` skills (currently a `dotfiles` skill). Stows to `$HOME`.| `stow claude`             |
| `.claude/`        | **Repo-local** Claude Code config (agents, skills, hooks, settings). Not stowed — read directly by Claude Code when working in this repo. |
| `npm/`            | `.npmrc` + `package.json` (global npm setup)                        | —                          |
| `.devcontainer/`  | Dev Container definition                                            | —                          |
| `.github/`        | GitHub Actions — `claude.yml`, `claude-code-review.yml`             | —                          |
| `.githooks/`      | Version-controlled git hooks (see [Git Hooks](#git-hooks))          | —                          |
| `Brewfile`        | Homebrew deps (brew/cask/cargo/tap)                                 | `brew bundle`              |
| `setup.sh`        | Install/update entry point (see [Setup](#setup))                    | —                          |
| `notes.md`        | Running todo/scratch list (see [Working through notes.md](#working-through-notesmd)) |          |

## Setup

`setup.sh` runs in one of two modes (auto-detected; force with `--install` / `--update`):

- **install** (no repo present): installs Homebrew + GitHub CLI, authenticates
  `gh`, clones this repo, `brew bundle`, sets fish as default shell, applies
  macOS defaults, activates git hooks (`git config core.hooksPath .githooks`),
  stows all configs, installs bun globals + nvim prettier plugins + devcontainer CLI.
- **update** (repo present): `git pull --rebase`, `brew bundle` + `brew upgrade`
  + `brew cleanup`, re-stows only changed configs, refreshes bun globals / prettier
  plugins / devcontainer CLI.

```bash
bash setup.sh            # auto-detect mode
bash setup.sh --install  # force install
bash setup.sh --update   # force update
```

Two toolchains live outside Homebrew:

- **bun globals**: `oxfmt`, `oxlint` (installed via `bun install --global`).
- **nvim prettier plugins**: `npm install` inside `.config/nvim/prettier-plugins/`
  so conform.nvim can format filetypes like `.astro` without a project-local install.

If a shell login (e.g. `gh auth login`) is needed, ask the user to run it via
`! <command>` in the prompt.

## Git Hooks

Version-controlled in `.githooks/`, activated by `git config core.hooksPath .githooks`
(done by `setup.sh`). After a `git pull`:

- `post-merge` (fast-forward) and `post-rebase` (`pull.rebase = true`) both call
  the shared `restow` helper with the list of changed files.
- `restow` diffs the changed paths and re-stows only affected packages:
  `.config/<name>/` → `xdg-config-stow <name>`; `git/` → `stow git`;
  `claude/` → `stow claude`. Unrelated configs are left untouched.

## Neovim

`.config/nvim/` — lazy.nvim (auto-bootstrapped on first run), Lua config.

- **Entry**: `init.lua` → `config/keymaps` → `config/lazy` → `config/vscode`.
- **Plugins auto-import** from `plugins.editor`, `plugins.lua`, `plugins.ui` —
  each file returns a lazy.nvim spec table; no manual registration.

### Structure

```
lua/
  config/
    keymaps.lua       -- all eager keymaps + helpers (git root, npm pkg, worktree picker)
    keymaps_lsp.lua   -- LSP on-attach keymaps (buffer-local; set on LspAttach)
    lazy.lua          -- lazy.nvim bootstrap + plugin imports
    vscode.lua        -- vscode-neovim overrides
  plugins/
    editor/  autocompletion, autopairs, comment, flash, formatting, linting,
             markdown, markdown-nav, multiple-cursors, persistence, syntax-highlighting
    lsp/     init.lua (lspconfig + mason + tools), lazydev.lua
    ui/      dropbar, edgy, git-blame, gitsigns, image, noice,
             snacks, start-screen, statusline, tabs, theme, which-key
colors/    rouge2.lua (custom)
```

### Key plugins (what's actually installed)

- **Completion**: `saghen/blink.cmp` (super-tab preset, LuaSnip snippets) — **not** nvim-cmp.
- **Picker / UI select**: `folke/snacks.nvim` picker; handles `vim.ui.select`.
  (Telescope and fff.nvim have been fully removed — don't reference them.)
- **UI stack**: `folke/noice.nvim` + `MunifTanjim/nui.nvim` (cmdline/messages/input/confirm),
  `rcarriga/nvim-notify` (toasts).
- **Statusline**: `echasnovski/mini.nvim` (`mini.statusline`) — **not** lualine.
  mini.nvim also provides `mini.ai` and `mini.surround`.
- **File tree**: `folke/snacks.nvim` explorer (`<leader>e`). **Tabs**: `akinsho/bufferline.nvim`.
- **Git**: `lewis6991/gitsigns.nvim`, `f-person/git-blame.nvim`.
- **Dashboard**: `goolord/alpha-nvim`. **Sessions**: `folke/persistence.nvim`.
- **Winbar**: `Bekaboo/dropbar.nvim`. **Layout**: `folke/edgy.nvim`.
- **Nav**: `folke/flash.nvim`. **Multi-cursor**: `mg979/vim-visual-multi`.
- **Treesitter**, `numToStr/Comment.nvim`, `windwp/nvim-autopairs`, `3rd/image.nvim`.
- **Themes** (`theme.lua`): active is **mellow** (`mellow-theme/mellow.nvim`, applied
  at plugin-load from `NVIM_COLORSCHEME` env, set by the `theme` fish function).
  Also embark, kanagawa, everforest, catppuccin, nightfox, gruvbox-material, and the
  local `rouge2`. Selected via `<leader>uC` (`Snacks.picker.colorschemes()`, live
  preview; it auto-discovers every colorscheme on the runtimepath, so there's no
  curated list to maintain).

### Keymaps

All eager keymaps are in `lua/config/keymaps.lua`, grouped by leader prefix
(LazyVim-aligned): **b**uffer, **c**ode, **e**xplorer, **f**ile/find, **g**it,
**q**uit, **s**earch, **u**i. LSP on-attach maps are buffer-local in
`keymaps_lsp.lua` and use LazyVim letters — `gd`/`gD`/`gr`/`gI`/`gy` for
definition/declaration/references/implementation/type, `<leader>cr`/`<leader>ca`
for rename/code action, `<leader>ss`/`<leader>sS` (and `gO`) for symbols, `K` for
hover. `gr` is `<nowait>`, so Neovim's native `gr*` maps (`grn`, `gra`, `grr`, …)
are shadowed and unreachable — don't add new mappings under that prefix.
which-key shows hints. Leaders: `<Space>`
(mapleader), `;` (maplocalleader).

### LSP (`lua/plugins/lsp/init.lua`)

- lspconfig + mason + mason-lspconfig (`automatic_enable = true`) + mason-tool-installer.
- Capabilities from `require("blink.cmp").get_lsp_capabilities()`.
- **Servers**: rust_analyzer, ts_ls, html, cssls, tailwindcss, astro, svelte,
  emmet_ls, biome, jsonls (formatting disabled), yamlls, taplo, lua_ls.
  Schemas via `b0o/schemastore.nvim`.
- **Mason-installed tools** (beyond servers): stylua, ruff, oxlint, oxfmt,
  markdownlint-cli2, yamllint.
- Diagnostics: `virtual_text = false`; float on CursorHold when
  `vim.g.lsp_auto_hover` is on (default off, toggled via `<leader>ush`).
- `tailwindcss`/`biome` attach only when the project actually uses them
  (walks up reading `package.json` / looking for `biome.json`); biome prefers
  project-local `node_modules/.bin/biome`.

### Linters & formatters (defaults live in `.config/nvim/`)

Global default configs are passed to each tool when no project-local config is found
(the fallback only fires when searching upward from the file finds nothing).

| Tool                | Default config       | Filetype(s)                  |
| ------------------- | -------------------- | ---------------------------- |
| `oxlint`            | zero-config          | JS/TS (fallback linter)      |
| `oxfmt`             | `.oxfmtrc.jsonc`     | JS/TS, JSON/JSONC (fallback) |
| `markdownlint-cli2` | `.markdownlint.json` | markdown                     |
| `yamllint`          | `.yamllint`          | yaml                         |
| `stylua`            | `.stylelua.toml`     | lua                          |
| prettier            | `.prettierrc.cjs` + `prettier-plugins/` | via conform when a project config is found |

- **Linter priority** (nvim-lint, JS/TS): eslint (if config) → oxlint.
- **Formatter priority** (conform.nvim, JS/TS): prettier/prettierd (if config) → oxfmt.

To add a global linter/formatter: add to `ensure_installed` in `lsp/init.lua`,
register in `linting.lua` (`linters_by_ft`) and/or `formatting.lua`
(`formatters_by_ft`), and drop any default config in `.config/nvim/`.

### Building UI in the Neovim config

Use the enhanced stdlib APIs — they're auto-styled by the noice/nui/notify/snacks stack:

- `vim.ui.select(items, { prompt = "..." }, cb)` — picker/dropdown
- `vim.ui.input({ prompt = "..." }, cb)` — text input
- `vim.notify(msg, vim.log.levels.INFO|WARN|ERROR)` — notification

Never build raw floating windows or custom pickers from scratch.

### Repo-local Claude agents & skills for Neovim

`.claude/` provides a **`neovim`** agent (worktree-isolated) and an **`add-theme`**
skill (`/add-theme`). Prefer the `neovim` agent for nontrivial nvim config work.
The `add-theme` skill registers a colorscheme in `theme.lua`; the `<leader>uC`
Snacks picker discovers it automatically, so nothing in `keymaps.lua` needs editing.

> Note: `.claude/agents/neovim.md` contains a config-structure map that has drifted
> from the current tree (it references a `keymaps/` subdir, `telescope.lua`,
> `diffview.lua`, `session.lua`, lualine). Trust this file and the live tree over it.

## Common Tasks

### Modifying configs

Edit under `.config/` (or `git/`, `claude/`), commit, then re-stow the affected
package (`xdg-config-stow <name>`, or `stow git` / `stow claude`). Changes to a
stowed symlink take effect immediately; new files need a fresh stow.

### Fish functions

Add to `.config/fish/functions/<name>.fish` (auto-loaded). Existing: `agentbox`,
`cd`, `fish_greeting`, `la`, `loadenv`, `setcursors`, `theme`, `zj`. Note
`conf.d/aws.fish` is gitignored (not committed) and stow-ignored.

### Dependencies

Edit `Brewfile`, then `brew bundle` (and `brew bundle cleanup` to prune). The
Brewfile also declares `cargo` packages (eza, jj-cli, rustlings, stylua,
xdg-config-stow) and casks (1password-cli, warp, aerospace).

### Working through notes.md

`notes.md` is a tracking doc. When addressing items line by line: mark done with
`[ ]` → `[x]`; mark skipped/won't-fix with strikethrough (`~~- [ ] item~~`); add
new items as `- [ ] description`. Keep it an accurate record of done vs. pending.
