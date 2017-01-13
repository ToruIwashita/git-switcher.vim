" File: autoload/git_switcher/session_component/session_file.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#session_component#session_file#new(key) abort
  let obj = git_switcher#session_component#file_base#new(a:key)
  let obj._self = 'session_file'

  fun! obj.escaped_ext() abort
    return '\.session\.vim'
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
