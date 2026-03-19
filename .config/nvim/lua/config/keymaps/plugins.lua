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
vim.keymap.set("n", "<C-\\>", "<cmd>Neotree toggle<CR>", { desc = "Toggle NeoTree visibility", silent = true })

-- Formatting with conform.nvim
vim.keymap.set("n", "<leader>bf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- Format with formatter picker
vim.keymap.set("n", "<leader>bF", function()
	local conform = require("conform")

	-- Use the public API to get available formatters for current buffer
	local available = {}
	for _, formatter in ipairs(conform.list_formatters(0)) do
		if formatter.available then
			table.insert(available, formatter.name)
		end
	end

	-- Add LSP formatting as an option if any attached client supports it
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.server_capabilities.documentFormattingProvider then
			table.insert(available, "LSP")
			break
		end
	end

	if #available == 0 then
		vim.notify("No formatters available for " .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end

	vim.ui.select(available, { prompt = "Select formatter:" }, function(choice)
		if not choice then
			return
		end
		if choice == "LSP" then
			vim.lsp.buf.format({ async = true })
			vim.notify("Formatted with LSP", vim.log.levels.INFO)
		else
			conform.format({ async = true, formatters = { choice } }, function(err)
				if err then
					vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
				else
					vim.notify("Formatted with " .. choice, vim.log.levels.INFO)
				end
			end)
		end
	end)
end, { desc = "Format buffer (choose formatter)" })
