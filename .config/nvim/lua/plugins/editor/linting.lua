---@module 'plugins.editor.linting'
---nvim-lint configuration with oxlint, ESLint, and Biome support

---@type LazySpec
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

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

		-- Point markdownlint-cli2 at the dotfile default config when no project
		-- config exists, so noisy rules (MD013, MD033, MD041) are always disabled.
		-- Project configs (.markdownlint.json etc.) take precedence when present.
		local markdownlint_project_config = vim.fs.find({
			".markdownlint.json",
			".markdownlint.jsonc",
			".markdownlint.yaml",
			".markdownlint.yml",
			".markdownlint-cli2.jsonc",
			".markdownlint-cli2.yaml",
			".markdownlint-cli2.cjs",
			".markdownlint-cli2.mjs",
		}, { upward = true })[1]
		if not markdownlint_project_config then
			local default = vim.fn.stdpath("config") .. "/.markdownlint.json"
			if vim.fn.filereadable(default) == 1 then
				lint.linters["markdownlint-cli2"].args = { "--config", default, "-" }
			end
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

		-- Replace nvim-lint's default linters_by_ft entirely so built-in defaults
		-- (vale, jsonlint, etc.) never fire. Only filetypes listed here are linted.
		lint.linters_by_ft = {
			javascript = get_js_linters,
			javascriptreact = get_js_linters,
			typescript = get_js_linters,
			typescriptreact = get_js_linters,
			json = {},
			jsonc = {},
			python = { "ruff" },
			yaml = { "yamllint" },
			markdown = { "markdownlint-cli2" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				pcall(lint.try_lint)
			end,
		})
	end,
}
