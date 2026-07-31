return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            -- Disable rust-analyzer's own diagnostics; use bacon-ls instead
            diagnostics = {
              enable = false,
            },
            -- Disable cargo check on save; bacon-ls provides diagnostics
            checkOnSave = false,
            -- Use `cargo check` for the rare case rust-analyzer still runs it
            check = {
              command = "check",
            },
            cargo = {
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
              -- Limit feature resolution to avoid slow workspace-wide analysis
              features = "all",
            },
            procMacro = {
              enable = true,
            },
            -- Disable heavy visual features to keep rust-analyzer responsive.
            -- Toggle them per-buffer if needed.
            semanticHighlighting = {
              enable = false,
            },
            inlayHints = {
              chainingHints = { enable = false },
              typeHints = { enable = false },
              parameterHints = { enable = false },
            },
          },
        },
      },
    }
  end,
}
