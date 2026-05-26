return {
	{
		"rcarriga/nvim-notify",
		{
			-- Eager so notifications work from the very first call.
			priority = 55,
			setup = function()
				local notify = require("notify")
				notify.setup({
					stages = "fade",
					timeout = 3000,
					top_down = false,
					render = "compact",
					max_width = 50,
					minimum_width = 50,
					on_open = function(win)
						vim.api.nvim_win_set_config(win, { focusable = true })
						vim.wo[win].wrap = true
						vim.wo[win].linebreak = true
					end,
				})

				vim.api.nvim_set_hl(0, "NotifyERRORBody", { link = "NotifyERRORBorder" })
				vim.api.nvim_set_hl(0, "NotifyWARNBody", { link = "NotifyWARNBorder" })
				vim.api.nvim_set_hl(0, "NotifyINFOBody", { link = "NotifyINFOBorder" })
				vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { link = "NotifyDEBUGBorder" })
				vim.api.nvim_set_hl(0, "NotifyTRACEBody", { link = "NotifyTRACEBorder" })

				vim.keymap.set("n", "<leader>snd", function()
					require("notify").dismiss({ silent = true, pending = true })
				end, { desc = "Dismiss notifications" })
			end,
		},
	},
	{
		"folke/noice.nvim",
		{
			event = "VeryLazy",
			keys = {
				{ "<leader>snl", "<cmd>Noice last<cr>", desc = "Last notification" },
			},
			setup = function()
				require("noice").setup({
					lsp = {
						hover = {
							enabled = true,
						},
						-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
						override = {
							["vim.lsp.util.convert_input_to_markdown_lines"] = true,
							["vim.lsp.util.stylize_markdown"] = true,
							["cmp.entry.get_documentation"] = true,
						},
					},
					presets = {
						bottom_search = false,
						command_palette = false,
						long_message_to_split = true,
						inc_rename = false,
						lsp_doc_border = false,
					},
					views = {
						hover = {
							border = {
								style = "rounded",
								padding = { 0, 1 },
							},
							win_options = {
								winhighlight = {
									Normal = "Normal",
									FloatBorder = "LspHoverBorder",
								},
								conceallevel = 3,
								concealcursor = "",
							},
						},
						cmdline_popup = {
							backend = "popup",
							relative = "editor",
							position = {
								row = "50%",
								col = "50%",
							},
							size = {
								width = 60,
								height = "auto",
							},
							border = {
								style = "rounded",
								padding = { 0, 1 },
							},
							win_options = {
								winblend = 0,
								winhighlight = {
									Normal = "NoiceCmdlinePopup",
									FloatBorder = "NoiceCmdlinePopupBorder",
								},
							},
						},
						input = {
							backend = "popup",
							relative = "editor",
							position = {
								row = "50%",
								col = "50%",
							},
							size = {
								width = 50,
								height = "auto",
							},
							border = {
								style = "rounded",
								padding = { 0, 1 },
								text = {
									top = false,
								},
							},
							win_options = {
								winblend = 0,
								winhighlight = {
									Normal = "NoiceInput",
									FloatBorder = "NoiceInputBorder",
								},
							},
						},
						confirm = {
							backend = "popup",
							relative = "editor",
							position = {
								row = "50%",
								col = "50%",
							},
							size = {
								width = 50,
								height = "auto",
							},
							border = {
								style = "rounded",
								padding = { 0, 1 },
							},
							win_options = {
								winblend = 0,
								wrap = true,
								linebreak = true,
								winhighlight = {
									Normal = "NoiceConfirm",
									FloatBorder = "NoiceConfirmBorder",
								},
							},
						},
						notify = {
							max_width = 60,
							win_options = {
								wrap = true,
								linebreak = true,
							},
						},
					},
					cmdline = {
						enabled = true,
						view = "cmdline_popup",
						format = {
							cmdline = { pattern = "^:", icon = "", lang = "vim" },
							search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
							search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
							filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
							lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
							help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
						},
					},
					messages = {
						enabled = true,
					},
					commands = {
						last = {
							view = "popup",
							opts = {
								enter = true,
								format = "details",
								relative = "editor",
								position = { row = "50%", col = "50%" },
								size = { width = 60, height = "auto", max_height = 20 },
								border = { style = "rounded", padding = { 0, 1 } },
								win_options = {
									wrap = true,
									linebreak = true,
									winblend = 0,
								},
							},
						},
					},
					routes = {
						{
							filter = {
								event = "confirm",
							},
							view = "confirm",
						},
						{
							-- Skip LSP progress messages to avoid spam from spinner animations
							filter = {
								event = "lsp",
								kind = "progress",
							},
							opts = { skip = true },
						},
						{
							-- Send verbose output to a persistent split so it doesn't vanish
							filter = { event = "msg_show", kind = "verbose" },
							view = "split",
						},
					},
				})
			end,
		},
	},
}
