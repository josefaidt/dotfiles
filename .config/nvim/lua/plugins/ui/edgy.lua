---@module 'plugins.ui.edgy'
---Edgy.nvim - Manage neo-tree positioning and prevent it from taking over the window
---https://github.com/folke/edgy.nvim

---@type LazySpec
return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = "screen"
  end,
  ---@type table<string, fun(win:Edgy.Window)|false>
  keys = {
    -- Jump to main editor window
    {
      "<leader>ue",
      function()
        require("edgy").goto_main()
      end,
      desc = "Focus editor (from drawer)",
    },
  },
  opts = {
    ---@type (Edgy.View.Opts|string)[]
    right = {
      -- Neo-tree file explorer on the right. Pin width to 30 columns. The
      -- grow/shrink-on-its-own came from neo-tree's auto_expand_width fitting
      -- long filenames; that's disabled in file-tree.lua. winfixwidth below
      -- additionally stops edgy's layout equalization from nudging the width.
      {
        title = "Files",
        ft = "neo-tree",
        filter = function(buf)
          return vim.b[buf].neo_tree_source == "filesystem"
        end,
        size = { width = 30 },
        wo = {
          -- Lock this window's width so neither edgy's equalization nor a
          -- content-driven resize can move it off 30.
          winfixwidth = true,
        },
      },
    },
    -- Disable animations for better performance
    ---@type Edgy.Animate
    animate = {
      enabled = false,
    },
    -- Disable edgy's custom window highlights to preserve neo-tree's original appearance
    ---@type vim.wo
    wo = {
      winhighlight = "",
    },
  },
}
