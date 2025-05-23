" IMPORTANT: on windows, check the global utf-8 setting in region settings for
" correct utf-8 quickfix visualization
"
" TODO: syntax highlighting for NOTEs, TODOs and IMPORTANTs
" TODO: syntax highlighting for WARNING in quickfix
" TODO: reorder .vimrc
" TODO: maybe implement file backup
" TODO: look at conceal characters
" TODO: ctrl-x to switch to last unrelated file (different than what you'd get with ctrl-c)
" TODO: look at vim compiler feature (:h compiler)
" TODO: ignorecase
" TODO: maximize buffer shortcut
"
" NOTE: https://github.com/itchyny/lightline.vim
syntax on
if has("gui_running")
    let g:sonokai_style = 'light'
    let g:sonokai_better_performance = 0
    colorscheme sonokai
endif

set number
set wrap!
set textwidth=0
set relativenumber
set wildmode=list:full
set wildmenu
set errorformat+=%f(%l\\,%c):\ %t%*\\D%n:\ %m        " msdev linker errors
set errorformat+=%o\ :\ %t%*\\D%n:\ %m               " msdev linker errors
set errorformat+=%f(%l)\ :\ %t%*\\D%n:\ %m           " msdev 'the following warning is treated as an error' & warnings
set errorformat+=%f(%l\\,%c-%*\\d):\ %t%*\\D%n:\ %m  " hlsl compiler errors
set errorformat+=%f(%l:%c)\ %m                       " odin compiler errors
set incsearch
set enc=utf-8
set sidescrolloff=3
set sidescroll=1
let mapleader=" "
"expandtab?

noremap <silent> <C-N> <C-D>
noremap <silent> <C-M> <C-U>
noremap <silent> <C-J> <C-E>
noremap <silent> <C-K> <C-Y>
noremap <C-H> 7zh
noremap <C-L> 7zl
nnoremap <A-b> :b#<CR>
vnoremap p "_dP
vnoremap <F5> :<BS><BS><BS><BS><BS>Align 
nnoremap <silent> <C-T> :tabe<CR>

nnoremap <silent> <A-Space> :set hlsearch! <Bar>:echo<CR>

" Highlighting 70th column
"if (exists('+colorcolumn'))
"    set colorcolumn=70
"    highlight ColorColumn ctermbg=9
"endif

" Setting fonts for gvim (others will be added)
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=DM_Mono:h14:cANSI:qDRAFT,Consolas:h11:cANSI
    "set guifont=Natural_Mono_Alt:h11:cANSI:qDRAFT

    set guioptions+=P "on windows, 'a' option could be used. It only makes a difference on linux
    set guioptions-=m
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
  endif
endif

if !has('nvim') && has("gui_running")
    def! Split_once()
        simalt ~x
        if !exists("s:IsSplit")
            vsplit
            s:IsSplit = 1
        endif
        winc =
    enddef
    
    " Split window on open (splits twice in gvim)
    au GUIEnter * call Split_once()

    "
    " Inline Color Previews
    " @todo: These should not be active in all file types
    au BufNewFile,BufRead *.glsl call dst#preview_colors()
    au BufNewFile,BufRead *.vim call dst#preview_colors()
    au TextChanged,TextChangedP * call dst#rescan_last_edited_lines()
    au TextChangedI * call dst#rescan_current_line()
endif

au VimResized * winc =
au BufNewFile,BufRead *.hlsl set syntax=hlsl
au BufNewFile,BufRead *.toml set filetype=rust
au BufNewFile,BufRead *.rs   set filetype=rust
au BufNewFile,BufRead *.odin set filetype=odin
au BufNewFile,BufRead *.csv  set filetype=csv
au BufNewFile,BufRead *.odin source ~/vimfiles/indent/odin.vim
" au BufNewFile,BufRead *.jai  set filetype=jai
au BufNewFile,BufRead *.jai  source ~/vimfiles/indent/jai.vim
au BufNewFile,BufRead *.glsl set filetype=glsl
au BufNewFile,BufRead *.vert set filetype=glsl
au BufNewFile,BufRead *.frag set filetype=glsl

