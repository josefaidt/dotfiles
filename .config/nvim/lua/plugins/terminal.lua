return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		-- open_mapping = [[<leader>t]],
		open_mapping = [[<C-\>]],
		direction = "vertical", -- Changed to vertical as default
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.3 -- 40% of screen width
			end
		end,
		float_opts = {
			border = "curved",
		},
	},
	config = function(_, opts)
		--   require("toggleterm").setup(opts)

		--   -- Additional keybind for floating terminal
		--   vim.keymap.set('n', '<leader>to', ':ToggleTerm direction=float<CR>', { desc = 'Toggle floating terminal' })
	end,
}
