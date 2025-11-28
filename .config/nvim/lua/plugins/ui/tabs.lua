-- bufferline.nvim - VSCode-like tabs for buffers
-- https://github.com/akinsho/bufferline.nvim

return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	-- lazy = false, -- Load immediately so global functions are available for neo-tree
	opts = {
		options = {
			mode = "buffers", -- set to "tabs" to only show tabpages instead
			themable = true,
			numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
			close_command = function(bufnum)
				-- Get list of all listed buffers
				local buffers = vim.tbl_filter(function(b)
					return vim.fn.buflisted(b) == 1
				end, vim.api.nvim_list_bufs())

				-- If this is the only buffer, just delete it
				if #buffers <= 1 then
					vim.cmd("bdelete! " .. bufnum)
					return
				end

				-- Find the next buffer to switch to
				for i, b in ipairs(buffers) do
					if b == bufnum then
						local next_buf = buffers[i % #buffers + 1]
						vim.cmd("buffer " .. next_buf)
						vim.cmd("bdelete! " .. bufnum)
						return
					end
				end
			end,
			right_mouse_command = function(bufnum)
				-- Get list of all listed buffers
				local buffers = vim.tbl_filter(function(b)
					return vim.fn.buflisted(b) == 1
				end, vim.api.nvim_list_bufs())

				-- If this is the only buffer, just delete it
				if #buffers <= 1 then
					vim.cmd("bdelete! " .. bufnum)
					return
				end

				-- Find the next buffer to switch to
				for i, b in ipairs(buffers) do
					if b == bufnum then
						local next_buf = buffers[i % #buffers + 1]
						vim.cmd("buffer " .. next_buf)
						vim.cmd("bdelete! " .. bufnum)
						return
					end
				end
			end,
			left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
			middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
			indicator = {
				icon = "▎", -- this should be omitted if indicator style is not 'icon'
				style = "icon", -- | 'underline' | 'none',
			},
			buffer_close_icon = "󰅖",
			modified_icon = "●",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",
			max_name_length = 18,
			max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
			truncate_names = true, -- whether or not tab names should be truncated
			tab_size = 18,
			diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc",
			diagnostics_update_in_insert = false,
			-- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			offsets = {
				{
					filetype = "neo-tree",
					-- text = function()
					-- 	return _G.__get_selector() or ""
					-- end,
					-- text_align = "center",
					-- raw = " %{%v:lua.__get_selector()%} ",
					text = "", -- Leave empty since Neo-tree's winbar will fill it
					text_align = "left",
					separator = true,
				},
			},
			color_icons = false,
			show_buffer_icons = true,
			show_buffer_close_icons = true,
			show_close_icon = true,
			show_tab_indicators = true,
			show_duplicate_prefix = true,
			persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
			separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
			enforce_regular_tabs = false,
			always_show_bufferline = true,
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			sort_by = "insert_after_current", -- | 'insert_after_current' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
		},
		highlights = {
			buffer_selected = {
				italic = false,
			},
			buffer_visible = {
				italic = false,
			},
			numbers_selected = {
				italic = false,
			},
			diagnostic_selected = {
				italic = false,
			},
			hint_selected = {
				italic = false,
			},
			info_selected = {
				italic = false,
			},
			warning_selected = {
				italic = false,
			},
			error_selected = {
				italic = false,
			},
		},
	},
}
