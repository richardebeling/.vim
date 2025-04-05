" No backwards compatibility to VI
set nocompatible
scriptencoding utf-8
set encoding=utf-8

" ------------------ Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible', { 'commit': '0ce2d843d6f588bb0c8c7eec6449171615dc56d9' }
Plug 'tpope/vim-fugitive', { 'commit': '4a745ea72fa93bb15dd077109afbb3d1809383f2' }
Plug 'tpope/vim-commentary', { 'commit': '64a654ef4a20db1727938338310209b6a63f60c9' }
Plug 'tpope/vim-surround', { 'commit': '3d188ed2113431cf8dac77be61b842acb64433d9' }
Plug 'tpope/vim-sleuth', { 'commit': 'be69bff86754b1aa5adcbb527d7fcd1635a84080' }
Plug 'christoomey/vim-tmux-navigator', { 'commit': '791dacfcfc8ccb7f6eb1c853050883b03e5a22fe' }
Plug 'lifepillar/vim-gruvbox8', { 'commit': '4b56d56e287b74758edb4504e23be2d4977d0972' }

if(has('nvim'))
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

  Plug 'hrsh7th/nvim-cmp', { 'commit': 'c27370703e798666486e3064b64d59eaf4bdc6d5' }
  Plug 'hrsh7th/cmp-nvim-lsp', { 'commit': '99290b3ec1322070bcfb9e846450a46f6efa50f0' }
  Plug 'hrsh7th/cmp-buffer', { 'commit': '3022dbc9166796b644a841a02de8dd1cc1d311fa' }
  Plug 'hrsh7th/cmp-nvim-lsp-signature-help', { 'commit': '031e6ba70b0ad5eee49fd2120ff7a2e325b17fa7' }
  Plug 'ibhagwan/fzf-lua', { 'commit': 'd40d2e7225a18fb3bbb7b9be38c51876d652741d', 'do': 'rm lua/fzf-lua/data/colorschemes.json'}

  Plug 'navarasu/onedark.nvim', { 'commit': '67a74c275d1116d575ab25485d1bfa6b2a9c38a6' }
  Plug 'projekt0n/github-nvim-theme', { 'commit': 'c106c9472154d6b2c74b74565616b877ae8ed31d' }
  Plug 'ellisonleao/gruvbox.nvim', { 'commit': '15958f5ee43e144856cd2084ce6c571bfdb44504' }
else
  Plug 'junegunn/fzf', { 'commit': '10cbac20f96de35acf272ddc4a998868c5694bd9' }
  Plug 'junegunn/fzf.vim', { 'commit': '245eaf8e50fe440729056ce8d4e7e2bb5b1ff9c9' }
endif

call plug#end()

syntax enable
filetype plugin indent on

if(has('nvim'))
" treesitter
lua << EOF
  if pcall(require, 'nvim-treesitter.configs') then
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = { 'cmake', 'vim', 'c', 'cpp', 'lua', 'java', 'python', 'json' },
      sync_install = false,
      auto_install = true,
      ignore_install = {},
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = function(lang, bufnr)
          if lang == 'git_rebase' then return true end  -- breaks command highlighting (reword, fixup, ...)
        end
      },
      indent = { enable = true },
    }
  end
EOF

" lsp
  command Rename lua vim.lsp.buf.rename()
  command Format lua vim.lsp.buf.format()
  command ToggleDiagnostic lua if(vim.diagnostic.is_enabled()) then vim.diagnostic.disable() else vim.diagnostic.enable() end

lua << EOF
  local lspconfig_defaults = require('lspconfig').util.default_config
  lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
  )

  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = {buffer = event.buf}

      vim.keymap.set('n', '<leader>k', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
      vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
      vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end,
  })

  require('lspconfig').clangd.setup({
    cmd = {
      "clangd",
      "-j", "4",
      "--limit-references", "10000",
      "--limit-results", "10000",
      "--background-index",
      "--clang-tidy",
    }
  })

  require('lspconfig').pylsp.setup({
    settings = {
      pylsp = {
        plugins = {
          jedi_completion = { enabled = true, },
          jedi_definition = {
            enabled = true,
            follow_imports = true,
            follow_builtin_imports = true,
          },
          rope_completion = { enabled = false, },
          rope_autoimport = { enabled = false, },
          pycodestyle = { enabled = false, },
          pyflakes = { enabled = false, },
          ruff = { enabled = false, },
          isort = { enabled = false, },
          mccabe = { enabled = false, }
        }
      }
    }
  })
  require('lspconfig').lua_ls.setup({})
  require('lspconfig').ruff.setup({
    init_options = {
      settings = {
        organizeImports = true,
        showSyntaxErrors = true,
        lint = {
          enable = true,
          -- select = { 'E', 'W', 'F', 'I', 'C90', },
          -- ignore = { 'W291' },  -- trailing whitespace
        },
      },
    },
  })
  vim.api.nvim_create_autocmd("DiagnosticChanged", { callback = function() vim.diagnostic.setloclist({open = false}) end })
EOF

" auto completion
lua << EOF
  local cmp = require('cmp')
  local types = require('cmp.types')
  cmp.setup({
    sources = { {name = 'nvim_lsp'}, { name = 'nvim_lsp_signature_help' }, },
    snippet = { expand = function(args) end, },
    mapping = cmp.mapping.preset.insert({
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.insert }),
      ['<C-Space>'] = cmp.mapping.complete(),
    }),
  })
