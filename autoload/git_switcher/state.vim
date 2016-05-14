" File: autoload/git_switcher/state.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#state#new() abort
  let obj = {'_self': 'state'}

  fun! obj.delete_all_buffers() abort
    for buf_num in filter(range(1, bufnr('$')), 'buflisted(v:val)')
      exec 'silent bdelete' buf_num
    endfor
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
