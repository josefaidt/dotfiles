---@module 'plugins.lsp.lazydev'
---Lazydev configuration for proper Lua LSP setup with Neovim API support

---@type LazySpec
return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- Always load the Neovim runtime and all plugins for full `vim` API support
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			-- Load luvit types when the `vim.uv` word is found
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
			-- Add lazy.nvim types
			{ path = "lazy.nvim", words = { "LazySpec", "LazyPlugin" } },
			-- Load full Neovim runtime for vim global
			{ path = "LazyVim", words = { "LazyVim" } },
		},
		-- Always enable for Neovim config files
		enabled = function(root_dir)
			return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
		end,
	},
	dependencies = {
		{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	},
}
