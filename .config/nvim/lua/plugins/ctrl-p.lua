return {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      -- Your telescope config here
      defaults = {
        layout_strategy = 'vertical',
        -- ... other settings
      },
    })
    
    -- keybinds specific to telescope
    local builtin = require('telescope.builtin')

    -- Cmd+P
    vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = 'Find files' })
    -- Cmd+Shift+P
    vim.keymap.set('n', '<leader>P', builtin.commands, { desc = 'Command palette' })
    -- Cmd+Shift+F
    vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Search in files' })
    -- switch open buffers (ctrl+tab?)
    vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Switch buffer' })
    -- vim help
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
    -- recently opened
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
  end,
}