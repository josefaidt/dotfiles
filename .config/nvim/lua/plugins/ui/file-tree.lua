return {
	{
		"nvim-tree/nvim-web-devicons",
		{
			-- Eager: dropbar/tabs/neo-tree all `require("nvim-web-devicons")` directly.
			priority = 50,
			setup = function()
				require("nvim-web-devicons").setup({ color_icons = false })
			end,
		},
	},
	{ "nvim-lua/plenary.nvim" },
	{ "MunifTanjim/nui.nvim" },
	{
		"nvim-neo-tree/neo-tree.nvim",
		{
			version = "v3.x",
			-- Keymaps live in lua/config/keymaps.lua; load eagerly so they work immediately.
			priority = 30,
			setup = function()
				-- Strip the "Neo-tree Popup\n" prefix that Neo-tree prepends to prompts when
				-- cmdheight=0 and use_popups_for_input=false (see neo-tree/ui/inputs.lua).
				-- Without this, noice renders "Neo-tree Popup" as a visible title line in
				-- the input dialog.
				local orig_ui_input = vim.ui.input
				vim.ui.input = function(opts, on_confirm)
					if opts and type(opts.prompt) == "string" then
						opts = vim.tbl_extend("force", opts, {
							prompt = opts.prompt:gsub("^Neo%-tree Popup\n", ""),
						})
					end
					return orig_ui_input(opts, on_confirm)
				end

				vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { link = "DiagnosticOk" })
				vim.api.nvim_set_hl(0, "NeoTreeGitModified", { link = "DiagnosticWarn" })
				vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { link = "DiagnosticError" })
				vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { link = "DiagnosticHint" })

				require("neo-tree").setup({
					use_popups_for_input = false,
					window = {
						position = "right",
						width = 30,
						mappings = {
							["O"] = function(state)
								local node = state.tree:get_node()
								local path = node:get_id()
								vim.fn.jobstart({ "open", path }, { detach = true })
							end,
							["d"] = function(state)
								local node = state.tree:get_node()
								local path = node:get_id()
								local name = vim.fn.fnamemodify(path, ":t")
								local type_str = node.type == "directory" and "directory" or "file"

								local choice = vim.fn.confirm(
									string.format("Delete %s '%s'?", type_str, name),
									"&Yes\n&No",
									2
								)

								if choice == 1 then
									local success
									if node.type == "directory" then
										success = vim.fn.delete(path, "rf") == 0
									else
										success = vim.fn.delete(path) == 0
									end

									if success then
										require("neo-tree.sources.manager").refresh(state.name)
										vim.notify(string.format("Deleted %s: %s", type_str, name), vim.log.levels.INFO)
									else
										vim.notify(
											string.format("Failed to delete %s: %s", type_str, name),
											vim.log.levels.ERROR
										)
									end
								end
							end,
							["r"] = function(state)
								local node = state.tree:get_node()
								local old_path = node:get_id()
								local old_name = vim.fn.fnamemodify(old_path, ":t")

								vim.ui.input({
									prompt = "Rename to: ",
									default = old_name,
								}, function(new_name)
									if not new_name or new_name == "" or new_name == old_name then
										return
									end

									local dir = vim.fn.fnamemodify(old_path, ":h")
									local new_path = dir .. "/" .. new_name

									local in_git_repo =
										vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")

									local success
									if in_git_repo then
										local result = vim.fn.system({ "git", "mv", old_path, new_path })
										success = vim.v.shell_error == 0
										if not success then
											vim.notify("git mv failed: " .. result, vim.log.levels.ERROR)
										else
											vim.notify(
												"Renamed with git mv: " .. old_name .. " → " .. new_name,
												vim.log.levels.INFO
											)
										end
									else
										success = vim.loop.fs_rename(old_path, new_path)
										if not success then
											vim.notify("Rename failed", vim.log.levels.ERROR)
										else
											vim.notify("Renamed: " .. old_name .. " → " .. new_name, vim.log.levels.INFO)
										end
									end

									if success then
										require("neo-tree.sources.manager").refresh(state.name)
									end
								end)
							end,
							["K"] = function(state)
								local node = state.tree:get_node()
								local path = node:get_id()

								local stat = vim.uv.fs_stat(path)
								if not stat then
									vim.notify("Could not stat: " .. path, vim.log.levels.ERROR)
									return
								end

								local function fmt_size(bytes)
									if bytes < 1024 then
										return bytes .. " B"
									elseif bytes < 1024 * 1024 then
										return string.format("%.1f KB", bytes / 1024)
									elseif bytes < 1024 * 1024 * 1024 then
										return string.format("%.1f MB", bytes / (1024 * 1024))
									else
										return string.format("%.1f GB", bytes / (1024 * 1024 * 1024))
									end
								end

								local function fmt_time(ts)
									return ts and os.date("%Y-%m-%d %H:%M:%S", ts) or "unknown"
								end

								local owner = vim.fn.system("stat -f '%Su' " .. vim.fn.shellescape(path)):gsub("\n", "")

								local function fmt_mode(mode)
									local perms = { "---", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx" }
									local function bits(shift)
										return perms[math.floor(mode / (2 ^ shift)) % 8 + 1]
									end
									local prefix = stat.type == "directory" and "d" or "-"
									return prefix .. bits(6) .. bits(3) .. bits(0)
								end

								local lines = {
									"  " .. vim.fn.fnamemodify(path, ":t"),
									"",
									"  Path    " .. vim.fn.fnamemodify(path, ":~"),
									"  Type    " .. stat.type,
									"  Size    " .. fmt_size(stat.size),
									"  Mode    " .. fmt_mode(stat.mode),
									"  Owner   " .. owner,
									"  Modified " .. fmt_time(stat.mtime and stat.mtime.sec),
									"  Created  " .. fmt_time(stat.birthtime and stat.birthtime.sec),
								}

								local width = 0
								for _, l in ipairs(lines) do
									width = math.max(width, #l + 2)
								end
								local height = #lines

								local buf = vim.api.nvim_create_buf(false, true)
								vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
								vim.bo[buf].modifiable = false

								local win = vim.api.nvim_open_win(buf, true, {
									relative = "editor",
									width = width,
									height = height,
									row = math.floor((vim.o.lines - height) / 2),
									col = math.floor((vim.o.columns - width) / 2),
									style = "minimal",
									border = "rounded",
									title = " File Info ",
									title_pos = "center",
								})
								vim.wo[win].cursorline = false

								vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
								vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
								vim.keymap.set("n", "K", "<cmd>close<CR>", { buffer = buf, silent = true })
							end,
							["<C-x>"] = function()
								-- Plugin updates now use vim.pack.update; expose it under <C-x>
								-- to mirror the old <C-x> = ":Lazy" binding.
								vim.pack.update()
							end,
							["<leader>sf"] = function(state)
								local node = state.tree:get_node()
								local path = node:get_id()
								if node.type == "file" then
									path = vim.fn.fnamemodify(path, ":h")
								end
								Snacks.picker.files({ cwd = path })
							end,
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
					hide_root_node = true,
					filesystem = {
						follow_current_file = {
							enabled = true,
							leave_dirs_open = true,
						},
						use_libuv_file_watcher = true,
						async_directory_scan = "auto",
						scan_mode = "shallow",
						filtered_items = {
							visible = true,
							hide_dotfiles = false,
							hide_gitignored = false,
							hide_by_name = {
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
						symlink_target = {
							enabled = false,
						},
					},
					reveal = true,
					source_selector = {
						winbar = false,
						statusline = false,
					},
				})
			end,
		},
	},
}
