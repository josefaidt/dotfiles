---@module 'plugins.ui.soft-wrap'
---VS Code-style `wordWrapColumn`: soft-wrap prose/code at N columns and center the
---text area, so long lines wrap at N instead of running across a wide window.
---Neovim can't wrap at an arbitrary column natively (`wrap` uses the window edge),
---so no-neck-pain.nvim caps the main window at `vim.g.wrap_column` columns.
---Windows narrower than that behave normally.
---
---Configure: `vim.g.wrap_column = 100` (before plugins load), or `<leader>uw` to
---toggle at runtime, `<leader>uW` to set the column.

vim.g.wrap_column = vim.g.wrap_column or 120

---@type LazySpec
return {
	"shortcuts/no-neck-pain.nvim",
	cmd = { "NoNeckPain", "NoNeckPainResize", "NoNeckPainWidthUp", "NoNeckPainWidthDown" },
	event = "VimEnter",
	keys = {
		{ "<leader>uw", "<cmd>NoNeckPain<cr>", desc = "Toggle soft wrap column" },
		{
			"<leader>uW",
			function()
				vim.ui.input({ prompt = "Wrap column: ", default = tostring(vim.g.wrap_column) }, function(input)
					local n = tonumber(input)
					if not n or n < 20 then
						return
					end
					vim.g.wrap_column = n
					require("no-neck-pain").resize(n)
					vim.notify("Wrap column set to " .. n, vim.log.levels.INFO)
				end)
			end,
			desc = "Set soft wrap column",
		},
	},
	opts = function()
		return {
			width = vim.g.wrap_column,
			autocmds = { enableOnVimEnter = true },
			-- The snacks explorer opens on the right (see snacks.lua); the default
			-- is "left", which shrinks the wrong side and squeezes the editor.
			integrations = {
				snacks_picker = { position = "right" },
				-- Leave the snacks dashboard full-width and uncentered; no-neck-pain
				-- kicks in once a real file opens. Its default filetype list only has
				-- "snacks", which doesn't match "snacks_dashboard".
				dashboard = { enabled = true, filetypes = { "dashboard", "alpha", "starter", "snacks", "snacks_dashboard" } },
			},
			-- Empty side splits: no number/sign clutter, and don't count as buffers.
			buffers = {
				wo = { fillchars = "eob: " },
			},
		}
	end,
	config = function(_, opts)
		require("no-neck-pain").setup(opts)
		-- Wrap long lines visually inside the capped area.
		vim.opt.wrap = true
		-- With 'equalalways' (the default), opening any split (e.g. the snacks
		-- explorer) makes nvim equalize every window, so the padding splits and the
		-- editor each end up ~1/3 of the width. Turning it off lets no-neck-pain keep
		-- the editor at the wrap column and shrink only the padding.
		vim.opt.equalalways = false
	end,
}
