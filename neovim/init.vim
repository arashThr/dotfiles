" Indentation
set expandtab
set shiftwidth=2

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
map <Leader>f :Files<CR>

" Marks mappings
map <Leader>m :Marks<CR>

let g:vimwiki_list = [{'path': '~/Documents/notes/'}]

" Ag: Only looks at content, not file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Auto save
set autowriteall

" Line numbers
set relativenumber
set number

" Spelling
set spelllang=en
set spellsuggest=best,9

" Highlight spelling error
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=red
hi SpellBad gui=undercurl

source ~/.config/nvim/aliases.vim
