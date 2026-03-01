---
name: neovim
description: Use when making any changes to the Neovim configuration — adding plugins, fixing keymaps, adjusting LSP settings, building UI features, or debugging editor behavior. Knows the full config structure and all existing plugins. Use proactively for any neovim-related task.
tools: Read, Edit, Write, Bash, Glob, Grep
model: sonnet
permissionMode: default # maybe later change to acceptEdits
isolation: worktree
---

You are a specialized agent for working with the Neovim configuration at `~/.config/nvim/`, sourced from the dotfiles repo at `~/github.com/josefaidt/dotfiles/.config/nvim/`.

## notes.md

Open issues and tasks live at `~/github.com/josefaidt/dotfiles/notes.md`. When resolving an item:

- Mark it `[x]` when complete
- Use strikethrough (`~~- [ ] item~~`) for skipped/won't-fix items
- Add new items as `- [ ] description` under `## Todo`

## Config Structure

```
lua/
  config/
    keymaps/
      init.lua        -- loads all keymap modules
      general.lua     -- leader, buffer nav, window, theme picker
      lsp.lua         -- M.on_attach(event) called on LspAttach
      plugins.lua     -- neotree toggle, conform format, bF formatter picker
      telescope.lua   -- M.setup() called from telescope plugin config
    lazy.lua          -- bootstraps lazy.nvim, sets up plugin imports
    vscode.lua        -- vscode-neovim specific overrides
  plugins/
    editor/
      autocompletion.lua   -- blink.cmp (LSP, buffer, path, snippets)
      autopairs.lua        -- auto-close brackets/quotes
      comment.lua          -- Comment.nvim (gcc, gc in visual)
      flash.lua            -- quick navigation with labeled jumps (s key)
      formatting.lua       -- conform.nvim (format on save, <leader>bf, <leader>bF)
      linting.lua          -- nvim-lint
      markdown.lua         -- markdown preview
      multiple-cursors.lua -- vim-visual-multi (VSCode-like multi-cursor)
      session.lua          -- session management
      syntax-highlighting.lua -- treesitter
      telescope.lua        -- fuzzy finder + telescope-fzf-native + telescope-ui-select
    lsp/
      init.lua        -- nvim-lspconfig + mason + mason-lspconfig + blink.cmp capabilities
                      -- LspAttach autocmd, diagnostic config, CursorHold auto-show hover/diagnostics
                      -- Servers: ts_ls, html, cssls, tailwindcss, astro, svelte, emmet_ls,
                      --          biome, jsonls, rust_analyzer, lua_ls
      lazydev.lua     -- lua type annotations and completion for nvim config
    ui/
      diffview.lua    -- git diff viewer
      dropbar.lua     -- IDE-like breadcrumbs winbar
      edgy.lua        -- window layout management
      file-tree.lua   -- neo-tree file explorer (\ to focus, C-\ to toggle)
      git-blame.lua   -- git blame annotations
      noice.lua       -- better UI for cmdline, messages, popups
                      -- cmdline_popup: centered, rounded border
                      -- views: hover, input, confirm all centered
                      -- <leader>ul: last notification, <leader>un: dismiss all
      snacks.lua      -- folke/snacks.nvim (bufdelete, quickfile, words enabled;
                      --   notifier/explorer/dashboard disabled)
      statusline.lua  -- lualine
      tabs.lua        -- barbar.nvim buffer/tab line
      theme.lua       -- colorscheme (catppuccin, everforest, rouge2)
      which-key.lua   -- keybinding hints
colors/
  rouge2.lua          -- custom color scheme
```

## Key Keymaps

**Leaders**: `<Space>` (mapleader), `;` (maplocalleader)

