return {
	"folke/edgy.nvim",
	{
		event = "VeryLazy",
		keys = {
			{
				"<leader>ue",
				function()
					require("edgy").goto_main()
				end,
				desc = "Focus editor (from drawer)",
			},
		},
		setup = function()
			vim.opt.laststatus = 3
			vim.opt.splitkeep = "screen"

			require("edgy").setup({
				right = {
					{
						title = "Files",
						ft = "neo-tree",
						filter = function(buf)
							return vim.b[buf].neo_tree_source == "filesystem"
						end,
						size = { width = 30 },
					},
				},
				animate = {
					enabled = false,
				},
				wo = {
					winhighlight = "",
				},
			})
		end,
	},
}
