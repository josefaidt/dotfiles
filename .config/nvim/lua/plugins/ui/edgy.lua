---@module 'plugins.ui.edgy'
---Edgy.nvim - Manage neo-tree positioning and prevent it from taking over the window
---https://github.com/folke/edgy.nvim

---@type LazySpec
return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.laststatus = 3
		vim.opt.splitkeep = "screen"
	end,
	---@type table<string, fun(win:Edgy.Window)|false>
	keys = {
		-- Jump to main editor window
		{
			"<leader>fd",
			function()
				require("edgy").goto_main()
			end,
			desc = "Focus editor",
		},
	},
	opts = {
		---@type (Edgy.View.Opts|string)[]
		right = {
			-- Neo-tree file explorer on the right
			{
				title = "Files",
				ft = "neo-tree",
				filter = function(buf)
					return vim.b[buf].neo_tree_source == "filesystem"
				end,
				size = { width = 30 },
			},
		},
		-- Disable animations for better performance
		---@type Edgy.Animate
		animate = {
			enabled = false,
		},
		-- Disable edgy's custom window highlights to preserve neo-tree's original appearance
		---@type vim.wo
		wo = {
			winhighlight = "",
		},
	},
}
