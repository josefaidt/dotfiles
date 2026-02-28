---@module 'plugins.editor.session'
---Auto-session configuration for automatic session management

---@type LazySpec
return {
	"rmagatti/auto-session",
	lazy = false,
	config = function()
		-- Extend sessionoptions so the active buffer, window positions, and
		-- local options are all captured and restored correctly.
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

		require("auto-session").setup({
			log_level = "error",
			suppressed_dirs = { "~/", "~/Downloads", "/" },
		})
	end,
}
