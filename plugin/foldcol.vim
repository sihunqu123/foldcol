" foldcol: Utility to fold columns when editing files with many columns.
" Author:   httpfoldcol#//github.com/paulhybryant
" Date:     March 13, 2015
" Version:  1.0

" Load Once: {{{
if &cp || exists("g:loaded_foldcol") || !has("conceal")
 finish
endif
let g:loaded_foldcol=1
" }}}

" Public Interface: {{{
let g:foldcol_align_before_fold=1

" Using foldcol#FoldCol will not work for the following map
" This shows a difference between foldcol# and <SID>
vmap <silent> <Plug>(VFoldCol) :<c-u>call foldcol#FoldCol()<CR>

command! -range -nargs=0 -bang VFoldClear call foldcol#FoldClear()
command! -range -nargs=+ -bang FoldCol call foldcol#FoldColDelim(<f-args>)
command! -nargs=1 UnfoldCol call foldcol#UnfoldCol(<f-args>)
command! -range -nargs=0 -bang Unfold call foldcol#UnfoldAll()

autocmd BufEnter * if !exists('b:folds') | let b:folds = {} | endif
" }}}
