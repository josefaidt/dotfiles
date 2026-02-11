---@module 'config.keymaps.general'
---General keymaps that don't belong to specific plugins

-- leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- unset space bar in normal mode
vim.keymap.set("n", "<SPACE>", "<NOP>", { noremap = true })
-- set `jj` to escape from insert to normal
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc key is too far" })

-- buffer/tab management
---Close current buffer intelligently
---If multiple buffers exist, go to previous buffer then close
---If it's the last buffer, create a scratch buffer first
vim.keymap.set("n", "<leader>qt", function()
	local current_buf = vim.api.nvim_get_current_buf()
	local buffers = vim.api.nvim_list_bufs()

	-- Count listed buffers (exclude special buffers)
	local listed_count = 0
	for _, buf in ipairs(buffers) do
		if vim.fn.buflisted(buf) == 1 then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			if buftype == "" then
				listed_count = listed_count + 1
			end
		end
	end

	-- If this is the last buffer, create a scratch buffer first
	if listed_count <= 1 then
		vim.cmd("enew")
		vim.bo.buftype = "nofile"
		vim.bo.bufhidden = "wipe"
		vim.bo.swapfile = false
		vim.bo.modifiable = false
		vim.bo.buflisted = false
	else
		-- Multiple buffers exist, go to previous
		vim.cmd("bprevious")
	end

	-- Delete the original buffer
	vim.api.nvim_buf_delete(current_buf, { force = false })
end, { desc = "Close buffer" })
---Close all buffers except special ones (neo-tree, terminal, etc)
---Then show a non-editable scratch buffer
vim.keymap.set("n", "<leader>qk", function()
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if vim.fn.buflisted(buf) == 1 then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			-- Skip special buffers
			if buftype == "" then
				vim.api.nvim_buf_delete(buf, { force = false })
			end
		end
	end
	-- Create non-editable scratch buffer
	vim.cmd("enew")
	vim.bo.buftype = "nofile" -- Not associated with a file
	vim.bo.bufhidden = "wipe" -- Wipe buffer when hidden
	vim.bo.swapfile = false -- No swap file
	vim.bo.modifiable = false -- Make it non-editable
	vim.bo.buflisted = false -- Don't show in buffer list
end, { desc = "Close all buffers" })
vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })

-- buffer navigation removed - use Telescope <leader><leader> to find buffers

-- write file
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "write file" })

-- reload current buffer from disk (useful when external tools modify files)
vim.keymap.set("n", "<leader>br", function()
	vim.cmd("checktime")
	vim.notify("Buffer reloaded from disk", vim.log.levels.INFO)
end, { desc = "[B]uffer [R]eload from disk" })

-- LSP restart commands (useful when diagnostics don't refresh)
vim.keymap.set("n", "<leader>lr", function()
	vim.cmd("LspRestart")
	vim.notify("LSP restarted for current buffer", vim.log.levels.INFO)
end, { desc = "[L]SP [R]estart" })

vim.keymap.set("n", "<leader>ls", function()
	vim.cmd("LspStop")
	vim.schedule(function()
		vim.cmd("LspStart")
		vim.notify("All LSP clients restarted", vim.log.levels.INFO)
	end)
end, { desc = "[L]SP [S]top and start all" })

-- open lazy with ctrl+x
vim.keymap.set("n", "<C-x>", ":Lazy<CR>", { desc = "Open Lazy.nvim" })

---Theme picker using vim.ui.select
vim.keymap.set("n", "<leader>tt", function()
	---@type string[]
	local themes = {
		"everforest",
		"catppuccin",
		"catppuccin-latte",
		"catppuccin-frappe",
		"catppuccin-macchiato",
		"catppuccin-mocha",
		"rouge2",
	}

	vim.ui.select(
		themes,
		{
			prompt = "Select Theme:",
			---@param item string
			---@return string
			format_item = function(item)
				local current = vim.g.colors_name
				if item == current then
					return item .. " (current)"
				end
				return item
			end,
		}, ---@param choice? string
		function(choice)
			if choice then
				vim.cmd.colorscheme(choice)
				vim.notify("Switched to " .. choice, vim.log.levels.INFO)
			end
		end
	)
end, { desc = "Choose theme" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation removed - use Ctrl+h/j/k/l in Ghostty for pane navigation
-- Focus neo-tree
vim.keymap.set("n", "<leader>fe", ":Neotree focus<CR>", { desc = "Focus explorer" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- open urls
vim.keymap.set("n", "gx", ":!open <cfile><CR>", { desc = "Open URL under cursor" })

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
