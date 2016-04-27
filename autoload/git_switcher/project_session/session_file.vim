" File: autoload/git_switcher/project_session/session_file.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#session_file#new(key)
  let obj = {
    \ '_self': 'session_file',
    \ '_key': a:key
  \ }

  fun! obj.basename()
    return self._key
  endf

  fun! obj.name()
    return self.basename().self.ext()
  endf

  fun! obj.ext()
    return '.session.vim'
  endf

  fun! obj.escaped_ext()
    return "\\.session\\.vim"
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
