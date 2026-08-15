---
name: add-theme
description: Add a new neovim colorscheme plugin to the dotfiles. Registers it in theme.lua; the <leader>uC Snacks colorscheme picker discovers it automatically. Use whenever the user asks to add a colorscheme/theme.
argument-hint: [plugin repo or theme name]
---

Add a neovim colorscheme: $ARGUMENTS

The dotfiles repo lives at `~/github.com/josefaidt/dotfiles`. There is one file to touch: `.config/nvim/lua/plugins/ui/theme.lua`. The picker (`<leader>uC` → `Snacks.picker.colorschemes()`) enumerates every `colors/*.lua|vim` file on the runtimepath — including plugins lazy.nvim hasn't loaded yet — so there is no list to keep in sync.

## Steps

1. **Register the plugin** in `~/github.com/josefaidt/dotfiles/.config/nvim/lua/plugins/ui/theme.lua`. Append a new entry to the returned table:
   ```lua
   {
     "owner/repo",
     lazy = true, -- not active by default
   }
   ```
   Do NOT set `priority` or call `vim.cmd.colorscheme(...)` unless the user asked to make it the default. `lazy = true` keeps it dormant until invoked via `:colorscheme`.

2. **Check how variants are exposed.** Most plugins ship one `colors/<name>.lua` per variant (nightfox → `nightfox`, `dayfox`, `dawnfox`, `duskfox`, `nordfox`, `terafox`, `carbonfox`; catppuccin → `catppuccin`, `catppuccin-latte`, …) and those all show up in the picker for free. Some expose a single colorscheme name whose look is tuned by `vim.g.*` variables instead (gruvbox-material → `vim.g.gruvbox_material_background`). For that second kind, set the preferred defaults in an `init = function() ... end` on the spec — only the configured variant is reachable from the picker.

3. **Tell the user how to load it.** `:Lazy sync` to install, then `<leader>uC` to pick (live preview as you scroll) or `:colorscheme <name>` directly.

## Don't

- Don't set the new theme as active (no `vim.cmd.colorscheme`, no `priority = 1001`) unless the user explicitly asks.
- Don't add a picker entry anywhere — the old curated `themes` list in `keymaps.lua` is gone.
