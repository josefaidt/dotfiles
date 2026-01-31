---@module 'config.keymaps.telescope'
---Telescope keymaps module
---These keymaps will be set up when Telescope is loaded

local M = {}

-- Store the initial working directory when Neovim was opened
-- This ensures Telescope searches stay rooted in the project directory
local initial_cwd = vim.fn.getcwd()

---Set up Telescope keymaps
function M.setup()
	local builtin = require("telescope.builtin")

	-- Cmd+P - search files in initial directory
	vim.keymap.set("n", "<leader>p", function()
		builtin.find_files({ cwd = initial_cwd })
	end, { desc = "Find files" })
	-- Cmd+Shift+P
	vim.keymap.set("n", "<leader>P", builtin.commands, { desc = "Command palette" })

	-- general search commands
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })

	-- Search all files with live grep (ignoring node_modules, .git, etc.)
	vim.keymap.set("n", "<leader>sa", function()
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
	end, { desc = "[S]earch [A]ll files (grep)" })

	-- Search for visually selected text in all files (prefills search input)
	vim.keymap.set("v", "<leader>sa", function()
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
	end, { desc = "[S]earch [A]ll files for selection" })

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
end

return M
