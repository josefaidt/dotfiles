---@module 'plugins.editor.comment'
---Comment.nvim configuration for code commenting
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("Comment").setup({
      -- Add any custom configuration here
      padding = true,
      sticky = true,
      ignore = "^$", -- Ignore empty lines
    })

    -- Custom keybindings for <leader>m
    local api = require("Comment.api")

    -- Normal mode: toggle comment for current line
    vim.keymap.set("n", "<leader>m", function()
      api.toggle.linewise.current()
    end, { desc = "Toggle comment" })

    -- Visual mode: toggle comment for selected lines
    vim.keymap.set("v", "<leader>m", function()
      local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
      vim.api.nvim_feedkeys(esc, "nx", false)
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = "Toggle comment" })
  end,
}
