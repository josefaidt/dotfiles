return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Disable jsonlint explicitly - we don't want it
		lint.linters.jsonlint = nil

		-- Helper function to check if biome config exists
		local function has_biome_config()
			local root = vim.fs.dirname(vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true })[1])
			return root ~= nil
		end

		-- Helper function to check if eslint config exists
		local function has_eslint_config()
			local root = vim.fs.dirname(vim.fs.find({
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
			}, { upward = true })[1])
			return root ~= nil
		end

		-- Dynamically choose linter based on project config
		local function get_js_linters()
			if has_eslint_config() then
				return { "eslint" }
			elseif has_biome_config() then
				return { "biomejs" }
			end
			return {} -- No linting if no config found
		end

		-- Setup linters
		lint.linters_by_filetype = {
			javascript = get_js_linters(),
			javascriptreact = get_js_linters(),
			typescript = get_js_linters(),
			typescriptreact = get_js_linters(),
			-- Use biome for JSON, but only if it exists
			-- Return empty array to prevent any fallback to jsonlint
			json = {},
			jsonc = {},
		}

		-- Auto-lint on save and edit
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				local ft = vim.bo.filetype
				-- Only lint if we have a linter configured for this filetype
				local linters = lint.linters_by_filetype[ft]
				if linters and #linters > 0 then
					pcall(lint.try_lint)
				end
			end,
		})
	end,
}
