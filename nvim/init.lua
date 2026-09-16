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

-- Neovim 0.12's treesitter injection handling calls `range` on a nil node
-- ("attempt to call method 'range' (a nil value)") for some injected languages:
-- markdown (inline content) and bash (heredocs, e.g. `cat <<'EOF'`).
-- `vim.treesitter.language.add()` accepts no `injections` option, so disable the
-- injection queries directly instead.
for _, lang in ipairs({ "markdown", "bash" }) do
  vim.treesitter.query.set(lang, "injections", "")
end

require("nullst8.core")
require("nullst8.lazy")
