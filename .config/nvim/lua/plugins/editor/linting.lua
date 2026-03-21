---@module 'plugins.editor.linting'
---nvim-lint configuration with oxlint, ESLint, and Biome support

---@type LazySpec
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Disable jsonlint explicitly - we don't want it
		lint.linters.jsonlint = nil

		local function has_oxlint_config()
			return vim.fs.find({ "oxlintrc.json", ".oxlintrc.json" }, { upward = true })[1] ~= nil
		end

		local function has_eslint_config()
			return vim.fs.find({
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
			}, { upward = true })[1] ~= nil
		end

		local function has_biome_config()
			return vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true })[1] ~= nil
		end

		-- Dynamically choose linter based on project config.
		-- Priority: eslint (if config) > biome (if config) > oxlint (default)
		local function get_js_linters()
			if has_eslint_config() then
				return { "eslint" }
			elseif has_biome_config() then
				return { "biomejs" }
			end
			return { "oxlint" }
		end

		-- linters_by_filetype uses functions so detection runs per-buffer
		lint.linters_by_filetype = {
			javascript = get_js_linters,
			javascriptreact = get_js_linters,
			typescript = get_js_linters,
			typescriptreact = get_js_linters,
			-- Return empty array to prevent any fallback to jsonlint
			json = {},
			jsonc = {},
			-- Python linting with ruff
			python = { "ruff" },
			-- YAML linting with yamllint
			yaml = { "yamllint" },
		}

		-- Auto-lint on save and edit.
		-- Skip json/jsonc entirely — nvim-lint's built-in defaults include jsonlint
		-- and setting linters_by_filetype json={} isn't sufficient to suppress it.
		local no_lint_filetypes = { json = true, jsonc = true }
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				if no_lint_filetypes[vim.bo.filetype] then
					return
				end
				pcall(lint.try_lint)
			end,
		})
	end,
}
