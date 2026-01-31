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

			-- Enable italic for comments only (not all keywords)
			-- We'll configure language-specific keyword italics below
			vim.g.everforest_enable_italic = 0

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

			-- Configure italics for comments globally
			vim.api.nvim_set_hl(0, "Comment", { italic = true })

			-- Configure language-specific keyword italics
			-- Only apply italics to actual language keywords in JS/TS files
			local keyword_groups = {
				"@keyword.conditional", -- if, else, switch
				"@keyword.repeat", -- for, while, do
				"@keyword.import", -- import, export
				"@keyword.return",
				"@keyword.function", -- function, async (when it's a keyword)
				"@keyword.operator", -- typeof, instanceof
				"@keyword.modifier", -- const, let, var, static
			}

			-- Apply italic only to these specific treesitter groups
			for _, group in ipairs(keyword_groups) do
				vim.api.nvim_set_hl(0, group, { italic = true })
			end

			-- Ensure @lsp.type.keyword does NOT get italics (this affects JSON and other contexts)
			vim.api.nvim_set_hl(0, "@lsp.type.keyword", { italic = false })

			-- Normalize function colors - use the same color for all function types
			-- This addresses the Vitest vs builtin function color issue
			local function_color = vim.api.nvim_get_hl(0, { name = "@function", link = false })
			if function_color then
				vim.api.nvim_set_hl(0, "@function.builtin", function_color)
				vim.api.nvim_set_hl(0, "@function.call", function_color)
				vim.api.nvim_set_hl(0, "@function.method", function_color)
				vim.api.nvim_set_hl(0, "@function.method.call", function_color)
				vim.api.nvim_set_hl(0, "@lsp.type.function", function_color)
				vim.api.nvim_set_hl(0, "@lsp.type.method", function_color)
			end

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
					-- Don't italicize all keywords globally
					keywords = {},
					functions = {},
					variables = {},
				},
				custom_highlights = function(colors)
					return {
						-- Only italicize specific keyword types
						["@keyword.conditional"] = { style = { "italic" } },
						["@keyword.repeat"] = { style = { "italic" } },
						["@keyword.import"] = { style = { "italic" } },
						["@keyword.return"] = { style = { "italic" } },
						["@keyword.function"] = { style = { "italic" } },
						["@keyword.operator"] = { style = { "italic" } },
						["@keyword.modifier"] = { style = { "italic" } },
					}
				end,
			})
		end,
	},
}
