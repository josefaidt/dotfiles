-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
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
		opts = {
			window = {
				width = 30, -- Default is 40, try 25-35
				mappings = {
					["E"] = function()
						vim.api.nvim_exec("Neotree focus filesystem left", true)
					end,
					["B"] = function()
						vim.api.nvim_exec("Neotree focus buffers left", true)
					end,
					["G"] = function()
						vim.api.nvim_exec("Neotree focus git_status left", true)
					end,
					["O"] = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.jobstart({ "open", path }, { detach = true })
					end,
					["\\"] = "close_window",
					["<C-x>"] = function()
						vim.cmd("Lazy")
					end,
				},
			},
			enable_diagnostics = false,
			enable_git_status = true,
			hide_root_node = true, -- Hide the top level directory name
			filesystem = {
				follow_current_file = {
					enabled = true, -- Expand folders to reveal current file
					leave_dirs_open = true, -- Close folders when navigating away
				},
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
						".DS_Store",
					},
				},
			},
			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 0,
				},
			},
			reveal = true,
			source_selector = {
				winbar = true,
				statusline = false,
				show_scrolled_off_parent_node = true,
				tabs_layout = "equal",
				content_layout = "start",
				separator = { left = "", right = "" },
			},
		},
	},
}
