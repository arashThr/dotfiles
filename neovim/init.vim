" Indentation
set expandtab
set shiftwidth=2
set tabstop=2

" Theme
colorscheme wildcharm

" Better search
set ignorecase
set smartcase

set pastetoggle=<F2>

" Add plugin
lua require('plugins')

" NERDTree
nnoremap <Leader>e :NERDTreeFind<CR>
map <F5> :NERDTreeToggle<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>

" Make mappings
nnoremap <leader>mr :!make run<CR>
nnoremap <leader>mb :!make build<CR>
nnoremap <leader>mc :!make clean<CR>
nmap <F10> :!make<CR>

" Telescope mappings
nnoremap <Leader>b :Telescope buffers<CR>
nnoremap <Leader>p :Telescope git_files<CR>
nnoremap <Leader>ft :Telescope tags<CR>
nnoremap <Leader>ff :Telescope find_files<CR>
nnoremap <Leader>fg :Telescope live_grep<CR>
nnoremap <Leader>fm :Telescope marks<CR>
nnoremap <Leader>fs :Telescope current_buffer_fuzzy_find<CR>
nnoremap <Leader>fh :Telescope help_tags<CR>

nnoremap <Leader>gr :Telescope lsp_references<CR>
nnoremap <Leader>gs :Telescope lsp_document_symbols<CR>
nnoremap <Leader>gi :Telescope lsp_implementations<CR>
nnoremap <Leader>gT :Telescope lsp_type_definitions<CR>
nnoremap <Leader>gd :Telescope lsp_definitions<CR>
nnoremap <Leader>gn :Telescope diagnostics<CR>
nnoremap <Leader>gw :Telescope lsp_dynamic_workspace_symbols<CR>
nnoremap <Leader>gic :Telescope lsp_incoming_calls<CR>
nnoremap <Leader>goc :Telescope lsp_outgoing_calls<CR>

let g:vimwiki_list = [{'path': '~/Documents/notes/'}]

" Ag: Only looks at content, not file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Enable calendar in vimwiki
" let g:vimwiki_use_calendar = 1
let g:vimwiki_list = [{'auto_diray_index': 1}]

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

" Create a variable that has the path to the aliases file
let g:aliases_file = $HOME . '/.config/nvim/aliases.vim'

" Check if the aliase file exists and if it does, source it
if filereadable(g:aliases_file)
  execute 'source ' . g:aliases_file
endif

" Press escape to exit terminal mode
tnoremap <Esc> <C-\><C-n>

" Disable Copilot autocompletion for Markdown files
" let g:copilot_disable_for_markdown = 1
" let g:copilot_filetypes = { 'markdown': v:false }
" let g:copilot_disable_filetypes = ['markdown']

" Disable Copilot autocompletion for Vimwiki files
let g:copilot_disable_for_vimwiki = 1
let g:copilot_filetypes = { 'vimwiki': v:false }
let g:copilot_disable_filetypes = ['vimwiki']

" Ignore paths
set wildignore+=**/node_modules/**

" Folding
set nofoldenable " Disable folding by default
autocmd FileType javascript,typescript setlocal foldmethod=syntax " Enable folding for JavaScript and TypeScript

" Get rid of ~file
set nobackup

