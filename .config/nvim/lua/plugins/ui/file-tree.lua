---@module 'plugins.ui.file-tree'
---Neo-tree file browser configuration with auto-refresh
---https://github.com/nvim-neo-tree/neo-tree.nvim

---@type LazySpec[]
return {
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			color_icons = false,
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false, -- neo-tree will lazily load itself
		-- Keymaps are configured in lua/config/keymaps/plugins.lua
		config = function()
			-- Define custom highlight groups for git status using theme colors
			vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { link = "DiagnosticOk" }) -- green
			vim.api.nvim_set_hl(0, "NeoTreeGitModified", { link = "DiagnosticWarn" }) -- yellow
			vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { link = "DiagnosticError" }) -- red
			vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { link = "DiagnosticHint" }) -- purple/magenta

			require("neo-tree").setup({
				window = {
					position = "right", -- Position on the right side
					width = 30, -- Default is 40, try 25-35
					mappings = {
						-- Override delete to have "y" pre-filled in confirmation
						["d"] = function(state)
							local node = state.tree:get_node()
							local path = node.path
							local filename = vim.fn.fnamemodify(path, ":t")

							-- Use vim.ui.input with default "y" so user just needs to press Enter
							vim.ui.input({
								prompt = "Delete " .. filename .. "? (y/n): ",
								default = "y", -- Pre-fill with "y"
							}, function(input)
								if input and (input:lower() == "y" or input:lower() == "yes") then
									vim.fn.system({ "rm", "-rf", path })
									require("neo-tree.sources.manager").refresh(state.name)
									vim.notify("Deleted " .. filename, vim.log.levels.INFO)
								end
							end)
						end,
						["O"] = function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							vim.fn.jobstart({ "open", path }, { detach = true })
						end,
						["<C-x>"] = function()
							vim.cmd("Lazy")
						end,
						-- Search files in folder (only works when in neo-tree)
						["<leader>sf"] = function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							-- If it's a file, get its parent directory
							if node.type == "file" then
								path = vim.fn.fnamemodify(path, ":h")
							end
							-- Use telescope to find files in this directory
							require("telescope.builtin").find_files({
								prompt_title = "Find Files in: " .. vim.fn.fnamemodify(path, ":~:."),
								cwd = path,
							})
						end,
						-- Git add all files
						["gA"] = function(state)
							vim.fn.system("git add .")
							require("neo-tree.sources.manager").refresh(state.name)
							vim.notify("Staged all files", vim.log.levels.INFO)
						end,
					},
				},
				local_settings = { wrap = true },
				enable_diagnostics = false,
				enable_git_status = true,
				hide_root_node = true, -- Hide the top level directory name
				filesystem = {
					follow_current_file = {
						enabled = true, -- Expand folders to reveal current file
						leave_dirs_open = true, -- Close folders when navigating away
					},
					-- Auto-refresh when files are created externally (e.g., by Claude, bun init)
					use_libuv_file_watcher = true,
					filtered_items = {
						visible = true, -- Show filtered items dimmed
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_name = {
							-- These will be completely hidden (not even dimmed)
							".git",
							".DS_Store",
						},
						never_show = {
							".git",
							".DS_Store",
						},
					},
				},
				default_component_configs = {
					indent = {
						indent_size = 2,
						padding = 1,
						with_markers = true,
					},
					icon = {
						folder_closed = "",
						folder_open = "",
						folder_empty = "",
						default = "",
					},
					-- Add more vertical spacing between items
					name = {
						trailing_slash = false,
						use_git_status_colors = true,
						highlight = "NeoTreeFileName",
					},
					git_status = {
						symbols = {
							added = "A",
							modified = "M",
							deleted = "D",
							renamed = "R",
							untracked = "U",
							ignored = "I",
							unstaged = "",
							staged = "S",
							conflict = "C",
						},
					},
				},
				reveal = true,
				source_selector = {
					winbar = false, -- Disable tabs (file/buffer/git) - using DiffView instead
					statusline = false,
				},
			})
		end,
	},
}
