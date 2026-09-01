return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },

  config = function()
    require("nvim-treesitter.configs").setup({
      indent = {
        enable = true,
        disable = { "c", "cpp" },
      },
      highlight = { enable = true },
      autotag = { enable = true },

      ensure_installed = {
        "vimdoc",
        "javascript",
        "typescript",
        "c",
        "lua",
        "rust",
        "jsdoc",
        "bash",
        "markdown",
        "markdown_inline",
      },
    })
  end,
}
