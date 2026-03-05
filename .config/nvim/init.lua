-- Set to true if you have a Nerd Font installed and selected in your terminal
vim.g.have_nerd_font = true

-- use personal keymap
require("config.keymaps")

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true
-- Reduce gutter width for line numbers
vim.opt.numberwidth = 2

-- Use the system clipboard for all operations
vim.opt.clipboard = "unnamedplus"

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent and better text wrapping
vim.opt.breakindent = true
-- Only wrap at word boundaries (spaces, punctuation) not in the middle of words
vim.opt.linebreak = true
-- When wrapping, continue at the same indent level
vim.opt.breakindentopt = "shift:2"

-- Use spaces instead of tabs
vim.opt.expandtab = true
-- Set tab width to 2 spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 700

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- VSCode-like line spacing for better readability and clickable tabs
-- Increase for taller tabs that are easier to click
vim.opt.linespace = 12

-- allow switching buffers without saving
vim.opt.hidden = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Automatically reload files when changed outside of Neovim
-- This is useful when external tools (like Claude Code) modify files
vim.opt.autoread = true

-- Automatically check for file changes when:
-- - Gaining focus (switching back to the terminal)
-- - Entering a buffer
-- - After terminal job finishes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermClose", "TermLeave" }, {
	desc = "Check for external file changes",
	group = vim.api.nvim_create_augroup("auto-reload-files", { clear = true }),
	callback = function()
		-- Only check if the buffer is not modified
		if vim.bo.buftype == "" and not vim.bo.modified then
			vim.cmd("checktime")
		end
	end,
})

-- Show a notification when a file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	desc = "Notify when file is changed outside of Neovim",
	group = vim.api.nvim_create_augroup("file-changed-notification", { clear = true }),
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
})

-- Better handling for file changes when buffer has unsaved modifications
-- Detects when external changes conflict with local edits
vim.api.nvim_create_autocmd("FileChangedShell", {
	desc = "Prompt for action when file changed externally with local modifications",
	group = vim.api.nvim_create_augroup("file-conflict-handler", { clear = true }),
	callback = function()
		-- If buffer has modifications, notify but don't auto-reload
		if vim.bo.modified then
			vim.notify(
				"Warning: File changed on disk and you have unsaved changes.\nUse :e to reload or :w to overwrite.",
				vim.log.levels.WARN
			)
		end
	end,
})

-- Handle swap file conflicts with a better UI
-- This replaces the default vim swap file dialog with vim.ui.select
vim.api.nvim_create_autocmd("SwapExists", {
	desc = "Custom swap file handler with better UI",
	group = vim.api.nvim_create_augroup("swap-file-handler", { clear = true }),
	callback = function(args)
		local filename = vim.fn.fnamemodify(args.file, ":t")
		local swap_file = vim.v.swapname
		local bufnr = args.buf

		-- Default to edit mode to allow the file to load
		vim.v.swapchoice = "e"

		-- Schedule the UI prompt after the file has loaded
		vim.schedule(function()
			local choices = {
				"Reload from disk (discard my changes)",
				"Keep my version (ignore disk changes)",
				"Open read-only",
				"Quit without loading",
				"Show diff before deciding",
			}

			vim.ui.select(choices, {
				prompt = string.format(
					"Swap file exists for '%s'\nAnother instance may be editing this file, or it has external changes.",
					filename
				),
			}, function(choice)
				if not choice then
					-- User cancelled, close the buffer
					vim.api.nvim_buf_delete(bufnr, { force = true })
					return
				end

				if choice == choices[1] then
					-- Reload from disk (delete swap, reload buffer)
					-- Delete the swap file first
					pcall(vim.fn.delete, swap_file)
					-- Reload the buffer
					vim.cmd("edit!")
					vim.notify("Reloaded from disk", vim.log.levels.INFO)
				elseif choice == choices[2] then
					-- Keep my version (delete swap file, keep current buffer)
					pcall(vim.fn.delete, swap_file)
					vim.notify("Kept your version", vim.log.levels.INFO)
				elseif choice == choices[3] then
					-- Open read-only
					vim.bo[bufnr].readonly = true
					vim.notify("Opened read-only", vim.log.levels.INFO)
				elseif choice == choices[4] then
					-- Quit - close the buffer
					vim.api.nvim_buf_delete(bufnr, { force = true })
				elseif choice == choices[5] then
					-- Show diff - save current to temp and show diff
					local temp_file = vim.fn.tempname()
					local current_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
					vim.fn.writefile(current_content, temp_file)

					-- Delete swap and reload to get disk version
					pcall(vim.fn.delete, swap_file)
					vim.cmd("edit!")

					-- Open vertical split with diff
					vim.cmd("vertical diffsplit " .. temp_file)
					vim.notify("Left: Disk version | Right: Your version", vim.log.levels.INFO)
				end
			end)
		end)
	end,
})

