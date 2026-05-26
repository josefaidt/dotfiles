return {
	"folke/snacks.nvim",
	{
		priority = 1000,
		setup = function()
			require("snacks").setup({
				bufdelete = { enabled = true },
				quickfile = { enabled = true },
				words = { enabled = true },
				picker = {
					enabled = true,
					ui_select = true,
					-- Per-source overrides. Snacks picker defaults hide dotfiles AND
					-- respect .gitignore; we want the inverse — show dotfiles, still
					-- respect .gitignore — plus a baseline exclude list for scratch
					-- repos that don't have a .gitignore yet.
					sources = {
						files = {
							hidden = true,
							exclude = {
								".git",
								"node_modules",
								".next",
								".astro",
								".svelte-kit",
								"dist",
								"build",
								"coverage",
								".amplify-hosting",
								".venv",
								".DS_Store",
							},
						},
						grep = {
							hidden = true,
							exclude = {
								".git",
								"node_modules",
								".next",
								".astro",
								".svelte-kit",
								"dist",
								"build",
								"coverage",
								".amplify-hosting",
								".venv",
							},
						},
					},
				},
				statuscolumn = { enabled = false },
				dashboard = { enabled = false },
				notifier = { enabled = false },
				explorer = { enabled = false },
			})
		end,
	},
}
