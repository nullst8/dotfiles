return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 5,
      multiline_threshold = 3,
      separator = "─",
    })
  end,
}
