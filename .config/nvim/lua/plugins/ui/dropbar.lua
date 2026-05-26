local function set_neutral_highlights()
	for _, group in ipairs({
		"DropBarIconKindFile",
		"DropBarIconKindModule",
		"DropBarIconKindNamespace",
		"DropBarIconKindPackage",
		"DropBarIconKindClass",
		"DropBarIconKindMethod",
		"DropBarIconKindProperty",
		"DropBarIconKindField",
		"DropBarIconKindConstructor",
		"DropBarIconKindEnum",
		"DropBarIconKindInterface",
		"DropBarIconKindFunction",
		"DropBarIconKindVariable",
		"DropBarIconKindConstant",
		"DropBarIconKindString",
		"DropBarIconKindNumber",
		"DropBarIconKindBoolean",
		"DropBarIconKindArray",
		"DropBarIconKindObject",
		"DropBarIconKindKey",
		"DropBarIconKindNull",
		"DropBarIconKindEnumMember",
		"DropBarIconKindStruct",
		"DropBarIconKindEvent",
		"DropBarIconKindOperator",
		"DropBarIconKindTypeParameter",
		"DropBarIconUIIndicator",
		"DropBarIconUIPickPivot",
		"DropBarIconUISeparator",
		"DropBarIconUISeparatorMenu",
		"DropBarMenuCurrentContext",
		"DropBarMenuFloatBorder",
		"DropBarMenuHoverEntry",
		"DropBarMenuHoverIcon",
		"DropBarMenuHoverSymbol",
		"DropBarMenuNormalFloat",
		"DropBarMenuSbar",
		"DropBarPreview",
		"DropBarKindFile",
		"DropBarKindModule",
		"DropBarKindNamespace",
		"DropBarKindPackage",
		"DropBarKindClass",
		"DropBarKindMethod",
		"DropBarKindProperty",
		"DropBarKindField",
		"DropBarKindConstructor",
		"DropBarKindEnum",
		"DropBarKindInterface",
		"DropBarKindFunction",
		"DropBarKindVariable",
		"DropBarKindConstant",
		"DropBarKindString",
		"DropBarKindNumber",
		"DropBarKindBoolean",
		"DropBarKindArray",
		"DropBarKindObject",
		"DropBarKindKey",
		"DropBarKindNull",
		"DropBarKindEnumMember",
		"DropBarKindStruct",
		"DropBarKindEvent",
		"DropBarKindOperator",
		"DropBarKindTypeParameter",
	}) do
		vim.api.nvim_set_hl(0, group, { bg = "NONE", bold = false })
	end
end

return {
	{
		"Bekaboo/dropbar.nvim",
		{
			event = "VeryLazy",
			setup = function()
				require("dropbar").setup({
					bar = {
						enable = function(buf, win)
							return vim.api.nvim_buf_get_option(buf, "buftype") == ""
								and vim.api.nvim_win_get_config(win).relative == ""
						end,
					},
				})
				set_neutral_highlights()
			end,
		},
	},
}
