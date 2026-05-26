return {
	"folke/flash.nvim",
	{
		event = "VeryLazy",
		opts = {
			search = {
				mode = "search",
				incremental = false,
			},
			label = {
				rainbow = {
					enabled = true,
				},
			},
			modes = {
				search = {
					enabled = true,
				},
			},
		},
		setup = function(opts)
			require("flash").setup(opts)
		end,
		keys = {
			{
				"s",
				function()
					require("flash").jump()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash Jump",
			},
			{
				"S",
				function()
					require("flash").treesitter()
				end,
				mode = { "n", "x", "o" },
				desc = "Flash Treesitter",
			},
			{
				"r",
				function()
					require("flash").remote()
				end,
				mode = "o",
				desc = "Remote Flash",
			},
			{
				"R",
				function()
					require("flash").treesitter_search()
				end,
				mode = { "o", "x" },
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				function()
					require("flash").toggle()
				end,
				mode = "c",
				desc = "Toggle Flash Search",
			},
		},
	},
}
