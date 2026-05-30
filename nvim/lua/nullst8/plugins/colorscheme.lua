return {
  "ellisonleao/gruvbox.nvim",
  event = "UIEnter",

  config = function()
    vim.cmd([[colorscheme gruvbox]])

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
  end,
}
