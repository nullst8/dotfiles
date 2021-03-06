syntax on

so ~/.config/nvim/plugins.vim

let g:gruvbox_italic=1
colo gruvbox

let mapleader = " "


nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <leader>k :m .-2<cr>
nnoremap <leader>j :m .+1<cr>

so ~/.config/nvim/execute.vim

lua << EOF
require('telescope').setup{
  -- see :help telescope.setup()
  defaults = {
    -- The below pattern is lua regex and not wildcard
    file_ignore_patterns = {"node_modules","%.out"},
  }
}
EOF

" Find files using Telescope command-line sugar.
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

fun! TrimWhiteSpace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

fun! IsGit()
  if isdirectory(".git")
    nnoremap <C-p> <cmd>Telescope git_files<cr>
  else
    nnoremap <c-p> <cmd>Telescope find_files<cr>
  endif
endfun

augroup ATTIC
  autocmd!
  autocmd BufWritePre * :call TrimWhiteSpace()
  autocmd VimEnter * :call IsGit()
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
" autocmd BufEnter * silent! lcd %:p:h
"Replace Line
vnoremap K :m '<-2<cr>gv=gv
vnoremap J :m '>+1<cr>gv=gv
" Fugitive1e1e1e
nmap <leader>gs :G<cr>
" format on save
augroup fmt
  autocmd!
  au BufWritePre * try | undojoin | Neoformat | catch /^Vim\%((\a\+)\)\=:E790/ | finally | silent Neoformat | endtry
augroup END

so ~/.config/nvim/startify.vim

let g:neoformat_enabled_javascript = ['prettierd']
let g:neoformat_enabled_javascriptreact = ['prettierd']
let g:neoformat_enabled_typescriptreact = ['prettierd']
let g:neoformat_enabled_typescript = ['prettierd']

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

set background=dark
hi Normal guibg=none ctermbg=none

" lua << EOF
" require'lualine'.setup{
" options = {
"     icons_enabled = false,
"     theme = 'auto',
"     component_separators = { left = '', right = ''},
"     section_separators = { left = '', right = ''},
"     disabled_filetypes = {},
"     always_divide_middle = true,
"   },
"   sections = {
"     lualine_a = {'mode'},
"     lualine_b = {'branch', 'diff', 'diagnostics'},
"     lualine_c = {'filename'},
"     lualine_x = {'encoding', 'fileformat', 'filetype'},
"     lualine_y = {'progress'},
"     lualine_z = {'location'}
"   },
"   inactive_sections = {
"     lualine_a = {},
"     lualine_b = {},
"     lualine_c = {'filename'},
"     lualine_x = {'location'},
"     lualine_y = {},
"     lualine_z = {}
"   },
"   tabline = {},
"   extensions = {'fugitive'}
" }
" EOF

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

so ~/.config/nvim/nerdtree.vim

let g:bufferline_show_bufnr = 1

" Move to previous/next
nnoremap <silent>    <A-,> :BufferPrevious<CR>
nnoremap <silent>    <A-.> :BufferNext<CR>
" Re-order to previous/next
nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
nnoremap <silent>    <A->> :BufferMoveNext<CR>
" Goto buffer in position...
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>
" Pin/unpin buffer
nnoremap <silent>    <A-p> :BufferPin<CR>
" Close buffer
nnoremap <silent>    <A-c> :BufferClose<CR>

lua << EOF
require('el').setup()
EOF

so ~/.config/nvim/sets.vim

tmap <Esc> <C-\><C-n>
nnoremap <silent><leader>l :OneTerm term<cr>
