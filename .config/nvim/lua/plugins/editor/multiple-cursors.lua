---@module 'plugins.editor.multiple-cursors'
---Multiple cursors plugin for VSCode-like editing experience

---@type LazySpec
return {
	"mg979/vim-visual-multi",
	branch = "master",
	event = "VeryLazy",
	init = function()
		-- Disable default mappings (we'll set custom ones)
		vim.g.VM_default_mappings = 0

		-- Custom mappings for VSCode-like experience
		-- Using Alt+j/k since Ctrl+Alt is taken by window manager
		vim.g.VM_maps = {
			-- Find/Select word under cursor (like Ctrl+D in VSCode)
			["Find Under"] = "<C-d>",
			["Find Subword Under"] = "<C-d>",

			-- Add cursor above/below with Alt+j/k
			["Add Cursor Down"] = "<A-j>",
			["Add Cursor Up"] = "<A-k>",

			-- Skip current and get next occurrence
			["Skip Region"] = "q",
			["Remove Region"] = "Q",

			-- Navigate between cursors
			["Goto Next"] = "]",
			["Goto Prev"] = "[",

			-- Select all occurrences
			["Select All"] = "<A-l>",
			["Visual All"] = "<A-l>",

			-- Start/End visual-multi mode
			["Visual Cursors"] = "<A-c>",

			-- Undo/Redo in multi-cursor mode
			["Undo"] = "u",
			["Redo"] = "<C-r>",
		}

		-- Plugin settings
		vim.g.VM_theme = "iceblue" -- or 'ocean', 'sand', 'purplegray'
		vim.g.VM_highlight_matches = "underline" -- or 'hi', 'underline', 'red'

		-- Show notifications
		vim.g.VM_silent_exit = 0
		vim.g.VM_show_warnings = 1
	end,
	config = function()
		-- Add keymaps that work in insert mode (like VSCode)
		-- Exit insert mode, trigger VM action, stay in VM mode
		vim.keymap.set("i", "<A-j>", function()
			-- Exit insert mode and add cursor down
			vim.cmd("stopinsert")
			vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(VM-Add-Cursor-Down)", true, false, true))
		end, { desc = "Add cursor down (insert mode)" })

		vim.keymap.set("i", "<A-k>", function()
			-- Exit insert mode and add cursor up
			vim.cmd("stopinsert")
			vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(VM-Add-Cursor-Up)", true, false, true))
		end, { desc = "Add cursor up (insert mode)" })
	end,
}
