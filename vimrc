" Vim Init {{{
" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

" Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Extra user or machine specific settings
source ~/.vim/user.vim

" Gui settings
if &t_Co > 2 || has("gui_running")
   syntax on                    " switch syntax highlighting on, when the terminal has colors
   set guifont=DejaVu\ Sans\ Mono\ for\ Powerline
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Plugins {{{
NeoBundle 'dbext.vim'
NeoBundle 'Valloric/YouCompleteMe'
NeoBundle 'regedarek/ZoomWin'
NeoBundle 'jiangmiao/auto-pairs.git'
NeoBundle 'docunext/closetag.vim'
NeoBundle 'lfilho/cosco.vim'
NeoBundle 'JulesWang/css.vim'
NeoBundle 'FelikZ/ctrlp-py-matcher'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'othree/eregex.vim'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'scrooloose/nerdtree.git'
NeoBundle 'mtth/scratch.vim'
NeoBundle 'cakebaker/scss-syntax.vim'
NeoBundle 'ervandew/supertab'
NeoBundle 'scrooloose/syntastic.git'
NeoBundle 'godlygeek/tabular'
NeoBundle 'marijnh/tern_for_vim'
NeoBundle 'bling/vim-airline'
NeoBundle 'moll/vim-bbye'
NeoBundle 'jeetsukumaran/vim-buffergator'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'ap/vim-css-color'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'tpope/vim-fugitive.git'
NeoBundle 'airblade/vim-gitgutter.git'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'suan/vim-instant-markdown'
NeoBundle 'pangloss/vim-javascript'
"NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
NeoBundle 'rcmdnk/vim-markdown'
NeoBundle 'mustache/vim-mustache-handlebars'
NeoBundle 'jistr/vim-nerdtree-tabs'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
"}}}

call neobundle#end()

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"}}}

" Vim behaviour {{{

" Style & colorscheme {{{
set background=light
colorscheme solarized
if has('gui_running')
  set background=light
else
  set background=dark
endif
" }}}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

set shell=bash                  " Vim expects a POSIX-compliant shell
set ffs=unix,dos,mac            " prefer unix file format but display every file correct
set iskeyword+=-                " select dasherized words
set hidden                      " hide buffers instead of closing them this
                                "    means that the current buffer can be put
                                "    to background without being written; and
                                "    that marks and undo history are preserved
set switchbuf=useopen           " reveal already opened files from the
                                " quickfix window instead of opening new
                                " buffers
set history=1000                " remember more commands and search history
set undolevels=1000             " use many muchos levels of undo
if v:version >= 730
  set undofile                  " keep a persistent backup file
  set undodir=~/.vim/.undo,~/tmp,/tmp
endif
set nobackup                    " do not keep backup files, it's 70's style cluttering
set noswapfile                  " do not write annoying intermediate swap files,
                                "    who did ever restore from swap files anyway?
set directory=~/.vim/.tmp,~/tmp,/tmp
                                " store swap files in one of these directories
                                "    (in case swapfile is ever turned on)
set viminfo='20,\"80            " read/write a .viminfo file, don't store more
                                "    than 80 lines of registers
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete
                                "    first full match
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                       " change the terminal's title
set visualbell                  " don't beep
set noerrorbells                " don't beep
set showcmd                     " show (partial) command in the last line of the screen
                                "    this also shows visual selection info
set nomodeline                  " disable mode lines (security measure)
set ttyfast                     " always use a fast terminal
set cursorline                  " underline the current line, for quick orientation

" more natural split behaviour
set splitbelow
set splitright

set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " don't update the display while executing macros
set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window
set cmdheight=2                 " use a status bar that is 2 rows high

filetype plugin indent on

" Cursor setting
" Switch from block-cursor to vertical-line-cursor when going into/out of
" insert mode
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Conflict markers
" highlight conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" }}}

" Editing behaviour {{{
"syntax on
set showmode                    " always show what mode we're currently editing in"
set nowrap                      " don't wrap lines

set tabstop=2                   " a tab is two spaces
set softtabstop=2               " when hitting <BS>, pretend like a tab is removed, even if spaces
set expandtab                   " expand tabs by default (overloadable per file type later)
set shiftwidth=2                " number of spaces to use for autoindenting
set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " always set autoindenting on
set copyindent                  " copy the previous indentation on autoindenting
set number                      " always show line numbers
set showmatch                   " set show matching parenthesis
set ignorecase                  " ignore case when searching
set smartcase                   " ignore case if search pattern is all lowercase, case-sensitive otherwise
set smarttab                    " insert tabs on the start of a line according to shiftwidth, not tabstop
set scrolloff=4                 " keep 4 lines off the edges of the screen when scrolling
set virtualedit=all             " allow the cursor to go in to "invalid" places
set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type
set gdefault                    " search/replace "globally" (on a line) by default
set listchars=tab:>.,trail:.,extends:#,nbsp:.

