---@module 'plugins.ui.diffview'
---DiffView for git diffs and file history
return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{
			"<leader>gd",
			"<cmd>DiffviewOpen<CR>",
			desc = "[G]it [D]iff view",
		},
		{
			"<leader>gh",
			"<cmd>DiffviewFileHistory %<CR>",
			desc = "[G]it file [H]istory",
		},
		{
			"<leader>gq",
			"<cmd>DiffviewClose<CR>",
			desc = "[G]it diff [Q]uit/close",
		},
	},
	opts = {
		enhanced_diff_hl = true, -- Better syntax highlighting in diffs
		view = {
			default = {
				layout = "diff2_horizontal",
			},
			merge_tool = {
				layout = "diff3_horizontal",
			},
		},
	},
}
