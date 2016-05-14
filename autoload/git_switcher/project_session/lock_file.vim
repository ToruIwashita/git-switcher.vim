" File: autoload/git_switcher/project_session/lock_file.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#lock_file#new(key) abort
  let obj = {
    \ '_self': 'lock_file',
    \ '_key': a:key
  \ }

  fun! obj.basename() abort
    return self._key
  endf

  fun! obj.name() abort
    return self.basename().self.ext()
  endf

  fun! obj.glob_name() abort
    return self.basename().self.glob_ext()
  endf

  fun! obj.ext() abort
    return '.session.lock.'.substitute(system('echo $PPID'), '\n$', '', '').'.vim'
  endf

  fun! obj.glob_ext() abort
    return '.session.lock*'
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
