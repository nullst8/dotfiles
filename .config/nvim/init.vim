syntax on

so ~/.config/nvim/sets.vim
so ~/.config/nvim/plugins.vim

colo gruvbox

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

" netrw
let g:netrw_banner = 0      " hide banner
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:NetrwIsOpen=0
let g:netrw_winsize = 25

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

nnoremap <silent><C-n> :call ToggleNetrw()<cr>

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

" ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" buffers
" Move to previous/next
nnoremap <silent>    <A-,> :bp<CR>
nnoremap <silent>    <A-.> :bn<CR>
" delete buffer
nnoremap <silent>    <A-c> :bd<CR>
let g:bufferline_show_bufnr = 0
