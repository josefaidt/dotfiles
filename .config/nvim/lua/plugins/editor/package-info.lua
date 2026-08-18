---@module 'plugins.editor.package-info'
---package-info.nvim — inline dependency version/outdated/vulnerable hints for
---package.json, plus actions to install/update/change/delete deps.
---https://github.com/vuki656/package-info.nvim
---
---Loads only for package.json. nui.nvim is already installed (noice stack), so
---lazy resolves the shared dependency rather than managing a second copy. All
---action maps are buffer-local (package.json only) and registered under the
---<leader>c (code) group via a buffer-local which-key group label.

---@type LazySpec
return {
	"vuki656/package-info.nvim",
	event = { "BufRead package.json" },
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		-- Inline version + outdated/vulnerable hints as virtual text.
		hide_up_to_date = false,
		package_manager = "npm",
	},
	config = function(_, opts)
		local package_info = require("package-info")
		package_info.setup(opts)

		-- Buffer-local actions, only live inside package.json. Grouped under the
		-- <leader>c (code) prefix; the group label is registered per-buffer.
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "package.json",
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
				end

				map("<leader>cv", package_info.show, "Package show versions")
				map("<leader>ct", package_info.toggle, "Package toggle hints")
				map("<leader>cu", package_info.update, "Package update")
				map("<leader>cx", package_info.delete, "Package delete")
				map("<leader>cn", package_info.install, "Package install new")
				map("<leader>cp", package_info.change_version, "Package change version")

				-- Register the which-key group label for this buffer only.
				local ok, wk = pcall(require, "which-key")
				if ok then
					wk.add({ { "<leader>c", group = "code/package", buffer = event.buf } })
				end
			end,
		})
	end,
}
