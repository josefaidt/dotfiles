---@module 'plugins.ui.noice'
---Noice configuration for better UI for messages, cmdline and popups

---@type LazySpec
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		{
			"rcarriga/nvim-notify",
			config = function()
				local notify = require("notify")
				notify.setup({
					-- Position notifications at bottom-right
					stages = "fade",
					timeout = 3000, -- 3 seconds
					top_down = false, -- Show notifications from bottom to top
					render = "compact",
					-- Fixed width with text wrapping
					max_width = 50,
					minimum_width = 50,
					-- Make notifications manually dismissible
					on_open = function(win)
						vim.api.nvim_win_set_config(win, { focusable = true })
						-- Enable text wrapping
						vim.wo[win].wrap = true
						vim.wo[win].linebreak = true
					end,
				})

				-- Fix notification background colors to match
				vim.api.nvim_set_hl(0, "NotifyERRORBody", { link = "NotifyERRORBorder" })
				vim.api.nvim_set_hl(0, "NotifyWARNBody", { link = "NotifyWARNBorder" })
				vim.api.nvim_set_hl(0, "NotifyINFOBody", { link = "NotifyINFOBorder" })
				vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { link = "NotifyDEBUGBorder" })
				vim.api.nvim_set_hl(0, "NotifyTRACEBody", { link = "NotifyTRACEBorder" })
			end,
			keys = {
				-- Dismiss all notifications with <leader>un
				{
					"<leader>un",
					function()
						require("notify").dismiss({ silent = true, pending = true })
					end,
					desc = "[U]I: Dismiss [N]otifications",
				},
			},
		},
	},
	---@module 'noice'
	---@type NoiceConfig
	opts = {
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = false, -- use a centered popup cmdline for search
			command_palette = false, -- disable to use custom centered views
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
		-- Configure the display for various UI elements
		views = {
			-- Center the cmdline popup
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
			-- Center input dialogs (like neotree's delete confirmation)
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
						top = false, -- Hide title text like "neo-tree input"
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
			-- Center confirm dialogs
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
					winhighlight = {
						Normal = "NoiceConfirm",
						FloatBorder = "NoiceConfirmBorder",
					},
				},
			},
		},
		-- Configure cmdline to use centered popup
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				-- styling for different kinds of cmdline prompts
				cmdline = { pattern = "^:", icon = "", lang = "vim" },
				search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
				search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
				filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
				lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
				help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
			},
		},
		messages = {
			-- NOTE: If you enable messages, then the cmdline is enabled automatically.
			-- This is a current Neovim limitation.
			enabled = true,
		},
		-- Configure routes to handle specific message patterns
		routes = {
			{
				-- Show confirmation dialogs in center popup
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
		},
	},
}
