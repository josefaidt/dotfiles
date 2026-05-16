---@module 'plugins.editor.fff'
---fff.nvim - frecency-ranked file finder and live grep

---@type LazySpec
return {
	"dmtrKovalenko/fff.nvim",
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	lazy = false,
	opts = {
		prompt = "> ",
		title = "FFFiles",
		max_results = 100,
		layout = {
			height = 0.8,
			width = 0.8,
			prompt_position = "bottom",
			preview_position = "right",
			preview_size = 0.5,
		},
		frecency = { enabled = true },
		git = { status_text_color = true },
	},
}