-- Better :Inspect command that shows output in a readable floating window
vim.api.nvim_create_user_command("Inspect", function()
	-- Get highlight info at cursor position
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local result = vim.inspect_pos(0, row - 1, col)

	-- Format the output nicely
	local lines = {}

	-- Syntax groups
	if #result.syntax > 0 then
		table.insert(lines, "Syntax:")
		for _, syn in ipairs(result.syntax) do
			table.insert(lines, string.format("  - %s", syn.hl_group))
		end
		table.insert(lines, "")
	end

	-- Treesitter
	if #result.treesitter > 0 then
		table.insert(lines, "Treesitter:")
		for _, ts in ipairs(result.treesitter) do
			table.insert(lines, string.format("  - %s", ts.hl_group or ts.capture))
		end
		table.insert(lines, "")
	end

	-- Semantic tokens
	if #result.semantic_tokens > 0 then
		table.insert(lines, "Semantic Tokens:")
		for _, sem in ipairs(result.semantic_tokens) do
			table.insert(lines, string.format("  - %s", sem.hl_group))
		end
		table.insert(lines, "")
	end

	-- Extmarks
	if #result.extmarks > 0 then
		table.insert(lines, "Extmarks:")
		for _, ext in ipairs(result.extmarks) do
			if ext.opts.hl_group then
				table.insert(lines, string.format("  - %s", ext.opts.hl_group))
			end
		end
	end

	if #lines == 0 then
		table.insert(lines, "No highlight groups found at cursor position")
	end

	-- Show in a floating window using vim.ui (noice will handle the display)
	local text = table.concat(lines, "\n")
	vim.notify(text, vim.log.levels.INFO, { title = "Inspect Highlight Groups" })
end, { desc = "Show highlight groups at cursor in a floating window" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- smooth scrolling
vim.opt.smoothscroll = true
vim.opt.scrolloff = 8 -- keep 8 lines visible above/below cursor
vim.opt.sidescrolloff = 8 -- same but horizontallys

-- Disable heavy features for large files to prevent freezing
-- Useful when inspecting large build files
local large_file_group = vim.api.nvim_create_augroup("large-file-optimizations", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
	desc = "Disable expensive features for large files",
	group = large_file_group,
	callback = function(ev)
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		if ok and stats and stats.size > 1000000 then -- 1MB threshold
			vim.notify("Large file detected. Disabling heavy features for better performance.", vim.log.levels.WARN)

			-- Disable syntax highlighting
			vim.cmd("syntax off")

			-- Disable treesitter for this buffer
			vim.b[ev.buf].large_file = true

			-- Disable LSP
			vim.api.nvim_create_autocmd("LspAttach", {
				buffer = ev.buf,
				callback = function(args)
					vim.schedule(function()
						vim.lsp.buf_detach_client(ev.buf, args.data.client_id)
					end)
				end,
			})

			-- Disable other expensive options
			vim.opt_local.swapfile = false
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.undolevels = -1
			vim.opt_local.undoreload = 0
			vim.opt_local.list = false -- disable showing whitespace chars
		end
	end,
})

require("config.lazy")

-- @TODO redo lazy config loading, something is awry

-- load vscode settings
require("config.vscode")
