-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Prefer ruff as the Python "LSP" until npm is available for pyright.
-- ruff is already installed via Mason; pyright requires node/npm.
vim.g.lazyvim_python_lsp = "ruff"
