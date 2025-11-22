return {
  "rmagatti/auto-session",
  lazy = false,
  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    auto_restore_enabled = true,
    auto_save_enabled = true,
    suppressed_dirs = { "~/", "~/Downloads", "/" },
  },
}
