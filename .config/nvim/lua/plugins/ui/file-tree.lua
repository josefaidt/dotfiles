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
				-- Use vim.ui for all prompts (noice will intercept and center them)
				use_popups_for_input = false,
				window = {
					position = "right", -- Position on the right side
					width = 30, -- Default is 40, try 25-35
					mappings = {
						-- Use native neotree delete (will use popup near sidebar)
						["O"] = function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							vim.fn.jobstart({ "open", path }, { detach = true })
						end,
						-- Custom rename that uses git mv when in a git repo
						["r"] = function(state)
							local node = state.tree:get_node()
							local old_path = node:get_id()
							local old_name = vim.fn.fnamemodify(old_path, ":t")

							-- Prompt for new name
							vim.ui.input({
								prompt = "Rename to: ",
								default = old_name,
							}, function(new_name)
								if not new_name or new_name == "" or new_name == old_name then
									return
								end

								-- Get the directory and construct new path
								local dir = vim.fn.fnamemodify(old_path, ":h")
								local new_path = dir .. "/" .. new_name

								-- Check if we're in a git repo
								local in_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")

								local success
								if in_git_repo then
									-- Use git mv
									local result = vim.fn.system({ "git", "mv", old_path, new_path })
									success = vim.v.shell_error == 0
									if not success then
										vim.notify("git mv failed: " .. result, vim.log.levels.ERROR)
									else
										vim.notify("Renamed with git mv: " .. old_name .. " → " .. new_name, vim.log.levels.INFO)
									end
								else
									-- Use regular rename
									success = vim.loop.fs_rename(old_path, new_path)
									if not success then
										vim.notify("Rename failed", vim.log.levels.ERROR)
									else
										vim.notify("Renamed: " .. old_name .. " → " .. new_name, vim.log.levels.INFO)
									end
								end

								if success then
									-- Refresh neo-tree
									require("neo-tree.sources.manager").refresh(state.name)
								end
							end)
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
					-- Add event handler configuration
					async_directory_scan = "auto",
					scan_mode = "shallow",
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
