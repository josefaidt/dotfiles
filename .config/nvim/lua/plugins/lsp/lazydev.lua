---@module 'plugins.lsp.lazydev'
---Lazydev configuration for proper Lua LSP setup with Neovim API support
return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
			-- Add lazy.nvim types
			{ path = "lazy.nvim", words = { "LazySpec", "LazyPlugin" } },
		},
	},
	dependencies = {
		{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	},
}
