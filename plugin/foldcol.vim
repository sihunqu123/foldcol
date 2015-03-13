" foldcol:
" Load Once: {{{
if &cp || exists("g:loaded_foldcol") || !has("conceal")
 finish
endif
let g:loaded_foldcol=1
" }}}

" Public Interface: {{{

""
" @setting foldcol_align_before_fold
" @default foldcol_align_before_fold=1
" Whether to align the text before folding the columns.
let g:foldcol_align_before_fold=1

" Using foldcol#FoldCol will not work for the following map
" This shows a difference between foldcol# and <SID>

vmap <silent> <Plug>(VFoldCol) :<c-u>call foldcol#FoldCol()<CR>

""
" @command VFoldClear
" Remove all folds created in visual mode.
command! -range -nargs=0 -bang VFoldClear call foldcol#FoldClear()

""
" @command FoldCol
" @usage {col_num} [delim]
" @default delim=','
" Fold column 'col_num' separated by delimiter 'delim'.
command! -range -nargs=+ -bang FoldCol call foldcol#FoldColDelim(<f-args>)

""
" @command UnfoldCol
" @usage {col_num}
" Unfold column 'col_num'.
command! -nargs=1 UnfoldCol call foldcol#UnfoldCol(<f-args>)

""
" @command UnfoldAll
" Unfold all folded columns.
command! -range -nargs=0 -bang UnfoldAll call foldcol#UnfoldAll()

autocmd BufEnter * if !exists('b:folds') | let b:folds = {} | endif
" }}}
