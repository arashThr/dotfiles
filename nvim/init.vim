" Indentation
set expandtab
set shiftwidth=4

" Better search
set ignorecase
set smartcase

nmap <F8> :TagbarToggle<CR>
set pastetoggle=<F2>

" Add plugin
lua require('plugins')

" CtrlP mappings
map <Leader>b :CtrlPBuffer<CR>
map <Leader>t :CtrlPBufTag<CR>
map <Leader>p :Files<CR>

