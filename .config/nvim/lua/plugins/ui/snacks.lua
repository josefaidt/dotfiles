---@module 'plugins.ui.snacks'
---Snacks.nvim - Collection of useful utilities from folke

---@type LazySpec[]
return {
	-- Monochrome file-type icons across the UI (picker, explorer, dropbar).
	-- Snacks' picker/explorer consumes nvim-web-devicons for its file icons,
	-- so this override keeps the icon appearance consistent.
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			color_icons = false,
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			-- Enable the features you want
			bufdelete = { enabled = true }, -- Smart buffer deletion
			quickfile = { enabled = true }, -- Fast loading for small files
			words = { enabled = true }, -- Highlight references under cursor
			rename = { enabled = true }, -- LSP-aware file rename (updates import references)
			picker = {
				enabled = true,
				ui_select = true, -- replace vim.ui.select with snacks
				-- Per-source overrides. Snacks picker defaults hide dotfiles AND
				-- respect .gitignore; we want the inverse — show dotfiles, still
				-- respect .gitignore — plus a baseline exclude list for scratch
				-- repos that don't have a .gitignore yet.
				sources = {
					files = {
						hidden = true, -- show dotfiles/dotdirs (.config, .github, etc.)
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
					-- Open the file explorer on the right side (LazyVim-style).
					-- The explorer is a picker source, so its layout position is
					-- controlled here rather than by the top-level `explorer` opt.
					explorer = {
						layout = { layout = { position = "right" } },
						-- The explorer is a distinct picker source and does NOT
						-- inherit the `files`/`grep` overrides above, so it needs
						-- its own visibility flags: show dotfiles/dotdirs (.claude,
						-- .agents, .config, …) instead of Snacks' default of hiding
						-- them.
						hidden = true,
						win = {
							list = {
								keys = {
									-- Don't dismiss the sidebar on <Esc>. Upstream
									-- Snacks maps <Esc> to `close`; that made a stray
									-- Esc (e.g. after closing a diagnostic float)
									-- tear down the whole explorer. Treat it as a
									-- persistent sidebar instead — close via \ or
									-- <leader>e.
									["<Esc>"] = false,
								},
							},
						},
					},
				},
			},
			statuscolumn = { enabled = false }, -- Using default for now
			dashboard = { enabled = false }, -- Disabled for now
			notifier = { enabled = false }, -- Using nvim-notify instead
			explorer = { enabled = true }, -- Primary file tree (replaces neo-tree)
		},
	},
}
