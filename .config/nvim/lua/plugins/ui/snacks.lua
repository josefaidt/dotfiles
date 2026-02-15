---@module 'plugins.ui.snacks'
---Snacks.nvim - Collection of useful utilities from folke

---@type LazySpec
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- Enable the features you want
		bufdelete = { enabled = true }, -- Smart buffer deletion
		quickfile = { enabled = true }, -- Fast loading for small files
		words = { enabled = true }, -- Highlight references under cursor
		statuscolumn = { enabled = false }, -- Using default for now
		dashboard = { enabled = false }, -- Disabled for now
		notifier = { enabled = false }, -- Using nvim-notify instead
		explorer = { enabled = false }, -- Disabled - using neotree instead
	},
}
