-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false,                    -- neo-tree will lazily load itself
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      window = {
        width = 30, -- Default is 40, try 25-35
      },
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      -- Auto-open neo-tree when opening a directory
      -- vim.api.nvim_create_autocmd("VimEnter", {
      --   callback = function()
      --     -- Use defer_fn to avoid race conditions with other autocmds
      --     vim.defer_fn(function()
      --       if vim.fn.argc() == 0 then
      --         -- Opened nvim with no arguments
      --         vim.cmd("Neotree show")
      --       elseif vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      --         -- Opened nvim with a directory argument
      --         vim.cmd("Neotree show")
      --       end
      --     end, 10) -- 10ms delay
      --   end,
      -- })
    end,
  }
}
