if vim.g.vscode then
  local fold_filters = require("vscode_amplify_docs_fold_filters")
  -- VSCode extension
  local vscode = require("vscode-neovim")
  -- set vscode as default notifier
  vim.notify = vscode.notify

  -- command to unfold all
  vim.api.nvim_create_user_command(
    'UnfoldAll',
    function()
      require('vscode-neovim').call('editor.unfoldAll')
    end,
    {}
  )

  -- set filter
  vim.api.nvim_create_user_command(
    'AmplifyDocsSetFilter',
    function(opts)
      fold_filters.SetFilter(opts.args)
      vim.api.nvim_command('UnfoldAll')
      fold_filters.FoldNonMatchingFilters()
    end,
    { nargs = 1 }
  )

  -- Define a command to apply the existing filter in a new file
  vim.api.nvim_create_user_command(
    'AmplifyDocsApplyFilter',
    function(opts)
      vim.api.nvim_command('UnfoldAll')
      if opts.args and #opts.args > 0 then
        fold_filters.SetFilter(opts.args)
      end
      fold_filters.FoldNonMatchingFilters()
    end,
    { nargs = '?' }
  )
  -- vscode.call("editor.action.save")
  vim.keymap.set("n", "<leader>w", function() vscode.call("workbench.action.files.save") end)
  vim.keymap.set("n", "<leader>m", function() vscode.call("editor.action.commentLine") end)
  vim.keymap.set("v", "<leader>m", function() vscode.call("editor.action.commentLine") end)
  vim.keymap.set("n", "<leader>uf", ":UnfoldAll<CR>", { noremap = true, silent = false })
  vim.keymap.set("n", "<leader>sf", ":AmplifyDocsSetFilter<Space>", { noremap = true, silent = false })
  vim.keymap.set("n", "<leader>af", ":AmplifyDocsApplyFilter<Space>", { noremap = true, silent = false })
  -- vim.keymap.set("v", "<leader>uf", function() vscode.call("editor.unfoldAll") end)
else
  -- ordinary Neovim
  vim.keymap.set("n", "<leader>w", ":w<CR>")
end