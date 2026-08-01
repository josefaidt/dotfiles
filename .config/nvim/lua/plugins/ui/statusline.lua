---@module 'plugins.ui.statusline'
---Mini.nvim collection including statusline, surround, and text objects

---@type LazySpec
return {
	"echasnovski/mini.nvim",
	event = "VeryLazy",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		require("mini.surround").setup()

		local statusline = require("mini.statusline")
		statusline.setup({
			use_icons = vim.g.have_nerd_font,
			content = {
				-- Minimal layout: mode (single letter) | git | diagnostics | filename … location
				-- Deliberately omits the fileinfo block (encoding/format/filetype).
				active = function()
					local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
					local git = statusline.section_git({ trunc_width = 40 })
					local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
					local filename = statusline.section_filename({ trunc_width = 140 })
					local location = statusline.section_location({ trunc_width = 75 })

					return statusline.combine_groups({
						{ hl = mode_hl, strings = { mode:sub(1, 1):upper() } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
						"%<", -- truncate from here if the line is too long
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=", -- right-align what follows
						{ hl = mode_hl, strings = { location } },
					})
				end,
			},
		})

		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
