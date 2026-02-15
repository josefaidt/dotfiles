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
	config = function(_, opts)
		local npairs = require("nvim-autopairs")
		npairs.setup(opts)

		-- Add custom rule for multiline comments in JS/TS
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")

		-- Rule for /* */ comments with proper multiline formatting
		npairs.add_rules({
			Rule("/*", "*/", { "javascript", "typescript", "javascriptreact", "typescriptreact" })
				:with_pair(cond.not_before_text("/")), -- Don't trigger on ///
		})
	end,
}
