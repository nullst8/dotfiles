return {
  "folke/noice.nvim",
  event = "UIEnter",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lsp = {
      override = {
        "vim.lsp.util.convert_input_to_markdown",
        "vim.lsp.util.stylify_markdown",
        "cmp.entry.get_documentation",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
    },
  },
}
