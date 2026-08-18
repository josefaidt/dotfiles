---@module 'plugins.editor.crates'
---crates.nvim — inline version/feature management for Cargo.toml.
---https://github.com/saecki/crates.nvim
---
---Loads only for Cargo.toml. Enables inline version + outdated hints via
---virtual text. Completion is wired into blink.cmp through crates' own blink
---source (registered on the crates.nvim source list), scoped to Cargo.toml.
---All action maps are buffer-local and registered under the <leader>c (code)
---group via a buffer-local which-key group label.

---@type LazySpec
return {
	"saecki/crates.nvim",
	event = { "BufRead Cargo.toml" },
	dependencies = { "saghen/blink.cmp" },
	---@module 'crates.config'
	---@type crates.UserConfig
	opts = {
		-- Inline version/outdated hints rendered as virtual text on each dep line.
		completion = {
			-- crates.nvim ships a native blink.cmp source; enabling it here lets
			-- blink pull crate names/versions/features from within Cargo.toml.
			crates = { enabled = true },
			cmp = { enabled = false },
		},
		lsp = {
			enabled = true,
			-- Route actions/hover/completion through crates' pseudo-LSP so they
			-- integrate with the existing LSP keymaps (K, code actions).
			actions = true,
			completion = true,
			hover = true,
		},
	},
	config = function(_, opts)
		local crates = require("crates")
		crates.setup(opts)

		-- Buffer-local actions, only live inside Cargo.toml. Grouped under the
		-- <leader>c (code) prefix; the group label is registered per-buffer.
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "Cargo.toml",
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
				end

				map("<leader>cu", crates.update_crate, "Crate update")
				map("<leader>cU", crates.upgrade_crate, "Crate upgrade")
				map("<leader>cv", crates.show_versions_popup, "Crate versions")
				map("<leader>ce", crates.show_features_popup, "Crate features")
				map("<leader>cD", crates.show_dependencies_popup, "Crate dependencies")
				map("<leader>co", crates.open_documentation, "Crate open docs")
				map("<leader>ci", crates.open_crates_io, "Crate open crates.io")

				-- Register the which-key group label for this buffer only.
				local ok, wk = pcall(require, "which-key")
				if ok then
					wk.add({ { "<leader>c", group = "code/crate", buffer = event.buf } })
				end
			end,
		})
	end,
}
