---@module 'plugins.editor.syntax-highlighting'
---Treesitter configuration for syntax highlighting and text objects
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
			"bash",
			"fish",
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css",
			"json",
			"astro",
			"svelte",
			"markdown",
			"markdown_inline",
			"toml",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]f"] = "@function.outer",
					["]c"] = "@class.outer",
				},
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
				},
			},
		},
	},
}
