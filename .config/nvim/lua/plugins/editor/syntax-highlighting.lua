-- MDX has no Treesitter parser, so treat it as markdown for highlighting purposes
vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})

local parsers = {
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
	"yaml",
	"rust",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		{
			version = "main",
			priority = 100, -- load before other eager plugins so language.add works
			build = function()
				-- Run :TSUpdate after install/update so parsers stay in sync.
				pcall(vim.cmd, "TSUpdate")
			end,
			setup = function()
				-- Install declared parsers on first run (idempotent; async).
				require("nvim-treesitter").install(parsers)

				vim.api.nvim_create_autocmd("FileType", {
					desc = "Enable treesitter highlighting, folds, and indentation",
					callback = function(ev)
						-- Skip large files (vim.b.large_file set by init.lua)
						if vim.b[ev.buf].large_file then
							return
						end

						-- Resolve filetype → language and bail if no parser is available.
						-- `language.add` returns (ok, err); pcall only catches throws, so we
						-- need to check the return tuple as well (e.g. "neo-tree" is an
						-- invalid language name but doesn't throw).
						local ft = vim.bo[ev.buf].filetype
						local lang = vim.treesitter.language.get_lang(ft) or ft
						local pcall_ok, add_ok = pcall(vim.treesitter.language.add, lang)
						if not pcall_ok or not add_ok then
							return
						end

						vim.treesitter.start(ev.buf)
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.wo[0][0].foldmethod = "expr"
					end,
				})
			end,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		{
			version = "main",
			priority = 90, -- after treesitter
			setup = function()
				local ts_select = require("nvim-treesitter-textobjects.select")
				local move = require("nvim-treesitter-textobjects.move")

				require("nvim-treesitter-textobjects").setup({
					select = {
						lookahead = true,
					},
					move = {
						set_jumps = true,
					},
				})

				vim.keymap.set({ "x", "o" }, "af", function()
					ts_select.select_textobject("@function.outer", "textobjects")
				end, { desc = "around function" })
				vim.keymap.set({ "x", "o" }, "if", function()
					ts_select.select_textobject("@function.inner", "textobjects")
				end, { desc = "inner function" })

				vim.keymap.set({ "x", "o" }, "ac", function()
					ts_select.select_textobject("@class.outer", "textobjects")
				end, { desc = "around class" })
				vim.keymap.set({ "x", "o" }, "ic", function()
					ts_select.select_textobject("@class.inner", "textobjects")
				end, { desc = "inner class" })

				vim.keymap.set({ "x", "o" }, "aa", function()
					ts_select.select_textobject("@parameter.outer", "textobjects")
				end, { desc = "around parameter" })
				vim.keymap.set({ "x", "o" }, "ia", function()
					ts_select.select_textobject("@parameter.inner", "textobjects")
				end, { desc = "inner parameter" })

				vim.keymap.set({ "x", "o" }, "ai", function()
					ts_select.select_textobject("@conditional.outer", "textobjects")
				end, { desc = "around conditional" })
				vim.keymap.set({ "x", "o" }, "ii", function()
					ts_select.select_textobject("@conditional.inner", "textobjects")
				end, { desc = "inner conditional" })

				vim.keymap.set({ "x", "o" }, "al", function()
					ts_select.select_textobject("@loop.outer", "textobjects")
				end, { desc = "around loop" })
				vim.keymap.set({ "x", "o" }, "il", function()
					ts_select.select_textobject("@loop.inner", "textobjects")
				end, { desc = "inner loop" })

				vim.keymap.set({ "x", "o" }, "a/", function()
					ts_select.select_textobject("@comment.outer", "textobjects")
				end, { desc = "around comment" })
				vim.keymap.set({ "x", "o" }, "i/", function()
					ts_select.select_textobject("@comment.inner", "textobjects")
				end, { desc = "inner comment" })

				vim.keymap.set({ "x", "o" }, "ab", function()
					ts_select.select_textobject("@block.outer", "textobjects")
				end, { desc = "around block" })
				vim.keymap.set({ "x", "o" }, "ib", function()
					ts_select.select_textobject("@block.inner", "textobjects")
				end, { desc = "inner block" })

				vim.keymap.set({ "n", "x", "o" }, "]f", function()
					move.goto_next_start("@function.outer", "textobjects")
				end, { desc = "next function start" })
				vim.keymap.set({ "n", "x", "o" }, "]c", function()
					move.goto_next_start("@class.outer", "textobjects")
				end, { desc = "next class start" })
				vim.keymap.set({ "n", "x", "o" }, "]a", function()
					move.goto_next_start("@parameter.inner", "textobjects")
				end, { desc = "next parameter start" })
				vim.keymap.set({ "n", "x", "o" }, "]i", function()
					move.goto_next_start("@conditional.outer", "textobjects")
				end, { desc = "next conditional start" })
				vim.keymap.set({ "n", "x", "o" }, "]l", function()
					move.goto_next_start("@loop.outer", "textobjects")
				end, { desc = "next loop start" })

				vim.keymap.set({ "n", "x", "o" }, "[f", function()
					move.goto_previous_start("@function.outer", "textobjects")
				end, { desc = "previous function start" })
				vim.keymap.set({ "n", "x", "o" }, "[c", function()
					move.goto_previous_start("@class.outer", "textobjects")
				end, { desc = "previous class start" })
				vim.keymap.set({ "n", "x", "o" }, "[a", function()
					move.goto_previous_start("@parameter.inner", "textobjects")
				end, { desc = "previous parameter start" })
				vim.keymap.set({ "n", "x", "o" }, "[i", function()
					move.goto_previous_start("@conditional.outer", "textobjects")
				end, { desc = "previous conditional start" })
				vim.keymap.set({ "n", "x", "o" }, "[l", function()
					move.goto_previous_start("@loop.outer", "textobjects")
				end, { desc = "previous loop start" })

				vim.keymap.set({ "n", "x", "o" }, "]F", function()
					move.goto_next_end("@function.outer", "textobjects")
				end, { desc = "next function end" })
				vim.keymap.set({ "n", "x", "o" }, "]C", function()
					move.goto_next_end("@class.outer", "textobjects")
				end, { desc = "next class end" })

				vim.keymap.set({ "n", "x", "o" }, "[F", function()
					move.goto_previous_end("@function.outer", "textobjects")
				end, { desc = "previous function end" })
				vim.keymap.set({ "n", "x", "o" }, "[C", function()
					move.goto_previous_end("@class.outer", "textobjects")
				end, { desc = "previous class end" })
			end,
		},
	},
}
