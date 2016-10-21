" File: autoload/git_switcher/session_component/prev_branch_file.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#session_component#prev_branch_file#new(key) abort
  let obj = git_switcher#session_component#file_base#new(a:key)
  let obj._self = 'prev_branch_file'

  fun! obj.ext() abort
    return '.branch.prev.'.substitute(system('echo $PPID'), '\n$', '', '').'.vim'
  endf

  fun! obj.escaped_glob_ext() abort
    return '\.branch\.prev\.'.substitute(system('echo $PPID'), '\n$', '', '').'\.vim'
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
