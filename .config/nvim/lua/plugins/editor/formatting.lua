---@module 'plugins.editor.formatting'
---Conform.nvim formatting configuration with oxfmt, Biome, and Prettier support

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
		-- Filetypes where the LSP must never be used as a fallback formatter.
		-- Without this, the biome LSP proxy attached to JSON buffers can trigger
		-- stylua (which errors on non-Lua input) when no conform formatter resolves.
		local no_lsp_fallback_filetypes = { json = true, jsonc = true }
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if disable_filetypes[ft] then
					return
				end
				local lsp_format = no_lsp_fallback_filetypes[ft] and "never" or "fallback"
				local done = false
				local format_err = nil
				require("conform").format({
					bufnr = args.buf,
					timeout_ms = 2000,
					lsp_format = lsp_format,
				}, function(err, _did_edit)
					format_err = err
					done = true
				end)
				vim.wait(2500, function()
					return done
				end, 10)
				if format_err and not format_err:match("No formatters available") then
					vim.notify(format_err, vim.log.levels.ERROR)
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

		local function has_prettier_config()
			return vim.fs.find({
				".prettierrc",
				".prettierrc.js",
				".prettierrc.cjs",
				".prettierrc.mjs",
				".prettierrc.json",
				".prettierrc.json5",
				".prettierrc.yaml",
				".prettierrc.yml",
				".prettierrc.toml",
				"prettier.config.js",
				"prettier.config.cjs",
				"prettier.config.mjs",
			}, { upward = true })[1] ~= nil
		end

		-- Choose formatter for JS/TS filetypes.
		-- Priority: biome (if config) > prettier (if config) > oxfmt (default)
		local function get_js_formatter()
			if has_biome_config() then
				return { "biome", stop_after_first = true }
			elseif has_prettier_config() then
				return { "prettierd", "prettier", stop_after_first = true }
			end
			return { "oxfmt" }
		end

		-- Point oxfmt at the dotfile default config so settings like semi=false
		-- and singleQuote=true are always applied. If a project-local oxfmt config
		-- exists in or above the file's directory, skip --config so the project
		-- config takes precedence (checked at format time via ctx.dirname).
		local oxfmt_default_config = vim.fn.expand("$HOME/.config/oxfmt/.oxfmtrc.jsonc")

		return {
			notify_on_error = false,
			formatters = {
				oxfmt = {
					inherit = true,
					prepend_args = function(_, ctx)
						local project_config = vim.fs.find({
							".oxfmtrc.json",
							".oxfmtrc.jsonc",
							".oxfmtrc.js",
							".oxfmtrc.mjs",
							".oxfmtrc.cjs",
							".oxfmtrc.ts",
							".oxfmtrc.mts",
							".oxfmtrc.cts",
						}, { upward = true, path = ctx.dirname })[1]
						if project_config then
							return {}
						end
						return { "--config", oxfmt_default_config }
					end,
				},
			},
			formatters_by_ft = {
				lua = { "stylua" },
				rust = { "rustfmt", lsp_format = "fallback" },
				python = { "ruff_format", "ruff_organize_imports" },

				javascript = get_js_formatter,
				javascriptreact = get_js_formatter,
				typescript = get_js_formatter,
				typescriptreact = get_js_formatter,

				json = function()
					if has_biome_config() then
						return { "biome", stop_after_first = true }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,
				jsonc = function()
					if has_biome_config() then
						return { "biome", stop_after_first = true }
					end
					return { "prettierd", "prettier", stop_after_first = true }
				end,

				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				astro = { "prettierd", "prettier", stop_after_first = true }, -- requires @prettier/plugin-astro
				svelte = { "prettierd", "prettier", stop_after_first = true }, -- requires @prettier/plugin-svelte
				markdown = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
			},
		}
	end,
}
