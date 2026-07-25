---@type LazySpec
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		-- How the `s`/`S` jump keys interpret what you type: "search" = regex.
		search = {
			mode = "search",
			incremental = false,
		},
		-- Rainbow-colored jump labels for `s`/`S`.
		label = {
			rainbow = {
				enabled = true,
			},
		},
		modes = {
			-- Disable flash labels during regular `/` and `?` search. The label
			-- workflow (type a label char instead of <CR> to jump) conflicts with
			-- normal search-then-<CR> muscle memory — pressing <CR> just clears
			-- the labels, so it added flicker without value. Flash jumping stays
			-- on the dedicated `s`/`S` keys below.
			search = {
				enabled = false,
			},
		},
	},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
	},
	specs = {
		{
			"folke/snacks.nvim",
			opts = {
				picker = {
					win = {
						input = {
							keys = {
								["<a-s>"] = { "flash", mode = { "n", "i" } },
								["s"] = { "flash" },
							},
						},
					},
					actions = {
						flash = function(picker)
							require("flash").jump({
								pattern = "^",
								label = { after = { 0, 0 } },
								search = {
									mode = "search",
									exclude = {
										function(win)
											return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
												~= "snacks_picker_list"
										end,
									},
								},
								action = function(match)
									local idx = picker.list:row2idx(match.pos[1])
									picker.list:_move(idx, true, true)
								end,
							})
						end,
					},
				},
			},
		},
	},
}
