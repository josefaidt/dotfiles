---@type LazySpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    -- How the `s`/`S` jump keys interpret what you type: "search" = regex.
    search = {
      mode = "search",
      incremental = false,
    },
    -- Rainbow-colored jump labels for `s`/`S`.
    label = {
      rainbow = {
        enabled = true,
      },
    },
    modes = {
      -- Disable flash labels during regular `/` and `?` search. The label
      -- workflow (type a label char instead of <CR> to jump) conflicts with
      -- normal search-then-<CR> muscle memory — pressing <CR> just clears
      -- the labels, so it added flicker without value. Flash jumping stays
      -- on the dedicated `s`/`S` keys below.
      search = {
        enabled = false,
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
  },
}
