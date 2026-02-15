---@module 'config.keymaps.plugins'
---Plugin-specific keymaps that don't fit in other categories

-- Neo-tree (file explorer)
-- \ toggles focus between neotree and editor (doesn't close neotree)
vim.keymap.set("n", "\\", function()
	local neo_tree_wins = vim.tbl_filter(function(win)
		local buf = vim.api.nvim_win_get_buf(win)
		return vim.bo[buf].filetype == "neo-tree"
	end, vim.api.nvim_list_wins())

	if #neo_tree_wins > 0 then
		-- Neo-tree is open, check if we're currently in it
		local current_win = vim.api.nvim_get_current_win()
		local in_neotree = vim.bo[vim.api.nvim_win_get_buf(current_win)].filetype == "neo-tree"

		if in_neotree then
			-- We're in neotree, jump to the previous window (editor)
			vim.cmd("wincmd p")
		else
			-- We're in editor, focus neotree
			vim.cmd("Neotree focus")
		end
	else
		-- Neo-tree is not open, open it
		vim.cmd("Neotree show")
	end
end, { desc = "Toggle focus between NeoTree and editor", silent = true })

-- Ctrl+\ toggles neotree visibility (open/close)
vim.keymap.set("n", "<C-\\>", ":Neotree toggle<CR>", { desc = "Toggle NeoTree visibility", silent = true })

-- Formatting with conform.nvim
vim.keymap.set("n", "<leader>bf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })
