-- return {
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000,
--   lazy = false, -- Load immediately to avoid flash
--   config = function()
--     require("catppuccin").setup({
--       flavour = "mocha", -- latte, frappe, macchiato, mocha
--       styles = {
--         comments = { "italic" },
--         keywords = { "italic" },
--         functions = {},
--         variables = {},
--       },
--     })
--     -- vim.cmd.colorscheme("catppuccin")
--   end,
-- }
-- return {
--   "neanias/everforest-nvim",
--   version = false,
--   lazy = false,
--   priority = 1000, -- make sure to load this before all the other start plugins
--   -- Optional; default configuration will be used if setup isn't called.
--   config = function()
--     require("everforest").setup({
--       -- Your config here
--       background = "hard"
--     })

--     vim.cmd.colorscheme("everforest")
--   end,
-- }
return {
  "sainnhe/everforest",
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    vim.opt.termguicolors = true
    vim.g.everforest_background = "hard"
    vim.g.everforest_enable_italic = true
    vim.cmd.colorscheme("everforest")
  end,
}
