---@module 'plugins.ui.theme'
---Theme configuration for Everforest and Catppuccin

---@type LazySpec[]
return {
	-- Everforest theme
	{
		"sainnhe/everforest",
		priority = 1000,
		lazy = false, -- Load immediately to avoid flash
		config = function()
			-- Everforest configuration
			-- Available values: 'hard', 'medium'(default), 'soft'
			vim.g.everforest_background = "hard"

			-- For better performance
			vim.g.everforest_better_performance = 1

			-- Enable italic for comments and keywords
			vim.g.everforest_enable_italic = 1

			-- Transparent background (set to 1 if you want transparency)
			vim.g.everforest_transparent_background = 0

			-- UI related
			vim.g.everforest_ui_contrast = "high" -- 'low', 'high'

			-- Dim inactive windows
			vim.g.everforest_dim_inactive_windows = 0

			-- Diagnostic style: 'default' or 'colored'
			vim.g.everforest_diagnostic_text_highlight = 1
			vim.g.everforest_diagnostic_line_highlight = 0
			vim.g.everforest_diagnostic_virtual_text = "colored"

			-- Load the colorscheme (default theme)
			vim.cmd.colorscheme("everforest")

			-- Dim shebang lines at the top of executables (use comment theming)
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { "*.sh", "*.bash", "*.zsh", "*.py", "*.rb", "*.pl", "*" },
				callback = function()
					-- Create syntax match for shebang lines
					vim.cmd([[
						syntax match Shebang /\%^#!.*/
						highlight link Shebang Comment
					]])
				end,
			})
		end,
	},
	-- Catppuccin theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 999, -- Slightly lower priority than default theme
		lazy = false,
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
		end,
	},
}
