" File: autoload/git_switcher/state.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#state#new() abort
  let l:obj = {'_self': 'state'}

  fun! l:obj.delete_all_buffers() abort
    for l:buf_num in range(1, bufnr('$'))
      if !bufexists(l:buf_num)
        continue
      endif

      try
        exec 'silent bdelete!' l:buf_num
      catch
      endtry
    endfor
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
