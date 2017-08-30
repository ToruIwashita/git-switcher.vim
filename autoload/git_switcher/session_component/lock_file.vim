" File: autoload/git_switcher/session_component/lock_file.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#session_component#lock_file#new(key) abort
  let l:obj = git_switcher#session_component#file_base#new(a:key)
  let l:obj._self = 'lock_file'

  " private

  fun! l:obj._glob_ext() abort
    return '.session.lock*'
  endf

  " private END

  fun! l:obj.ext() abort
    return '.session.lock.'.substitute(system('echo $PPID'), '\n$', '', '').'.vim'
  endf

  fun! l:obj.glob_name() abort
    return l:self.basename().l:self._glob_ext()
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
