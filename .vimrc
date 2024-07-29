" set verbose=15
" set verbosefile=filename.txt
" 1.if hidden is not set, TextEdit might fail.
set hidden
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup
" Better display for messages. I will set back to 1 for now
set cmdheight=1
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=200
" don't give |ins-completion-menu| messages.
set shortmess+=c
" gutter space for lsp info on left
set signcolumn=auto:2
set cedit=<C-e>

"" 2.Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
if executable("rg")
  set grepprg=rg\ --engine\ auto\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif
" ************** MAC SENSITIVE **************%%%1
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif
if g:os == "Linux"
    let home_dir = "/home/benson"
    set runtimepath+=~/Dropbox/Code/Projects/my_plugin
    let g:vsnip_snippet_dir = expand('~/Dropbox/Code/dotfiles/my-snippets')
    set runtimepath+=~/Dropbox/Code/dotfiles/my-snippets
    "Remember to call :UpdateRemotePlugins manually
else
    let home_dir = "/Users/benson"
    set runtimepath+=~/Documents/Code/Projects/my_plugin
    set runtimepath+=~/dotfiles/my-snippets
    let g:vsnip_snippet_dir = expand('~/dotfiles/my-snippets')
endif
" ************** OPTIONS **************%%%1
" Always put regexes in function rather than as expr 
    " -> vim will do weird escapes otherwise
" 1. First let me fold line comments
function! CheckSingleLineComment()
    let thisline = getline(v:lnum)
    return thisline =~# '\v^\s{-}\/\/'
endfunction
let g:in_multiline_comment = 0
" function! MatchComment()

"     if (g:in_multiline_comment)
"         if (end_of_multiline(v:lnum))
"             let g:in_multiline_comment = 0
"             return 1
"         else
"             return 1
"         endif
"     else
"         if (start_of_multiline(v:lnum))
"             let g:in_multiline_comment = 1
"             return 1
"         else 
"             return CheckSingleLineComment(v:lnum)
"         endif
"     endif
" endfunction
" set foldmethod=expr
set foldexpr=CheckSingleLineComment()
autocmd FileType *.cpp,*.c,*.h,*.java syn region myCComment start="/\*" end="\*/" fold keepend transparent
" set foldexpr=getline(v:lnum)=~'^\\s*'.&commentstring[0]
" set fdo-=search "only search in unfolded text
set foldmethod=marker
" set foldmarker=%%%,^^^
autocmd FileType cpp setlocal foldmethod=expr
"set foldtext="MyFoldText()"
"function MyFoldText()
  "let line = getline(v:foldstart)
  "See help for full
  "return v:folddashes . sub
"endfunction
"Since vim will run some bash commands on startup, so make sure shell is POSIX
"compatible.Mac has this but not /usr/bin/bash
set shell=/bin/bash
" set iskeyword+=- "Since arrow operator begins with this
set iskeyword+=_
syntax enable
" Temp for creating plugin
"set verbosefile=verbose.txt

set ignorecase
set smartcase "default case insensitive search. WIll change if captial letter in search

set linebreak "will not wrap in middle of word
set breakindent "wrapped lines will start at same indentation level
set breakindentopt=sbr
" I use a unicode curly array with a <backslash><space>
set showbreak=↪>\

set timeoutlen=600 "Any smaller and copy to global register will be too slow
set nocompatible
set hidden
set number relativenumber
set showcmd "To show keys pressed in normal mode; useful for completing Vim sentences
filetype on
filetype plugin on
"set cindent
set hlsearch
set incsearch
set lazyredraw
set laststatus=2
set t_Co=256
set foldenable
set foldlevel=0
"set list lcs =tab:\|\
"set list
"set listchars=tab:\|\
set ruler
set splitright
"set splitbelow
" set number ""relativenumber
set title
set cursorline
set autoread "doesn't work in terminal atm
set gdefault "/g is used in command mode substitution by default
"autocomplete with spellcheck
set complete+=kspell
"set clipboard=unamedplus
set wrap
set mouse=a
set tabstop=4
set expandtab "Tabs are now spaces, whatever that means
set wildmenu "This is default in Neovim
set showmatch "Will highlight matching parantheses, brackets, etc"
set shiftwidth=4
set autoindent
set undofile
"set undodir=~/.undodir/
set colorcolumn=80

" ************** PLUGINS **************%%%1
call plug#begin('~/.vim/plugged')
"Plug 'ThePrimeagen/vim-be-good'
" Plug 'bbli/filter-jump.nvim', {'do': ':UpdateRemotePlugins'}
" Plug '~/Dropbox/Code/Projects/my_plugin', {'do': ':UpdateRemotePlugins'}
"Plug 'ripxorip/aerojump.nvim', { 'do': ':UpdateRemotePlugins' }

"Vim Testing Frameworks
"---
" Plug 'dhruvasagar/vim-testify' "Vimscript unit testing
" Plug 'junegunn/vader.vim' "Vimscript integration testing
" Plug 'tpope/vim-scriptease' "Vimscript error messages can be jumped to in the quickfix list
" Plug 'LucHermitte/lh-vim-lib' "For the logging library + C++ algorithms in Vimscript -> loggin to quickfix kills space though?
"Visual
"---
" Plug 'vim-airline/vim-airline'
" Plug 'bbli/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'edkolev/tmuxline.vim'
Plug 'edkolev/promptline.vim'
Plug 'mhinz/vim-startify'
Plug 'gruvbox-community/gruvbox'
"Plug 'sainnhe/sonokai'
Plug 'bbli/edge'
"Plug 'drewtempelmeyer/palenight.vim'
Plug 'rakr/vim-one'

"Conveniences
"---
" For renaming tabs
" Plug 'gcmt/taboo.vim'
Plug 'dbakker/vim-projectroot'
Plug 'roxma/vim-tmux-clipboard'
" Plug 'google/vim-searchindex' "Apparantly causes issues with GitRipGrep atm
" Below Plugin not that useful since I can use tabs for that purpose
"Plug 'troydm/zoomwintab.vim'
" Plug 'osyo-manga/vim-over'
"Plug 'MattesGroeger/vim-bookmarks'
" Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'unblevable/quick-scope'
"Plug 'jiangmiao/auto-pairs'
" Plug 'scrooloose/nerdcommenter'
Plug 'AndrewRadev/bufferize.vim' "To show messages in a real buffer
Plug 'tpope/vim-commentary'
Plug 'bronson/vim-visual-star-search'
Plug 'andymass/vim-matchup'
" Plug 'Yggdroot/indentLine'
"Plug 'tpope/vim-surround'
" Plug 'dohsimpson/vim-macroeditor'
" using this fork so that MACROS can be repeated too. Not working though?
" Plug 'svermeulen/vim-macrobatics'
Plug 'svermeulen/vim-repeat'
Plug 'machakann/vim-sandwich'
Plug 'embear/vim-foldsearch'
"So <C-j> works properly -> Actually still doesn't work
"Plug '~/.vim/plugged/bash-support'
" Plug 'justinmk/vim-sneak' -> my plugin is better
"Plug 'goldfeld/vim-seek'
"Plug 'jayflo/vim-skip'
" Plug 'rhysd/clever-f.vim' "Actually this prevents iterative f hopping
" Plug 'https://gitlab.com/yorickpeterse/nvim-window.git', { 'branch': 'main'} "I rather use motions to move rather than labels
" Plug 'https://gitlab.com/yorickpeterse/nvim-pqf.git', { 'branch': 'main'}

