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
		local function session_label()
			local ok, persistence = pcall(require, "persistence")
			if not ok then
				return "  Restore session"
			end
			if vim.fn.filereadable(persistence.current()) == 0 then
				return "  Restore session (none for this dir)"
			end
			local branch = persistence.branch and persistence.branch() or nil
			if not branch or branch == "" then
				return "  Restore session"
			end
			return "  Restore session (" .. branch .. ")"
		end

		-- Dim the "Restore session" button so the branch annotation reads as
		-- secondary info rather than a full action label.
		local restore_btn = dashboard.button("s", session_label(), "<cmd>lua require('persistence').load()<CR>")
		restore_btn.opts.hl = "Comment"

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>enew<CR>"),
			dashboard.button("f", "  Find file", "<cmd>lua Snacks.picker.files()<CR>"),
			dashboard.button("g", "  Grep", "<cmd>lua Snacks.picker.grep()<CR>"),
			-- `files` arg makes pick_worktree open a file picker after tcd,
			-- replacing the dashboard with something actionable.
			dashboard.button("w", "  Worktrees", "<cmd>PickWorktree files<CR>"),
			restore_btn,
			dashboard.button("S", "  Select session", "<cmd>lua require('persistence').select()<CR>"),
			dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
		}
		-- Tighten the dashboard: no blank lines between buttons.
		dashboard.section.buttons.opts.spacing = 0

		require("alpha").setup(dashboard.config)
	end,
}
