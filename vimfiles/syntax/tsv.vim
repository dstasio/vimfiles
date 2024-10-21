" From https://github.com/mechatroner/rainbow_csv (Commit: 3dbbfd7)
"
"
" MIT License
" 
" Copyright (c) 2017 Dmitry Ignatovich
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
"


syntax match column9 /.\{-}\(	\|$\)/ nextgroup=column0
syntax match column8 /.\{-}\(	\|$\)/ nextgroup=column9
syntax match column7 /.\{-}\(	\|$\)/ nextgroup=column8
syntax match column6 /.\{-}\(	\|$\)/ nextgroup=column7
syntax match column5 /.\{-}\(	\|$\)/ nextgroup=column6
syntax match column4 /.\{-}\(	\|$\)/ nextgroup=column5
syntax match column3 /.\{-}\(	\|$\)/ nextgroup=column4
syntax match column2 /.\{-}\(	\|$\)/ nextgroup=column3
syntax match column1 /.\{-}\(	\|$\)/ nextgroup=column2
syntax match column0 /.\{-}\(	\|$\)/ nextgroup=column1
