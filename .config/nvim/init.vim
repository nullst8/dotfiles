syntax on

so ~/.config/nvim/sets.vim
so ~/.config/nvim/plugins.vim

set background=dark
let g:gruvbox_contrast_dark='medium'
colorscheme gruvbox
" lua require('colorbuddy').colorscheme('gruvbuddy')
" Use terminal background
"hi Normal guibg=none ctermbg=none
"
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

let g:airline_left_sep = ''
let g:airline_right_sep = ''

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

let g:dashboard_default_executive ='telescope'
nmap <Leader>ss :<C-u>SessionSave<CR>
nmap <Leader>sl :<C-u>SessionLoad<CR>
nnoremap <silent> <Leader>fh :DashboardFindHistory<CR>
nnoremap <silent> <Leader>ff :DashboardFindFile<CR>
nnoremap <silent> <Leader>tc :DashboardChangeColorscheme<CR>
nnoremap <silent> <Leader>fa :DashboardFindWord<CR>
nnoremap <silent> <Leader>fb :DashboardJumpMark<CR>
nnoremap <silent> <Leader>cn :DashboardNewFile<CR>
