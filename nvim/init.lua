vim.loader.enable()

-- Reduce LSP log noise and disk I/O from the default DEBUG level.
vim.lsp.log.set_level("WARN")

require("nullst8.core")
require("nullst8.lazy")
