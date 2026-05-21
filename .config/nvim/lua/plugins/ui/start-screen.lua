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

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>enew<CR>"),
			dashboard.button("f", "  Find file", "<cmd>lua Snacks.picker.files()<CR>"),
			dashboard.button("g", "  Grep", "<cmd>lua Snacks.picker.grep()<CR>"),
			dashboard.button("c", "  Config", "<cmd>edit " .. vim.fn.stdpath("config") .. "/init.lua<CR>"),
			dashboard.button("w", "  Worktrees", "<leader>gw"),
			dashboard.button("s", "  Restore session", "<cmd>lua require('persistence').load()<CR>"),
			dashboard.button("S", "  Select session", "<cmd>lua require('persistence').select()<CR>"),
			dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
			dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
		}

		require("alpha").setup(dashboard.config)
	end,
}
