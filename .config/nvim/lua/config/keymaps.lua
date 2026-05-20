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
-- Helpers (telescope/fff pickers and git utilities)
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

---Open a Telescope picker for selecting a git worktree.
---The selected worktree opens in a new tab via `tcd`.
local function pick_worktree()
	local worktrees = list_worktrees()
	if #worktrees == 0 then
		vim.notify("No git worktrees found", vim.log.levels.WARN)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.getcwd()

	local displayer = entry_display.create({
		separator = "  ",
		items = {
			{ width = 35 },
			{ remaining = true },
		},
	})

	local function make_display(entry)
		local wt = entry.value
		local branch = wt.branch or "(detached)"
		local is_current = wt.path == cwd
		local is_claude = wt.path:find("%.claude/worktrees") ~= nil

		local label = (is_current and "* " or "  ") .. branch .. (is_claude and " [claude]" or "")
		local hl = is_current and "TelescopeResultsIdentifier" or "Normal"

		return displayer({
			{ label, hl },
			{ wt.path, "TelescopeResultsComment" },
		})
	end

	pickers
		.new({}, {
			prompt_title = "Git Worktrees",
			finder = finders.new_table({
				results = worktrees,
				entry_maker = function(wt)
					return {
						value = wt,
						display = make_display,
						ordinal = (wt.branch or "") .. " " .. wt.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("tabnew")
						vim.cmd("tcd " .. vim.fn.fnameescape(selection.value.path))
					end
				end)
				return true
			end,
		})
		:find()
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
end, { desc = "[B]uffer [D]elete" })

vim.keymap.set("n", "<leader>bD", function()
	Snacks.bufdelete.all()
end, { desc = "[B]uffer [D]elete all" })

vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Jump to last buffer" })
vim.keymap.set("n", "<C-->", "<C-o>", { desc = "Jump to previous position" })
vim.keymap.set("n", "<C-=>", "<C-i>", { desc = "Jump to next position" })

vim.keymap.set("n", "<leader>br", function()
	vim.cmd("checktime")
	vim.notify("Buffer reloaded from disk", vim.log.levels.INFO)
end, { desc = "[B]uffer [R]eload from disk" })

-- =============================================================================
-- Code (<leader>c) — format + LSP control
-- =============================================================================

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[C]ode [F]ormat" })

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
end, { desc = "[C]ode [F]ormat (choose formatter)" })

vim.keymap.set("n", "<leader>cr", function()
	vim.cmd("LspRestart")
	vim.notify("LSP restarted for current buffer", vim.log.levels.INFO)
end, { desc = "[C]ode: LSP [R]estart" })

vim.keymap.set("n", "<leader>cR", function()
	vim.cmd("LspStop")
	vim.schedule(function()
		vim.cmd("LspStart")
		vim.notify("All LSP clients restarted", vim.log.levels.INFO)
	end)
end, { desc = "[C]ode: LSP stop and start all" })

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
-- File/Find (<leader>f) + Search (<leader>s) — telescope + fff
-- =============================================================================

local function find_files_at_root()
	require("fff").find_files_in_dir(initial_cwd)
end

-- File finding
vim.keymap.set("n", "<leader>p", find_files_at_root, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", find_files_at_root, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>P", function()
	require("telescope.builtin").commands()
end, { desc = "Command palette" })

vim.keymap.set("n", "<leader>fn", "<cmd>enew<CR>", { desc = "[F]ile: [N]ew" })
vim.keymap.set("n", "<leader>fc", function()
	vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "[F]ile: edit nvim [C]onfig" })

-- Find files within the current npm package
vim.keymap.set("n", "<leader>fp", function()
	local package_root = find_package_root()
	if package_root then
		require("fff").find_files_in_dir(package_root)
	else
		vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
	end
end, { desc = "[F]ind files in current [P]ackage" })

-- General search commands
vim.keymap.set("n", "<leader>sh", function()
	require("telescope.builtin").help_tags()
end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", function()
	require("telescope.builtin").keymaps()
end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>snt", function()
	require("telescope").extensions.noice.noice()
end, { desc = "[S]earch [N]oice: [T]elescope picker" })
vim.keymap.set("n", "<leader><leader>", function()
	require("telescope.builtin").buffers()
end, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>sw", function()
	require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "[S]earch [W]ord under cursor" })

-- LazyVim-style search expansions (telescope built-ins)
vim.keymap.set("n", "<leader>s/", function()
	require("telescope.builtin").search_history()
end, { desc = "[S]earch: search history" })
vim.keymap.set("n", '<leader>s"', function()
	require("telescope.builtin").registers()
end, { desc = "[S]earch: registers" })
vim.keymap.set("n", "<leader>sc", function()
	require("telescope.builtin").command_history()
end, { desc = "[S]earch: [C]ommand history" })
vim.keymap.set("n", "<leader>sd", function()
	require("telescope.builtin").diagnostics()
end, { desc = "[S]earch: [D]iagnostics" })
vim.keymap.set("n", "<leader>sj", function()
	require("telescope.builtin").jumplist()
end, { desc = "[S]earch: [J]umplist" })

-- Grep across project
vim.keymap.set("n", "<leader>sg", function()
	require("fff").live_grep()
end, { desc = "[S]earch/[G]rep all text" })

vim.keymap.set("v", "<leader>sg", function()
	vim.cmd('normal! "vy')
	require("fff").live_grep({ query = vim.fn.getreg("v") })
end, { desc = "[S]earch/[G]rep selection in all text" })

-- Fuzzy search in current buffer
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- fff has no per-call cwd, so we re-index to the package root.
vim.keymap.set("n", "<leader>sp", function()
	local package_root = find_package_root()
	if package_root then
		require("fff").change_indexing_directory(package_root)
		require("fff").live_grep()
	else
		vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
	end
end, { desc = "[S]earch/grep text in current [P]ackage" })

-- =============================================================================
-- Git (<leader>g)
-- =============================================================================

vim.keymap.set("n", "<leader>gw", pick_worktree, { desc = "[G]it [W]orktrees" })

-- =============================================================================
-- Quit (<leader>q)
-- =============================================================================

vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

-- =============================================================================
-- UI (<leader>u)
-- =============================================================================

vim.keymap.set("n", "<leader>uc", function()
	---@type string[]
	local themes = {
		"mellow",
		"everforest",
		"catppuccin",
		"catppuccin-latte",
		"catppuccin-frappe",
		"catppuccin-macchiato",
		"catppuccin-mocha",
		"rouge2",
	}

	vim.ui.select(
		themes,
		{
			prompt = "Select Theme:",
			---@param item string
			---@return string
			format_item = function(item)
				local current = vim.g.colors_name
				if item == current then
					return item .. " (current)"
				end
				return item
			end,
		}, ---@param choice? string
		function(choice)
			if choice then
				vim.cmd.colorscheme(choice)
				vim.notify("Switched to " .. choice, vim.log.levels.INFO)
			end
		end
	)
end, { desc = "[U]I: [C]hoose colorscheme/theme" })

vim.keymap.set("n", "<leader>ua", function()
	vim.g.lsp_auto_hover = not vim.g.lsp_auto_hover
	vim.notify("LSP auto-hover " .. (vim.g.lsp_auto_hover and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "[U]I: toggle LSP [A]uto-hover" })

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
end, { desc = "[U]I: Set buffer [L]anguage/filetype" })

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
