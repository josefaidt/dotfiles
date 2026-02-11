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
	opts = {
		bar = {
			enable = function(buf, win)
				return vim.api.nvim_buf_get_option(buf, "buftype") == ""
					and vim.api.nvim_win_get_config(win).relative == ""
			end,
		},
	},
	config = function(_, opts)
		require("dropbar").setup(opts)

		-- Set dropbar highlights to match editor background and remove bold
		vim.api.nvim_set_hl(0, "DropBarIconKindFile", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindModule", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindNamespace", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindPackage", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindClass", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindMethod", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindProperty", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindField", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindConstructor", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindEnum", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindInterface", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindFunction", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindVariable", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindConstant", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindString", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindNumber", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindBoolean", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindArray", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindObject", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindKey", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindNull", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindEnumMember", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindStruct", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindEvent", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindOperator", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconKindTypeParameter", { bg = "NONE", bold = false })

		-- Set main dropbar highlights
		vim.api.nvim_set_hl(0, "DropBarIconUIIndicator", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconUIPickPivot", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconUISeparator", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarIconUISeparatorMenu", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuCurrentContext", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuFloatBorder", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuHoverEntry", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuHoverIcon", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuHoverSymbol", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuNormalFloat", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarMenuSbar", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarPreview", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindFile", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindModule", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindNamespace", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindPackage", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindClass", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindMethod", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindProperty", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindField", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindConstructor", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindEnum", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindInterface", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindFunction", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindVariable", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindConstant", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindString", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindNumber", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindBoolean", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindArray", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindObject", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindKey", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindNull", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindEnumMember", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindStruct", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindEvent", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindOperator", { bg = "NONE", bold = false })
		vim.api.nvim_set_hl(0, "DropBarKindTypeParameter", { bg = "NONE", bold = false })
	end,
}
