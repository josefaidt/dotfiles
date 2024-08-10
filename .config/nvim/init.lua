-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
require("config.leader")
-- use lazy.nvim for package management
require("config.lazy")
-- require("leap").create_default_mappings()

-- load vscode settings
require("config.vscode")

-- Use the system clipboard for all operations
vim.opt.clipboard = "unnamedplus"

-- unset space bar in normal mode
vim.api.nvim_set_keymap("n", "<SPACE>", "<NOP>", { noremap = true })
-- set `jj` to escape from insert to normal
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })