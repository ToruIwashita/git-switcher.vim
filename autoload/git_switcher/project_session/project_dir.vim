" File: autoload/git_switcher/project_session/project_dir.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#project_dir#new(key) abort
  let obj = {'_self': 'project_dir'}

  " initialize

  fun! obj.initialize(key) abort
    let self._root_dir = g:gsw_sessions_dir
    let self._key = a:key
  endf

  call call(obj.initialize, [a:key], obj)

  " initialize END

  fun! obj.name() abort
    return self._key
  endf

  fun! obj.root_dir_path() abort
    return self._root_dir.'/'
  endf

  fun! obj.path() abort
    return self.root_dir_path().self.name().'/'
  endf

  fun! obj.exists() abort
    return isdirectory(self.path())
  endf

  fun! obj.create() abort
    if !self.exists()
      call mkdir(self.path(), 'p')
    endif
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
