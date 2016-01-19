" git-switcher
" Author:  ToruIwashita <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#state#new()
  let obj = {'name': 'state'}

  fun! obj.delete_all_buffers() abort
    for buf_num in filter(range(1, bufnr('$')), 'buflisted(v:val)')
      exec 'silent bdelete' buf_num
    endfor
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
