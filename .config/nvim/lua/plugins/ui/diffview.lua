---@module 'plugins.ui.diffview'
---diffview.nvim — side-by-side git diffs, merge-conflict resolution, and file
---history. Complements gitsigns (hunk-level) with a full-window review UI.
---https://github.com/sindrets/diffview.nvim
---
---Lazy-loaded on its commands + the keymaps below. Keys live under the
---<leader>g (git) group. <leader>gd (Snacks git_diff hunks) is intentionally
---left untouched — diffview uses <leader>gv/<leader>gV/<leader>gh/<leader>gH.

---@type LazySpec
return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
		{ "<leader>gV", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview file history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview project history" },
	},
	opts = {
		use_icons = true, -- nvim-web-devicons is present (pulled in by mini/statusline stack)
		enhanced_diff_hl = true,
	},
}
