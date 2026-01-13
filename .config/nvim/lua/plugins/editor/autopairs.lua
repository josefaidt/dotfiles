---@module 'plugins.editor.autopairs'
---Auto-closing brackets and quotes configuration

---@type LazySpec
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- Enable treesitter integration
		ts_config = {
			lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
			javascript = { "template_string" },
			typescript = { "template_string" },
		},
		-- Disable auto-pairs for certain filetypes
		disable_filetype = { "TelescopePrompt", "vim" },
	},
}
