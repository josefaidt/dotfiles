---@module 'plugins.ui.snacks'
---Snacks.nvim - Collection of useful utilities from folke

-- Resolve the session that "Restore session" will load and surface the git
-- branch as a dimmed suffix, so the user sees what they're about to open
-- before pressing `s`. Called from `config()` below (not the static `opts`
-- table), so persistence.nvim is guaranteed to already be set up — see the
-- `dependencies` entry on the spec.
local function session_desc()
	local base = "Restore session"
	local ok, persistence = pcall(require, "persistence")
	if not ok then
		return base
	end
	if vim.fn.filereadable(persistence.current()) == 0 then
		return { { base }, { " (none for this dir)", hl = "Comment" } }
	end
	local branch = persistence.branch and persistence.branch() or nil
	if not branch or branch == "" then
		return base
	end
	return { { base }, { " (" .. branch .. ")", hl = "Comment" } }
end

-- Render the dashboard into the main editor window. Used when the last real
-- buffer is closed (mirrors the previous alpha-nvim start-screen.lua).
--
-- The dashboard no longer force-opens a side tree: the file explorer is the
-- Snacks explorer, opened on demand via `\` / `<leader>e`. Skip floating
-- windows and any `snacks*` filetype (the explorer picker included) so the
-- dashboard lands in a real editor window rather than inside the explorer.
local function open_dashboard()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_win_get_config(win).relative == "" and not vim.bo[buf].filetype:find("snacks") then
			-- Focus the target window explicitly, otherwise the dashboard is
			-- silently rendered into a window that never gets focus.
			vim.api.nvim_set_current_win(win)
			Snacks.dashboard({ buf = buf, win = win })
			break
		end
	end
end

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
		-- Needed so persistence.nvim is loaded (and its own setup() has run)
		-- before `config()` below calls `session_desc()`, regardless of
		-- persistence's own lazy `event`.
		dependencies = { "folke/persistence.nvim" },
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
			---@type snacks.dashboard.Config
			dashboard = {
				enabled = true,
				preset = {
					header = [[
██████╗ ███████╗███╗   ██╗ █████╗ ██╗     ██╗
██╔══██╗██╔════╝████╗  ██║██╔══██╗██║     ██║
██║  ██║█████╗  ██╔██╗ ██║███████║██║     ██║
██║  ██║██╔══╝  ██║╚██╗██║██╔══██║██║     ██║
██████╔╝███████╗██║ ╚████║██║  ██║███████╗██║
╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝]],
					-- `desc` for the "s" (restore session) key is filled in for real in
					-- `config()` below, once persistence.nvim is guaranteed loaded.
					keys = {
						{ key = "e", desc = "New file", action = ":enew" },
						{ key = "f", desc = "Find file", action = ":lua Snacks.picker.files()" },
						{ key = "g", desc = "Grep", action = ":lua Snacks.picker.grep()" },
						-- `session` arg makes pick_worktree restore the worktree's session
						-- after tcd (falling back to a file picker), replacing the
						-- dashboard with something actionable.
						{ key = "w", desc = "Worktrees", action = ":PickWorktree session" },
						-- `section = "session"` resolves to persistence.nvim's load()
						-- since that's the only session plugin this config has installed
						-- (see Snacks.dashboard.sections.session in snacks/dashboard.lua).
						{ key = "s", desc = "Restore session", section = "session" },
						{ key = "S", desc = "Select session", action = ":lua require('persistence').select()" },
						{ key = "q", desc = "Quit", action = ":qa" },
					},
				},
				-- Just header + keys, no recent-files/projects/startup sections — keep
				-- it as close to the old alpha-nvim dashboard as possible.
				sections = {
					{ section = "header" },
					{ section = "keys", padding = 1 },
				},
			},
			notifier = { enabled = false }, -- Using nvim-notify instead
			explorer = { enabled = true }, -- Primary file tree (replaces neo-tree)
		},
		config = function(_, opts)
			for _, item in ipairs(opts.dashboard.preset.keys) do
				if item.key == "s" then
					item.desc = session_desc()
				end
			end

			require("snacks").setup(opts)

			-- `nvim <dir>` needs no handling here. With `explorer.enabled = true`,
			-- Snacks covers that case natively: Snacks.dashboard.setup() skips its
			-- own `argc(-1) > 0` bail for a single directory arg, and the explorer's
			-- `replace_netrw` hook claims the directory buffer and focuses on
			-- UIEnter. The hand-rolled VimEnter handler this config used to carry
			-- predates the explorer (back when neo-tree was the tree and the
			-- explorer was off) and now only races it for the same buffer, which is
			-- what surfaced as "Invalid window id".

			local group = vim.api.nvim_create_augroup("snacks-dashboard", { clear = true })

			-- When the last real (listed, named) buffer is deleted, fall back to the
			-- dashboard instead of an empty [No Name] scratch buffer. Snacks has no
			-- built-in handling for this (only for the initial startup buffer), so
			-- this stays a manual autocmd. Snacks.bufdelete already preserves window
			-- layout, so we just need to fill the void.
			vim.api.nvim_create_autocmd("BufDelete", {
				group = group,
				callback = function(ev)
					-- Ignore buffer churn during startup. lazy.nvim creates and deletes
					-- scratch buffers while loading plugins; at that point no named
					-- buffer exists yet, so the "nothing left" check below would fire
					-- and pop open the dashboard on a plain `nvim` launch. Only react
					-- once we're fully started and the user is actively editing.
					if vim.v.vim_did_enter == 0 then
						return
					end
					-- Only react to closing an actual file buffer. Unnamed
					-- scratch/plugin buffers (which fire BufDelete constantly) must
					-- not trigger this.
					if vim.api.nvim_buf_get_name(ev.buf) == "" then
						return
					end
					vim.schedule(function()
						-- If the dashboard is already up, there's nothing to fill.
						if vim.bo[vim.api.nvim_get_current_buf()].filetype == "snacks_dashboard" then
							return
						end
						-- Count remaining listed buffers with a real file name.
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if
								vim.api.nvim_buf_is_valid(buf)
								and vim.bo[buf].buflisted
								and vim.api.nvim_buf_get_name(buf) ~= ""
							then
								return
							end
						end
						-- None left — show the dashboard.
						open_dashboard()
					end)
				end,
			})
		end,
	},
}
