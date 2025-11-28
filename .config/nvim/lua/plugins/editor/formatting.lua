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
			return root ~= nil
		end

		return {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },

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
				astro = { "prettier" }, -- prettierd doesn't support astro
				svelte = { "prettier" }, -- prettierd doesn't support svelte
				markdown = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
			},
		}
	end,
}
