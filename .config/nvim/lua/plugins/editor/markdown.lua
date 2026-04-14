---@module 'plugins.editor.markdown'
---Markdown enhancements including auto-continuing lists

---@type LazySpec
return {
	"dkarter/bullets.vim",
	ft = { "markdown", "text", "gitcommit" },
	init = function()
		-- Enable bullets.vim for specific file types
		vim.g.bullets_enabled_file_types = {
			"markdown",
			"text",
			"gitcommit",
		}
		-- Don't enable in empty buffers
		vim.g.bullets_enable_in_empty_buffers = 0
		-- Configure outline levels: numbered, alphabetic, standard dash
		vim.g.bullets_outline_levels = { "num", "abc", "std-" }
		-- Enable automatic renumbering of ordered lists
		vim.g.bullets_renumber_on_change = 1
		-- Pad spaces in front of bullets
		vim.g.bullets_pad_right = 1
		-- Enable nested indentation
		vim.g.bullets_nested_checkboxes = 1
		-- Use <Tab> for indenting, <S-Tab> for dedenting
		vim.g.bullets_mapping_leader = ""
	end,
	config = function()
		-- Markdown-specific settings and keybindings
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "text", "gitcommit" },
			callback = function()
				-- For markdown, we want wrapped lines to continue at the same indent as the list item
				-- but without the extra "shift". This makes prose wrap cleanly while lists maintain
				-- proper indentation for wrapped content.
				vim.opt_local.breakindent = true
				vim.opt_local.breakindentopt = ""
				vim.opt_local.linebreak = true

				local opts = { buffer = true, silent = true }

				-- Toggle checkbox: <leader>x or <C-Space> in normal mode
				vim.keymap.set("n", "<leader>x", function()
					local line = vim.api.nvim_get_current_line()
					local row = vim.api.nvim_win_get_cursor(0)[1]

					-- Check if line contains a checkbox
					if line:match("%- %[ %]") then
						-- Unchecked -> Checked
						local new_line = line:gsub("%- %[ %]", "- [x]", 1)
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
					elseif line:match("%- %[x%]") or line:match("%- %[X%]") then
						-- Checked -> Unchecked
						local new_line = line:gsub("%- %[[xX]%]", "- [ ]", 1)
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
					elseif line:match("^%s*%- ") then
						-- Regular list item -> Add checkbox
						local new_line = line:gsub("(%s*%- )", "%1[ ] ", 1)
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
					end
				end, vim.tbl_extend("force", opts, { desc = "Toggle markdown checkbox" }))

				-- Tab to indent list item (works regardless of cursor position within the line)
				vim.keymap.set("i", "<Tab>", function()
					local line = vim.api.nvim_get_current_line()
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))

					if line:match("^%s*%- ") or line:match("^%s*%d+%. ") then
						-- Prepend two spaces, keep cursor at same text offset
						local new_line = "  " .. line
						vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
						vim.api.nvim_win_set_cursor(0, { row, col + 2 })
					else
						-- Default tab behavior
						vim.api.nvim_feedkeys("\t", "n", false)
					end
				end, vim.tbl_extend("force", opts, { desc = "Indent markdown list item" }))

				-- Shift-Tab to dedent list item (works regardless of cursor position within the line)
				vim.keymap.set("i", "<S-Tab>", function()
					local line = vim.api.nvim_get_current_line()
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))

					if line:match("^%s*%- ") or line:match("^%s*%d+%. ") then
						local new_line, removed = line:gsub("^  ", "", 1)
						if removed > 0 then
							vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
							vim.api.nvim_win_set_cursor(0, { row, math.max(0, col - 2) })
						end
					end
				end, vim.tbl_extend("force", opts, { desc = "Dedent markdown list item" }))
			end,
		})
	end,
}
