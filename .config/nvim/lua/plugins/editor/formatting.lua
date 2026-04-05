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
		-- Find the project root so config searches don't escape into parent directories.
		-- Falls back to $HOME as a hard stop if no root markers are found.
		local function get_project_stop()
			local root = vim.fs.root(0, { ".git", "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", "Cargo.toml", "pyproject.toml" })
			return root and vim.fn.fnamemodify(root, ":h") or vim.env.HOME
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
			}, { upward = true, stop = get_project_stop() })[1] ~= nil
		end

		-- Filetypes with full or experimental Biome support:
		--   JS, TS, JSX, TSX, HTML, CSS, GraphQL, Vue, Svelte, Astro
		-- Priority: oxfmt (default) > prettier (if config); biome is never used as formatter
		local function get_formatter()
			if has_prettier_config() then
				return { "prettierd", "prettier", stop_after_first = true }
			end
			return { "oxfmt" }
		end

		-- JSON/JSONC: oxfmt always wins.
		local function get_json_formatter()
			return { "oxfmt" }
		end

		-- Filetypes Biome does not yet support (SCSS, YAML, Markdown, Less, TOML, MDX, JSON5).
		-- Priority: prettier (if config) > oxfmt (default)
		local function get_prettier_or_oxfmt()
			if has_prettier_config() then
				return { "prettierd", "prettier", stop_after_first = true }
			end
			return { "oxfmt" }
		end

		-- Point oxfmt at the dotfile default config so settings like semi=false
		-- are always applied. If a project-local oxfmt config exists in or above
		-- the file's directory, skip --config so the project config takes precedence.
		local oxfmt_default_config = vim.fn.stdpath("config") .. "/.oxfmtrc.jsonc"

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

				-- Biome fully supported
				javascript = get_formatter,
				javascriptreact = get_formatter,
				typescript = get_formatter,
				typescriptreact = get_formatter,
				html = get_formatter,
				css = get_formatter,
				graphql = get_formatter,

				-- Biome experimental
				vue = get_formatter,
				svelte = get_formatter,
				astro = get_formatter,

				-- Biome supported, no prettier needed
				json = get_json_formatter,
				jsonc = get_json_formatter,

				-- Biome not yet supported, oxfmt as default
				scss = get_prettier_or_oxfmt,
				less = get_prettier_or_oxfmt,
				yaml = get_prettier_or_oxfmt,
				markdown = get_prettier_or_oxfmt,
				mdx = get_prettier_or_oxfmt,
				toml = get_prettier_or_oxfmt,
				json5 = get_prettier_or_oxfmt,
			},
		}
	end,
}
