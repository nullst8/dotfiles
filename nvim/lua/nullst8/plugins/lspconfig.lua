return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "saghen/blink.cmp",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    mason.setup()

    -- Formatters and tools used elsewhere in the config (conform, treesitter).
    require("mason-tool-installer").setup({
      ensure_installed = { "stylua", "black", "prettierd", "prettier", "tree-sitter-cli" },
    })

    -- rust_analyzer is managed by rustaceanvim, but install the binary via Mason
    -- bacon_ls provides cargo check diagnostics for Rust
    local auto_enable_servers = { "lua_ls", "clangd", "ts_ls", "pyright", "bacon_ls" }
    local ensure_installed_servers = { "lua_ls", "rust_analyzer", "clangd", "ts_ls", "pyright", "bacon_ls" }
    mason_lspconfig.setup({
      ensure_installed = ensure_installed_servers,
      -- Only auto-enable these servers; rust_analyzer is handled by rustaceanvim
      automatic_enable = auto_enable_servers,
    })

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.config("bacon_ls", {
      -- live diagnostics while typing (cargo backend only)
      init_options = {
        cargo = {
          updateOnInsert = true,
        },
      },
      settings = {
        bacon_ls = {
          -- Use the cargo backend: bacon-ls runs `cargo check` directly,
          -- no separate `bacon` process or terminal needed.
          backend = "cargo",
          cargo = {
            command = "check",              -- faster than clippy
            checkOnSave = true,             -- run check on save
            cancelRunning = true,           -- cancel stale runs
            refreshIntervalSeconds = 1,     -- publish partial results every second
            updateOnInsertDebounceMillis = 500, -- debounce live typing diagnostics
          },
        },
      },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "hl" },
          },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoImportCompletions = true,
          },
        },
      },
    })

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = true,
    })
  end,
}
