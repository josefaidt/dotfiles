---@module 'plugins.editor.session'
---Auto-session configuration for automatic session management

---@type LazySpec
return {
	"rmagatti/auto-session",
	lazy = false,
	config = function()
		-- Extend sessionoptions so the active buffer, window positions, and
		-- local options are all captured and restored correctly.
		-- localoptions excluded: it saves the winbar string (%{v:lua.dropbar()}) which
		-- Neovim evaluates on restore before dropbar has loaded, causing a nil error.
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

		require("auto-session").setup({
			log_level = "error",
			suppressed_dirs = { "~/", "~/Downloads", "/" },
			-- Open mini.starter only when there is no session to restore
			no_restore_cmds = { "lua require('mini.starter').open()" },
			-- Before saving, wipe buffers whose files no longer exist so they
			-- aren't restored into the next session.
			pre_save_cmds = {
				function()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
							local name = vim.api.nvim_buf_get_name(buf)
							if name ~= "" and vim.fn.filereadable(name) == 0 then
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end
					end
				end,
			},
		})
	end,
}