"Special Windows
"---
Plug 'scrooloose/nerdtree'
"Plug 'tpope/vim-vinegar'
"Plug 'milkypostman/vim-togglelist'
"Plug 'jceb/vim-editqf'
Plug 'romainl/vim-qf'
Plug 'AndrewRadev/qftools.vim', { 'branch': 'main' }
" Plug 'mileszs/ack.vim'
"Plug 'jremmen/vim-ripgrep', {'frozen': 1}
Plug 'bbli/vim-ripgrep'
" Plug 'mhinz/vim-grepper'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all','frozen':1}
"Plug 'junegunn/fzf.vim', {'frozen': 1}
Plug 'bbli/fzf.vim'
Plug 'mbbill/undotree'
"Plug 'vimlab/split-term.vim'
Plug 'voldikss/vim-floaterm'
Plug 'bbli/vim-logreview'

"Plug 'vim-voom/VOoM'
"Language Server
Plug 'tpope/vim-projectionist' "This plugin also helps in setting file local variables, like `makerpg`
"---
"Plug 'majutsushi/tagbar'
Plug 'bbli/tagbar' "for changing tagbar highlight to IncSearch
" Plug 'liuchengxu/vista.vim' "Doesn't work on mac?
Plug 'ludovicchabant/vim-gutentags' "Vista auto does this
"Plug 'm-pilia/vim-ccls'
"Plug 'roxma/nvim-yarp'
"Plug 'ncm2/ncm2'
"Plug 'ncm2/ncm2-ultisnips'
"Plug 'ncm2/ncm2-bufword'
"Plug 'ncm2/ncm2-path'
"Plug 'fgrsnau/ncm2-otherbuf', { 'branch': 'ncm2' }
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
"Plug 'jackguo380/vim-lsp-cxx-highlight'
"Plug 'wellle/tmux-complete.vim'
"Plug 'cespare/vim-toml'
"Plug 'dag/vim-fish'
"Plug 'pboettch/vim-cmake-syntax'
"Plug 'rhysd/vim-llvm'
Plug 'Raku/vim-raku'
Plug 'elixir-editors/vim-elixir'

