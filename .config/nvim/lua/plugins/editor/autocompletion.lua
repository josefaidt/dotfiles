local luasnip_build = (function()
	if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
		return nil
	end
	return function(path)
		vim.system({ "make", "install_jsregexp" }, { cwd = path }):wait()
	end
end)()

return {
	{
		"L3MON4D3/LuaSnip",
		{
			version = vim.version.range("2"),
			build = luasnip_build,
			setup = function()
				require("luasnip").setup({})
			end,
		},
	},
	{
		"saghen/blink.cmp",
		{
			-- Loaded eagerly: nvim-lspconfig setup needs blink.cmp's
			-- get_lsp_capabilities() during init, before VimEnter fires.
			priority = 60,
			version = vim.version.range("1"),
			setup = function()
				require("blink.cmp").setup({
					keymap = {
						-- VSCode-like behavior: Tab to accept, Enter as alternative
						-- 'super-tab' preset enables:
						--   - Tab to accept completion and expand snippets
						--   - Shift-Tab to navigate backwards through suggestions
						--   - Enter also accepts completions
						-- <c-space>: Open menu or open docs if already open
						-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
						-- <c-e>: Hide menu
						-- <c-k>: Toggle signature help
						preset = "super-tab",
					},

					appearance = {
						nerd_font_variant = "mono",
					},

					completion = {
						documentation = {
							auto_show = false,
							auto_show_delay_ms = 500,
							window = {
								border = "rounded",
								max_width = 80,
								max_height = 20,
								scrollbar = true,
							},
						},
						menu = {
							border = "rounded",
							max_height = 15,
							scrollbar = true,
							draw = {
								padding = 1,
								gap = 1,
								columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
							},
						},
					},

					sources = {
						default = { "lsp", "path", "snippets", "lazydev" },
						providers = {
							lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
						},
					},

					cmdline = {
						enabled = true,
						sources = function()
							local type = vim.fn.getcmdtype()
							if type == "/" or type == "?" then
								return { "buffer" }
							end
							if type == ":" then
								return { "cmdline" }
							end
							return {}
						end,
					},

					snippets = { preset = "luasnip" },

					-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
					-- which automatically downloads a prebuilt binary when enabled.
					-- We use the Lua implementation instead.
					fuzzy = { implementation = "lua" },

					signature = {
						enabled = true,
						window = {
							border = "rounded",
							scrollbar = false,
						},
					},
				})
			end,
		},
	},
}
