" File: autoload/git_switcher/state.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#state#new() abort
  let obj = {'_self': 'state'}

  fun! obj.delete_all_buffers() abort
    for buf_num in filter(range(1, bufnr('$')), 'buflisted(v:val)')
      exec 'silent bdelete' buf_num
    endfor
  endf

  return obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
