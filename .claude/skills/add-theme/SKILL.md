---
name: add-theme
description: Add a new neovim colorscheme plugin to the dotfiles. Registers it in theme.lua and wires every selectable variant into the <leader>uc theme picker. Use whenever the user asks to add a colorscheme/theme.
argument-hint: [plugin repo or theme name]
---

Add a neovim colorscheme: $ARGUMENTS

The dotfiles repo lives at `~/github.com/josefaidt/dotfiles`. There are two files to touch and they MUST stay in sync — a plugin without a picker entry is invisible, and a picker entry without a plugin will error on selection.

## Steps

1. **Identify variants.** A single plugin often ships multiple selectable colorschemes (e.g. nightfox.nvim → `nightfox`, `dayfox`, `dawnfox`, `duskfox`, `nordfox`, `terafox`, `carbonfox`; catppuccin → `catppuccin`, `catppuccin-latte`, `catppuccin-frappe`, `catppuccin-macchiato`, `catppuccin-mocha`). Check the plugin's README for the full list — every variant the user can `:colorscheme` to needs a picker entry.

2. **Register the plugin** in `~/github.com/josefaidt/dotfiles/.config/nvim/lua/plugins/ui/theme.lua`. Append a new entry to the returned table:
   ```lua
   {
     "owner/repo",
     lazy = true, -- not active by default
   }
   ```
   Do NOT set `priority` or call `vim.cmd.colorscheme(...)` unless the user asked to make it the default. `lazy = true` keeps it dormant until invoked via `:colorscheme`.

3. **Wire it into the picker.** Edit the `themes` array inside the `<leader>uc` keymap in `~/github.com/josefaidt/dotfiles/.config/nvim/lua/config/keymaps.lua` (search for `local themes = {`). Add one string per selectable variant. Group related variants together; keep `rouge2` last (it's the local custom one).

4. **Verify both files.** After editing, grep both files for the theme name to confirm it's in both. If only one shows up, you missed a step.

5. **Tell the user how to load it.** `:Lazy sync` to install, then `<leader>uc` to pick (or `:colorscheme <name>` directly).

## Don't

- Don't set the new theme as active (no `vim.cmd.colorscheme`, no `priority = 1001`) unless the user explicitly asks.
- Don't add only the plugin — the picker is the user-facing surface; missing it makes the change invisible.
- Don't add only one variant when the plugin ships several — list every one the plugin exposes.
