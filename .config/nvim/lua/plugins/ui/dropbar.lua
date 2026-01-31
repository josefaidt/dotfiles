---@module 'plugins.ui.dropbar'
---IDE-like breadcrumbs winbar with drop-down menus for context-aware navigation

---@type LazySpec
return {
	"Bekaboo/dropbar.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- For file type icons
	},
	event = "VeryLazy",
	keys = {
		{
			"<leader>db",
			function()
				require("dropbar.api").pick()
			end,
			desc = "[D]rop[b]ar pick",
		},
		{
			"<leader>dg",
			function()
				require("dropbar.api").goto_context_start()
			end,
			desc = "[D]ropbar [G]oto context start",
		},
	},
	-- Zero config required - dropbar works great out of the box
	-- Uses LSP, treesitter, and path information automatically
	opts = {},
}
