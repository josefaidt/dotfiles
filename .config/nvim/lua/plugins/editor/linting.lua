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
			-- Markdown linting with GFM support
			markdown = { "markdownlint-cli2" },
		}

		-- Auto-lint on save and edit.
		-- Use an allowlist of configured filetypes so nvim-lint's built-in defaults
		-- (jsonlint, vale, etc.) never fire for unconfigured filetypes.
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				local ft = vim.bo.filetype
				if not lint.linters_by_filetype[ft] then
					return
				end
				pcall(lint.try_lint)
			end,
		})
	end,
}
