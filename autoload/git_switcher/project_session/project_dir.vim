" File: project_dir.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#project_dir#new(key)
  let obj = {
    \ '_self': 'project_dir',
    \ '_root_dir': g:gsw_sessions_dir,
    \ '_key': a:key
  \ }

  fun! obj.name()
    return self._key
  endf

  fun! obj.root_dir_path()
    return self._root_dir.'/'
  endf

  fun! obj.path()
    return self.root_dir_path().self.name().'/'
  endf

  fun! obj.exists()
    return isdirectory(self.path())
  endf

  fun! obj.create()
    if !self.exists()
      return mkdir(self.path(), 'p')
    endif
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save