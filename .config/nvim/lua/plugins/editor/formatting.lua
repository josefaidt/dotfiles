---@module 'plugins.editor.formatting'
---Conform.nvim formatting configuration with Biome and Prettier support

---@type LazySpec
return {
	"stevearc/conform.nvim",
	dependencies = {
		"williamboman/mason.nvim",
	},
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	-- Keymaps are configured in lua/config/keymaps/plugins.lua
	opts = function()
		local function has_biome_config()
			local root = vim.fs.dirname(vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true })[1])
			if not root then
				return false
			end
			-- Also verify biome is actually installed, otherwise fall through to prettier
			return vim.fn.filereadable(root .. "/node_modules/.bin/biome") == 1
				or vim.fn.exepath("biome") ~= ""
		end

		return {
			notify_on_error = true,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 2000,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				rust = { "rustfmt", lsp_format = "fallback" },
				python = { "ruff_format", "ruff_organize_imports" },

				javascript = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				javascriptreact = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				typescript = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				typescriptreact = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				json = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				jsonc = function()
					if has_biome_config() then
						return { "biome" }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				astro = { "prettierd", "prettier", stop_after_first = true }, -- requires @prettier/plugin-astro
				svelte = { "prettierd", "prettier", stop_after_first = true }, -- requires @prettier/plugin-svelte
				markdown = { "prettierd", "prettier", stop_after_first = true },
			},
		}
	end,
}
