return { -- Autocompletion
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		-- Snippet Engine
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			build = (function()
				-- Build Step is needed for regex support in snippets.
				-- This step is not supported in many windows environments.
				-- Remove the below condition to re-enable on windows.
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {
				-- `friendly-snippets` contains a variety of premade snippets.
				--    See the README about individual language/framework/plugin snippets:
				--    https://github.com/rafamadriz/friendly-snippets
				-- {
				--   'rafamadriz/friendly-snippets',
				--   config = function()
				--     require('luasnip.loaders.from_vscode').lazy_load()
				--   end,
				-- },
			},
			opts = {},
		},
		"folke/lazydev.nvim",
	},
	--- @module 'blink.cmp'
	--- @type blink.cmp.Config
	opts = {
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
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		completion = {
			-- By default, you may press `<c-space>` to show the documentation.
			-- Optionally, set `auto_show = true` to show the documentation after a delay.
			documentation = {
				auto_show = false,
				auto_show_delay_ms = 500,
				-- Window configuration for documentation popup
				window = {
					border = "rounded",
					max_width = 80,
					max_height = 20,
					scrollbar = true,
				},
			},
			-- Menu (completion list) configuration
			menu = {
				border = "rounded",
				max_height = 15,
				scrollbar = true,
				-- VSCode-like: draw completion menu with more spacing
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

		-- Enable cmdline completion for : and / commands
		cmdline = {
			enabled = true,
			sources = function()
				local type = vim.fn.getcmdtype()
				-- For search commands (/ and ?)
				if type == "/" or type == "?" then
					return { "buffer" }
				end
				-- For ex commands (:)
				if type == ":" then
					return { "cmdline" }
				end
				return {}
			end,
		},

		snippets = { preset = "luasnip" },

		-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
		-- which automatically downloads a prebuilt binary when enabled.
		--
		-- By default, we use the Lua implementation instead, but you may enable
		-- the rust implementation via `'prefer_rust_with_warning'`
		--
		-- See :h blink-cmp-config-fuzzy for more information
		fuzzy = { implementation = "lua" },

		-- Shows a signature help window while you type arguments for a function
		signature = {
			enabled = true,
			window = {
				border = "rounded",
				scrollbar = false,
			},
		},
	},
}
