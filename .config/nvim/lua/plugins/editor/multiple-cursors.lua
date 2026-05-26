return {
	"mg979/vim-visual-multi",
	{
		event = "VeryLazy",
		version = "master",
		setup = function()
			vim.g.VM_default_mappings = 0

			vim.g.VM_maps = {
				["Find Under"] = "<C-d>",
				["Find Subword Under"] = "<C-d>",
				["Add Cursor Down"] = "<A-j>",
				["Add Cursor Up"] = "<A-k>",
				["Skip Region"] = "q",
				["Remove Region"] = "Q",
				["Goto Next"] = "]",
				["Goto Prev"] = "[",
				["Select All"] = "<A-l>",
				["Visual All"] = "<A-l>",
				["Visual Cursors"] = "<A-c>",
				["Undo"] = "u",
				["Redo"] = "<C-r>",
			}

			vim.g.VM_theme = "iceblue"
			vim.g.VM_highlight_matches = "underline"
			vim.g.VM_silent_exit = 0
			vim.g.VM_show_warnings = 1

			vim.keymap.set("i", "<A-j>", function()
				vim.cmd("stopinsert")
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(VM-Add-Cursor-Down)", true, false, true))
			end, { desc = "Add cursor down (insert mode)" })

			vim.keymap.set("i", "<A-k>", function()
				vim.cmd("stopinsert")
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(VM-Add-Cursor-Up)", true, false, true))
			end, { desc = "Add cursor up (insert mode)" })
		end,
	},
}
