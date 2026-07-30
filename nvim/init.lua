vim.loader.enable()

-- Neovim 0.12.3's built-in markdown parser has a bug in injection processing
-- (markdown_inline) that causes "attempt to call method 'range' (a nil value)".
-- Disable injections for markdown to avoid the bug while keeping basic parsing.
for _, lang in ipairs({ "markdown", "markdown_inline" }) do
  local path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/" .. lang .. ".so"
  if not vim.uv.fs_stat(path) then
    path = "/usr/share/nvim/runtime/parser/" .. lang .. ".so"
  end
  if vim.uv.fs_stat(path) then
    vim.treesitter.language.add(lang, { path = path, injections = false })
  end
end

require("nullst8.core")
require("nullst8.lazy")
