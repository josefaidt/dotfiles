return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false, -- Load immediately to avoid flash
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			styles = {
				comments = { "italic" },
				keywords = { "italic" },
				functions = {},
				variables = {},
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
