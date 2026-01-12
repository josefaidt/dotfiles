---@module 'config.keymaps.plugins'
---Plugin-specific keymaps that don't fit in other categories

-- Neo-tree (file explorer)
vim.keymap.set("n", "\\", ":Neotree toggle<CR>", { desc = "NeoTree toggle", silent = true })

-- Formatting with conform.nvim
vim.keymap.set("n", "<leader>bf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })
