" foldcol: Fold Column function
" Author:   Charles E. Campbell
" Date:     Nov 17, 2013
" Version:  3g  ASTRO-ONLY
" Usage:
"   Using visual-block mode, select a block (use ctrl-v).  Press \vfc
"   This operation will fold the selected block away.
"   Using normal mode, press \vfc.  This operation will remove all
"   FoldCol-generated inline-folds.
"
"   Note: this plugin requires Vince Negri's conceal-ownsyntax patch
"         See http://groups.google.com/group/vim_dev/web/vim-patches, Patch#14
"
"   "But if any of you lacks wisdom, let him ask of God, who gives to
"   all liberally and without reproach; and it will be given to him."
"   (James 1:5)
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
" GetLatestVimScripts: 1161 1 :AutoInstall: foldcol.vim

" ------------------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_foldcol") || !has("conceal")
 finish
endif
let g:loaded_foldcol= "v3g"

" ------------------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto("<Plug>VFoldCol","v")
 vmap <unique> <Leader>vfc <Plug>VFoldCol
endif
vmap <silent> <Plug>VFoldCol    :<c-u>call <SID>FoldCol(1)<cr>

if !hasmapto("<Plug>NFoldCol","n")
 nmap <unique> <Leader>vfc <Plug>NFoldCol
endif
nmap <silent> <Plug>NFoldCol    :call <SID>FoldCol(0)<cr>

command! -range -nargs=0 -bang VFoldCol call s:FoldCol(<bang>1)
silent! command -range -nargs=0 -bang FC call s:FoldCol(<bang>1)

command! -range -nargs=+ -bang FoldCol call s:FoldColDelim(<f-args>)
command! -nargs=1 UnfoldCol call s:UnfoldCol(<f-args>)
silent! command -range -nargs=0 -bang FCA call s:UnfoldAll()

autocmd BufEnter * if !exists('b:folds') | let b:folds = {} | endif

" ------------------------------------------------------------------------------
"  FoldCol: use visual block mode (ctrl-v) to select a block to fold {{{1
function! s:FoldCol(dofold)
"  call Dfunc("FoldCol(dofold=".a:dofold.")")
"  call Decho("firstline#".a:firstline." lastline#".a:lastline." <".line("'<")." >".line("'>"))

  if a:dofold
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

   " call Decho('syn region FoldCol start="\%>'.line_ul.'l\%>'.col_ul.'v" end="\%>'.line_lr.'l\|\%>'.col_lr.'v" conceal')
   " With containedin=ALL, every concealed char will be replaced by cchar
   " without that, the concealed text matched by the syntax will be replaced
   " by a single cchar
   " exe 'syn region FoldCol start="\%>'.line_ul.'l\%>'.col_ul.'v" end="\%>'.line_lr.'l\|\%>'.col_lr.'v" conceal containedin=ALL cchar=*'
   exe 'syn region FoldCol start="\%>'.line_ul.'l\%>'.col_ul.'v" end="\%>'.line_lr.'l\|\%>'.col_lr.'v" conceal cchar=*'
   setlocal concealcursor=nci
  else
   " remove all folded columns
   syn clear FoldCol
  endif
  " call Dret("FoldCol")
endfun

let g:foldcol_align_before_fold=1

function! s:CreateFoldName(col)
  return "FoldCol" . a:col
endfunction

" TODO:
"   Write tests for it
"   See why multi folding not working completely

" ------------------------------------------------------------------------------
"  FoldColDelim: Fold column 'col' with delimiter 'delim', default ',' {{{1
function! s:FoldColDelim(col, ...)
  " Extra Argument1: delim
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
  if exists(':Align') && g:foldcol_align_before_fold == 1
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
  let l:foldname=s:CreateFoldName(a:col)
  try
    execute "syn clear ".l:foldname
  catch /E28/
  endtry
  if l:col_r < 0
    if l:col_l == 0
      echoerr "Incorrect delimiter: " . l:delim
      return
    endif
    exe 'syn region '.l:foldname.' start="\%>'.l:col_l.'v" end="$" conceal cchar=*'
  else
    exe 'syn region '.l:foldname.' start="\%>'.l:col_l.'v" end="\%>'.l:col_r.'v" conceal cchar=*'
  endif
  let b:folds[l:foldname] = 1
  setlocal concealcursor=nci
endfunction

" ------------------------------------------------------------------------------
"  UnfoldCol: Remove fold created for column 'col' {{{1
function! s:UnfoldCol(col)
  let l:foldname=s:CreateFoldName(a:col)
  if has_key(b:folds, l:foldname)
    execute "silent! syn clear ".l:foldname
    unlet b:folds[l:foldname]
  endif
endfunction

" ------------------------------------------------------------------------------
"  UnfoldAll: Remove all folds created in the buffer {{{1
function! s:UnfoldAll()
  for [key, val] in items(b:folds)
    execute "syn clear ".key
    unlet b:folds[key]
  endfor
endfunction

" ---------------------------------------------------------------------
" vim: ts=4 fdm=marker
