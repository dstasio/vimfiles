

if exists("b:defined_common_syntax_functions")
    finish
endif

let b:defined_common_syntax_functions = 1

" From https://vim.fandom.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
function! dst#define_syntax_region(filetype,start,end,textSnipHl = 'SpecialComment') abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'

  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ keepend
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction

if has('nvim')
    finish
endif



" ======================================================================================
" Inline color previews for hex and vec3/vec4.
"
def s:add_inline_color_bullet(row: number, column: number, hex_color_string: string)
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
def dst#preview_colors(startline = -1, endline = -1, reset_previous_previews = v:true)
    const enabled_types = ['glsl', 'hlsl', 'jai']
    var filetype = &ft
    if index(enabled_types, filetype) < 0
        return
    endif

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

            s:add_inline_color_bullet(row, starts + 1, hex)

            cnt += 1
            [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
        endwhile

        cnt = 1
        const glsl_vec_color_regexpr = 'vec[34](\(\s*\d\+\.\?\d*f\?\s*[,)]\)\{3,4\}'
        # const      jai_color_regexpr = 'Vector[34]\.{\(\s*\d\+\.\?\d*f\?\s*[,)]\)\{3,4\}'
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
                    s:add_inline_color_bullet(row, v_starts + 1, hex_color)
                endif
            endif

            cnt += 1
            [vec, v_starts, v_ends] = matchstrpos(current, glsl_vec_color_regexpr, 0, cnt)
        endwhile
    endfor
enddef

def dst#rescan_last_edited_lines()
    var edit_start = getpos("'[")[1]
    var edit_end   = getpos("']")[1]

    dst#preview_colors(edit_start, edit_end)
enddef

def dst#rescan_current_line()
    var current_line = line('.')

    dst#preview_colors(current_line, current_line, v:false)
enddef


def dst#align_lines(token: string)
    # This function uses the following convention:
    # - prefix: the portion of the line until just before the alignment token
    # - suffix: the portion of the line that starts right after the alignment token
    const trim_start = 1
    const trim_end   = 2

    const selection_start = getpos("'<")[1]
    const selection_end   = getpos("'>")[1]

    const IDX_PREFIX_LENGTH = 0
    const IDX_TOKEN_POS     = 1

    var max_prefix_length = -1
    var lines_data        = []
    for line_number in range(selection_start, selection_end)
        const in_line = getline(line_number)
        lines_data += [[-1, -1]]
        
        const match_index = match(in_line, token)
        if match_index >= 0
            const line_until_token = trim(in_line[ : match_index - strlen(token)], "", trim_end)

            lines_data[-1][IDX_TOKEN_POS] = match_index

            const current_prefix_length = strlen(line_until_token)
            lines_data[-1][IDX_PREFIX_LENGTH] = current_prefix_length

            if current_prefix_length > max_prefix_length
                max_prefix_length = current_prefix_length
            endif
        endif
    endfor

    for line_number in range(selection_start, selection_end)
        const line_data = lines_data[line_number - selection_start]

        if line_data[IDX_PREFIX_LENGTH] < 0
            continue
        endif

        const in_line = getline(line_number)
        const prefix  = in_line[ : line_data[IDX_PREFIX_LENGTH]]
        const suffix  = trim(in_line[line_data[IDX_TOKEN_POS] + strlen(token) : ], "", trim_start)

        const spaces_before_token = max_prefix_length - strlen(prefix) + 1
        const out_line            = prefix .. repeat(" ", spaces_before_token) .. token .. " " .. suffix
        setline(line_number, out_line)
    endfor
enddef


defcompile
