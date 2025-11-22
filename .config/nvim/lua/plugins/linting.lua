return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  priority = 100,
  config = function()
    local lint = require('lint')

    -- CRITICAL: Disable all default linters immediately
    lint.linters_by_filetype = {}

    -- Helper functions
    local function has_biome_config()
      local root = vim.fs.dirname(vim.fs.find({ 'biome.json', 'biome.jsonc' }, { upward = true })[1])
      return root ~= nil
    end

    local function has_eslint_config()
      local root = vim.fs.dirname(vim.fs.find({
        '.eslintrc',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json',
        'eslint.config.js',
        'eslint.config.mjs',
        'eslint.config.cjs',
      }, { upward = true })[1])
      return root ~= nil
    end

    local function get_js_linters()
      if has_eslint_config() then
        return { 'eslint' }
      elseif has_biome_config() then
        return { 'biomejs' }
      end
      return {}
    end

    local function get_json_linters()
      if has_biome_config() then
        return { 'biomejs' }
      end
      return {}
    end

    -- Auto-lint
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        local buftype = vim.bo.buftype
        if buftype ~= '' then
          return
        end

        local ft = vim.bo.filetype
        if ft == '' or ft == 'neo-tree' or ft == 'TelescopePrompt' then
          return
        end

        -- Determine linters dynamically
        local linters = {}
        if ft == 'javascript' or ft == 'javascriptreact' or ft == 'typescript' or ft == 'typescriptreact' then
          linters = get_js_linters()
        elseif ft == 'json' or ft == 'jsonc' then
          linters = get_json_linters()
        end

        -- Update the config for this filetype
        lint.linters_by_filetype[ft] = linters

        -- Only lint if we have linters configured
        if #linters > 0 then
          lint.try_lint()
        end
      end,
    })
  end,
}
