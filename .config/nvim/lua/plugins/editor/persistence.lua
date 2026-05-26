return {
	"folke/persistence.nvim",
	{
		event = "BufReadPre",
		opts = {
			need = 1,
		},
		setup = function(opts)
			require("persistence").setup(opts)
		end,
	},
}
