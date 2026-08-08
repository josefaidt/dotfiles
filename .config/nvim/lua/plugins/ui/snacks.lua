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

-- Open the dashboard plus the file-tree, leaving the dashboard focused. Used
-- both when launching on a directory and when the last real buffer is
-- closed (mirrors the previous alpha-nvim start-screen.lua).
--
-- Reveal neo-tree FIRST, then render the dashboard into the (now stable)
-- main window, embedding it there instead of opening a floating overlay —
-- this is how Snacks' own auto-open embeds into the startup window too (see
-- Snacks.dashboard.setup() in snacks/dashboard.lua).
local function open_dashboard()
	if vim.fn.exists(":Neotree") ~= 0 then
		pcall(vim.cmd, "Neotree show")
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype ~= "neo-tree" then
			-- `:Neotree show` focuses its own split; explicitly refocus the main
			-- window first so the dashboard actually lands there, not just gets
			-- silently rendered into an unfocused window.
			vim.api.nvim_set_current_win(win)
			Snacks.dashboard({ buf = buf, win = win })
			break
		end
	end
end

---@type LazySpec
return {
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
		explorer = { enabled = false }, -- Disabled - using neotree instead
	},
	config = function(_, opts)
		for _, item in ipairs(opts.dashboard.preset.keys) do
			if item.key == "s" then
				item.desc = session_desc()
			end
		end

		require("snacks").setup(opts)

		local group = vim.api.nvim_create_augroup("snacks-dashboard", { clear = true })

		-- `nvim <dir>` (or any directory arg) lands on a netrw/directory buffer
		-- that Snacks' own dashboard auto-open skips (argc(-1) > 0, and
		-- `explorer` is disabled here so it won't override that check — see
		-- the `skip` logic in Snacks.dashboard.setup()). Detect that case and
		-- swap in the dashboard + file-tree instead, same as the old
		-- alpha-nvim start-screen.lua did.
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			nested = true,
			callback = function()
				if vim.fn.argc(-1) ~= 1 then
					return
				end
				local arg = vim.fn.argv(0)
				if type(arg) ~= "string" or vim.fn.isdirectory(arg) == 0 then
					return
				end
				-- Make the directory the cwd so the dashboard's Find file / Grep /
				-- session resolution all operate where we were pointed.
				pcall(vim.cmd.tcd, arg)
				open_dashboard()
			end,
		})

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
}
