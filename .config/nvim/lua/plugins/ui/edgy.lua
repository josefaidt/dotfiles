---@module 'plugins.ui.edgy'
---Edgy.nvim - Global window layout settings (laststatus/splitkeep) plus a
---"focus the main editor window" keymap. The Snacks explorer now manages its
---own right-side positioning, so edgy no longer pins a file-tree slot.
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
      desc = "Focus main editor window",
    },
  },
  opts = {
    -- Disable animations for better performance
    ---@type Edgy.Animate
    animate = {
      enabled = false,
    },
    -- Disable edgy's custom window highlights to preserve the original appearance
    ---@type vim.wo
    wo = {
      winhighlight = "",
    },
  },
}
