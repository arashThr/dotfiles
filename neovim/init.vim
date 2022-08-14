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

set spelllang=en
set spellsuggest=best,9

" Ag: Only looks at content, not file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Auto save
set autowriteall
