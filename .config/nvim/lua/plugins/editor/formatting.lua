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
	init = function()
		local disable_filetypes = { c = true, cpp = true }
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				if disable_filetypes[vim.bo[args.buf].filetype] then
					return
				end
				local done = false
				local format_err = nil
				require("conform").format({
					bufnr = args.buf,
					timeout_ms = 2000,
					lsp_format = "fallback",
				}, function(err, _did_edit)
					format_err = err
					done = true
				end)
				vim.wait(2500, function()
					return done
				end, 10)
				if format_err then
					vim.notify(format_err, vim.log.levels.ERROR, { title = "conform.nvim" })
				end
			end,
		})
	end,
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
			notify_on_error = false,
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
