return {
	"dkarter/bullets.vim",
	{
		ft = { "markdown", "text", "gitcommit" },
		setup = function()
			vim.g.bullets_enabled_file_types = {
				"markdown",
				"text",
				"gitcommit",
			}
			vim.g.bullets_enable_in_empty_buffers = 0
			vim.g.bullets_outline_levels = { "num", "abc", "std-" }
			vim.g.bullets_renumber_on_change = 1
			vim.g.bullets_pad_right = 1
			vim.g.bullets_nested_checkboxes = 1
			vim.g.bullets_mapping_leader = ""

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "text", "gitcommit" },
				callback = function()
					vim.opt_local.tabstop = 2
					vim.opt_local.softtabstop = 2
					vim.opt_local.shiftwidth = 2
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.breakindent = true
					vim.opt_local.breakindentopt = ""
					vim.opt_local.textwidth = 0
					vim.opt_local.wrapmargin = 0

					local opts = { buffer = true, silent = true }

					vim.keymap.set("n", "j", "gj", opts)
					vim.keymap.set("n", "k", "gk", opts)

					vim.keymap.set("n", "<leader>x", function()
						local line = vim.api.nvim_get_current_line()
						local row = vim.api.nvim_win_get_cursor(0)[1]

						if line:match("%- %[ %]") then
							local new_line = line:gsub("%- %[ %]", "- [x]", 1)
							vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
						elseif line:match("%- %[x%]") or line:match("%- %[X%]") then
							local new_line = line:gsub("%- %[[xX]%]", "- [ ]", 1)
							vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
						elseif line:match("^%s*%- ") then
							local new_line = line:gsub("(%s*%- )", "%1[ ] ", 1)
							vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
						end
					end, vim.tbl_extend("force", opts, { desc = "Toggle markdown checkbox" }))

					vim.keymap.set("i", "<Tab>", function()
						local line = vim.api.nvim_get_current_line()
						local row, col = unpack(vim.api.nvim_win_get_cursor(0))

						if line:match("^%s*%- ") or line:match("^%s*%d+%. ") then
							local new_line = "  " .. line
							new_line = new_line:gsub("^(%s*)%d+(%. )", "%11%2", 1)
							vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
							vim.api.nvim_win_set_cursor(0, { row, col + 2 })
						else
							vim.api.nvim_feedkeys("\t", "n", false)
						end
					end, vim.tbl_extend("force", opts, { desc = "Indent markdown list item" }))

					vim.keymap.set("i", "<S-Tab>", function()
						local line = vim.api.nvim_get_current_line()
						local row, col = unpack(vim.api.nvim_win_get_cursor(0))

						if line:match("^%s*%- ") or line:match("^%s*%d+%. ") then
							local new_line, removed = line:gsub("^  ", "", 1)
							if removed > 0 then
								new_line = new_line:gsub("^(%s*)%d+(%. )", "%11%2", 1)
								vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
								vim.api.nvim_win_set_cursor(0, { row, math.max(0, col - 2) })
							end
						end
					end, vim.tbl_extend("force", opts, { desc = "Dedent markdown list item" }))
				end,
			})
		end,
	},
}