"Terminal Interactions
"---
" Plug 'vim-test/vim-test'
Plug 'bbli/vim-test', {'branch': 'benson-catch'}
" Plug 'rcarriga/vim-ultest', { 'do': ':UpdateRemotePlugins' } "Not working atm(and probably only works with correct errorformat. ALSO NOTE I ADDING LOGGING TO THE PLUGIN ITSELF
"Plug 'alepez/vim-gtest' "Hardcodes certain things
"If I want to explicitly choose the window for vim test
" Plug 'esamattis/slimux'
" For asynchronous make builds + supposedly help vim-test out regardless
" if chosen as strategy
Plug 'tpope/vim-dispatch'
" Plug 'neomake/neomake'
Plug 'mattboehm/vim-unstack'
" Plug 'benmills/vimux'
" Plug 'jpalardy/vim-slime', { 'branch': 'main'} "useful for creating specific state in script for profiling
" used by vim-test. NOTE YOU HAVE TO LET IT CREATE THE INITAL WINDOW
"Plug 'christoomey/vim-tmux-runner'
" Plug 'skywind3000/asynctasks.vim'
" Plug 'skywind3000/asyncrun.vim'

"Git
"---
"For Gvsplit and co
Plug 'tpope/vim-fugitive'
Plug 'jreybert/vimagit'
Plug 'f-person/git-blame.nvim'
" Plug 'airblade/vim-gitgutter'
" This plugin cannot stage hunks
"Plug 'mhinz/vim-signify'

"For diffing code that is not between branches
"Plug 'AndrewRadev/linediff.vim'
" When I work on a large codebase and need to see past logs that modified a certain line
"Plug 'rhysd/git-messenger.vim'

"Snippets
"---
" Plug 'SirVer/ultisnips', {'for': ['rust', 'cpp', 'vim', 'lua','python','sh','cmake','go','fish','perl', 'haskell']}
" Plug 'hrsh7th/vim-vsnip'
" Plug 'hrsh7th/vim-vsnip-integ'
" Plug 'honza/vim-snippets'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips', {'branch': 'main'}
" Plug 'dawikur/algorithm-mnemonics.vim'

"Latex
"---
"Plug 'lervag/vimtex', { 'tag': 'v1.0' }
"Plug 'brennier/quicktex'

"Text Objects 
"---
"Plug 'coderifous/textobj-word-column.vim'
"Plug 'glts/vim-textobj-indblock'
"Plug 'kana/vim-textobj-user' 
Plug 'wellle/targets.vim'
Plug 'michaeljsmith/vim-indent-object'
"Plug 'wellle/context.vim'
" For camelCase word deletion
"Plug 'Julian/vim-textobj-variable-segment'
call plug#end()
source ~/.vim/plugged/vim-sandwich/macros/sandwich/keymap/surround.vim


if !has('nvim')
	set ttymouse=xterm2
endif

"Making ALt usable on Linux
for i in range(97,122)
	  let c = nr2char(i)
	    exec "map \e".c." <M-".c.">"
		  exec "map! \e".c." <M-".c.">"
	  endfor
"augroup markdown
    "au!
    "au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
"augroup END
"""Leader maps must be defined after this command.
let mapleader=" "
let maplocalleader="-"

" ************** LEADER MAPS **************%%%1
" ---Misc--- %%%2
"nnoremap <leader><leader>t :MerlinTypeOf<CR>
"nnoremap <leader><leader>i :call <SID>show_documentation()<CR>
" nnoremap <leader>l 40l
" Override marks for now
nnoremap <leader><leader>z :nohlsearch<CR>
" nnoremap <C-t> <C-z>
" <C-^> switches between two files
nnoremap <leader>el :UnstackFromTmux<CR>
nnoremap <leader>ec :sign unplace<CR>

"let g:qf_auto_open_quickfix = 0
"let g:qf_auto_open_loclist = 0
"let g:qf_shorten_path = 0
let g:toggle_qf = 0
function! ToggleQuickfixList()
    if g:toggle_qf == 0
        let g:toggle_qf = 1
        execute "copen"
    else
        let g:toggle_qf = 1
        execute "cclose"
    endif
endfunction


nmap <leader>tq :call ToggleQuickfixList()<CR>
nmap <leader>qn <Plug>(qf_newer)
let g:qf_mapping_ack_style = 1
let g:qf_nowrap=0
nmap <leader>qN <Plug>(qf_older)
nmap <leader>qq <Plug>(qf_qf_switch)
" Don't apply g when substituting
nnoremap <leader>qr :cdo s/
" nnoremap <leader>qr :cdo s/

" coc's version is more useful as it will generate based on file path, not current
" directory
nnoremap <F9> :!ctags -R --sort=yes .<CR>


" ---Buffer Related---{{2
command! BufOnly silent! :%bd|e#|bd#<CR>
nnoremap <leader>bD :BufOnly<CR>
nnoremap <leader>ba :A<CR>
nnoremap <leader>bs <C-^>
nnoremap <silent> <leader>bk :bwipeout<CR>
nnoremap <leader>bf :ZenMode<CR>
nnoremap <leader>bz :ZenMode<CR>
nnoremap <leader>bb <cmd>Telescope buffers<cr>

nnoremap <leader>br :%s/\<<C-r><C-w>\>/
" nnoremap <leader>br :%s/\<<C-r><C-w>\>/
nnoremap <leader>bm :g/\<<C-r><C-w>\>/norm! @m<CR>

" ---Edit Related--- %%%2
"  stuff
" nmap gc <Plug>NERDCommenterToggle
" vmap gc <Plug>NERDCommenterToggle
vmap <unique> <leader>c  <Plug>Commentary
vmap <unique> <leader><leader>c  <Plug>Commentary
omap <unique> <leader>c  <Plug>Commentary
nmap <unique> <leader>cc <Plug>CommentaryLine
nmap <unique> <leader><leader>c <Plug>CommentaryLine

nnoremap <leader><leader>p "+p
nnoremap <leader><leader>P "+P
vnoremap <leader><leader>y "+y
nnoremap <leader><leader>y "+yy
vnoremap <leader><leader>d "+d
nnoremap <leader><leader>d "+dd

nnoremap <unique> <leader><leader>t :ISwapWith<CR>

vnoremap mm :'<,'>norm @m<CR>
vnoremap lc :'<,'>norm 0i--<CR>
vnoremap lC :'<,'>norm 0xx<CR>
vnoremap : :'<,'>norm 
nnoremap <leader>me :MacroEdit m<CR>
" nnoremap <leader>mm @m
nnoremap <leader><leader>m @m
nnoremap <leader>ma :%normal @m<CR>
vnoremap <leader><leader>m :'<,'>normal @m<CR>

nmap <leader>mr <plug>(Mac_NameCurrentMacro)
nmap <leader>mf <plug>(Mac_SearchForNamedMacroAndPlay)

nmap <leader>md <plug>(Mac_SearchForNamedMacroAndDelete)
nmap <leader>mo <plug>(Mac_SearchForNamedMacroAndOverwrite)
" ---Workspace Related--- %%%2
nnoremap <leader>ws :mks ~/.vim/sessions/default.vim<CR>
nnoremap <leader>wl :source ~/.vim/sessions/default.vim<CR>

nnoremap <leader>wn :tabnext<CR>
nnoremap <leader>wp :tabprevious<CR>
" TODO: change to w to be aligned with emac's workspace?
" Also, my hands moving to w feels much better than moving to t,
" As I can still use my pointer finger after clicking w
" Last of all, t can be back to being "Toggle" keymaps
nnoremap <leader>wo :tab split<CR>
nnoremap <leader>wO <C-w>T
nnoremap <leader>wk :tabc<CR>
" nnoremap <leader>wr :TabooRename 
"nnoremap <leader>ws :TabooReset<CR>

" ---Git Related--- %%%2
autocmd FileType magit nnoremap <buffer> <leader>gy "gyy
autocmd FileType magit nnoremap <buffer> <leader>gp "gp
" nmap <leader>gp <Plug>(GitGutterPreviewHunk)
" nmap gs <Plug>(GitGutterStageHunk)
" vmap gs <Plug>(GitGutterStageHunk)
" nmap <leader>gu <Plug>(GitGutterUndoHunk)
" nmap <leader>gn <Plug>(GitGutterNextHunk)
" nmap <leader>gN <Plug>(GitGutterPrevHunk)

nnoremap <leader>gm :Magit<CR>
" nmap <leader>gf :GitGutterFold<CR>
" nmap <leader>go <Plug>(git-messenger)
nmap <leader>gl :Gclog -10000<CR>

nnoremap <unique> <leader>gc :Gclog -10000 --grep=
" nnoremap <unique> <leader>gc :Gclog --grep=
nnoremap <unique> <leader>gs :Gclog -10000 -S 
" nnoremap <unique> <leader>gs :Gclog -S
nnoremap <unique> <leader>gf :Gclog -10000 -- %<CR>
" Above is better b/c if commit on another branch -> will have a name
"nmap <leader>gl :VTerm<CR>git tree<CR>
nmap <leader>gg :G<CR>
nnoremap <leader>gd :Gvdiff 
nnoremap <leader>gb :Git blame<CR>

" ---Terminal Related --- %%%2
"  <root> option only works with FloattermToggle
let g:shell_count = 0
function! ToggleShell()
    if g:shell_count == 0
        let g:shell_count = 1
        execute "FloatermNew --cwd=<root> --name=shell"
        execute "bn"
        execute "normal \<C-o>"
    else
        execute "FloatermToggle shell"
    endif
endfunction

let g:test_shell_count = 0
function! ToggleTestShell()
    if g:test_shell_count == 0
        let g:test_shell_count = 1
        execute "FloatermNew --cwd=<root> --name=test"
        execute "bn"
        execute "normal \<C-o>"
    else
        execute "FloatermToggle test"
    endif
endfunction
let g:vifm_count = 0
function! ToggleVifm()
    if g:vifm_count == 0
        let g:vifm_count = 1
        " execute "FloatermKill vifm"
        echo "vifm_count = " .. g:vifm_count
        execute "FloatermNew --name=vifm --cwd=<buffer> vifm"
    else
        let g:vifm_count = 0
        echo "vifm_count = " .. g:vifm_count
        let output = execute("FloatermKill vifm")
        " echo output
        " Means we need to open instead
        if output != ""
            execute "FloatermNew --name=vifm --cwd=<buffer> vifm"
        endif
        " 1.Open Vifm
        " 2. Click Enter
        " 3. Vifm is now closed, but vifm_count still 1
        " 4. Try to call ToggleVifm again, will call "FloatermKill" instead of
        " open
    endif
endfunction
nnoremap <leader>ts :call ToggleShell()<CR>
nnoremap <leader>os :call ToggleShell()<CR>
nnoremap <leader>ot :call ToggleTestShell()<CR>
nnoremap <leader>tn :call ToggleVifm()<CR>
nnoremap <leader>ov :call ToggleVifm()
function s:open_in_normal_window() abort
  let f = findfile(expand('<cfile>'))
  if !empty(f) && has_key(nvim_win_get_config(win_getid()), 'anchor')
    FloatermHide
    execute 'e ' . f
  endif
endfunction

autocmd FileType floaterm nnoremap <silent><buffer> gf :call <SID>open_in_normal_window()<CR>
let g:floaterm_opener="edit"
let g:floaterm_autoclose=0
let g:floaterm_width = 0.8
let g:floaterm_height = 0.95
nnoremap <leader>sn <cmd>FloatermNext
nnoremap <leader>sN <cmd>FloatermPrev
" Rerun last command
command -nargs=+ ShellSend :call v:lua.require'benson-term'.benson_floaterm_send(<q-args>)
nnoremap <leader>ss <cmd>lua require('benson-term').send_last_string_to_term()<CR>
" Run a specific command
nnoremap <leader>sl :ShellSend 
nnoremap <leader>sh <cmd>lua require('benson-term').send_string_from_history()<CR>


" ---Open + Find Related--- %%%2
" fzf and ripgrep settings
let g:rg_highlight = 1
command! -bang -nargs=? -complete=dir HFiles
  "\ call fzf#vim#files(<q-args>, {'source': 'rg --hidden --ignore .git -g ""'}, <bang>0)
  "\ call fzf#vim#files(<q-args>, fzf#wrap({'source': 'rg --hidden --ignore --hidden .git'}), <bang>0)
  \ call fzf#vim#files(<q-args>, fzf#wrap({'source': 'rg --files --hidden'}), <bang>0)
"command! -bang -nargs=? -complete=dir Files
  "\ call fzf#vim#files(<q-args>, {'source': 'rg --ignore .git -g ""'}, <bang>0)
"fix this
"2

command! -bang OP call fzf#run(fzf#wrap({'source':'rg --files --hidden','sink':'' 'dir':"~/"}))<CR>
"1
"command! -bang OP call fzf#vim#complete#path('rg --files',{'dir':home_dir})
"nnoremap <leader>op :call fzf#vim#complete#path('rg --files',{'dir':home_dir})<CR>
"nnoremap <leader>op :OP<CR>
nnoremap <leader>oo :GFiles<CR>
"nnoremap <leader>oa :FZF<CR>
nnoremap <leader>oa :HFiles<CR>
"nnoremap <leader>ob :CocList buffers<CR>
nnoremap <leader>od :BD<CR>
" TODO: Replace with meta-;??
nnoremap <leader>oc :Commands<CR>
"nnoremap <leader>os :History/<CR>
"nnoremap / :History/<CR>
"nnoremap : :Commands<CR>
"nnoremap <leader>: :
" nnoremap <leader>oi :HFiles<CR>
" nnoremap <leader>ob :Files ../<CR>
nnoremap <leader>oh :History<CR>
nnoremap <leader>or :Registers<CR>
nnoremap <leader>oy :Registers<CR>
" nnoremap <leader>op :CocList mru<CR>
"nnoremap <leader><leader>oh :FZF ~<CR>
nmap <leader>oq <Plug>(qf_qf_toggle)

"My wrapper so that I don't need to modify the plugin itself
"fun
let g:rg_command = 'rg --vimgrep --hidden -g "!.git"'
"command! -bang -nargs=* GRg
    "\ call fzf#vim#grep('rg --hidden -g "!.git" '.shellescape(<q-args>), 0,
        "\ {'dir': systemlist('git rev-parse --show-toplevel')[0]}, <bang>0)
"This way doesn't work for some reason
  "\ call fzf#vim#grep(<q-args>, 0, {'source': 'rg --hidden ', 'dir': systemlist('git rev-parse --show-toplevel')[0]}, <bang>0)
command! -bang -nargs=* GGrep
        \ call fzf#vim#grep(
            \   'git grep --line-number -- '.shellescape(<q-args>), 0,
            \   {'dir': systemlist('git rev-parse --show-toplevel')[0]}, <bang>0)


nnoremap <leader>ff :Telescope live_grep<CR>
" nnoremap <leader>ff :GitRipGrep 
" Search in git repo
function! s:find_git_root()
    return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
function! RipGrepProjectHelper(pattern)
    " we cannot use shell escape b/c it will SINGLE QUOTE the pattern ->
    " which prevents passing ADDITIONAL ARGUMENTS
    execute "grep " .. a:pattern .. " " .. s:find_git_root()
endfunction
command! -nargs=1 RipGrepProject call RipGrepProjectHelper(<q-args>)
nnoremap <leader>fp :RipGrepProject 
nnoremap <leader>fa :grep 
nnoremap <leader>fw :Ggrep \b<C-r><C-w>\b<CR>
nnoremap <leader>fs :Telescope lsp_dynamic_workspace_symbols<CR> 
" Doesn't really work
" nnoremap <leader>fs :tabnew %<CR>:Fw<CR> 
" nnoremap <leader>fw :Ggrep <C-r><C-w><CR>
autocmd FileType logreview nnoremap <leader>fl :RemoveAllButClass 
autocmd FileType logreview nnoremap <leader>fe :RemoveAllButClass BENSON_DEBUG<CR>
autocmd FileType log nnoremap <leader>fl :RemoveAllButClass 
autocmd FileType log nnoremap <leader>fe :RemoveAllButClass BENSON_DEBUG<CR>

let g:eventignore_toggle = 0
function! SetEventIgnore()
    if g:eventignore_toggle == 0
        let g:eventignore_toggle = 1
        setlocal eventignore=all
    else
        let g:eventignore_toggle = 0
        setlocal eventignore=
    endif
endfunction
nnoremap <leader>te :call SetEventIgnore()<CR>

" :'<,'>norm! @a to apply the macro only to a visual selection
" (hit : in visual mode to switch to command mode)

function! JumpToBookMark()
    execute('BookmarkShowAll')  
   call feedkeys("\<CR>")
endfunction


" ---Compling/Running/Project Related--- %%%2
"TODO: change prefix to 'r' or 'p' for run/project?
"nnoremap <leader>sp :SlimuxREPLConfigure<CR>
"nnoremap <leader>ss :SlimuxShellRun
nnoremap <leader>pe <cmd>TroubleToggle lsp_workspace_diagnostics<CR>
" For some reason need to do two escapes
" nnoremap <leader>pt :GitRipGrep TODO\\|NOTE<CR>
nnoremap <leader>pt :GitRipGrep TODO<CR>
nnoremap <leader>jt :call JumpToBookMark()<CR>
" mm to toggle a bookmark
" nnoremap <leader>se <cmd>TroubleToggle lsp_workspace_diagnostics<CR>
" nnoremap <leader>ss :ProjectRootExe TestNearest<CR>
" nnoremap <leader>sl :ProjectRootExe TestLast<CR>
" nnoremap <leader>sf :ProjectRootExe TestFile<CR>
" nnoremap <leader>sp :ProjectRootExe TestSuite<CR>
nmap <leader><leader>t <Plug>PlenaryTestFile
nmap <leader><leader>r <Plug>LuaRun

" nnoremap <leader>sm :Messages<CR>
" vim test also integrates with projectionist plugin
let g:VimuxUseNearest=1
" nnoremap <leader>sp :VimuxOpenRunner<CR>

"nnoremap <leader>sl :VimuxPromptCommand<CR>
"nnoremap <leader>ss :VimuxRunLastCommand<CR>
"nnoremap <leader>si :VimuxInspectRunner<CR>
"nnoremap <localleader>vs :VimuxInterruptRunner<CR>
"
"nnoremap <leader>sl :VtrSendLinesToRunner<CR>
"vnoremap <leader>sl :VtrSendLinesToRunner<CR>
"nnoremap <leader>sp :VtrAttachToPane<CR>
"nnoremap <leader>ss :VtrSendCommand<CR>
"nnoremap <leader>sf :VtrFlushCommand<CR>

" Vimux's version is better
"nnoremap <leader>sz :VtrFocusRunner<CR>
" These didn't work that well
"nnoremap <leader>sd :VtrDetachRunner<CR>
"nnoremap <leader>sa :VtrReattachRunner<CR>
"
"nnoremap <leader>sd :VtrSendCtrlD<CR>
"nnoremap <leader>ss %

" ---Toggles--- %%%2
"nnoremap <leader>to :VoomToggle markdown<CR>
nnoremap <leader>tw :AirlineToggleWhitespace<CR>

function! ToggleFoldSearch()
    if &foldopen =~ "search"
        set foldopen-=search
    else
        set foldopen+=search
    endif
endf
nnoremap <leader>tf :call ToggleFoldSearch()<CR>
nnoremap <leader>tg :GitBlameToggle<CR>
nnoremap <leader>tc :TSContextToggle<CR>
nnoremap <leader>tu :UndotreeToggle<CR>
nnoremap <leader>tt :TagbarToggle<CR>
"nnoremap <leader>ts :set spell!<CR>
" nnoremap <leader>ts :FloatermToggle<CR>
let s:nerdtree_open = 0
function! ToggleNerdTree()
    " NOTE: an aside, but notice that we have the choice here of setting
    " before activating or vice versa -> from RLE
    if s:nerdtree_open
        let s:nerdtree_open = 0
        echom "close"
        execute "NERDTreeToggle"
    else
        let s:nerdtree_open = 1
        echom "open"
        execute "NERDTreeFind"
    endif
endf
" nnoremap <leader>tn :call ToggleNerdTree()<CR>
"nnoremap <leader>tp :set paste!<CR>

"nnoremap <leader>ti :IndentGuidesToggle<CR>

"nmap <leader>tq :copen<CR>
"nmap <leader>tl :lopen<CR>
"nmap <leader>tq :call ToggleQuickfixList()<CR>
"nmap <leader>tl :call ToggleLocationList()<CR>
nmap <leader>tl <Plug>(qf_loc_toggle)

" nmap <leader>jt <Plug>(coc-refactor)
" nmap <leader>ji <Plug>(coc-funcobj-i)
" nmap <leader>jj <Plug>(coc-funcobj-a)

" ---Jump Related--- %%%2
" nmap <leader>jf <Plug>(coc-float-jump)
" nnoremap <leader>jb <C-t>
nnoremap <leader>jc g;
nnoremap <leader>jC g,

"TODO: rarely used and will soon be replaced by harpoon
" nnoremap <leader>jm `M
" nnoremap <leader>mm mM

" ---Diff View Related--- %%%2
nnoremap <leader>dn ]c
nnoremap <leader>dN [c
"nnoremap <leader>dl :.diffput<CR>
"Grab from left side
nmap <leader>dh :diffget //2<CR>
"Grab from right side
nmap <leader>dl :diffget //3<CR>
nnoremap <leader>dp dp

"autocmd BufEnter *.py  nnoremap <buffer> <leader>c I#<esc>
"autocmd BufEnter *.m  nnoremap <buffer> <leader>c I%<esc>
" ************** LOCAL LEADER MAPS **************%%%1
nnoremap <localleader>v :e ~/.vimrc<CR>
nnoremap <localleader>b :e ~/.bash_aliases<CR>
nnoremap <localleader>t :e ~/.tmux.conf<CR>
nnoremap <localleader>g :e ~/.gitconfig<CR>
nnoremap <localleader>n :e ~/.config/nvim/init.vim<CR>
nnoremap <localleader>k :e ~/.config/kitty/kitty.conf<CR>
nnoremap <localleader>f :e ~/.config/fish/config.fish<CR>
nnoremap <localleader>x :e ~/.config/xmonad/xmonad.hs<CR>
nnoremap <localleader>l :e ~/.init.lua<CR>
" nnoremap <localleader>s :e ~/.config/starship.toml<CR>
" nnoremap <localleader>s :VsnipOpen!<CR>

" nnoremap <localleader>c :CocConfig<CR>


"nnoremap <localleader>ww :MarkdownPreview<CR>
"nnoremap <localleader>wc :MarkdownPreviewStop<CR>

"nnoremap <localleader>e :!python % <CR>
"nmap <localleader>e <Plug>(processing-run)

"nnoremap <localleader>t <C-W>T
" ************** META MAPS **************%%%1
"To move lines intuitively
"Alt and Shift combos won't work with K
"But Ctrl will mess up window specific mappings
nnoremap <M-k> :m .-2<CR>==
nnoremap <M-j> :m .+1<CR>==
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

nnoremap <C-w><Space> <C-w>=
" nnoremap <C-w><C-w> <C-w>p
nnoremap <C-w>; <C-w>p

"nnoremap <C-h> <C-w><C-h>
"nnoremap <C-j> <C-w><C-j>
"nnoremap <C-k> <C-w><C-k>
"nnoremap <C-l> <C-w><C-l>

map <M-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" ************  FN MAPS  ************%%%1
"nnoremap <F2> :TagbarToggle<CR>
"nnoremap <F3> :AirlineToggleWhitespace<CR>

"nnoremap <F4> :setlocal spell  spelllang=en_us<CR>
"nnoremap <F5> :set nospell<CR>

"nnoremap <silent> <F8> :NERDTreeToggle<CR>
"nnoremap <F10> :set nopaste

" ************** SEMI COLON MAPS **************%%%1
inoremap ;c <C-c>
vnoremap ;c <C-c>
inoremap ;; ;
vnoremap ;w <C-c>:w<CR>
inoremap ;w <C-c>:w<CR>
" nnoremap ;q <C-z>
nnoremap ;q :q<CR>
nnoremap ;z :q!<CR>
nnoremap ;w <C-c>:w<CR>
nnoremap ;n :bn<CR>
nnoremap ;N :bp<CR>
nnoremap <silent> ;d :bwipeout<CR>
nnoremap ;D :bwipeout!<CR>
"inoremap <C-m> <C-C>la
inoremap <C-l> <C-c>la

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'}))

nnoremap <leader>; ,

nnoremap ;t :MtaJumpToOtherTag<CR>
nnoremap ;o <C-^>
nnoremap ;r @:

" ************** NORMAL MODE MAPS **************%%%1
" nnoremap <unique> k gk
" nnoremap <unique> j gj
nnoremap <unique> gk k
nnoremap <unique> gj j
"nnoremap EE @

nnoremap <unique> C c$
nnoremap <unique> D d$
nnoremap Y y$
nnoremap <unique> E $
nnoremap <unique> gE g$
"nnoremap <unique> W 0w
" to jump between brackets/parantheses
nnoremap S %
"nnoremap w W
"nnoremap W w
"nnoremap b B
"nnoremap B b
" nnoremap n nzz
" nnoremap N Nzz
nnoremap <unique> <expr> k v:count > 1  ?  "m'" . v:count . "k"  : "gk"
nnoremap <unique> <expr> j v:count > 1  ?  "m'" . v:count . "j"  : "gj"

nnoremap <unique> gb gi

"Training vim skip
nnoremap <unique> h <Nop>
nnoremap <unique> l <Nop>
nnoremap <unique> <C-g> <cmd>close<CR>
vnoremap <unique> <C-g> <ESC>

vnoremap > >gv
vnoremap < <gv

" ************** COMMAND MODE MAPS **************%%%1
cnoremap sE %s
" nnoremap / /\<
nnoremap <leader>/ /
"For grep
"cnoremap cf cfirst
" cnoremap SB set scrollbind
" cnoremap NSB set noscrollbind
"cnoremap tc tabc
"cnoremap tn tabnext
"cnoremap tN tabprevious
"cnoremap tC tabc<CR>
" cnoremap vsb vertical sb
" nnoremap <leader><leader>t :tabn<CR>


" ************** OPERATOR MODE MAPS **************%%%1
"onoremap w W
"onoremap W w
"onoremap b B
"onoremap B b
"onoremap ) i)
"onoremap ] i]
" onoremap s i]
" onoremap S a]

onoremap p i)
onoremap P a)
onoremap ll $

" Cannot since this will override cc
onoremap <expr> c v:operator ==# 'c' ? 'c' : 'i}'
onoremap C a}
" So instead
" onoremap b i}
" onoremap B i}
" ************** INSERT MODE MAPS **************%%%1
" To be honest, I don't think this is nesscary. Those keys are not awkward,
" and I only mapped it because I was fixated on insert normal mode
"inoremap ]] <C-c>A

"make cause some issues, such as dummy -> but will be amortized zero cost with
"autocomplete
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap { {<c-g>u
inoremap [ [<c-g>u

imap <C-f> <plug>(fzf-complete-path)
" imap <C-l> <C-x><C-l> "move one character over is used more and has same
" mapping
"inoremap " ""<left>
"inoremap ' ''<left>
"inoremap ( ()<left>
"inoremap [ []<left>
"inoremap { {}<left>
" ************** CONTROL/SPECIAL KEY(TAB,etc) MAPS **************%%%1
"This may be dangerous as vim has a lot of built in control key maps
"Only do to overide
"nnoremap <C-]> :vs<CR><C-]>
"nnoremap <C-[> <C-t>
"nnoremap <C-j> :vs<CR><C-]>
"nnoremap <C-n> <C-^>
xmap <C-e><C-e> <Plug>SlimeRegionSend
nmap <C-e><C-e> <Plug>SlimeLineSend
nmap <C-d> <C-b>

let g:fold_flag = 0
function! ToggleFoldAll()
    if g:fold_flag
        let g:fold_flag = 0
        normal! zM
    else
        let g:fold_flag = 1
        normal! zR
    endif
endfunction
" Note this will override <C-i>
" nmap <TAB> za
nnoremap go za
nnoremap <S-TAB> :call ToggleFoldAll()<CR>
" Actually, this will override default "outline" command
" nnoremap gO :call ToggleFoldAll()<CR>


nnoremap <Space> <Nop>
" nnoremap <Up> <Nop>
" nnoremap <Down> <Nop>
" nnoremap <Left> <Nop>
" nnoremap <Right> <Nop>
" ************** COLORS **************%%%1
"makes vim colorscheme the same as the terminal

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" let g:taboo_tabline = 0

if has('termguicolors')
    set termguicolors
endif
" set termguicolors
"Makes a solarized approximation for vim
"let g:solarized_termcolors=256
set background=dark
let g:gruvbox_contrast_dark="soft"
" let g:gruvbox_bold=0
let g:gruvbox_underline=1

"colorscheme one
"colorscheme gruvbox
"colorscheme palenight
" Dark

" colorscheme neodark
" colorscheme deus
let g:sonokai_style = 'shusia'
let g:sonokai_diagnostic_line_highlight = 1
"colorscheme sonokai

let g:edge_style = 'default'
let g:edge_diagnostic_line_highlight = 1
colorscheme edge
"
"augroup filetype_color
	"autocmd!
	"autocmd FileType text color nova
	"autocmd FileType vim color seoul256
	"autocmd FileType matlab color seoul256
	"autocmd FileType python color gruvbox
	"autocmd FileType markdown color nova
	"autocmd FileType latex color nova
    "autocmd FileType html color nova
    "autocmd FileType javascript color gruvbox
    "autocmd FileType css color nova
    "autocmd FileType scheme color gruvbox
    "autocmd FileType c color gruvbox
    "autocmd FileType cpp color gruvbox
    "autocmd FileType clojure color gruvbox
"augroup END

"augroup buffer_color
	"autocmd!
	"autocmd BufEnter vim colorscheme seoul256
	""autocmd BufEnter *.txt colorscheme seoul256
	"autocmd BufEnter *.txt colorscheme nova
	"autocmd BufEnter *.py colorscheme gruvbox
	"autocmd BufEnter *.m colorscheme seoul256
    "autocmd BufEnter *.md colorscheme nova
	"autocmd BufEnter *.tex colorscheme nova
    "autocmd BufEnter *.html color nova
    "autocmd BufEnter *.js color gruvbox
    "autocmd BufEnter *.css color nova
    "autocmd BufEnter *.scm color gruvbox
    "autocmd BufEnter *.c color gruvbox
    "autocmd BufEnter *.cpp color gruvbox
    "autocmd BufEnter *.h color gruvbox
    "autocmd BufEnter *.clj color gruvbox
"augroup END

" ************** AUTOCOMMANDS **************%%%1
autocmd BufNewFile,BufReadPost *.fish set filetype=fish "Make vim recognize .md as markdown file
autocmd BufNewFile,BufReadPost xmobarrc set filetype=haskell "Make vim recognize xmobarrc as a haskell file
autocmd BufNewFile,BufReadPost Rexfile set filetype=perl "Make vim recognize .md as markdown file
autocmd BufNewFile,BufReadPost *.t set filetype=perl "Make vim recognize .t as perl test file
autocmd FileType fish set commentstring=#%s
autocmd FileType toml set commentstring=#%s
autocmd BufNewFile,BufReadPost *.md set filetype=markdown "Make vim recognize .md as markdown file
autocmd BufNewFile,BufReadPost *.txt set filetype=markdown "Make vim recognize .md as markdown file
autocmd BufNewFile,BufReadPost CMakeLists.txt set filetype=cmake "except cmake files
autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css

autocmd FileType go let b:dispatch = 'go test'
autocmd FileType perl set iskeyword+=$
autocmd FileType perl set iskeyword+=@-@
autocmd FileType perl set iskeyword+=%


" au BufReadPost quickfix :call ConcealPath() 
nnoremap <leader>cp :call ToggleConcealPath()<CR>
let s:quickfix_path_conceal = v:false
function ToggleConcealPath()
    if s:quickfix_path_conceal
        let s:quickfix_path_conceal = v:false
       setlocal conceallevel=0
   else
       let s:quickfix_path_conceal = v:true
       syntax match ConcealedPath /\v^\/[^|]*\// conceal cchar=&
       setlocal conceallevel=2
       setlocal concealcursor=nvic
   endif
endfunction

augroup quickfix
    autocmd!
    autocmd FileType qf setlocal wrap
augroup END

nnoremap <leader>is Bi$<ESC>W
nnoremap <leader>ia Bi@<ESC>W
nnoremap <leader>ih Bi%<ESC>W

""""""""Misc""""""""%%%1
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %
""""""""Plugin related variables""""""""%%%1
" let g:neomake_open_list = 2
" let g:yggdrasil_no_default_maps = 1
" au FileType yggdrasil nmap <silent> <buffer> o <Plug>(yggdrasil-toggle-node)
" au FileType yggdrasil nmap <silent> <buffer> <CR> <Plug>(yggdrasil-execute-node)
"let g:ccls_log_file = expand('~/my_log_file.txt')

" TODO:I still don't really understand the purpose of "type" key-value,but w.e
let g:projectionist_heuristics = {
            \ '*' : {
                \ '*.cpp' :{
                        \ 'alternate' : '{}.h',
                        \ 'type' : 'source'
                    \ },
                \ '*.h' : {
                        \ 'alternate' : '{}.cpp',
                        \ 'type' : 'header'
                    \}
                \}
            \}
"autocmd BufEnter * call ncm2#enable_for_buffer()
"Actually independent of ncm2 plugin. Just code for QOL when using autocomplete
set completeopt=noinsert,menuone,noselect

"make quickfix open with height of 6 lines
let g:asyncrun_open = 6


let g:tagbar_map_togglesort = ''
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
let g:tagbar_width = max([25,winwidth(0) / 4])
" "Doesn't look as nice, which is probably why I don't like vista.vim
" let g:tagbar_compact = 1 

let g:toggle_list_no_mappings = 1
let g:git_messenger_no_default_mappings = v:true

let g:sneak#s_next = 1
let g:sneak#use_ic_scs = 1
" nnoremap <silent> s :<C-U>call sneak#wrap('',           3, 0, 2, 1)<CR>
" nnoremap <silent> S :<C-U>call sneak#wrap('',           3, 1, 2, 1)<CR>
" highlight! link Sneak IncSearch
" highlight! link SneakScope Search

let g:clever_f_across_no_line = 1
let g:clever_f_smart_case = 1
let g:clever_f_highlight_timeout_ms=600
" nmap <unique> ;; <Plug>(clever-f-repeat-forward)
" nmap <unique> , <Plug>(clever-f-repeat-back)
nnoremap ;; ;


let g:indentLine_setColors = 0

"let g:indent_guides_enable_on_vim_startup = 1
"let g:gitgutter_sign_added = 'a'
"let g:gitgutter_sign_modified = 'm'
"let g:gitgutter_sign_removed = 'r'
"let g:gitgutter_sign_modified_removed = 'mr'
let g:gitgutter_map_keys = 0

let g:enable_bold_font = 1


let g:processing_no_default_mappings = 1

let g:gruvbox_italic=1
let g:gruvbox_contrast_dark = 'soft'
let g:gruvbox_contrast_light = 'soft'
"Makes sure tex files are read as latex type
let g:tex_flavor = 'latex'
let g:vimtex_mappings_enabled=1
"let g:ycm_python_binary_path = '/usr/bin/python3'

" let g:fzf_layout = { 'window': 
"     \ { 'width': 1,
"     \ 'height': 0.35,
"     \ 'yoffset': 1,
"     \ 'border': 'rounded',
"     \}}

" An action can be a reference to a function that processes selected lines
" Benson: Doesn't work though
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction
let g:fzf_action = {
  \ 'ctrl-l': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - Popup window
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
" let g:fzf_layout = { 'window': 
"     \ { 'width': 1,
"     \ 'height': 0.35,
"     \ 'yoffset': 1,
"     \ 'border': 'rounded',
"     \}}

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
	\ 'bg':      ['bg', 'Normal'],
	\ 'hl':      ['fg', 'Comment'],
	\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
	\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
	\ 'hl+':     ['fg', 'Statement'],
	\ 'info':    ['fg', 'PreProc'],
	\ 'prompt':  ['fg', 'Conditional'],
	\ 'pointer': ['fg', 'Exception'],
	\ 'marker':  ['fg', 'Keyword'],
	\ 'spinner': ['fg', 'Label'],
	\ 'header':  ['fg', 'Comment'] }

let g:vimtex_view_method = 'zathura'
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.1"}
let g:slime_paste_file = "$HOME/.slime_paste"
let g:slime_no_mappings = 1
let g:slime_dont_ask_default = 1
"let g:slime_no_mappings = 1
"let g:slime_python_ipython = 1
"let g:slime_dont_ask_default = 1

"let g:instant_markdown_slow=1
"Converting markdown to pdf
"autocmd BufWritePost *.md !markdown-pdf % -o %.pdf
"let g:vimwiki_hl_headers = 1

let g:UltiSnipsExpandTrigger = "zz" 
let g:UltiSnipsJumpForwardTrigger = "<leader><leader>"
let g:UltiSnipsJumpBackwardTrigger = "<c-h>"
" NOTE: You can use other key to expand snippet.

" Expand
" imap zz   <Plug>(vsnip-expand)
" smap zz   <Plug>(vsnip-expand)


" Expand or jump
" imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" smap <leader><leader>   <Plug>(vsnip-jump-next)

" " Jump forward or backward
" imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
" smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
" xmap        s   <Plug>(vsnip-select-text)
" nmap        s   <Plug>(vsnip-select-text)
" nmap        S   <Plug>(vsnip-cut-text)
" xmap        S   <Plug>(vsnip-cut-text)

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_extra_mapping = v:false
" let g:vsnip_filetypes = {}
" let g:vsnip_filetypes.javascriptreact = ['javascript']
" let g:vsnip_filetypes.typescriptreact = ['typescript']

"let g:mkdp_path_to_chrome = "firefox"
"let g:mkdp_auto_start = 0
"let g:mkdp_auto_close = 0
"let g:mkdp_refresh_slow = 1

"let g:airline_section_c = '%-0.10{getcwd()}'
"let g:airline_theme='gruvbox'
let g:airline_theme = "onedark"
"let g:airline_theme = "raven"
"let g:airline_theme = "base16_google"
"let g:airline_theme = "base16_eighties"
"let g:promptline_theme = 'gruvbox'
"let g:airline_theme='one'
"Makes it so actual buffer number shows up in the tabline. Not nesscary since idx mode works now
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#enabled = 1
"Just show the filename
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#vimtex#enabled = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#tab_nr_type = 1
" This should allow me to select buffers by their numbers. But is currently not working
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#show_buffers = 1
"Do not draw separators for empty sections (only for the active window) >
"This is for a tag outline, to be used with majutsushi/tagbar
let g:airline#extensions#tagbar#enabled=0
let g:airline_skip_empty_sections = 1
let g:airline#extensions#vimagit#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
"let g:airline_symbols.maxlinenr
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7

let g:ackprg = 'ag --vimgrep --ignore=tags'

let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_DiffCommand = "diff"


let NERDCreateDefaultMappings = 0
let NERDTreeHijackNetrw=1
let NERDTreeChDirMode=3
let NERDTreeHighlightCursorline=1

"nnoremap <C-j> <C-W><C-j>
"nnoremap <C-k> <C-W><C-k>
"nnoremap <C-l> <C-W><C-l>
"nnoremap <C-h> <C-W><C-h>

let g:promptline_preset = {
        \'a' : [ promptline#slices#conda_env(),promptline#slices#cwd({'dir_limit':1}) ],
        \'b' : [ promptline#slices#vcs_branch(),promptline#slices#git_status() ],}
" \'b' : [ promptline#slices#cwd({'dir_limit':1}) ],
" \'y' : [ promptline#slices#git_status() ]}
"\'a' : [ promptline#slices#conda_env() ],
"\'b' : [ promptline#slices#user() ],
 "\'warn' : [ promptline#slices#last_exit_code() ]}
"Use this one for custom thing on left
"     \'b'    : '#(df -h| head -n 4 | tail -n 1)',
let g:tmuxline_preset = {
     \'a'    : '#S',
     \'win'  : ['#I', '#W'],
     \'cwin' : ['#I', '#W', '#F'],
     \'y'    : ['%R', '%a', '%m', '%d', '%Y'],
     \'z'    : '#H'}

"let g:tmuxline_preset = {
"     \'a'    : '#S',
"     \'c'    : ['#(whoami)', '#(uptime  | cut -d " " -f 1,2,3)'],
"     \'win'  : ['#I', '#W'],
"     \'cwin' : ['#I', '#W', '#F'],
"     \'x'    : '#(date)',
"     \'y'    : ['%R', '%a', '%Y'],
"     \'z'    : '#H'}

"SourceIfExists(~/.vim_config)
" source ~/.vim_config
"this only works when calling vimdiff from command line
"so its useless for comparing different versions with git
" NOTE: guicolors are what chages things -> as I have "termguicolors"  set
highlight DiffAdd    cterm=none ctermfg=none ctermbg=Green gui=none guifg=none guibg=Green
highlight DiffDelete cterm=none ctermfg=none ctermbg=Red gui=none guifg=none guibg=Red
highlight DiffChange cterm=none ctermfg=none ctermbg=DarkCyan gui=none guifg=none guibg=DarkCyan
highlight DiffText   cterm=bold ctermfg=none ctermbg=none gui=bold guifg=none guibg=SlateBlue
"let g:gitgutter_highlight_lines = 1
"hi CursorLine cterm=underline term=underline ctermbg=Grey40 guibg=Grey40

"For tmux runner
let g:VtrStripLeadingWhitespace = 0
let g:VtrClearEmptyLines = 0
let g:VtrAppendNewline = 1
let g:VtrClearBeforeSend = 0


" highlights yanked text
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

autocmd FileType json syntax match Comment +\/\/.\+$+
" autocmd BufReadPre,FileReadPre * :set background=dark

" Enabling highlighting on C++ functions/methods
highlight LspCxxHlSymClassMethod ctermfg=White
highlight LspCxxHlSymClassVariable ctermfg=White
highlight LspCxxHlSymStructMethod ctermfg=White
" highlight LspCxxHlSymFunction ctermfg=White

"
" autocmd BufWritePost * GitGutter

let g:unstack_mapkey=''
let g:unstack_layout="portrait"

let test#strategy = "vimux"
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
let g:tslime_autoset_pane = 0



map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"

let neovide_remember_window_size = v:true
"let g:vista_sidebar_keepalt
let g:vista_sidebar_width = 40
let g:BASH_Ctrl_j = 'off'
let g:C_Ctrl_j = 'off'
let g:benson_lsp_status = 0
"let g:signify_sign_show_count = 0
" call wilder#setup({
"       \ 'modes': [':'],
"       \ 'next_key': '<Tab>',
"       \ 'previous_key': '<S-Tab>',
"       \ 'accept_key': '<Down>',
"       \ 'reject_key': '<Up>',
"       \ })
" call wilder#set_option('pipeline', [
"       \   wilder#branch(
"       \     wilder#cmdline_pipeline({
"       \       'language': 'python',
"       \       'fuzzy': 1,
"       \     }),
"       \     wilder#python_search_pipeline({
"       \       'pattern': wilder#python_fuzzy_pattern(),
"       \       'sorter': wilder#python_difflib_sorter(),
"       \       'engine': 're',
"       \     }),
"       \   ),
"       \ ])
" let g:python3_host_prog = '/usr/bin/python3'
let g:foldsearch_disable_mappings = 1
" let g:raku_unicode_abbrevs = 1
nnoremap f f
nnoremap F F
nnoremap t t
nnoremap T T
" ************** MY PLUGIN STUFF **************%%%1
"let g:filter_jump_strip_characters = ["_"]
"highlight! link SearchCurrent Red
"highlight! link SearchHighlights Green
" nmap s <Plug>(FilterJump)
"nmap f <Plug>(FilterJumpLineForward)
"nmap F <Plug>(FilterJumpLineBackward)
let g:filter_jump_keymaps = {
    \ "<C-n>" : "FilterJumpNextMatch",
    \ "<C-p>" : "FilterJumpPrevMatch",
    \ "<CR>" : "FilterJumpSelect",
    \ "<C-f>" : "FilterJumpSelect",
    \ "<C-c>" : "FilterJumpExit"}
" TODO: change plugin to accept setup + teardown lambdas instead,
" as CocDisable applies for the whole vim session, not just current buffer
let g:filter_jump_buffer_options = []

autocmd FileType FilterJump lua requires('cmp').setup.buffer{enabled = false}
let test#custom_runners = {'cpp': ['catch2']}
" ************** Learning **************%%%1
" let g:value = 0
" function ToggleValue()
"     if g:value % 2 == 0
"         let g:value = g:value +1
"         return "ieven"
"     else
"         let g:value = g:value +1
"         return "iodd"
"     endif
" endf
" inoremap <expr> <leader><leader>r ToggleValue()
" nnoremap <expr> <leader><leader>r ToggleValue()
" nnoremap <unique> <leader>rt :TestifyFile<CR> "vim-test already
" covers this
" VIM LOGGER
" call lh#log#set_logger('qf')
" lh#log#this()
let g:test#again=0
let g:test#runner_commands = ['Catch2']
function! TestOpenLog()
    execute "vs"
    call feedkeys("/BENSON_DEBUG\n")
endfunction
function! JumpToFile()
    let cword = expand("<cWORD>")
    echom cword
    let fileline = trim(cword,":")
    let array = split(fileline,':')
    if len(array) > 1
        " echom "file and line"
        let filename = array[0]
        let linenumber=array[1]
        FloatermHide
        let s = "edit +" . linenumber . " " . filename
        " echom s
        execute s
    else
        " echom "just file"
        let filename = array[0]
        FloatermHide
        let s = "edit " .. filename
        " echom s
        execute s
    endif
endfunction
nnoremap gl :call JumpToFile()<CR>
nnoremap <leader>pp :echo expand('%:p')<CR>
nnoremap <leader>pd :echo getcwd()<CR>
