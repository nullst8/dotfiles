return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    mason.setup()

    local servers = { "lua_ls", "rust_analyzer", "clangd", "ts_ls" }
    mason_lspconfig.setup({
      ensure_installed = servers,
      -- Only enable these servers, not all 18 mason-installed ones
      automatic_enable = servers,
    })

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          check = { command = "check" },
          diagnostics = { enable = true },
          cargo = { loadOutDirsFromCheck = true },
          files = { excludeDirs = { "target", "node_modules" } },
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

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
    })
  end,
}
