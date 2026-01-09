-- General keymaps that don't belong to specific plugins

-- leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- unset space bar in normal mode
vim.keymap.set("n", "<SPACE>", "<NOP>", { noremap = true })
-- set `jj` to escape from insert to normal
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc key is too far" })

-- buffer/tab management
vim.keymap.set("n", "<leader>qt", ":bp | bd #<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>qk", function()
	-- Close all buffers except special ones (neo-tree, terminal, etc)
	-- Then show an empty buffer like VSCode
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if vim.fn.buflisted(buf) == 1 then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
			-- Skip special buffers
			if buftype == "" and filetype ~= "neo-tree" then
				vim.api.nvim_buf_delete(buf, { force = false })
			end
		end
	end
	-- Create empty buffer to prevent neo-tree from maximizing
	vim.cmd("enew")
end, { desc = "Close all buffers" })
vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit Neovim" })

-- buffer navigation (tabs)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer" })

-- write file
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "write file" })

-- open lazy with ctrl+x
vim.keymap.set("n", "<C-x>", ":Lazy<CR>", { desc = "Open Lazy.nvim" })

-- theme picker
vim.keymap.set("n", "<leader>tt", function()
	local themes = {
		"everforest",
		"catppuccin",
		"catppuccin-latte",
		"catppuccin-frappe",
		"catppuccin-macchiato",
		"catppuccin-mocha",
		"rouge2",
	}

	vim.ui.select(themes, {
		prompt = "Select Theme:",
		format_item = function(item)
			local current = vim.g.colors_name
			if item == current then
				return item .. " (current)"
			end
			return item
		end,
	}, function(choice)
		if choice then
			vim.cmd.colorscheme(choice)
			vim.notify("Switched to " .. choice, vim.log.levels.INFO)
		end
	end)
end, { desc = "Choose theme" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Terminal mode window navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to window below" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to window above" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- open urls
vim.keymap.set("n", "gx", ":!open <cfile><CR>", { desc = "Open URL under cursor" })

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
