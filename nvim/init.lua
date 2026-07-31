vim.loader.enable()

-- Reduce LSP log noise and disk I/O from the default DEBUG level.
vim.lsp.log.set_level("WARN")

-- rustaceanvim/nvim-lspconfig still access deprecated `client.request` and
-- `client.notify` on Neovim 0.12. The compat code triggers the deprecation
-- warning just by probing the method. Suppress the noisy LSP client warnings
-- until the plugins are updated. Other deprecation warnings are still shown.
local _deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  if name == 'client.request'
    or name == 'client.notify'
    or name == 'client.is_stopped'
    or name == 'vim.lsp.get_buffers_by_client_id()'
  then
    return nil
  end
  return _deprecate(name, alternative, version, plugin, backtrace)
end

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
