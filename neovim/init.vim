" Indentation
set expandtab
set shiftwidth=4

" Better search
set ignorecase
set smartcase

set pastetoggle=<F2>

" Add plugin
lua require('plugins')

" NERDTree
map <Leader>e :NERDTreeFind<CR>
map <F5> :NERDTreeToggle<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>

" CtrlP mappings
map <Leader>b :Buffers<CR>
map <Leader>t :BTag<CR>
map <Leader>p :GFiles<CR>

