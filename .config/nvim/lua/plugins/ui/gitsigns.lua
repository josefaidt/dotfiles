---@module 'plugins.ui.gitsigns'
---Git change indicators in the signcolumn — VSCode-style colored rails.
---https://github.com/lewis6991/gitsigns.nvim
---
---All signs use a single thin "│" bar so only the color communicates the
---change type (add/change/delete). Colors come from the GitSignsAdd/Change/Delete
---highlight groups, which the active colorscheme (or Neovim defaults) provides.

---@type LazySpec
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "│" },
			topdelete = { text = "│" },
			changedelete = { text = "│" },
			untracked = { text = "│" },
		},
		signs_staged = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "│" },
			topdelete = { text = "│" },
			changedelete = { text = "│" },
		},
		signcolumn = true,
	},
}
