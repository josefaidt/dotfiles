return {
	"mfussenegger/nvim-lint",
	{
		event = { "BufReadPre", "BufNewFile" },
		setup = function()
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

			local yamllint_project_config = vim.fs.find({
				".yamllint",
				".yamllint.yml",
				".yamllint.yaml",
			}, { upward = true })[1]
			if not yamllint_project_config then
				local default = vim.fn.stdpath("config") .. "/.yamllint"
				if vim.fn.filereadable(default) == 1 then
					lint.linters.yamllint.args = { "--format", "parsable", "-c", default, "-" }
				end
			end

			local function get_js_linters()
				if has_eslint_config() then
					return { "eslint" }
				end
				return { "oxlint" }
			end

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
	},
}
