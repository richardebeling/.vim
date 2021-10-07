" No backwards compatibility to VI
set nocompatible
scriptencoding utf-8
set encoding=utf-8

" ------------------ Plugins
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'Valloric/YouCompleteMe'
Plug 'lifepillar/vim-solarized8'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'dense-analysis/ale'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'rhysd/vim-clang-format'
Plug 'bfrg/vim-cpp-modern'
Plug 'psf/black'

call plug#end()

syntax enable
filetype plugin indent on

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2 " Always show the status bar
set t_Co=256     " Colors

" YouCompleteMe
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_python_binary_path = 'python3'
let g:ycm_global_ycm_extra_conf = '~/.vim/cpp/.ycm_extra_conf.py'
let g:ycm_extra_conf_globlist = [
      \ '~/uni/bachelor/semester-1/pt-1/.ycm_extra_conf.py',
      \ ]
let g:ycm_auto_hover = ''

" Solarized Color Scheme
set termguicolors
set background=dark
colorscheme solarized8

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8'],
\   'cpp': ['cpplint'],
\}
let g:ale_c_build_dir_names = ['build', 'bin', 'build-release', 'build-debug']
let g:ale_cpp_cppcheck_options="--enable=style,warning,information --inline-suppr"

" let g:ale_pattern_options = {
" \  '/evap/': { 'ale_linters': {'python': ['flake8', 'pylint']} }
" \}

" Workaround for closing location list when a buffer is deleted (:bd)
cabbrev <silent> bd <C-r>=(getcmdtype()==#':' && getcmdpos()==1 ? 'lclose\|bdelete' : 'bd')<CR>

" FZF
nnoremap <c-p> :Files<cr>
let g:fzf_preview_window = []           " no preview
let g:fzf_layout = { 'down': '30%' }    " bottom-dock instead of hover

" don't show statusline inside the FZF window
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

function s:build_quickfix_list(lines)
  if (len(a:lines) == 1)
    execute 'edit' a:lines[0]
  else
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
  endif
endfunction

" Allow selecting multiple entries in :Files just as in :Rg
let g:fzf_action = {'enter': function('s:build_quickfix_list')}

" ------------------ Settings
function! CElseL(command)
  try
    if len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist'))
      execute "c" . a:command
      return
    endif

    execute "l" . a:command
  catch /./
    echo v:exception
  endtry
endfunction

" vim-commentary uses commentstring, which by default makes the line /* ... */
autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s

" Indentation
set tabstop=4           " 1 tab = 4 spaces
set shiftwidth=4
set expandtab           " to spaces

" Whitespace Rendering
set listchars=tab:▸\ ,trail:·
set list

" Show 80th, 100th and 120th column
let &colorcolumn="80,100,120"

" Behavior
set clipboard=unnamed   " share OS clipboard
set autoread            " skip file reload question
set number              " show line number instead of 0
set relativenumber      " relative line numbers
set ttyfast             " faster redrawing
set scrolloff=3         " always 3 lines visible
set nostartofline       " do not go to start of line when changing buffers
set nowrap              " no linewrap

" Vim command Autocompletion
set wildmenu
set wildmode=longest:full,full

set mouse+=a            " allow mouse usage for resizing windows
if &term =~ '^screen'
    set ttymouse=xterm2
endif

set hidden              " allow hidden, unsaved buffers
set showmatch           " hilight matching surroundings

" Search Options
set ignorecase          " case-insensitive searching for lower-case expressions
set smartcase           " case-sensitive searching for mixed-case expressions
set incsearch           " search while typing
set hlsearch            " hilight search results
set gdefault            " substitute all matches by default
set shortmess-=S        " show [3/14] on searching

" Own keybindings
let mapleader = ","

" start global search for word under cursor with <leader>f
nnoremap <leader>f :Rg <c-r>=expand("<cword>")<cr>
nnoremap <leader>F :Rg <c-r>=expand("<cWORD>")<cr>

" Go to next / previous marked location:
nnoremap <silent><leader>n :call CElseL("next")<cr>
nnoremap <silent><leader>p :call CElseL("previous")<cr>

" Go to definition:
nnoremap <leader>g :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>G :YcmCompleter GoToDefinition<CR>

" Quick Buffer Switching
nnoremap <leader><leader> <C-^>

" Clear match highlighting
noremap <leader><space> :noh<cr>:call clearmatches()<cr>

" Y yanks to end of the line, not the whole line.
nnoremap Y y$

" Escape alternatives
inoremap jf <esc>
inoremap jF <esc>
inoremap Jf <esc>
inoremap JF <esc>

" Use sane regex's when searching
nnoremap / /\v
vnoremap / /\v

" German Mappings
map ß /

" Visual line nav, not real line nav
" For navigating into wrapped lines
noremap j gj
noremap k gk
