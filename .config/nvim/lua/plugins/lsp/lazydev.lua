return {
	{ "Bilal2453/luvit-meta" },
	{
		"folke/lazydev.nvim",
		{
			ft = "lua",
			enabled = function()
				return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
			end,
			setup = function()
				require("lazydev").setup({
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
						{ path = "luvit-meta/library", words = { "vim%.uv" } },
					},
				})
			end,
		},
	},
}
