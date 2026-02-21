---@module 'config.keymaps.telescope'
---Telescope keymaps module
---These keymaps will be set up when Telescope is loaded

local M = {}

-- Store the initial working directory when Neovim was opened
-- This ensures Telescope searches stay rooted in the project directory
local initial_cwd = vim.fn.getcwd()

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
					"!node_modules/*", -- Exclude node_modules
					"--glob",
					"!.next/*", -- Exclude .next
					"--glob",
					"!.astro/*", -- Exclude .astro
					"--glob",
					"!.svelte-kit/*", -- Exclude .svelte-kit
					"--glob",
					"!dist/*", -- Exclude dist
					"--glob",
					"!build/*", -- Exclude build
					"--glob",
					"!coverage/*", -- Exclude coverage
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
					"!node_modules/*", -- Exclude node_modules
					"--glob",
					"!.next/*", -- Exclude .next
					"--glob",
					"!.astro/*", -- Exclude .astro
					"--glob",
					"!.svelte-kit/*", -- Exclude .svelte-kit
					"--glob",
					"!dist/*", -- Exclude dist
					"--glob",
					"!build/*", -- Exclude build
					"--glob",
					"!coverage/*", -- Exclude coverage
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

	-- Shortcut for searching your Neovim configuration files
	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[S]earch [N]eovim files" })

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
