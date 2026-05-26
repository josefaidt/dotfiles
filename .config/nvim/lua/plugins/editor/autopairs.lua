return {
	"windwp/nvim-autopairs",
	{
		event = "InsertEnter",
		setup = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
					typescript = { "template_string" },
				},
				disable_filetype = { "TelescopePrompt", "vim" },
			})

			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")

			npairs.add_rules({
				Rule("/*", "*/", { "javascript", "typescript", "javascriptreact", "typescriptreact" })
					:with_pair(cond.not_before_text("/")),
			})
		end,
	},
}
