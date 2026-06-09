---@module 'plugins.ui.start-screen'
---Startup dashboard via alpha-nvim. Buttons match the bindings actually
---wired up in this config (snacks pickers, persistence sessions, etc.).

---@type LazySpec
return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "folke/persistence.nvim" },
	config = function()
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"██████╗ ███████╗███╗   ██╗ █████╗ ██╗     ██╗",
			"██╔══██╗██╔════╝████╗  ██║██╔══██╗██║     ██║",
			"██║  ██║█████╗  ██╔██╗ ██║███████║██║     ██║",
			"██║  ██║██╔══╝  ██║╚██╗██║██╔══██║██║     ██║",
			"██████╔╝███████╗██║ ╚████║██║  ██║███████╗██║",
			"╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝",
		}

		-- Resolve the session that "Restore session" will load and surface the
		-- git branch on the button so the user sees what they're about to open.
		-- Returns the label plus the byte column where the dimmed suffix begins
		-- (or nil if there's no suffix to dim).
		local function session_label()
			local base = "  Restore session"
			local ok, persistence = pcall(require, "persistence")
			if not ok then
				return base, nil
			end
			if vim.fn.filereadable(persistence.current()) == 0 then
				return base .. " (none for this dir)", #base
			end
			local branch = persistence.branch and persistence.branch() or nil
			if not branch or branch == "" then
				return base, nil
			end
			return base .. " (" .. branch .. ")", #base
		end

		-- Keep "Restore session" in the normal button color and dim only the
		-- trailing " (branch)" annotation so it reads as secondary info.
		local label, suffix_col = session_label()
		local restore_btn = dashboard.button("s", label, "<cmd>lua require('persistence').load()<CR>")
		if suffix_col then
			-- alpha's opts.hl accepts a list of { group, col_start, col_end }
			-- regions; dim from the suffix to the end of the line (-1).
			restore_btn.opts.hl = { { "Comment", suffix_col, -1 } }
		end

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>enew<CR>"),
			dashboard.button("f", "  Find file", "<cmd>lua Snacks.picker.files()<CR>"),
			dashboard.button("g", "  Grep", "<cmd>lua Snacks.picker.grep()<CR>"),
			-- `session` arg makes pick_worktree restore the worktree's session
			-- after tcd (falling back to a file picker), replacing the dashboard
			-- with something actionable.
			dashboard.button("w", "  Worktrees", "<cmd>PickWorktree session<CR>"),
			restore_btn,
			dashboard.button("S", "  Select session", "<cmd>lua require('persistence').select()<CR>"),
			dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
		}
		-- Tighten the dashboard: no blank lines between buttons.
		dashboard.section.buttons.opts.spacing = 0

		require("alpha").setup(dashboard.config)
	end,
}
