" Copyright 2015 Yu Huang. All rights reserved.
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

let s:plugin = maktaba#plugin#Get('foldcol')

""
" @public
" Use visual block mode to select a block to fold.
function! foldcol#FoldCol() " {{{
  " make a new fold
  if &cole == 0
    let &cole= 1
  endif

  " upper left corner
  let line_ul = line("'<") - 1
  let col_ul  = virtcol("'<")  - 1

  " lower right corner
  let line_lr = line("'>")
  let col_lr  = virtcol("'>")
  if &selection ==# 'exclusive'
    " need to subtract the display width of the character at the end of the selection
    if exists('*strdisplaywidth')
        let col_lr -= strdisplaywidth(matchstr(getline(line_lr), '\%' . col("'>") . 'c.'), strdisplaywidth(strpart(getline(line_lr), 0, col("'>") - 1)))
    else
        let col_lr -= 1
    endif
  endif

  " With containedin=ALL, every concealed char will be replaced by cchar
  " without that, the concealed text matched by the syntax will be replaced
  " by a single cchar
  " exe 'syn region FoldCol start="\%>'.line_ul.'l\%>'.col_ul.'v" end="\%>'.line_lr.'l\|\%>'.col_lr.'v" conceal containedin=ALL cchar=*'
  exe 'syn region FoldCol start="\%>'.line_ul.'l\%>'.col_ul.'v" end="\%>'.line_lr.'l\|\%>'.col_lr.'v" conceal cchar=*'
  setlocal concealcursor=nci
endfun
" }}}

""
" @public
" Clear fold created in visual mode.
function! foldcol#FoldClear() " {{{
  syn clear FoldCol
endfunction
" }}}

""
" @private
" Create fold name for column {col}.
function! foldcol#CreateFoldName(col) " {{{
  return "FoldCol" . a:col
endfunction
" }}}

""
" @public
" Fold column {col} with delimiter [delim]. Align the text before folding the
" columns if @flag(align) is set.
function! foldcol#FoldColDelim(col, ...) " {{{
  if a:0 > 0
    let l:delim = a:1
  else
    let l:delim = ","
  endif
  if strlen(l:delim) != 1
    echoerr "Delimiter must be single character."
    return
  endif

  if &cole == 0
    setlocal conceallevel=1
  endif
  " Try align the text first.
  if exists(':Align') && s:plugin.Flag('align') == 1
    exec "Align " . l:delim
  endif
  " Find the left and right of the columns based on delimiter and column
  " number.
  let l:line = getline(1)
  let l:num_col = a:col
  let l:col_l = 0
  let l:col_r = 0
  while(l:num_col > 0 && l:col_r >= 0)
    let l:col_l = l:col_r
    let l:col_r = stridx(l:line, l:delim, l:col_l + 1)
    let l:num_col -= 1
  endwhile
  if l:num_col > 0
    echoerr "Invalid column number ".a:col." with delimiter ".l:delim
    return
  endif
  " Match to conceal.
  if l:col_l > 0
    let l:col_l += 1
  endif
  let l:foldname=foldcol#CreateFoldName(a:col)
  try
    execute "syn clear ".l:foldname
  catch /E28/
  endtry
  if l:col_r < 0
    if l:col_l == 0
      echoerr "Incorrect delimiter: " . l:delim
      return
    endif
    " exe 'syn region '.l:foldname.' start="\%>'.l:col_l.'v" end="$" conceal cchar=*'
    let l:col_l += 1
    exe 'syn match '.l:foldname.' "\%'.l:col_l.'c.*$" conceal cchar=*'
  else
    " exe 'syn region '.l:foldname.' start="\%>'.l:col_l.'v" end="\%>'.l:col_r.'v" conceal cchar=*'
    let l:col_l += 1
    exe 'syn match '.l:foldname.' "\%'.l:col_l.'c'.repeat(".", l:col_r - l:col_l + 1).'" conceal cchar=*'
  endif
  let b:folds[l:foldname] = 1
  setlocal concealcursor=nci
endfunction
" }}}

""
" @public
" Remove fold created for column {col}.
function! foldcol#UnfoldCol(col) " {{{
  let l:foldname=foldcol#CreateFoldName(a:col)
  if has_key(b:folds, l:foldname)
    execute "silent! syn clear ".l:foldname
    unlet b:folds[l:foldname]
  endif
endfunction
" }}}

""
" @public
" Remove all folds created in the buffer.
function! foldcol#UnfoldAll() " {{{
  for [key, val] in items(b:folds)
    execute "syn clear ".key
    unlet b:folds[key]
  endfor
endfunction
" }}}

" vim: set sw=2 ts=2 sts=2 et tw=78 foldlevel=0 foldmethod=marker filetype=vim nospell:
