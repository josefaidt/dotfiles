return {
	{
		"mellow-theme/mellow.nvim",
		{
			priority = 1001,
			setup = function()
				vim.g.mellow_italic_keywords = false

				-- YAML keys map to @property, which mellow sets to gray07 (#c1c0d4) —
				-- nearly identical to fg (#c9c7cd), making them look unstyled.
				-- Override to use a distinct color so keys are visually differentiated.
				vim.g.mellow_highlight_overrides = {
					["@property.yaml"] = { fg = "#aca1cf" }, -- blue (mellow's c.blue)
				}

				vim.cmd.colorscheme("mellow")

				-- Selective keyword italics to match catppuccin's approach
				local italic = { italic = true }
				for _, group in ipairs({
					"@keyword.conditional",
					"@keyword.repeat",
					"@keyword.import",
					"@keyword.return",
					"@keyword.function",
					"@keyword.operator",
					"@keyword.modifier",
					"@keyword.type",
				}) do
					local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
					vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", hl, italic))
				end
			end,
		},
	},
	{
		"sainnhe/everforest",
		{
			priority = 1000,
			setup = function()
				-- Available values: 'hard', 'medium' (default), 'soft'
				vim.g.everforest_background = "hard"
				vim.g.everforest_better_performance = 1
				vim.g.everforest_enable_italic = 1
				-- Transparent background (set to 1 if you want transparency)
				vim.g.everforest_transparent_background = 0
				vim.g.everforest_ui_contrast = "high"
				vim.g.everforest_dim_inactive_windows = 0
				vim.g.everforest_diagnostic_text_highlight = 1
				vim.g.everforest_diagnostic_line_highlight = 0
				vim.g.everforest_diagnostic_virtual_text = "colored"
				-- Mellow is the default; this just makes the colorscheme available.
			end,
		},
	},
	{
		"catppuccin/nvim",
		{
			name = "catppuccin",
			priority = 999,
			setup = function()
				require("catppuccin").setup({
					flavour = "mocha",
					styles = {
						comments = { "italic" },
						keywords = {},
						functions = {},
						variables = {},
					},
					custom_highlights = function(colors)
						return {
							["@keyword.conditional"] = { style = { "italic" } },
							["@keyword.repeat"] = { style = { "italic" } },
							["@keyword.import"] = { style = { "italic" } },
							["@keyword.return"] = { style = { "italic" } },
							["@keyword.function"] = { style = { "italic" } },
							["@keyword.operator"] = { style = { "italic" } },
							["@keyword.modifier"] = { style = { "italic" } },
							["@keyword.type"] = { style = { "italic" } },
						}
					end,
				})
			end,
		},
	},
}
