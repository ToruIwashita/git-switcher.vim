" File: autoload/git_switcher/project_session/session_file.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#session_file#new(key) abort
  let obj = {'_self': 'session_file'}

  " initialize

  fun! obj.initialize(key) abort
    let self._key = a:key
  endf

  call call(obj.initialize, [a:key], obj)

  " initialize END

  fun! obj.basename() abort
    return self._key
  endf

  fun! obj.name() abort
    return self.basename().self.ext()
  endf

  fun! obj.ext() abort
    return '.session.vim'
  endf

  fun! obj.escaped_ext() abort
    return '\.session\.vim' 
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
