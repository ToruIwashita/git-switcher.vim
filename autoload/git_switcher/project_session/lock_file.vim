" File: autoload/git_switcher/project_session/lock_file.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#lock_file#new(key) abort
  let obj = {'_self': 'lock_file'}

  " initialize

  fun! obj.initialize(key) abort
    let self._key = a:key
  endf

  call call(obj.initialize, [a:key], obj)

  " initialize END

  " private

  fun! obj._basename() abort
    return self._key
  endf

  " private END

  fun! obj.name() abort
    return self._basename().self.ext()
  endf

  fun! obj.glob_name() abort
    return self._basename().self.glob_ext()
  endf

  fun! obj.ext() abort
    return '.session.lock.'.substitute(system('echo $PPID'), '\n$', '', '').'.vim'
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
