syntax on

so ~/.config/nvim/sets.vim
so ~/.config/nvim/plugins.vim
" so ~/.config/nvim/coc.vim

let g:gruvbox_contrast_dark='medium'
colorscheme darkplus

" lua require('colorbuddy').colorscheme('gruvbuddy')
let mapleader = " "

so ~/.config/nvim/telescope.vim

nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <leader>k :m .-2<cr>
nnoremap <leader>j :m .+1<cr>

so ~/.config/nvim/execute.vim

fun! TrimWhiteSpace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

augroup MANAS
  autocmd!
  autocmd BufWritePre * :call TrimWhiteSpace()
augroup END

nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

"" Resize Splits
nnoremap <silent> <C-h> :vertical resize +3<cr>
nnoremap <silent> <C-l> :vertical resize -3<cr>
nnoremap <silent> <C-k> :resize +3<cr>
nnoremap <silent> <C-j> :resize -3<cr>

nnoremap <silent> <C-s> :w<cr>

" Set Current direcotry based on the file opened
autocmd BufEnter * silent! lcd %:p:h
"Replace Line
vnoremap K :m '<-2<cr>gv=gv
vnoremap J :m '>+1<cr>gv=gv
" Fugitive
nmap <leader>gs :G<cr>
" Terminal Toggle
nnoremap <silent> <leader>l :ToggleTerm<cr>
tnoremap <Esc> <C-\><C-n>
" format on save
augroup fmt
  autocmd!
  au BufWritePre * try | undojoin | Neoformat | catch /^Vim\%((\a\+)\)\=:E790/ | finally | silent Neoformat | endtry
augroup END

so ~/.config/nvim/startify.vim

let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_javascriptreact = ['prettier']
let g:neoformat_enabled_typescriptreact = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']

command Gruvbuddy lua require('colorbuddy').colorscheme('gruvbuddy')

so ~/.config/nvim/treesitter.vim
so ~/.config/nvim/cmplsp.vim

" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

nnoremap <silent><leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent><C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>

let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+'
nnoremap <silent><C-n> :Ex<CR>

set background=dark
" hi Normal guibg=none ctermbg=none

lua << EOF
require'lualine'.setup{
options = {
    icons_enabled = false,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {'fugitive'}
}
EOF

lua << EOF
  require('Comment').setup()
EOF

if has("persistent_undo")
   let target_path = expand('~/.undodir')

    " create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif

    let &undodir=target_path
    set undofile
endif

nnoremap <silent><leader>u :UndotreeToggle<CR>
