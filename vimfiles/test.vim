def s:AddColorBullet(row: number, column: number, hex_color_string: string)
    var col_tag = "inline_color_" .. hex_color_string[1 : ]
    var col_type = prop_type_get(col_tag)
    if col_type == {}
        hlset([{ name: col_tag, guifg: hex_color_string}])
        prop_type_add(col_tag, {highlight: col_tag})
    endif
    prop_add(row, column, { text: "■ ",
                            type: col_tag })
enddef

" Adapted from u/wasser-frosch at https://www.reddit.com/r/vim/comments/wm08fl/simple_vim_9_virtual_text_example_for_hex_colors
def s:PreviewColors(startline = -1, endline = -1, reset_previous_previews = v:true)
    var first_line = 1
    if startline != -1
        first_line = startline
    endif

    var last_line = line('$')
    if endline != -1
        last_line = endline
    endif

    for row in range(first_line, last_line)
        var current = getline(row)
        var cnt = 1

        var line_has_been_reset = v:false
	if reset_previous_previews
            prop_clear(row)
            line_has_been_reset = v:true
	endif

        var [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
        while starts != -1
	    if line_has_been_reset == v:false
                prop_clear(row)
                line_has_been_reset = v:true
	    endif

            s:AddColorBullet(row, starts + 1, hex)

            cnt += 1
            [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
        endwhile

        cnt = 1
        const glsl_vec_color_regexpr = 'vec[34](\(\s*\d\+\.\?\d*f\?\s*[,)]\)\{3,4\}'
        var [vec, v_starts, v_ends] = matchstrpos(current, glsl_vec_color_regexpr, 0, cnt)
        while v_starts != -1
            var params_start = matchend(vec, '(')
            if params_start != -1
                var params = split(vec[params_start : ], ',')
                var rr: float = 0.0
                var gg: float = 0.0
                var bb: float = 0.0
                var valid = v:false

                var params_count = len(params)
                # @todo: if params_count == 1 # this requires changing the regexpr
                if params_count == 3
                    rr = str2float(params[0])
                    gg = str2float(params[1])
                    bb = str2float(params[2])

                    valid = rr >= 0.0 && rr <= 1.0 && gg >= 0.0 && gg <= 1.0 && bb >= 0.0 && bb <= 1.0
                endif

                if valid
	            if line_has_been_reset == v:false
                        prop_clear(row)
                        line_has_been_reset = v:true
	            endif

                    var hex_color = printf('#%02x%02x%02x', float2nr(rr * 255), float2nr(gg * 255), float2nr(bb * 255))
                    s:AddColorBullet(row, v_starts + 1, hex_color)
                endif
            endif

            cnt += 1
            [vec, v_starts, v_ends] = matchstrpos(current, glsl_vec_color_regexpr, 0, cnt)
        endwhile
    endfor
enddef

def RescanLastEditedLines()
    var edit_start = getpos("'[")[1]
    var edit_end = getpos("']")[1]

    s:PreviewColors(edit_start, edit_end)
enddef

def RescanCurrentLine()
    var current_line = line('.')

    s:PreviewColors(current_line, current_line, v:false)
enddef

au TextChanged,TextChangedP * call RescanLastEditedLines()
au TextChangedI * call RescanCurrentLine()
