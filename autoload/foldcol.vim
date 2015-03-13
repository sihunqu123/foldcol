function! foldcol#TestOnlyGetSynGroup(group_name) " {{{
  let l:syngroup=""
  redir => l:syngroup
  execute "silent! syntax list " . a:group_name
  redir END
  let l:groups = split(l:syngroup, "\n")
  if len(l:groups) != 2
    return ""
  endif
  return l:groups[1]
endfunction
" }}}
