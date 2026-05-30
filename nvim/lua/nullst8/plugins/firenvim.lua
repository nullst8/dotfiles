return {
  "glacambre/firenvim",
  cond = function()
    return vim.g.started_by_firenvim == 1
  end,
  build = function()
    vim.fn["firenvim#install"](0)
  end,
  config = function()
    vim.g.firenvim_config = {
      globalSettings = {
        alt = "all",
      },
      localSettings = {
        [".*"] = {
          takeover = "once",
          priority = 0,
        },
        ["https://www.google.com/"] = {
          takeover = "never",
        },
        ["https://www.reddit.com/"] = {
          takeover = "always",
        },
      },
    }
  end,
}
