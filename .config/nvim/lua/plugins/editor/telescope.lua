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
		local actions = require("telescope.actions")

		require("telescope").setup({
			-- Your telescope config here
			defaults = {
				layout_strategy = "vertical",
				-- Search hidden files (dotfiles) but exclude .git directory
				file_ignore_patterns = {
					"^.git/", -- Ignore .git directory
					"node_modules/",
					".DS_Store",
					".next/",
					".astro/",
					".svelte%-kit/", -- Lua pattern: % escapes the hyphen
					"dist/",
					"build/",
					"coverage/",
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- Search hidden files/dotfiles
					"--glob",
					"!.git/*", -- But exclude .git
					"--glob",
					"!node_modules/*",
					"--glob",
					"!.next/*",
					"--glob",
					"!.astro/*",
					"--glob",
					"!.svelte-kit/*",
					"--glob",
					"!dist/*",
					"--glob",
					"!build/*",
					"--glob",
					"!coverage/*",
				},
				-- Use default Telescope keymaps (Ctrl+n/p for navigation)
			},
			pickers = {
				-- Configure find_files to show dotfiles but not .git
				find_files = {
					find_command = {
						"rg",
						"--files",
						"--hidden", -- Include hidden files/dotfiles
						"--no-ignore", -- Shows gitignored files
						"--glob",
						"!.git/*", -- Exclude .git directory
						"--glob",
						"!node_modules/*",
						"--glob",
						"!.next/*",
						"--glob",
						"!.astro/*",
						"--glob",
						"!.svelte-kit/*",
						"--glob",
						"!dist/*",
						"--glob",
						"!build/*",
						"--glob",
						"!coverage/*",
					},
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
