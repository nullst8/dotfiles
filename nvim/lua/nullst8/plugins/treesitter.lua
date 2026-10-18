return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },

  config = function()
    -- Mason's setup() runs lazily (on first buffer), so expose its bin dir now
    -- for the tree-sitter CLI.
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = vim.env.PATH .. ":" .. mason_bin
    end

    local ts = require("nvim-treesitter")
    ts.setup()

    -- Parsers are compiled with the tree-sitter CLI (installed via Mason).
    ts.install({
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
    })

    require("nvim-ts-autotag").setup()

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("nullst8.Treesitter", { clear = true }),
      callback = function(ev)
        if not pcall(vim.treesitter.start, ev.buf) then
          return
        end
        if not vim.tbl_contains({ "c", "cpp" }, vim.bo[ev.buf].filetype) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
