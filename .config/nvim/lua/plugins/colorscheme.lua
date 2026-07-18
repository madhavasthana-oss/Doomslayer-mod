-- Doomshell colorscheme is a plain colors/doomshell.lua file (no plugin
-- download needed), so we just register a fake "plugin" that does nothing
-- but exists to set priority/load order, and tell LazyVim to use it.
return {
  -- Disable/dim the default LazyVim colorscheme plugins so they don't
  -- fight for priority (optional — keep them installed for :colorscheme
  -- switching, just don't force-load them first).
  { "folke/tokyonight.nvim", lazy = true },
  { "catppuccin/nvim", lazy = true },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "doomshell",
    },
  },
}
