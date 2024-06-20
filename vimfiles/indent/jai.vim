" todo
"
"   if is_hovered {
"       button_color = CYAN;
"   
"       if input.mouse_l == .PRESSED
"           button_color.xyz *= 0.5;
"   }
"
"

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent
setlocal nolisp
setlocal autoindent

setlocal indentexpr=GetJaiIndent(v:lnum)
setlocal indentkeys+=;

if exists("*GetJaiIndent")
  finish
endif

let s:jai_indent_defaults = {
      \ 'default': function('shiftwidth'),
      \ 'case_labels': function('shiftwidth') }

function! s:indent_value(option)
    let Value = exists('b:jai_indent_options')
                \ && has_key(b:jai_indent_options, a:option) ?
                \ b:jai_indent_options[a:option] :
                \ s:jai_indent_defaults[a:option]

    if type(Value) == type(function('type'))
        return Value()
    endif
    return Value
endfunction

function! GetJaiIndent(lnum)
    let prev     = prevnonblank(a:lnum-1)
    let prevprev = prevnonblank(prev-1)

    if prev == 0
        return 0
    endif

    let prevprevline = ""
    if prevprev != 0
        let prevprevline = getline(prevprev)
    endif
    echo prevprevline

    let prevline = getline(prev)
    let line = getline(a:lnum)

    let ind = indent(prev)

    let prevline_contains_bracket = 0
    if prevline =~ '[({]\s*$'
        let prevline_contains_bracket = 1

        let ind += s:indent_value('default')
        if line =~ 'case\s*\S*;'
            let ind += s:indent_value('case_labels')
        endif
    elseif prevline =~ 'case\s*\S*;'
        let ind += s:indent_value('default')
    endif

    if line =~ '^\s*[)}]'
        let ind -= s:indent_value('default')

        " Find corresponding opening line and check if it’s an if/case
        call cursor(a:lnum, col('.') - 1)
        let opening_linenum = searchpair('{', '', '}', 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
        echom "Opened at" opening_linenum
        if opening_linenum > 0 
            let opening_line = getline(opening_linenum)
            echom opening_line
            if opening_line =~ '==\s*{\s*'
                echom "Matched!"
                " Seems like this was an if/case, so put indentation back at
                " the same level as before opening, no matter how we indented the case statements.
                let ind = indent(opening_linenum)
                echom "Indenting at" ind
            endif 
        endif
    elseif line =~ 'case\s*\S*;'
        let ind -= s:indent_value('default')
    endif

    if (prevline =~'\<if\>' || prevline =~'\<else\>') && prevline_contains_bracket != 1 && prevline !~ ';'
        " if the previous line contains an 'if', then we indent this line
        let ind += s:indent_value('default')
    elseif prevprev > 0
        if (indent(prev) > indent(prevprev)) && !prevline_contains_bracket && prevprevline !~ '[({]\s*$'
            let ind = indent(prevprev)
        endif
    endif

    return ind
endfunction


"function! GetJaiIndent(lnum)
"    let prev     = prevnonblank(a:lnum-1)
"    let prevprev = prevnonblank(prev-1)
"
"    if prev == 0
"        return 0
"    endif
"
"    let prevprevline = ""
"    if prevprev != 0
"        let prevprevline = getline(prevprev)
"    endif
"    echo prevprevline
"
"    let prevline = getline(prev)
"    let line = getline(a:lnum)
"
"    let ind = indent(prev)
"
"    let prevline_contains_bracket = 0
"    if prevline =~ '[({]\s*$' " if prevline ends with an open bracket/parenthesis
"        let prevline_contains_bracket = 1
"
"        let ind += s:indent_value('default')
"        if line =~ 'case\s*\S*;'
"            let ind += s:indent_value('case_labels')
"        endif
"    elseif prevline =~ '[({]' " if there is an open bracket/parenthesis in the middle of prevline
"        let [op_line, op_col] = searchpairpos('[{(]', '', '[})]', 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
"        if op_line == prev
"            let ind = op_col
"        endif
"    elseif prevline =~ '[)}]'
"        " go to previous line to start searching from it
"        exe 'normal ' . prev . 'G'
"        let [op_line, op_col] = searchpairpos('[{(]', '', '[})]', 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
"        "let [op_line, op_col] = searchpairpos('[{(]', '', '[})]', 'W', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
"        echo "Opline: " . op_line . ';   line: ' . line(".")
"        let ind = indent(op_line)
"    elseif prevline =~ 'case\s*\S*;'
"        let ind += s:indent_value('default')
"    endif
"
"    if line =~ '^\s*[)}]' " if line starts with a closing bracket/parenthesis
"        let ind -= s:indent_value('default')
"
"        " Find corresponding opening line and check if it’s an if/case
"        call cursor(a:lnum, col('.') - 1)
"        let opening_linenum = searchpair('{', '', '}', 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"')
"        echom "Opened at" opening_linenum
"        if opening_linenum > 0 
"            let opening_line = getline(opening_linenum)
"            echom opening_line
"            if opening_line =~ '==\s*{\s*'
"                echom "Matched!"
"                " Seems like this was an if/case, so put indentation back at
"                " the same level as before opening, no matter how we indented the case statements.
"                let ind = indent(opening_linenum)
"                echom "Indenting at" ind
"            endif 
"        endif
"    elseif line =~ 'case\s*\S*;'
"        let ind -= s:indent_value('default')
"    endif
"
"    if (prevline =~'\<if\>' || prevline =~'\<else\>') && prevline_contains_bracket != 1 && prevline !~ ';'
"        " if the previous line contains an 'if', then we indent this line
"        let ind += s:indent_value('default')
"    elseif prevprev > 0
"        if (indent(prev) > indent(prevprev)) && !prevline_contains_bracket && prevprevline !~ '[({]\s*$'
"            let ind = indent(prevprev)
"        endif
"    endif
"
"    return ind
"endfunction

