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

let g:ctrlp_map = '<C-p>'
let g:ctrlp_working_path_mode = 0 " don’t manage working directory.
let g:ctrlp_use_caching = 1
let g:ctrlp_custom_ignore = {
\ 'dir':  'node_modules'
 \ }
