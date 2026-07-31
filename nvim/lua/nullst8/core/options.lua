local opt = vim.opt

opt.relativenumber = true
opt.nu = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.cindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true

opt.backspace = "indent,eol,start"

opt.splitright = true
opt.splitbelow = true

opt.guicursor = ""

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.hlsearch = false
opt.incsearch = true

opt.scrolloff = 10

-- 250ms balances responsiveness with lower CPU usage from CursorHold events.
opt.updatetime = 250

opt.signcolumn = "no"

opt.pumheight = 10

opt.shada = "!,'20,<50,s10,h"
