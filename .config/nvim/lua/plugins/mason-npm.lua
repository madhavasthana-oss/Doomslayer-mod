-- Mason installs pyright and vtsls via npm.
-- You have no node/npm, so those installs spam errors on every start.
--
-- This is NOT a Lua bug and NOT a Python bug — it is a missing Node.js
-- toolchain. Your Python 3.14 is fine; ruff is already installed via Mason.
--
-- `vim.g.lazyvim_python_lsp = "ruff"` (see options.lua) stops LazyVim from
-- selecting pyright. This file also hard-disables the npm-based servers and
-- restores ruff hover (LazyVim disables ruff hover when pyright is expected).
--
-- After `sudo pacman -S npm`, you can:
--   1. Remove this file
--   2. Delete the lazyvim_python_lsp line in options.lua
--   3. :Lazy reload  then  :MasonInstall pyright vtsls

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      for _, name in ipairs({ "pyright", "basedpyright", "vtsls", "tsserver" }) do
        opts.servers[name] = vim.tbl_deep_extend("force", opts.servers[name] or {}, {
          enabled = false,
          mason = false,
        })
      end

      -- Override LazyVim python extra: it disables ruff hover "in favor of pyright".
      -- With pyright off, leave hover alone. Returning nil keeps default lsp setup.
      opts.setup = opts.setup or {}
      opts.setup.ruff = function() end
    end,
  },
}
