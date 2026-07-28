
if exists("b:did_jaiftplugin")
    finish
endif
let b:did_jaiftplugin = 1


" I haven't found a way to make these colors less hard-coded for now.
highlight jaiScopeFileNr   guifg=#7f5f6f ctermfg=174
highlight jaiScopeModuleNr guifg=#597f6f ctermfg=110
highlight jaiScopeExportNr guifg=#595f7f ctermfg=110
" highlight! link jaiScopeFileNr   DiffDelete
" highlight! link jaiScopeModuleNr Question
" highlight! link jaiScopeExportNr LineNr

" highlight! link jaiScopeFileNr   SpellLocal
" highlight! link jaiScopeModuleNr SpellCap
" highlight! link jaiScopeExportNr SpellBad

let s:sign_scope_file   = 'sign_jaiScopeFile'
let s:sign_scope_module = 'sign_jaiScopeModule'
let s:sign_scope_export = 'sign_jaiScopeExport'

call sign_define(s:sign_scope_file,   {'numhl': 'jaiScopeFileNr'})
call sign_define(s:sign_scope_module, {'numhl': 'jaiScopeModuleNr'})
call sign_define(s:sign_scope_export, {'numhl': 'jaiScopeExportNr'})

function! s:JaiRefreshScopeSigns() abort
    sign unplace * group=jai_scope

    let l:current_scope = s:sign_scope_export
    for l:lnum in range(1, line('$'))
        let l:text = getline(l:lnum)
        if l:text =~# '#scope_file\>'
            let l:current_scope = s:sign_scope_file
        elseif l:text =~# '^#scope_module\>'
            let l:current_scope = s:sign_scope_module
        elseif l:text =~# '^#scope_export\>'
            let l:current_scope = s:sign_scope_export
        endif

        if !empty(l:current_scope)
            call sign_place(0, 'jai_scope', l:current_scope, bufnr('%'), {'lnum': l:lnum})
        endif
    endfor
endfunction


setlocal signcolumn=no
augroup JaiScopeSigns
    autocmd! *
    autocmd BufEnter,TextChanged,TextChangedI,BufWritePost *.jai call s:JaiRefreshScopeSigns()
augroup END


call s:JaiRefreshScopeSigns()
