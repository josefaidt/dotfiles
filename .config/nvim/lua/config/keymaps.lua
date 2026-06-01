---@module 'config.keymaps'
---Centralized keymap configuration.
---
---Buffer-local maps and LSP on-attach maps live elsewhere:
---  - LSP on-attach: lua/config/keymaps_lsp.lua
---  - File-tree preview, markdown buffer-locals, treesitter textobjects:
---    inline in their respective plugin files

-- =============================================================================
-- Leaders (must be set before plugins/keymaps that use <leader>)
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- =============================================================================
-- Helpers (git utilities + custom snacks pickers)
-- =============================================================================

---Find the git repository root by searching upward from current directory
---@return string The git root directory, or initial cwd if not in a git repo
local function find_git_root()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error == 0 and git_root then
		return git_root
	end
	return vim.fn.getcwd()
end

-- Initial working directory captured at startup (prefer git root).
local initial_cwd = find_git_root()

---Find the nearest package.json directory by searching upward from current file
---@return string|nil The directory containing package.json, or nil if not found
local function find_package_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		return nil
	end

	local current_dir = vim.fn.fnamemodify(current_file, ":h")
	local root = vim.fs.find("package.json", {
		path = current_dir,
		upward = true,
		stop = vim.fn.expand("~"),
	})[1]

	if root then
		return vim.fn.fnamemodify(root, ":h")
	end
	return nil
end

---Parse `git worktree list --porcelain` into a list of worktree tables
---@return table[] List of {path, head, branch, bare} tables
local function list_worktrees()
	local lines = vim.fn.systemlist("git worktree list --porcelain")
	if vim.v.shell_error ~= 0 then
		return {}
	end

	local worktrees = {}
	local current = {}

	for _, line in ipairs(lines) do
		if line == "" then
			if current.path then
				table.insert(worktrees, current)
			end
			current = {}
		elseif vim.startswith(line, "worktree ") then
			current.path = line:sub(10)
		elseif vim.startswith(line, "HEAD ") then
			current.head = line:sub(6)
		elseif vim.startswith(line, "branch ") then
			current.branch = line:sub(8):gsub("^refs/heads/", "")
		elseif line == "bare" then
			current.bare = true
		end
	end
	if current.path then
		table.insert(worktrees, current)
	end

	return vim.tbl_filter(function(wt)
		return not wt.bare
	end, worktrees)
end

---Open a snacks picker for selecting a git worktree.
---The selected worktree changes the current tab's directory via `tcd`.
local function pick_worktree()
	local worktrees = list_worktrees()
	if #worktrees == 0 then
		vim.notify("No git worktrees found", vim.log.levels.WARN)
		return
	end

	local cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.getcwd()

	Snacks.picker.pick({
		source = "git_worktrees",
		title = "Git Worktrees",
		items = vim.tbl_map(function(wt)
			local branch = wt.branch or "(detached)"
			local is_current = wt.path == cwd
			local is_claude = wt.path:find("%.claude/worktrees") ~= nil
			return {
				text = (wt.branch or "") .. " " .. wt.path,
				path = wt.path,
				branch = branch,
				is_current = is_current,
				is_claude = is_claude,
			}
		end, worktrees),
		format = function(item)
			local prefix = item.is_current and "* " or "  "
			local label = prefix .. item.branch .. (item.is_claude and " [claude]" or "")
			return {
				{ label, item.is_current and "SnacksPickerLabel" or nil },
				{ "  " },
				{ item.path, "SnacksPickerComment" },
			}
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.cmd("tcd " .. vim.fn.fnameescape(item.path))
			end
		end,
	})
end

-- =============================================================================
-- General
-- =============================================================================

vim.keymap.set("n", "<SPACE>", "<NOP>", { noremap = true })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc key is too far" })

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "write file" })
vim.keymap.set({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

vim.keymap.set("n", "<C-x>", "<cmd>Lazy<CR>", { desc = "Open Lazy.nvim" })

-- Clear highlights on search and close floating windows when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", function()
	vim.cmd("nohlsearch")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, false)
		end
	end
	if _G.suppress_lsp_auto_show then
		_G.suppress_lsp_auto_show()
	end
end)

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "gx", ":!open <cfile><CR>", { desc = "Open URL under cursor" })

-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- =============================================================================
-- Buffer (<leader>b)
-- =============================================================================

vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Buffer delete" })

vim.keymap.set("n", "<leader>bD", function()
	Snacks.bufdelete.all()
end, { desc = "Buffer delete all" })

vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Jump to last buffer" })
vim.keymap.set("n", "<C-->", "<C-o>", { desc = "Jump to previous position" })
vim.keymap.set("n", "<C-=>", "<C-i>", { desc = "Jump to next position" })

vim.keymap.set("n", "<leader>br", function()
	vim.cmd("checktime")
	vim.notify("Buffer reloaded from disk", vim.log.levels.INFO)
end, { desc = "Buffer reload from disk" })

-- =============================================================================
-- Code (<leader>c) — format + LSP control
-- =============================================================================

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Code format" })

vim.keymap.set("n", "<leader>cF", function()
	local conform = require("conform")

	local available = {}
	for _, formatter in ipairs(conform.list_formatters(0)) do
		if formatter.available then
			table.insert(available, formatter.name)
		end
	end

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.server_capabilities.documentFormattingProvider then
			table.insert(available, "LSP")
			break
		end
	end

	if #available == 0 then
		vim.notify("No formatters available for " .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end

	vim.ui.select(available, { prompt = "Select formatter:" }, function(choice)
		if not choice then
			return
		end
		if choice == "LSP" then
			vim.lsp.buf.format({ async = true })
			vim.notify("Formatted with LSP", vim.log.levels.INFO)
		else
			conform.format({ async = true, formatters = { choice } }, function(err)
				if err then
					vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
				else
					vim.notify("Formatted with " .. choice, vim.log.levels.INFO)
				end
			end)
		end
	end)
end, { desc = "Code format (choose formatter)" })

vim.keymap.set("n", "<leader>cr", function()
	-- Stop LSP clients attached to current buffer; lspconfig's filetype
	-- autocmds will reattach them on the next event (e.g. cursor move).
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		client:stop()
	end
	vim.defer_fn(function()
		vim.cmd("edit") -- triggers FileType -> lspconfig reattach
		vim.notify("LSP restarted for current buffer", vim.log.levels.INFO)
	end, 100)
end, { desc = "LSP restart" })

vim.keymap.set("n", "<leader>cR", function()
	-- Stop every active client; lspconfig reattaches via filetype autocmds
	-- when buffers are re-edited.
	for _, client in ipairs(vim.lsp.get_clients()) do
		client:stop()
	end
	vim.defer_fn(function()
		vim.cmd("edit")
		vim.notify("All LSP clients restarted", vim.log.levels.INFO)
	end, 100)
end, { desc = "LSP stop and start all" })

-- =============================================================================
-- Diagnostics (top-level, work with linters not just LSP)
-- =============================================================================

vim.keymap.set("n", "<leader>e", function()
	local winid = vim.diagnostic.open_float()
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_set_current_win(winid)
	end
end, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- =============================================================================
-- File/Find (<leader>f) + Search (<leader>s) — snacks picker
-- =============================================================================

-- File finding
vim.keymap.set("n", "<leader>p", function()
	Snacks.picker.files({ cwd = initial_cwd })
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files({ cwd = initial_cwd })
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>P", function()
	Snacks.picker.commands()
end, { desc = "Command palette" })

vim.keymap.set("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>fc", function()
	vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit nvim config file" })

-- Find files within the current npm package
vim.keymap.set("n", "<leader>fp", function()
	local package_root = find_package_root()
	if package_root then
		Snacks.picker.files({ cwd = package_root })
	else
		vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
	end
end, { desc = "Find files in current package" })

-- General search commands
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "Find existing buffers" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Search word under cursor" })

-- LazyVim-style search expansions
vim.keymap.set("n", "<leader>s/", function()
	Snacks.picker.search_history()
end, { desc = "Search history" })
vim.keymap.set("n", '<leader>s"', function()
	Snacks.picker.registers()
end, { desc = "Registers" })
vim.keymap.set("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, { desc = "Command history" })
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>sj", function()
	Snacks.picker.jumps()
end, { desc = "Search jumplist" })

-- Grep across project
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep all text" })

-- Fuzzy search in current buffer
vim.keymap.set("n", "<leader>/", function()
	Snacks.picker.lines()
end, { desc = "Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>sp", function()
	local package_root = find_package_root()
	if package_root then
		Snacks.picker.grep({ cwd = package_root })
	else
		vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
	end
end, { desc = "Grep text in current package" })

-- =============================================================================
-- Git (<leader>g)
-- =============================================================================

vim.keymap.set("n", "<leader>gw", pick_worktree, { desc = "Git worktrees" })

-- Expose pick_worktree as a command so the alpha dashboard can call it
-- (dashboard buttons feed keystrokes; <leader> sequences don't resolve there).
vim.api.nvim_create_user_command("PickWorktree", pick_worktree, { desc = "Pick a git worktree" })

-- =============================================================================
-- Quit (<leader>q)
-- =============================================================================

vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Select session" })

-- =============================================================================
-- UI (<leader>u)
-- =============================================================================

vim.keymap.set("n", "<leader>uc", function()
	---@param colors string colorscheme name
	---@param vars? table<string, any> vim.g.* values to set before applying
	---@return fun() apply
	local function applier(colors, vars)
		return function()
			if vars then
				for k, v in pairs(vars) do
					vim.g[k] = v
				end
			end
			vim.cmd.colorscheme(colors)
		end
	end

	---@class ThemeChoice
	---@field label string display name + key for "(current)" check
	---@field apply fun()

	---@type ThemeChoice[]
	local themes = {
		{ label = "mellow", apply = applier("mellow") },
		{ label = "everforest", apply = applier("everforest") },
		{ label = "catppuccin", apply = applier("catppuccin") },
		{ label = "catppuccin-latte", apply = applier("catppuccin-latte") },
		{ label = "catppuccin-frappe", apply = applier("catppuccin-frappe") },
		{ label = "catppuccin-macchiato", apply = applier("catppuccin-macchiato") },
		{ label = "catppuccin-mocha", apply = applier("catppuccin-mocha") },
		{ label = "nightfox", apply = applier("nightfox") },
		{ label = "dayfox", apply = applier("dayfox") },
		{ label = "dawnfox", apply = applier("dawnfox") },
		{ label = "duskfox", apply = applier("duskfox") },
		{ label = "nordfox", apply = applier("nordfox") },
		{ label = "terafox", apply = applier("terafox") },
		{ label = "carbonfox", apply = applier("carbonfox") },
		{
			label = "gruvbox-material-hard",
			apply = applier("gruvbox-material", { gruvbox_material_background = "hard" }),
		},
		{
			label = "gruvbox-material-medium",
			apply = applier("gruvbox-material", { gruvbox_material_background = "medium" }),
		},
		{
			label = "gruvbox-material-soft",
			apply = applier("gruvbox-material", { gruvbox_material_background = "soft" }),
		},
		{ label = "rouge2", apply = applier("rouge2") },
	}

	vim.ui.select(
		themes,
		{
			prompt = "Select Theme:",
			---@param item ThemeChoice
			---@return string
			format_item = function(item)
				if item.label == vim.g.theme_picker_current then
					return item.label .. " (current)"
				end
				return item.label
			end,
		}, ---@param choice? ThemeChoice
		function(choice)
			if choice then
				choice.apply()
				vim.g.theme_picker_current = choice.label
				vim.notify("Switched to " .. choice.label, vim.log.levels.INFO)
			end
		end
	)
end, { desc = "Choose colorscheme/theme" })

vim.keymap.set("n", "<leader>ua", function()
	vim.g.lsp_auto_hover = not vim.g.lsp_auto_hover
	vim.notify("LSP auto-hover " .. (vim.g.lsp_auto_hover and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle LSP auto-hover" })

vim.keymap.set("n", "<leader>uL", function()
	local parsers = require("nvim-treesitter.parsers")
	local langs = vim.tbl_keys(parsers.get_parser_configs())
	table.sort(langs)

	vim.ui.select(langs, {
		prompt = "Set language:",
		format_item = function(item)
			if item == vim.bo.filetype then
				return item .. " (current)"
			end
			return item
		end,
	}, function(choice)
		if choice then
			vim.bo.filetype = choice
			vim.notify("Filetype set to " .. choice, vim.log.levels.INFO)
		end
	end)
end, { desc = "Set buffer language/filetype" })

-- =============================================================================
-- Plugin shortcuts (top-level)
-- =============================================================================

-- Neo-tree: \ toggles focus between neotree and editor (doesn't close neotree)
vim.keymap.set("n", "\\", function()
	local neo_tree_wins = vim.tbl_filter(function(win)
		local buf = vim.api.nvim_win_get_buf(win)
		return vim.bo[buf].filetype == "neo-tree"
	end, vim.api.nvim_list_wins())

	if #neo_tree_wins > 0 then
		local current_win = vim.api.nvim_get_current_win()
		local in_neotree = vim.bo[vim.api.nvim_win_get_buf(current_win)].filetype == "neo-tree"

		if in_neotree then
			vim.cmd("wincmd p")
		else
			vim.cmd("Neotree focus")
		end
	else
		vim.cmd("Neotree show")
	end
end, { desc = "Toggle focus between NeoTree and editor", silent = true })

vim.keymap.set("n", "<C-\\>", "<cmd>Neotree toggle<CR>", { desc = "Toggle NeoTree visibility", silent = true })