set nolist                      " don't show invisible characters by default, but it is enabled for some file types (see later)
set pastetoggle=<F11>           " when in insert mode, press <F2> to go to paste mode, where you can paste mass data that won't be autoindented
set mouse=a                     " enable using the mouse if terminal emulator supports it (xterm does)
set clipboard=unnamed           " ??? (allow clipboard copy/paste)

set formatoptions+=1            " When wrapping paragraphs, don't end lines with 1-letter words (looks stupid)

set nrformats=                  " make <C-a> and <C-x> play well with zero-padded numbers (i.e. don't consider them octal or hex)

set shortmess+=I                " hide the launch screen
"set clipboard=unnamed           " normal OS clipboard interaction
set autoread                    " automatically reload files changed outside of Vim

" Toggle show/hide invisible chars
nnoremap <leader>i :set list!<cr>

" Toggle line numbers
nnoremap <leader>N :setlocal number!<cr>

" Thanks to Steve Losh for this liberating tip
" See http://stevelosh.com/blog/2010/09/coming-home-to-vim
nnoremap <leader>- :call eregex#toggle()<CR>

" Speed up scrolling of the viewport slightly
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Folding rules {{{
set foldenable                  " enable folding
set foldcolumn=2                " add a fold column
set foldmethod=marker           " detect triple-{ style fold markers
set foldlevelstart=99           " start out with everything unfolded
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
                                " which commands trigger auto-unfold
function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 4
    return line . ' …' . repeat(" ",fillcharcount) . foldedlinecount . ' '
endfunction
set foldtext=MyFoldText()

" Mappings to easily toggle fold levels
nnoremap z0 :set foldlevel=0<cr>
nnoremap z1 :set foldlevel=1<cr>
nnoremap z2 :set foldlevel=2<cr>
nnoremap z3 :set foldlevel=3<cr>
nnoremap z4 :set foldlevel=4<cr>
nnoremap z5 :set foldlevel=5<cr>
" }}}
" }}}

" Shortcut mappings {{{
" add leader as <Space>
" http://www.reddit.com/r/vim/comments/1vdrxg/space_is_a_big_key_what_do_you_map_it_to/
map <Space> <nop>
map <Space> \
map <Space><Space> <leader><leader>

" remap command to ö
nnoremap ö :
nnoremap <leader>ö ö

" Avoid accidental hits of <F1> while aiming for <Esc>
noremap! <F1> <Esc>

nnoremap <leader>Q :q<CR>    " Quickly close the current window
nnoremap <leader>q :Bdelete<CR>   " Quickly close the current buffer

" Use Q for formatting the current paragraph (or visual selection)
vnoremap Q gq
nnoremap Q gqap
" set breakindent on  " keep paragraph indentation when re-wrapping text

" Sort paragraphs
"vnoremap <leader>s !sort -f<CR>gv
"nnoremap <leader>s vip!sort -f<CR><Esc>

" make p in Visual mode replace the selected text with the yank register
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Swap implementations of ` and ' jump to markers
" By default, ' jumps to the marked line, ` jumps to the marked line and
" column, so swap them
nnoremap ' `
nnoremap ` '

" Use the damn hjkl keys
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap j gj
nnoremap k gk

" Easy window navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
"nnoremap <leader>w <C-w>v<C-w>l

" Complete whole filenames/lines with a quicker shortcut key in insert mode
inoremap <C-f> <C-x><C-f>
inoremap <C-l> <C-x><C-l>

" Use <leader>d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nnoremap <silent> <leader>d "_d
vnoremap <silent> <leader>d "_d
" apply the same to ,x
nnoremap <silent> <leader>x "_x
vnoremap <silent> <leader>x "_x

" Quick yanking to the end of the line
nnoremap Y y$

" YankRing stuff
let g:yankring_history_dir = '$HOME/.vim/.tmp'
nnoremap <leader>r :YRShow<CR>

" Edit the vimrc file
nnoremap <silent> <leader>ev :e $MYVIMRC<CR>
nnoremap <silent> <leader>rv :so $MYVIMRC<CR>

" Clears the search register
nnoremap <silent> ä :nohlsearch<CR>

" Pull word under cursor into LHS of a substitute (for quick search and
" replace)
nnoremap <leader>z :%s#\<<C-r>=expand("<cword>")<CR>\>#

" Keep search matches in the middle of the window and pulse the line when moving
" to them.
nnoremap n n:call PulseCursorLine()<cr>
nnoremap N N:call PulseCursorLine()<cr>

" Quickly get out of insert mode without your fingers having to leave the
" home row (either use 'jj' or 'jk' in insert-, öö in visual-mode)
inoremap jk <Esc>
vnoremap öö <Esc>

" Quick alignment of text
" nnoremap <leader>al :left<CR>
" nnoremap <leader>ar :right<CR>
" nnoremap <leader>ac :center<CR>

" Sudo to write
cnoremap w!! w !sudo tee % >/dev/null

" Strip all trailing whitespace from a file, using ,W
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>

" Allow quick additions to the spelling dict
nnoremap <leader>g :spellgood <c-r><c-w>

" Reselect text that was just pasted with ,v
nnoremap <leader>v V`]

noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

" Quote words under cursor
nnoremap <leader>" viW<esc>a"<esc>gvo<esc>i"<esc>gvo<esc>3l
nnoremap <leader>' viW<esc>a'<esc>gvo<esc>i'<esc>gvo<esc>3l

" Quote current selection
" TODO: This only works for selections that are created "forwardly"
vnoremap <leader>" <esc>a"<esc>gvo<esc>i"<esc>gvo<esc>ll
vnoremap <leader>' <esc>a'<esc>gvo<esc>i'<esc>gvo<esc>ll

nmap cp :let @" = expand("%")"

nnoremap <C-c> :call HighlightNearCursor()<CR>

" jump through the grep/ag results in quickfix with <leader>n
" (similar to what 'n' does in a regular search)
nmap <leader>N [q
nmap <leader>n ]q
omap <leader>N [q
omap <leader>n ]q
xmap <leader>N [q
xmap <leader>n ]q

" Add useful registers {{{
let @r="\'<,\'>"
" }}}

" Toggle the quickfix window
" From Steve Losh, http://learnvimscriptthehardway.stevelosh.com/chapters/38.html
nnoremap <C-q> :call <SID>QuickfixToggle()<cr>

" shortcut to jump to next conflict marker
nnoremap <silent> <leader>c /^\(<\\|=\\|>\)\{7\}\([^=].\+\)\?$<CR>

"nmap <silent> ,/ :nohlsearch<CR>
"}}}

" Filetype specific handling {{{
" only do this part when compiled with support for autocommands
if has("autocmd")
  augroup invisible_chars "{{{
    au!

    " Show invisible characters in all of these files
    autocmd filetype vim setlocal list
    autocmd filetype python,rst setlocal list
    autocmd filetype ruby setlocal list
    autocmd filetype javascript,css setlocal list
  augroup end
  "}}}

  augroup vim_files "{{{
    au!

    " Bind <F1> to show the keyword under cursor
    " general help can still be entered manually, with :h
    autocmd filetype vim noremap <buffer> <F1> <Esc>:help <C-r><C-w><CR>
    autocmd filetype vim noremap! <buffer> <F1> <Esc>:help <C-r><C-w><CR>
    "delete trailing whitespace automatically"
    autocmd filetype vim autocmd BufWritePre <buffer> :%s/\s\+$//e
  augroup end
  "}}}

  augroup html_files "{{{
    au!

    "" Auto-closing of HTML/XML tags
    let g:closetag_default_xml=1
    autocmd filetype html let b:closetag_html_style=1
    autocmd filetype html set foldmethod=indent
    autocmd filetype html autocmd BufWritePre <buffer> :%s/\s\+$//e
  augroup end
  "}}}

  augroup mkd_files, makrdown_files "{{{
    au!

    autocmd filetype markdown set tw=80 wrap
    autocmd filetype markdown noremap <buffer> <leader>p :w<CR>:!open -a Marked %<CR><CR>
  augroup end
  "}}}

  augroup css_files "{{{
    au!

    autocmd filetype css,less setlocal foldmethod=marker foldmarker={,}
    autocmd filetype css,less autocmd BufWritePre <buffer> :%s/\s\+$//e
    augroup end
      "}}}

  augroup javascript_files "{{{
    au!

    autocmd filetype javascript setlocal listchars=tab:\ \ ,trail:·,extends:#,nbsp:·
    autocmd filetype javascript setlocal foldmethod=marker foldmarker={,}

    autocmd filetype javascript nnoremap <silent> <leader>, :call cosco#commaOrSemiColon()<CR>
    autocmd filetype javascript inoremap <silent> ,. <c-o>:call cosco#commaOrSemiColon()<CR>

    " Toggling True/False
    autocmd filetype javascript nnoremap <silent> <C-t> mmviw:s/true\\|false/\={'true':'false','false':'true'}[submatch(0)]/<CR>`m:nohlsearch<CR>
    autocmd filetype javascript autocmd BufWritePre <buffer> :%s/\s\+$//e
  augroup end
  "}}}

  augroup textile_files "{{{
    au!

    " Render YAML front matter inside Textile documents as comments
    autocmd filetype textile syntax region frontmatter start=/\%^---$/ end=/^---$/
    autocmd filetype textile highlight link frontmatter Comment

    autocmd filetype textile autocmd BufWritePre <buffer> :%s/\s\+$//e
  augroup end
  "}}}
endif
"}}}

" Auto commands {{{
" Restore cursor position upon reopening files
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
autocmd VimEnter * call AirlineInit()
" }}}

" Abbreviations {{{
iab lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit
iab llorem Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu.  Nulla non quam erat, luctus consequat nisi
iab lllorem Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu.  Nulla non quam erat, luctus consequat nisi.  Integer hendrerit lacus sagittis erat fermentum tincidunt.  Cras vel dui neque.  In sagittis commodo luctus.  Mauris non metus dolor, ut suscipit dui.  Aliquam mauris lacus, laoreet et consequat quis, bibendum id ipsum.  Donec gravida, diam id imperdiet cursus, nunc nisl bibendum sapien, eget tempor neque elit in tortor
iabbr me@ mail.steinberger@gmail.com
iabbr ssig --<cr>David Steinberger<cr>mail.steinberger@gmail.com
"}}}

" NERDTree settings {{{
let g:nerdtree_tabs_open_on_console_startup = 1
let g:NERDTreeChDirMode = 1

nnoremap <leader>m :NERDTreeTabsToggle<CR>

" Store the bookmarks file
let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")

" Show the bookmarks table on startup
let NERDTreeShowBookmarks=1

" Show hidden files, too
let NERDTreeShowFiles=1
let NERDTreeShowHidden=0

" Quit on opening files from the tree
let NERDTreeQuitOnOpen=1

" Highlight the selected entry in the tree
let NERDTreeHighlightCursorline=1

" Use a single click to fold/unfold directories and a double click to open
" files
let NERDTreeMouseMode=2

" Don't display these kinds of files
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$' ]
"}}}

" Silver Searcher {{{
" Use The Silver Searcher over grep, iff possible
if executable('ag')
  " Define "Ag" command
  command -nargs=+ -complete=file -bar Ag silent! grep! <args> | cwindow | redraw!

  " bind <leader>/ to grep shortcut
  nnoremap <leader>/ :Ag<SPACE>

  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor\ --column\ --numbers\ --noheading
  set grepformat=%f:%l:%c%m

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 1

  let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
    \ --ignore .git
    \ --ignore .svn
    \ --ignore .hg
    \ --ignore .DS_Store
    \ --ignore "**/*.pyc"
    \ --ignore Applications
    \ --ignore Library
    \ --ignore Adlm
    \ --ignore Mail alias
    \ --ignore Misc\ 2
    \ --ignore npmrc
    \ --ignore Diverses
    \ --ignore Cloud Drive
    \ --ignore eibPort
    \ --ignore g3cf
    \ --ignore g3
    \ --ignore Oracle
    \ --ignore jdeveloper
    \ --ignore oraInventory
    \ --ignore Autodesk
    \ --ignore Music
    \ --ignore Applications
    \ --ignore rethinkdb_data
    \ --ignore Public
    \ --ignore Pictures
    \ --ignore Movies
    \ --ignore Library
    \ --ignore .cache
    \ --ignore .bundler
    \ --ignore .codeintel
    \ --ignore .node-gyp
    \ --ignore .npm
    \ --ignore .nvm
    \ --ignore .rvm
    \ --ignore .Trash
    \ --ignore .vim
    \ --ignore .compass-ui
    \ --ignore .dropbox
    \ --ignore .emacs.d
    \ --ignore .sqldeveloper
    \ --ignore .gem
    \ -g ""'
  let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
endif

" grep/Ack/Ag for the word under cursor
vnoremap <leader>a y:grep! "\b<c-r>"\b"<cr>:cw<cr>
nnoremap <leader>a :grep! "\b<c-r><c-w>\b"
nnoremap K *N:grep! "\b<c-r><c-w>\b"<cr>:cw<cr>
"}}}

" CTRLP {{{
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = '0'
let g:ctrlp_cmd = 'CtrlP pwd'

" Ignore common directories
"\ 'dir':  '\.git$\|\.hg$\|\.svn$\|bower_components$\|dist$\|node_modules$\|project_files$\|test$',
"\ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }
let g:ctrlp_custom_ignore = {
  \ 'dir': '.git'
   \ }
"}}}

" Syntastic {{{
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

let g:syntastic_html_tidy_exec = 'tidy5'

let g:syntastic_html_tidy_ignore_errors = [
  \  'missing <li',
  \  'plain text isn''t allowed in <head> elements',
  \  '</head> isn''t allowed in <body> elements',
  \  'discarding unexpected <body>',
  \ ]
  "\  '<base> escaping malformed URI reference',
  "\  '<script> escaping malformed URI reference',

"let g:syntastic_filetype_map = { 'handlebars.html': 'handlebars' }
"let g:syntastic_hbs_checkers = []
"let g:syntastic_html_checkers = ['jshint']
"}}}

" Cosco {{{
command! CommaOrSemiColon call cosco#commaOrSemiColon()
"}}}

" Emmet {{{
let user_emmet_expandabbr_key = '<leader>e'
"}}}

" BBye {{{
" delete buffer without closing window
" https://github.com/majutsushi/etc/blob/16c6ac49638b0a3faeff789e8b1fda1cb5209644/vim/vimrc#L519
" now handled by plugin vim-bbye
cabbrev bd Bdelete
"}}}

" Markdown {{{
let g:instant_markdown_slow = 1
let g:instant_markdown_autostart = 0
"}}}

" Easymotion config {{{
nmap s <Plug>(easymotion-s2)
nmap <Leader>s <Plug>(easymotion-s)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
" keep cursor colum when JK motion
let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion"
" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
" }}}

" Airline {{{
" Make sure powerline fonts are used
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline#extensions#tabline#enabled = 1 "enable the tabline
let g:airline#extensions#tabline#fnamemod = ':t' " show just the filename of buffers in the tab line
let g:airline_detect_modified=1
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
" }}}

" Custom Functions {{{
function! PulseCursorLine()
  let current_window = winnr()

  windo set nocursorline
  execute current_window . 'wincmd w'

  setlocal cursorline

  redir => old_hi
  silent execute 'hi CursorLine'
  redir END
  let old_hi = split(old_hi, '\n')[0]
  let old_hi = substitute(old_hi, 'xxx', '', '')

  hi CursorLine guibg=#3a3a3a
  redraw
  sleep 20m

  hi CursorLine guibg=#4a4a4a
  redraw
  sleep 30m

  hi CursorLine guibg=#3a3a3a
  redraw
  sleep 30m

  hi CursorLine guibg=#2a2a2a
  redraw
  sleep 20m

  execute 'hi ' . old_hi

  windo set cursorline
  execute current_window . 'wincmd w'
endfunction

function HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    unlet s:highlightcursor
  endif
endfunction

" Function to show total amount of lines in the airline
function! AirlineInit()
  "let g:airline_section_z = airline#section#create_right(['%L'])
endfunction

let g:quickfix_is_open = 0
function! s:QuickfixToggle()
    if g:quickfix_is_open
        cclose
        let g:quickfix_is_open = 0
        execute g:quickfix_return_to_window . "wincmd w"
    else
        let g:quickfix_return_to_window = winnr()
        copen
        let g:quickfix_is_open = 1
    endif
endfunction

" Quick Buffer switch mappings {{{
" The idea is to press <leader> and then the number from normal mode to switch
" e.g. `,2` would switch to the second buffer (listed at the top of the
" airline strip
for i in range(1, 99)
    execute printf('nnoremap <Leader>%d :%db<CR>', i, i)
endfor
for i in range(1, 99)
    execute printf('nnoremap <Leader>d%d :Bdelete %d<CR>', i, i)
endfor
" }}}
" }}}
