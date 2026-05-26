-- Disabled in favor of buffer-search workflow; kept here in case it's re-enabled.
return {
	"akinsho/bufferline.nvim",
	{
		enabled = false,
		event = "VeryLazy",
		setup = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					themable = true,
					numbers = "none",
					close_command = function(bufnum)
						local buffers = vim.tbl_filter(function(b)
							return vim.fn.buflisted(b) == 1
						end, vim.api.nvim_list_bufs())

						if #buffers <= 1 then
							vim.cmd("bdelete! " .. bufnum)
							return
						end

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
						local buffers = vim.tbl_filter(function(b)
							return vim.fn.buflisted(b) == 1
						end, vim.api.nvim_list_bufs())

						if #buffers <= 1 then
							vim.cmd("bdelete! " .. bufnum)
							return
						end

						for i, b in ipairs(buffers) do
							if b == bufnum then
								local next_buf = buffers[i % #buffers + 1]
								vim.cmd("buffer " .. next_buf)
								vim.cmd("bdelete! " .. bufnum)
								return
							end
						end
					end,
					left_mouse_command = "buffer %d",
					middle_mouse_command = nil,
					indicator = {
						icon = "▎",
						style = "icon",
					},
					buffer_close_icon = "󰅖",
					modified_icon = "●",
					close_icon = "",
					left_trunc_marker = "",
					right_trunc_marker = "",
					max_name_length = 22,
					max_prefix_length = 15,
					truncate_names = true,
					tab_size = 24,
					diagnostics = "nvim_lsp",
					diagnostics_update_in_insert = false,
					diagnostics_indicator = function(count, level, diagnostics_dict, context)
						local icon = level:match("error") and " " or " "
						return " " .. icon .. count
					end,
					offsets = {
						{
							filetype = "neo-tree",
							text = "",
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
					persist_buffer_sort = true,
					separator_style = "thin",
					enforce_regular_tabs = false,
					always_show_bufferline = true,
					hover = {
						enabled = true,
						delay = 200,
						reveal = { "close" },
					},
					sort_by = "insert_after_current",
				},
				highlights = {
					buffer_selected = { italic = false },
					buffer_visible = { italic = false },
					numbers_selected = { italic = false },
					diagnostic_selected = { italic = false },
					hint_selected = { italic = false },
					info_selected = { italic = false },
					warning_selected = { italic = false },
					error_selected = { italic = false },
				},
			})
		end,
	},
}
