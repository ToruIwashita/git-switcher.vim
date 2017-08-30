" File: autoload/git_switcher/session_component/project_dir.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#session_component#project_dir#new(key) abort
  let l:obj = {'_self': 'project_dir'}

  " initialize

  fun! l:obj.initialize(key) abort
    let l:self._root_dir = g:gsw_sessions_dir
    let l:self._key = a:key
  endf

  call call(l:obj.initialize, [a:key], l:obj)

  " initialize END

  " private

  fun! l:obj._root_dir_path() abort
    return l:self._root_dir.'/'
  endf

  fun! l:obj._exists() abort
    return isdirectory(l:self.path())
  endf

  " private END

  fun! l:obj.name() abort
    return l:self._key
  endf

  fun! l:obj.path() abort
    return l:self._root_dir_path().l:self.name().'/'
  endf

  fun! l:obj.create() abort
    if !l:self._exists()
      call mkdir(l:self.path(), 'p')
    endif
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
