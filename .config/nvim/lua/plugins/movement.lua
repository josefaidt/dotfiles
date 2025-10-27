--@type LazySpec
return {
  {
    "ggandor/leap.nvim",
    dependencies = "tpope/vim-repeat",
    config = function()
      -- Remove existing mapping for 'S'
      -- vim.api.nvim_del_keymap('n', 's')
      -- configure leap
      require("leap")

      -- defaults
      -- vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
      -- vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
      -- vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')

      -- bidirectional
      vim.keymap.set('n',        's', '<Plug>(leap)')
      vim.keymap.set('n',        'S', '<Plug>(leap-from-window)')
      vim.keymap.set({'x', 'o'}, 's', '<Plug>(leap-forward)')
      vim.keymap.set({'x', 'o'}, 'S', '<Plug>(leap-backward)')
    end
  }
}