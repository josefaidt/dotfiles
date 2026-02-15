---@module 'plugins.editor.syntax-highlighting'
---Treesitter configuration for syntax highlighting and text objects

---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
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
			"rust",
		},
		auto_install = true,
		highlight = {
			enable = true,
			-- Disable treesitter for large files (set by init.lua)
			disable = function(lang, buf)
				return vim.b[buf].large_file
			end,
			additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
			-- Disable treesitter indenting for large files
			disable = function(lang, buf)
				return vim.b[buf].large_file
			end,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- Functions
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					-- Classes
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					-- Parameters/arguments
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					-- Conditionals (if/else)
					["ai"] = "@conditional.outer",
					["ii"] = "@conditional.inner",
					-- Loops
					["al"] = "@loop.outer",
					["il"] = "@loop.inner",
					-- Comments
					["a/"] = "@comment.outer",
					["i/"] = "@comment.inner",
					-- Blocks
					["ab"] = "@block.outer",
					["ib"] = "@block.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- Add jumps to jumplist
				goto_next_start = {
					["]f"] = "@function.outer",
					["]c"] = "@class.outer",
					["]a"] = "@parameter.inner",
					["]i"] = "@conditional.outer",
					["]l"] = "@loop.outer",
				},
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
					["[a"] = "@parameter.inner",
					["[i"] = "@conditional.outer",
					["[l"] = "@loop.outer",
				},
				goto_next_end = {
					["]F"] = "@function.outer",
					["]C"] = "@class.outer",
				},
				goto_previous_end = {
					["[F"] = "@function.outer",
					["[C"] = "@class.outer",
				},
			},
		},
	},
}
