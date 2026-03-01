---@module 'config.keymaps.telescope'
---Telescope keymaps module
---These keymaps will be set up when Telescope is loaded

local M = {}

---Find the git repository root by searching upward from current directory
---@return string The git root directory, or initial cwd if not in a git repo
local function find_git_root()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error == 0 and git_root then
		return git_root
	end
	return vim.fn.getcwd()
end

-- Store the initial working directory when Neovim was opened
-- Prefer git root if we're in a git repository, otherwise use current directory
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
	-- Flush last entry
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

---Set up Telescope keymaps
function M.setup()
	local builtin = require("telescope.builtin")

	-- File finding (VSCode-like + vim convention)
	-- <leader>p for VSCode muscle memory (Cmd+P)
	vim.keymap.set("n", "<leader>p", function()
		builtin.find_files({ cwd = initial_cwd })
	end, { desc = "Find files" })
	-- <leader>ff for vim users' expectation
	vim.keymap.set("n", "<leader>ff", function()
		builtin.find_files({ cwd = initial_cwd })
	end, { desc = "[F]ind [F]iles" })
	-- Cmd+Shift+P - command palette
	vim.keymap.set("n", "<leader>P", builtin.commands, { desc = "Command palette" })

	-- general search commands
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sn", function()
		require("telescope").extensions.noice.noice()
	end, { desc = "[S]earch [N]otifications" })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch [W]ord under cursor" })

	-- Search/grep all text in project (ignoring node_modules, .git, etc.)
	vim.keymap.set("n", "<leader>sg", function()
		builtin.live_grep({
			cwd = initial_cwd,
			additional_args = function()
				return {
					"--hidden", -- Include hidden files
					"--glob",
					"!.git/*", -- Exclude .git
					"--glob",
					"!**/node_modules/*",
					"--glob",
					"!**/.next/*",
					"--glob",
					"!**/.astro/*",
					"--glob",
					"!**/.svelte-kit/*",
					"--glob",
					"!**/dist/*",
					"--glob",
					"!**/build/*",
					"--glob",
					"!**/coverage/*",
					"--glob",
					"!**/.amplify-hosting/*",
				}
			end,
		})
	end, { desc = "[S]earch/[G]rep all text" })

	-- Search for visually selected text in all files (prefills search input)
	vim.keymap.set("v", "<leader>sg", function()
		-- Get the visual selection
		vim.cmd('normal! "vy')
		local selected_text = vim.fn.getreg("v")

		-- Open live_grep with the selected text prefilled
		builtin.live_grep({
			cwd = initial_cwd,
			default_text = selected_text,
			additional_args = function()
				return {
					"--hidden", -- Include hidden files
					"--glob",
					"!.git/*", -- Exclude .git
					"--glob",
					"!**/node_modules/*",
					"--glob",
					"!**/.next/*",
					"--glob",
					"!**/.astro/*",
					"--glob",
					"!**/.svelte-kit/*",
					"--glob",
					"!**/dist/*",
					"--glob",
					"!**/build/*",
					"--glob",
					"!**/coverage/*",
					"--glob",
					"!**/.amplify-hosting/*",
				}
			end,
		})
	end, { desc = "[S]earch/[G]rep selection in all text" })

	-- Slightly advanced example of overriding default behavior and theme
	vim.keymap.set("n", "<leader>/", function()
		-- You can pass additional configuration to Telescope to change the theme, layout, etc.
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- Git worktree picker — open selected worktree in a new tab
	vim.keymap.set("n", "<leader>gw", pick_worktree, { desc = "[G]it [W]orktrees" })

	-- Find files within the current npm package
	vim.keymap.set("n", "<leader>fp", function()
		local package_root = find_package_root()
		if package_root then
			builtin.find_files({
				cwd = package_root,
				prompt_title = "Find Files in Package: " .. vim.fn.fnamemodify(package_root, ":t"),
			})
		else
			vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
		end
	end, { desc = "[F]ind files in current [P]ackage" })

	-- Search/grep text within the current npm package (live grep)
	vim.keymap.set("n", "<leader>sp", function()
		local package_root = find_package_root()
		if package_root then
			builtin.live_grep({
				cwd = package_root,
				prompt_title = "Search in Package: " .. vim.fn.fnamemodify(package_root, ":t"),
				additional_args = function()
					return {
						"--hidden",
						"--glob",
						"!node_modules/*",
						"--glob",
						"!.git/*",
						"--glob",
						"!dist/*",
						"--glob",
						"!build/*",
					}
				end,
			})
		else
			vim.notify("No package.json found in parent directories", vim.log.levels.WARN)
		end
	end, { desc = "[S]earch/grep text in current [P]ackage" })
end

return M
