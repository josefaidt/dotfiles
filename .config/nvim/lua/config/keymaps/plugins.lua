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

-- Format with formatter picker
vim.keymap.set("n", "<leader>bF", function()
	local conform = require("conform")
	local ft = vim.bo.filetype
	local formatters = conform.list_formatters_by_ft(ft)

	-- Build a list of available formatters
	local available = {}
	for _, formatter in ipairs(formatters) do
		if type(formatter) == "string" then
			table.insert(available, formatter)
		elseif type(formatter) == "table" and formatter.name then
			table.insert(available, formatter.name)
		end
	end

	-- Add LSP formatting as an option if available
	local lsp_clients = vim.lsp.get_clients({ bufnr = 0 })
	local has_lsp_formatter = false
	for _, client in ipairs(lsp_clients) do
		if client.server_capabilities.documentFormattingProvider then
			has_lsp_formatter = true
			break
		end
	end
	if has_lsp_formatter then
		table.insert(available, "LSP")
	end

	if #available == 0 then
		vim.notify("No formatters available for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	-- Show picker
	vim.ui.select(available, {
		prompt = "Select formatter:",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if not choice then
			return
		end

		if choice == "LSP" then
			vim.lsp.buf.format({ async = true })
		else
			conform.format({
				async = true,
				formatters = { choice },
			})
		end
		vim.notify("Formatted with " .. choice, vim.log.levels.INFO)
	end)
end, { desc = "Format buffer (choose formatter)" })
