autocmd filetype cpp nnoremap <C-x> :w <bar> !g++ -std=c++17 -O2 -Wall -pthread % -o %:r && ./%:r <cr>
autocmd filetype cpp nnoremap <leader>x :w <bar> !g++ -std=c++17 -O2 -Wall -pthread % -o %:r<cr>
autocmd filetype c nnoremap <C-x> :w <bar> !gcc -Wall -lm % -o %:r && ./%:r <cr>
autocmd filetype c nnoremap <leader>x :w <bar> !gcc -Wall -lm % -o %:r<cr>
autocmd filetype python nnoremap <C-x> :w <bar> !python % <cr>
autocmd filetype perl nnoremap <C-x> :w <bar> !perl % <cr>
autocmd filetype sh nnoremap <C-x> :w <bar> !./% <cr>
autocmd filetype rust nnoremap <C-x> :w <bar> !cargo run -q <cr>
autocmd filetype rust nnoremap <leader>x :w <bar> !cargo build <cr>
autocmd filetype sh nnoremap <C-x> :w <bar> !./% <cr>
autocmd filetype lua nnoremap <C-x> :w <bar> !lua % <cr>
autocmd filetype go nnoremap <C-x> :w <bar> !go run % <cr>