EOF

" theme
lua << EOF
  require("gruvbox").setup({
    contrast = "high",
    italic = {
      strings = false,
    },
    overrides = {
      Function = { link = 'GruvboxFg0' },
      Delimiter = { link = 'GruvboxFg0' },
      Operator = { link = 'GruvboxFg0' },
      Identifier = { link = 'GruvboxFg0' },  -- members, parameter names, blue otherwise
      ["@variable.builtin"] = { link = 'GruvboxFg0' },  -- python "self" is orange otherwise
    },
  })
EOF

" paste through SSH through tmux (needs refresh, copy works out of the box)
lua << EOF
  if vim.env.TMUX ~= nul then
    local copy = {'tmux', 'load-buffer', '-w', '-'}
    local paste = {'bash', '-c', 'tmux refresh-client -l && sleep 0.1 && tmux save-buffer -'}
    vim.g.clipboard = {
      name = 'tmux',
      copy = {['+'] = copy, ['*'] = copy, },
      paste = {['+'] = paste, ['*'] = paste, },
      cache_enabled = 0,
    }
  end
EOF
endif

set statusline=%<%q\ \ %f\ %m%r%w%=%c\ %{FugitiveHead()}\ %l/%L\ [%P]
if(has('nvim'))
  set laststatus=3
else
  set laststatus=2
endif

" Color Scheme
set termguicolors
set background=dark

let g:onedark_config = {'style': 'warmer'} " alternatives: dark, darker, warmer

" ignore failure in setting the color scheme, useful for running `vim +PlugInstall +qall`
if(has('nvim'))
  silent! colorscheme gruvbox
else
  silent! colorscheme gruvbox8
endif


" Workaround for closing location list when a buffer is deleted (:bd)
cabbrev <silent> bd <C-r>=(getcmdtype()==#':' && getcmdpos()==1 ? 'lclose\|bdelete' : 'bd')<CR>

" FZF
let g:fzf_preview_window = []           " no preview
if has('nvim')
lua << EOF
  require('fzf-lua').setup({
    {'fzf-vim'},
    winopts = {split = "belowright new | resize 14"}
  })
EOF
else
  let g:fzf_layout = { 'down': '30%' }    " bottom-dock instead of hover
endif

" don't show statusline inside the FZF window
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noruler
      \| autocmd BufLeave <buffer> set laststatus=2 ruler

autocmd FileType qf setlocal wrap

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

" Allow opening django templates with gf
set path+=templates,include

" Indentation
set tabstop=4
set shiftwidth=4
set expandtab           " to spaces
autocmd FileType text setlocal autoindent

" Whitespace Rendering
set listchars=tab:▸\ ,trail:·
set list

" Show 80th, 100th and 120th column
let &colorcolumn="80,100,120"

" Behavior
set autoread            " skip file reload question
set number              " show line number instead of 0
set relativenumber      " relative line numbers
set ttyfast             " faster redrawing
set scrolloff=3         " always 3 lines visible
set nostartofline       " do not go to start of line when changing buffers
set nowrap              " no linewrap
set noshowmode          " don't show new mode in status line

" Vim command Autocompletion
set wildmenu
set wildmode=longest:full,full

set mouse+=a            " allow mouse usage for resizing windows
if !has('nvim') && &term =~ '^screen'
    set ttymouse=xterm2 " allowed for smoother mouse reporting inside tmux
endif

set hidden              " allow hidden, unsaved buffers
set showmatch           " hilight matching surroundings

" Search Options
set ignorecase          " case-insensitive searching for lower-case expressions
set smartcase           " case-sensitive searching for mixed-case expressions
set incsearch           " search while typing
set hlsearch            " hilight search results
set gdefault            " substitute all matches by default

" Own keybindings
nnoremap <SPACE> <Nop>
let mapleader = " "

" Remap macos / iterm control+left/right
map! <ESC>b <C-Left>
map! <ESC>f <C-Right>

" start global search for word under cursor with <leader>f
nnoremap <leader>f :Rg <c-r>=expand("<cword>")<cr>
nnoremap <leader>F :Rg <c-r>=expand("<cWORD>")<cr>

" fuzzy file search, full text search, fuzzy symbol search, fuzzy tag search
nnoremap <c-p> :Files<cr>
nnoremap <leader>g :FzfLua live_grep<cr>
nnoremap <leader>s :FzfLua lsp_live_workspace_symbols<cr>
nnoremap <leader>t :lua require("fzf-lua").tags({fzf_opts={["--nth"]="1"}})<cr>

" Go to next / previous marked location:
nnoremap <silent><leader>n :call CElseL("next")<cr>
nnoremap <silent><leader>p :call CElseL("previous")<cr>

" Quick Buffer Switching
nnoremap <leader><tab> <C-^>

" Open header/source files
nnoremap <leader>o :ClangdSwitchSourceHeader<cr>

" Clear match highlighting
noremap <leader><leader> :noh<cr>:call clearmatches()<cr>

" Y yanks to end of the line, not the whole line.
nnoremap Y y$

" Escape alternatives
inoremap jf <esc>
inoremap jF <esc>
inoremap Jf <esc>
inoremap JF <esc>

" Use sane regexs when searching
nnoremap / /\v
vnoremap / /\v

" German Mappings
map ß /

" Visual line nav, not real line nav
" For navigating into wrapped lines
noremap j gj
noremap k gk
