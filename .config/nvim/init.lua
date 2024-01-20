vim.api.nvim_set_keymap('n', '<SPACE>', '<NOP>', { noremap = true })
vim.g.mapleader = " "
if vim.g.vscode then
  -- VSCode extension
  local vscode = require('vscode-neovim')
  -- set vscode as default notifier
  vim.notify = vscode.notify
  vim.keymap.set('n', '<leader>w', function() vscode.call("workbench.action.files.save") end) 
  vim.keymap.set('n', '<leader>m', function() vscode.call("editor.action.commentLine") end) 
  vim.keymap.set('v', '<leader>m', function() vscode.call("editor.action.commentLine") end) 
else
  -- ordinary Neovim
  vim.keymap.set('n', '<leader>w', ':w<CR>')
end