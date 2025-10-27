return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Setup Mason first
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",          -- TypeScript/JavaScript
        "html",           -- HTML
        "cssls",          -- CSS
        "tailwindcss",    -- Tailwind
        "astro",          -- Astro
        "svelte",         -- Svelte
        "emmet_ls",       -- Emmet for HTML/CSS
      },
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- Formatters
        "stylua",
        "prettier",
        "prettierd",
        "biome",
        "eslint",
      },
      auto_update = false,
      run_on_start = true,
    })

    -- Common on_attach function for all LSPs
    local on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      
      -- LSP keybinds
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    end

    -- TypeScript/JavaScript
    vim.lsp.config.ts_ls = {
      on_attach = on_attach,
      filetypes = { 
        "javascript", 
        "javascriptreact", 
        "typescript", 
        "typescriptreact" 
      },
    }

    -- HTML
    vim.lsp.config.html = {
      on_attach = on_attach,
      filetypes = { "html", "htmldjango" },
    }

    -- CSS
    vim.lsp.config.cssls = {
      on_attach = on_attach,
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = "ignore" -- for @tailwind, etc
          }
        },
      },
    }

    -- Tailwind (optional)
    vim.lsp.config.tailwindcss = {
      on_attach = on_attach,
      filetypes = {
        "html",
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "astro",
        "svelte",
      },
    }

    -- Astro
    vim.lsp.config.astro = {
      on_attach = on_attach,
    }

    -- Svelte
    vim.lsp.config.svelte = {
      on_attach = on_attach,
    }

    -- Emmet (HTML/CSS shortcuts)
    vim.lsp.config.emmet_ls = {
      on_attach = on_attach,
      filetypes = {
        "html",
        "css",
        "javascriptreact",
        "typescriptreact",
        "astro",
        "svelte",
      },
    }

    -- Enable the LSPs
    vim.lsp.enable({ 'ts_ls', 'html', 'cssls', 'tailwindcss', 'astro', 'svelte', 'emmet_ls' })
  end,
}