nnoremap <silent> <A-w> :set wrap!<CR>
nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>
let g:FocusToggle = 0
nnoremap <silent> <Leader><Space> :if (g:FocusToggle == 0) \| :vertical res \| let g:FocusToggle=1 \| else \|winc =  \| let g:FocusToggle=0 \| endif<Bar>:echo<CR>

" NOTE: I don't know why this works, but adding a "^M"(ctrl-v ctrl-m in insert mode) makes this work as a toggle.
nnoremap <silent> <A-f> :simalt ~r<CR>:simalt ~x<CR>

function! HighlightCurrentColumn()
    let l:current_column = virtcol('.')
    echo l:current_column
    exe 'set colorcolumn+=' . l:current_column
endfunction

nnoremap <silent> <Leader>c :call HighlightCurrentColumn()<CR>
nnoremap <silent> <Leader>C :set colorcolumn=<CR>

fu! EndsWith(longer, shorter) abort
    return a:longer[len(a:longer)-len(a:shorter):] ==# a:shorter
endfunction

" TODO: syntax highlighting for compile log
" TODO: add searching for build script
" TODO: make this asyncronous
" TODO: print compilation time on success
if !exists("*Build")
function! Build()
    if match(expand("%"), "\.vimrc") > 0 || EndsWith(expand("%"), ".vim")
        silent wall
        so %
        simalt ~x
    elseif (expand("%:p:h:t") ==? "colors") && (expand("%:e") ==? "vim")
        silent wall
        let schemename = expand("%:t:r")
        exe ":colo " . schemename
    elseif (expand("%:e") ==? "jai")
        echo "No jai compilation yet..."
    else
        call setqflist([])
        silent wall
        echo "Compiling..."
        let Log = system('build')
        cgetexpr Log
        " wincmd h
        " TODO: set wrapping for quickfix buffer only
        bel cw
        echon "\r\rCompilation Finished!"
    endif
endfunction
endif

" Mapping Alt-m to run build.bat and Alt-n to go to next error
nnoremap <silent> <A-N> :cp<CR>
nnoremap <silent> <A-n> :cn<CR>
nnoremap <silent> <A-m> :call Build()<CR>
nnoremap <silent> <A-c> :call SourceToHeader(0)<CR>
nnoremap <silent> <A-C> :call SourceToHeader(1)<CR>

function! ToggleAndShowPasteMode()
    set paste!
    set paste?
endfun

nnoremap <A-p> :call ToggleAndShowPasteMode()<CR>

function! OpenScratchBuffer()
    let s:Scratchname = bufname("scratch")
    if (strlen(s:Scratchname)) > 0
        w
        exe ":buffer " . s:Scratchname
    else
        enew
        " exe \":enew" 
        file "scratch"
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
    endif
endfun

function! s:SwitchWindow()
    let OldWindow = winnr()
    wincmd l
    if winnr() == OldWindow
        wincmd h
    endif
endfun

function! OpenBufferOrFile(Filename, OtherWindow)
    let s:Bufname = bufname(a:Filename)
    if a:OtherWindow
        call s:SwitchWindow()
    endif
    if (strlen(s:Bufname)) > 0
        w
        exe ":buffer " . s:Bufname
    else
        exe ":e " . a:Filename
    endif
endfun

function! SourceToHeader(OtherWindow)
    if match(expand("%"), '\.cpp') > 0
        let l:flipname = substitute(expand("%"),'\.cpp\(.*\)','.h\1',"")
    elseif match(expand("%"), '\.h') > 0
        let l:flipname = substitute(expand("%"),'\.h\(.*\)','.cpp\1',"")
    endif

    if exists("l:flipname")
        call OpenBufferOrFile(l:flipname, a:OtherWindow)
    else
        echo "Unrecognized Source!"
    endif
endfun

