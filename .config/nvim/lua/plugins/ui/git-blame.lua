return {
	"f-person/git-blame.nvim",
	{
		event = "VeryLazy",
		setup = function()
			require("gitblame").setup({
				enabled = true,
				message_template = " <summary> • <date> • <author> • <<sha>>",
				date_format = "%m-%d-%Y %H:%M:%S",
				virtual_text_column = 1,
			})
		end,
	},
}
