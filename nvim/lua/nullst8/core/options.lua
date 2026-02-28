local opt = vim.opt

opt.relativenumber = true
opt.nu = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

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

opt.scrolloff = 8

opt.updatetime = 50

opt.signcolumn = "no"

opt.pumheight = 10
