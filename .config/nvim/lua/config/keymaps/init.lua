---@module 'config.keymaps'
---Main keymap configuration file (barrel file)
---This file loads all keymap modules from the keymaps/ directory

-- Load general keymaps (leaders, window navigation, etc.)
require("config.keymaps.general")

-- Load plugin-specific keymaps that should be available immediately
require("config.keymaps.plugins")

-- Note: Telescope and LSP keymaps are loaded by their respective plugins
-- See:
--   - lua/plugins/editor/telescope.lua for Telescope keymap loading
--   - lua/plugins/lsp/init.lua for LSP keymap loading
