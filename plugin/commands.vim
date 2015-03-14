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

let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter || !has("conceal")
  finish
endif

""
" @command VFoldCol
" Fold the selected columns in visual mode.
command! -range -nargs=0 -bang VFoldCol call foldcol#FoldCol()

""
" @command VFoldClear
" Remove all folds created in visual mode.
command! -range -nargs=0 -bang VFoldClear call foldcol#FoldClear()

""
" @command FoldCol
" @usage {col_num} [delim]
" @default delim=','
" Fold column {col_num} separated by delimiter [delim].
command! -range -nargs=+ -bang FoldCol call foldcol#FoldColDelim(<f-args>)

""
" @command UnfoldCol
" @usage {col_num}
" Unfold column {col_num}.
command! -nargs=1 UnfoldCol call foldcol#UnfoldCol(<f-args>)

""
" @command UnfoldAll
" Unfold all folded columns.
command! -range -nargs=0 -bang UnfoldAll call foldcol#UnfoldAll()
