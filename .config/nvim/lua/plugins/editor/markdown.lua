---@module 'plugins.editor.markdown'
---Markdown enhancements including auto-continuing lists
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
	end,
}
