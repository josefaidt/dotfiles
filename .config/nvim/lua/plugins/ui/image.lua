---@module 'plugins.ui.image'
---Image rendering in Neovim buffers using image.nvim
---Supports rendering images in markdown, neorg, and other file types
---https://github.com/3rd/image.nvim

---@type LazySpec
return {
	"3rd/image.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- Required for filetype detection
	},
	build = false, -- No build step needed; magick rock must be installed separately
	opts = {
		backend = "kitty", -- "kitty" | "ueberzug" | "sixel" (ghostty may work with kitty protocol)
		integrations = {
			-- Enable markdown image support
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki", "mdx" }, -- Supported file types
			},
			-- Enable neorg image support
			neorg = {
				enabled = false, -- Set to true if using neorg
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "norg" },
			},
			-- Enable HTML image support
			html = {
				enabled = false, -- Enable if needed
			},
			-- Enable CSS image support
			css = {
				enabled = false, -- Enable if needed
			},
		},
		max_width = nil, -- No max width constraint (nil = auto)
		max_height = nil, -- No max height constraint (nil = auto)
		max_width_window_percentage = nil, -- Scale to window percentage if desired
		max_height_window_percentage = 50, -- Limit image height to 50% of window
		-- Window overlap behavior
		window_overlap_clear_enabled = true, -- Clear images when windows overlap
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" }, -- Don't clear for these filetypes
		-- Editor behavior
		editor_only_render_when_focused = false, -- Render images even when not focused
		-- Tmux support
		tmux_show_only_in_active_window = true, -- Only show images in active tmux pane
		-- Hijack file patterns for image files
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
	},
}
