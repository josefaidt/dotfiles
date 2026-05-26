return {
	"numToStr/Comment.nvim",
	{
		event = { "BufReadPre", "BufNewFile" },
		setup = function()
			require("Comment").setup({
				padding = true,
				sticky = true,
				ignore = "^$",
			})

			local api = require("Comment.api")

			vim.keymap.set("n", "<leader>m", function()
				api.toggle.linewise.current()
			end, { desc = "Toggle comment" })

			vim.keymap.set("v", "<leader>m", function()
				local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
				vim.api.nvim_feedkeys(esc, "nx", false)
				api.toggle.linewise(vim.fn.visualmode())
			end, { desc = "Toggle comment" })
		end,
	},
}
