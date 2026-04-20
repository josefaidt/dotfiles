---@module 'config.keymaps.general'
---General keymaps that don't belong to specific plugins

-- leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- unset space bar in normal mode
vim.keymap.set("n", "<SPACE>", "<NOP>", { noremap = true })
-- set `jj` to escape from insert to normal
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc key is too far" })

-- buffer/tab management (using snacks.nvim for smart buffer deletion)
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "[B]uffer [D]elete" })

vim.keymap.set("n", "<leader>bD", function()
	Snacks.bufdelete.all()
end, { desc = "[B]uffer [D]elete all" })

vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

-- buffer navigation
-- Jump to last buffer (like Alt+Tab in other editors)
vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Jump to last buffer" })
-- Jump back to last position in jumplist (like Ctrl+- in VSCode)
vim.keymap.set("n", "<C-->", "<C-o>", { desc = "Jump to previous position" })
-- Jump forward in jumplist
vim.keymap.set("n", "<C-=>", "<C-i>", { desc = "Jump to next position" })

-- write file
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "write file" })

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
vim.keymap.set("n", "<C-x>", "<cmd>Lazy<CR>", { desc = "Open Lazy.nvim" })

---Theme picker using vim.ui.select
vim.keymap.set("n", "<leader>uc", function()
	---@type string[]
	local themes = {
		"mellow",
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
end, { desc = "[U]I: [C]hoose colorscheme/theme" })

-- Settings toggles (<leader>us)
vim.keymap.set("n", "<leader>ush", function()
	vim.g.lsp_auto_hover = not vim.g.lsp_auto_hover
	vim.notify("LSP auto-hover " .. (vim.g.lsp_auto_hover and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "[U]I [S]ettings: toggle LSP auto-[h]over" })

-- Set filetype/language for current buffer (for syntax highlighting of non-standard files)
vim.keymap.set("n", "<leader>uL", function()
	-- Collect installed Treesitter parsers as the language list
	local parsers = require("nvim-treesitter.parsers")
	local langs = vim.tbl_keys(parsers.get_parser_configs())
	table.sort(langs)

	vim.ui.select(langs, {
		prompt = "Set language:",
		format_item = function(item)
			if item == vim.bo.filetype then
				return item .. " (current)"
			end
			return item
		end,
	}, function(choice)
		if choice then
			vim.bo.filetype = choice
			vim.notify("Filetype set to " .. choice, vim.log.levels.INFO)
		end
	end)
end, { desc = "[U]I: Set buffer [L]anguage/filetype" })

-- Diagnostic keymaps (global so they work with linters, not just LSP)
vim.keymap.set("n", "<leader>e", function()
	local winid = vim.diagnostic.open_float()
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_set_current_win(winid)
	end
end, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Clear highlights on search and close floating windows when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", function()
	-- Clear search highlights
	vim.cmd("nohlsearch")
	-- Close all floating windows
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, false)
		end
	end
	-- Suppress auto-show at current cursor position
	if _G.suppress_lsp_auto_show then
		_G.suppress_lsp_auto_show()
	end
end)

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation removed - use Ctrl+h/j/k/l in Ghostty for pane navigation

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- open urls
vim.keymap.set("n", "gx", ":!open <cfile><CR>", { desc = "Open URL under cursor" })

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
