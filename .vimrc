set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Code completion
" Plugin 'ycm-core/YouCompleteMe'
" Plugin 'dense-analysis/ale'
Plugin 'neoclide/coc.nvim'

Plugin 'vimwiki/vimwiki'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin for perl syntax, template toolkit
Plugin 'vim-perl/vim-perl'
" plugin for javascript syntax
" Plugin 'pangloss/vim-javascript'
" plugin for json syntax
" Plugin 'elzr/vim-json'
" plugin to easy find file
Plugin 'kien/ctrlp.vim'
" tree explorer
Plugin 'scrooloose/nerdtree'
" Status line
Plugin 'vim-airline/vim-airline'
" HTML Syntax
" Plugin 'othree/html5.vim'
" Markdown highlighter
" Plugin 'plasticboy/vim-markdown'

" Code tags
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-syntastic/syntastic'
Plugin 'chaoren/vim-wordmotion'

" fzf
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Comment stuff out. Use gcc
Plugin 'tpope/vim-commentary'
 let g:ctrlp_map = '<C-p>'
 let g:ctrlp_working_path_mode = 0 " don’t manage working directory.
 let g:ctrlp_use_caching = 1
 let g:ctrlp_custom_ignore = {
 \ 'dir':  '\v\c\.(git|svn)$|cgi/t/sandbox|cover_db',
 \ 'file': '\v\c\.(swf|bak|png|gif|js|mov|ico|jpg|pdf|jrxml)$'
  \ }

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set autoindent
set backspace=indent,eol,start
set cindent " set smartindent
set cmdheight=2
set errorformat=\"../../%f\"\\,%*[^0-9]%l:\ %m
set expandtab
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:>-,trail:-
set mouse=c
set nowrap
set ruler
set scrolloff=5
set shiftwidth=4
set showcmd
set showmatch
set smarttab
set t_Co=256
set tags=./tags,./vstags,tags;/
set virtualedit=block
set wrap
set foldmethod=syntax
" Disable auto folding
set nofoldenable
set updatetime=500
set smartcase
set autowriteall
syntax on

colorscheme desert

highlight   CursorColumn  term=NONE    cterm=none ctermbg=232
highlight   CursorLine    term=NONE    cterm=bold ctermbg=8
highlight   FoldColumn                            ctermbg=8  ctermfg=14
highlight   Folded                                ctermbg=8  ctermfg=14
highlight   Search        term=reverse cterm=bold ctermbg=11 ctermfg=0
highlight   Visual        term=NONE    cterm=bold ctermbg=10 ctermfg=8
highlight   ColorColumn                           ctermbg=8

"" makes Omni Completion less pinky :P
highlight   Pmenu                                 ctermbg=2  ctermfg=0
highlight   PmenuSel                              ctermbg=7  ctermfg=0
highlight   PmenuSbar                             ctermbg=0  ctermfg=7
highlight   PmenuThumb                            ctermbg=7  ctermfg=0

" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

nnoremap <C-L> :noh<CR><C-L>
inoremap jj <Esc>
nnoremap <Leader>r :source ~/.vimrc<CR>
nnoremap <Leader>d :put =strftime('%a %d %b %Y')<CR>
nnoremap <Leader><Leader>r :e ~/.vimrc<CR>

map <Leader>gs :Gstatus<CR>
map <Leader>gc :Gcommit<CR>
map <Leader>gm :Gcommit --amend<CR>
map <Leader>gll :Git log<CR>
map <Leader>glp :Git log -p<CR>
map <Leader>gb :Gblame<CR>
map <Leader>gdd :Git diff<CR>
map <Leader>gdm :Git diff %<CR>
map <Leader>gdf :Gdiff<CR>
map <Leader>gg :Git

set pastetoggle=<F2>

autocmd FileType gitcommit autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" navigate display line when wrap is set
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

map <F5> :NERDTreeToggle<CR>
" au filetype perl :NERDTreeFind | wincmd p
nmap <F8> :TagbarToggle<CR>
" au filetype perl :TagbarToggle

map <Leader>e :NERDTreeFind<CR>
map <Leader>b :CtrlPBuffer<CR>
map <Leader>t :CtrlPBufTag<CR>
map <Leader>p :Files<CR>

" Ignore node_modules in CtrlP
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store'

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Code
let g:syntastic_mode_map={'mode': 'passive'}
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_checkers = ['perl']
" let g:syntastic_cpp_compiler_options = '-std=c++17'

" Perl
au filetype perl :iabbrev pdef use v5.26;<CR>use warnings;<CR><CR>use Data::Dumper::Concise;<CR>use Data::Printer;<CR>use Syntax::Keyword::Try;<CR>
au filetype perl :iabbrev pfuture use Future;<CR>use Future::AsyncAwait;<CR>use IO::Async::Loop;<CR><CR>my $loop = IO::Async::Loop->new;<CR>
au filetype perl :iabbrev plog use Log::Any qw($log);<CR>require Log::Any::Adapter;<CR>Log::Any::Adapter->import(qw(Stderr), log_level => 'info');
au filetype perl :iabbrev pdump use Data::Dumper::Concise;<CR>use Data::Printer;<CR>
au filetype perl :iabbrev pdb use Database::Async;<CR>use Database::Async::Engine::PostgreSQL;<CR>my $db = Database::Async->new(type => 'postgresql', engine => {service => 'feeddb'});<CR>
au filetype perl :iabbrev pp print STDERR

" JS/TS
au filetype javascript :iabbrev cl console.log()<LEFT>
au filetype typescript :iabbrev cl console.log()<LEFT>

" JSONC - JSON standard does not have comments
autocmd FileType json syntax match Comment +\/\/.\+$+
autocmd FileType json syntax match Comment +\/\*.\+$+

" let g:ale_completion_enabled = 1
" set omnifunc=ale#completion#OmniFunc
