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
vim.keymap.set("n", "<leader>qt", function()
	Snacks.bufdelete()
end, { desc = "Close buffer" })

vim.keymap.set("n", "<leader>qk", function()
	Snacks.bufdelete.all()
end, { desc = "Close all buffers" })

vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })

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

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- open urls
vim.keymap.set("n", "gx", ":!open <cfile><CR>", { desc = "Open URL under cursor" })

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
