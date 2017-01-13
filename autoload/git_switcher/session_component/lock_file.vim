" File: autoload/git_switcher/session_component/lock_file.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#session_component#lock_file#new(key) abort
  let obj = git_switcher#session_component#file_base#new(a:key)
  let obj._self = 'lock_file'

  fun! obj.ext() abort
    return '.session.lock.'.substitute(system('echo $PPID'), '\n$', '', '').'.vim'
  endf

  fun! obj.glob_name() abort
    return self.basename().self.glob_ext()
  endf

  fun! obj.glob_ext() abort
    return '.session.lock*'
  endf

  fun! obj.escaped_glob_ext() abort
    return '\.session\.lock\..*\.vim'
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
