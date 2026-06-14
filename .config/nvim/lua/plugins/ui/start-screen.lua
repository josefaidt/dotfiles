---@module 'plugins.ui.start-screen'
---Startup dashboard via alpha-nvim. Buttons match the bindings actually
---wired up in this config (snacks pickers, persistence sessions, etc.).

---@type LazySpec
return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "folke/persistence.nvim" },
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "██████╗ ███████╗███╗   ██╗ █████╗ ██╗     ██╗",
      "██╔══██╗██╔════╝████╗  ██║██╔══██╗██║     ██║",
      "██║  ██║█████╗  ██╔██╗ ██║███████║██║     ██║",
      "██║  ██║██╔══╝  ██║╚██╗██║██╔══██║██║     ██║",
      "██████╔╝███████╗██║ ╚████║██║  ██║███████╗██║",
      "╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝",
    }

    -- Resolve the session that "Restore session" will load and surface the
    -- git branch on the button so the user sees what they're about to open.
    -- Returns the label plus the byte column where the dimmed suffix begins
    -- (or nil if there's no suffix to dim).
    local function session_label()
      local base = "  Restore session"
      local ok, persistence = pcall(require, "persistence")
      if not ok then
        return base, nil
      end
      if vim.fn.filereadable(persistence.current()) == 0 then
        return base .. " (none for this dir)", #base
      end
      local branch = persistence.branch and persistence.branch() or nil
      if not branch or branch == "" then
        return base, nil
      end
      return base .. " (" .. branch .. ")", #base
    end

    -- Keep "Restore session" in the normal button color and dim only the
    -- trailing " (branch)" annotation so it reads as secondary info.
    local label, suffix_col = session_label()
    local restore_btn =
      dashboard.button("s", label, "<cmd>lua require('persistence').load()<CR>")
    if suffix_col then
      -- alpha's opts.hl accepts a list of { group, col_start, col_end }
      -- regions; dim from the suffix to the end of the line (-1).
      restore_btn.opts.hl = { { "Comment", suffix_col, -1 } }
    end

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", "<cmd>enew<CR>"),
      dashboard.button(
        "f",
        "  Find file",
        "<cmd>lua Snacks.picker.files()<CR>"
      ),
      dashboard.button("g", "  Grep", "<cmd>lua Snacks.picker.grep()<CR>"),
      -- `session` arg makes pick_worktree restore the worktree's session
      -- after tcd (falling back to a file picker), replacing the dashboard
      -- with something actionable.
      dashboard.button("w", "  Worktrees", "<cmd>PickWorktree session<CR>"),
      restore_btn,
      dashboard.button(
        "S",
        "  Select session",
        "<cmd>lua require('persistence').select()<CR>"
      ),
      dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
    }
    -- Tighten the dashboard: no blank lines between buttons.
    dashboard.section.buttons.opts.spacing = 0

    require("alpha").setup(dashboard.config)

    -- Open the dashboard plus the file-tree, leaving alpha focused. Used both
    -- when launching on a directory and when the last real buffer is closed.
    --
    -- Ordering matters. Alpha latches onto whatever window is current at :Alpha
    -- time and stores its id in state.windows[1], then keys its WinResized redraw
    -- off that id WITHOUT re-resolving it. If neo-tree opens *after* alpha, its
    -- split resizes/invalidates alpha's window and the next resize event throws
    -- "Invalid window id" from alpha's own draw(). So open neo-tree FIRST, let
    -- the layout settle, then render alpha into the (now stable) main window.
    local function open_dashboard()
      -- Reveal neo-tree first so its side split is in place before alpha latches
      -- onto its window. Guard on the command existing — during a fresh startup
      -- neo-tree may still be loading via lazy.nvim.
      if vim.fn.exists(":Neotree") ~= 0 then
        pcall(vim.cmd, "Neotree show")
      end
      -- Land in the main editor window (anything that isn't the neo-tree split),
      -- so alpha renders there rather than inside the tree.
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
      -- :Alpha renders into the current buffer; netrw's directory listing is
      -- 'nomodifiable', so give the window a fresh scratch buffer to draw into.
      local win = vim.api.nvim_get_current_win()
      local scratch = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(win, scratch)
      pcall(vim.cmd, "Alpha")
    end

    local group =
      vim.api.nvim_create_augroup("alpha-dashboard", { clear = true })

    -- `nvim .` (or any directory arg) lands on a netrw/directory buffer that
    -- alpha's own VimEnter handler skips because argc() > 0. Detect that case
    -- and swap in the dashboard + file-tree instead. Defer the actual swap until
    -- after startup settles (lazy.nvim done loading neo-tree, alpha's own
    -- VimEnter handler finished) so we don't race their window/buffer setup.
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      nested = true,
      callback = function()
        if vim.fn.argc() ~= 1 then
          return
        end
        local arg = vim.fn.argv(0)
        if type(arg) ~= "string" or vim.fn.isdirectory(arg) == 0 then
          return
        end
        -- Make the directory the cwd so the dashboard's Find file / Grep /
        -- session resolution all operate where we were pointed.
        pcall(vim.cmd.tcd, arg)
        local dir_buf = vim.api.nvim_get_current_buf()
        vim.schedule(function()
          open_dashboard()
          -- Wipe the directory listing buffer netrw created for the arg, now
          -- that alpha owns the window.
          if
            vim.api.nvim_buf_is_valid(dir_buf)
            and vim.bo[dir_buf].filetype ~= "alpha"
          then
            pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
          end
        end)
      end,
    })

    -- When the last real (listed, named) buffer is deleted, fall back to the
    -- dashboard instead of an empty [No Name] scratch buffer. Snacks.bufdelete
    -- already preserves window layout, so we just need to fill the void.
    vim.api.nvim_create_autocmd("BufDelete", {
      group = group,
      nested = true,
      callback = function()
        vim.schedule(function()
          -- Count remaining listed buffers with a real file name.
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if
              vim.api.nvim_buf_is_valid(buf)
              and vim.bo[buf].buflisted
              and vim.api.nvim_buf_get_name(buf) ~= ""
            then
              return
            end
          end
          -- None left — show the dashboard.
          open_dashboard()
        end)
      end,
    })
  end,
}