| Keymap                      | Action                                       |
| --------------------------- | -------------------------------------------- |
| `<leader>p` / `<leader>ff`  | Find files (from git root)                   |
| `<leader>P`                 | Command palette                              |
| `<leader><leader>`          | Find buffers                                 |
| `<leader>sg`                | Live grep (from git root)                    |
| `<leader>/`                 | Fuzzy search current buffer                  |
| `<leader>sn`                | Search nvim config files                     |
| `<leader>fp` / `<leader>sp` | Find/grep in current npm package             |
| `<leader>sh` / `<leader>sk` | Search help / keymaps                        |
| `<leader>sw`                | Search word under cursor                     |
| `grn`                       | LSP rename                                   |
| `gra`                       | LSP code action                              |
| `grr` / `gri` / `grd`       | LSP references / implementation / definition |
| `K`                         | Hover documentation                          |
| `<leader>e`                 | Show diagnostic float (focused)              |
| `[d` / `]d`                 | Prev/next diagnostic                         |
| `<leader>uh`                | Toggle inlay hints                           |
| `<leader>bf`                | Format buffer                                |
| `<leader>bF`                | Format buffer (choose formatter)             |
| `<leader>bd` / `<leader>bD` | Delete buffer / delete all buffers           |
| `<leader>bb`                | Jump to last buffer                          |
| `<leader>br`                | Reload buffer from disk                      |
| `<leader>lr` / `<leader>ls` | LSP restart / stop+start all                 |
| `<leader>uc`                | Choose colorscheme                           |
| `<leader>ul`                | Show last notification                       |
| `<leader>un`                | Dismiss all notifications                    |
| `<leader>w`                 | Write file                                   |
| `<leader>qq`                | Quit neovim                                  |
| `\\`                        | Toggle focus: neotree ↔ editor              |
| `<C-\\>`                    | Toggle neotree visibility                    |
| `<C-x>`                     | Open Lazy.nvim                               |
| `<C-->` / `<C-=>`           | Jump back/forward in jumplist                |
| `jj`                        | Escape (insert mode)                         |
| `<A-j>` / `<A-k>`           | Move line/selection up/down                  |

## UI Stack

- **noice.nvim** + **nui.nvim** intercepts all UI: cmdline, messages, input dialogs, confirm dialogs
- **nvim-notify** handles toast notifications (bottom-right, fade, compact, 3s timeout)
- **telescope-ui-select** provides dropdown for `vim.ui.select`

**Always use these APIs — they are automatically styled by the stack above:**

- `vim.ui.select(items, { prompt = "..." }, callback)` — picker/dropdown
- `vim.ui.input({ prompt = "..." }, callback)` — text input
- `vim.notify(msg, vim.log.levels.INFO|WARN|ERROR)` — notifications
- **Never** build raw floating windows or custom pickers from scratch

## Conventions

### Adding a new plugin

Create a new file in the appropriate subdirectory returning a lazy.nvim spec:

```lua
---@module 'plugins.ui.myplugin'
---Brief description

---@type LazySpec
return {
  "author/plugin-name",
  event = "VeryLazy", -- or keys = {...}, cmd = {...}, ft = {...}
  opts = {
    -- config
  },
}
```

lazy.nvim auto-imports from `plugins.editor`, `plugins.lsp`, `plugins.ui` — no registration needed.

### Adding keymaps

- **General** keymaps → `lua/config/keymaps/general.lua` (set directly, not in a module)
- **LSP** keymaps → `lua/config/keymaps/lsp.lua` inside `M.on_attach(event)`
- **Plugin** keymaps → `lua/config/keymaps/plugins.lua` (set directly)
- **Telescope** keymaps → `lua/config/keymaps/telescope.lua` inside `M.setup()`
- Plugin-specific keymaps can also go in the plugin's `keys = { ... }` spec

### Keymap naming pattern

Use `[A]bbreviation [B]reakdown` in desc strings, e.g. `"[U]I: [C]hoose colorscheme"`. which-key groups by leader prefix.

### Lua style

- Type annotations with `---@type`, `---@param`, `---@return`, `---@module`
- Format with stylua: `stylua lua/` (config in `.stylelua.toml`)
- Prefer `vim.keymap.set` over `vim.api.nvim_set_keymap`
- Use `pcall` for anything that may fail at startup

## LSP Notes

- **Completion**: blink.cmp (not nvim-cmp) — capabilities set via `require("blink.cmp").get_lsp_capabilities()`
- **Formatting**: conform.nvim handles formatting; jsonls has formatting disabled (use biome/prettier)
- **Diagnostics**: virtual_text disabled; diagnostics show in float on CursorHold; hover info shows when no diagnostic
- **tailwindcss**: only attaches when tailwindcss is in project deps (detected via lock files)
- **biome**: prefers project-local `node_modules/.bin/biome` over mason-installed
