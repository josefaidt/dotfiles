-- Plugin-specific keymaps that don't fit in other categories

-- Neo-tree (file explorer)
vim.keymap.set("n", "\\", ":Neotree reveal<CR>", { desc = "NeoTree reveal", silent = true })

-- Formatting with conform.nvim
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[F]ormat buffer" })
