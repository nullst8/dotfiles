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
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-p> <cmd>Telescope git_files<cr>
