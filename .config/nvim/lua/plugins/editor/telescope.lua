---@module 'plugins.editor.telescope'
---Telescope fuzzy finder configuration

---@type LazySpec
return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ -- If encountering errors, see telescope-fzf-native README for installation instructions
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },

		-- Useful for getting pretty icons, but requires a Nerd Font.
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				layout_strategy = "vertical",
				-- file_ignore_patterns still applies to LSP pickers (references,
				-- definitions, symbols) and buffer/help pickers.
				file_ignore_patterns = {
					"^.git/",
					"node_modules/",
					".DS_Store",
					"%.next/",
					"%.astro/",
					"%.svelte%-kit/",
					"/dist/",
					"/build/",
					"/coverage/",
					"%.amplify%-hosting/",
					"%.venv/",
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")
		pcall(require("telescope").load_extension, "noice")

		-- Load Telescope keymaps from centralized keymap config
		-- Wrap in pcall to catch any errors
		local ok, err = pcall(function()
			require("config.keymaps.telescope").setup()
		end)
		if not ok then
			vim.notify("Failed to load telescope keymaps: " .. tostring(err), vim.log.levels.ERROR)
		end
	end,
}
