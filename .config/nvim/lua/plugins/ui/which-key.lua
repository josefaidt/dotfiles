---@module 'plugins.ui.which-key'
---Which-key configuration to show pending keybinds

---@type LazySpec
return {
	"folke/which-key.nvim",
	event = "VeryLazy", -- Sets the loading event to 'VimEnter'
	---@module 'which-key'
	---@type wk.Config
	opts = {
		preset = "helix",
		-- delay between pressing a key and opening which-key (milliseconds)
		-- this setting is independent of vim.o.timeoutlen
		delay = 0,
		icons = {
			-- Custom rules take precedence over which-key's built-ins.
			-- Match against the lowercased description with Lua patterns.
			rules = {
				{ pattern = "register", icon = " ", color = "yellow" },
				{ pattern = "command", icon = " ", color = "purple" },
				{ pattern = "grep", icon = " ", color = "green" },
				{ pattern = "colorscheme", icon = " ", color = "purple" },
				{ pattern = "theme", icon = " ", color = "purple" },
				{ pattern = "focus", icon = " ", color = "blue" },
				{ pattern = "buffers", icon = "󰈔", color = "cyan" },
				{ pattern = "lsp", icon = " ", color = "blue" },
			},
			-- set icon mappings to true if you have a Nerd Font
			mappings = vim.g.have_nerd_font,
			-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
			-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},

		-- Document existing key chains
		spec = {
			{ "<leader>e", desc = "Show diagnostic" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>f", group = "file/find" },
			{ "<leader>g", group = "git" },
			{ "<leader>q", group = "quit" },
			{ "<leader>s", group = "search" },
			{ "<leader>sn", group = "noice" },
			{ "<leader>u", group = "ui" },
			{ "gr", group = "goto/refactor" },
		},

		triggers = {
			{ "<auto>", mode = "nxso" },
		},
	},
}
