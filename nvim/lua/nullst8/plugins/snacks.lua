return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    picker = { enabled = true },
  },
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<C-p>", function() Snacks.picker.git_files() end, desc = "Git files" },
    { "<leader>fc", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
    { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers" },
  },
}