" Autoindent options
set expandtab
set shiftwidth=4
set softtabstop=4
set smarttab
set autoindent
set cindent
set cinoptions=l1,g0,N-s,E-s,t0,(0,w1,Ws,m1,=0

" JAI
" set cinoptions=L0,=0,l1,(0,w1,Ws,
" set cinkeys-=0#
" set indentkeys-=0# " only used if indentexpr is set

" TODO: Maybe add color to statusline
set statusline=\ %f%m\%=\ %y\ %{&fileencoding?&fileencoding:&encoding}\[%{&fileformat}\]\ %p%%\ %l:%c\ 

filetype plugin on
set omnifunc=syntaxcomplete#Complete

function! HeaderSkeleton(filename)
    let l:HeaderMacro = toupper( substitute( substitute(a:filename, '\.h', '_H',""), '\.', '_', ""))
    call setline(1, '#if !defined(' . l:HeaderMacro . ')')
    call setline(2, '')
    call setline(3, '#define ' . l:HeaderMacro)
    call setline(4, '#endif // ' . l:HeaderMacro)
endfun

function! SourceSkeleton(filename)
    "let l:header_name = substitute(a:filename, '/\.c\(pp\)\?', '\.h',"")
    call setline(1, '// ' . a:filename)
    "call setline(2, '#include "' . l:header_name . '"')
endfun

au BufNewFile *.h   call HeaderSkeleton(expand('%:t'))
au BufNewFile *.c   call SourceSkeleton(expand('%:t'))
au BufNewFile *.cpp call SourceSkeleton(expand('%:t'))

" Typing utilities
function! InsertFor(Signed, IndexEnd, ...)
    " TODO: Maybe add '[u]int' vs '[u]int32' check
    if a:Signed
        let l:Type = 's32'
    else
        let l:Type = 'u32'
    endif
    if a:0 > 0
        let l:IndexStart = a:1
    else
        let l:IndexStart = 0
    endif
    call append(line('.') - 1, [
                \ 'for('. l:Type . ' it_index = ' . l:IndexStart . ';' .
                \ ' it_index < ' . a:IndexEnd . ';' .
                \ ' it_index += 1)',
                \ '{'
                \])
    normal k
    normal =3k
    normal j
endfun 

command! -nargs=+ Foru call InsertFor(0, <f-args>)
command! -nargs=+ For  call InsertFor(1, <f-args>)
command! -nargs=1 Align call dst#align_lines(<f-args>)

nnoremap <Leader>f  :For 
nnoremap <Leader>uf :Foru 
nnoremap <silent> <A-s> :call OpenScratchBuffer()<CR>

autocmd FileType c,cpp,java,scala,rust let b:comment_leader = '//'
autocmd FileType sh,ruby,python        let b:comment_leader = '#'
autocmd FileType conf,fstab,toml       let b:comment_leader = '#'
autocmd FileType tex                   let b:comment_leader = '%'
autocmd FileType mail                  let b:comment_leader = '>'
autocmd FileType vim                   let b:comment_leader = '"'
function! CommentToggle()  " https://stackoverflow.com/a/22246318
    execute ':silent! s/\([^ ]\)/' . escape(b:comment_leader,'\/') . '\1/'
    execute ':silent! s/^\( *\)' . escape(b:comment_leader,'\/') . ' \?' . escape(b:comment_leader,'\/') . '\?/\1/'
endfunction
map <F8> :call CommentToggle()<CR>

au BufNewFile,BufRead *.rs source $HOME/vimfiles/indent/rust.vim

function! GetSyntaxSroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun


" --------------------------------------------------------------------
" Font resize commands - from https://vim.fandom.com/wiki/Change_font_size_quickly
nnoremap <C-Up> :silent! let &guifont = substitute(
 \ &guifont,
 \ ':h\zs\d\+',
 \ '\=eval(submatch(0)+1)',
 \ 'g')<CR>
nnoremap <C-Down> :silent! let &guifont = substitute(
 \ &guifont,
 \ ':h\zs\d\+',
 \ '\=eval(submatch(0)-1)',
 \ 'g')<CR>
" End font resize commands
" --------------------------------------------------------------------

