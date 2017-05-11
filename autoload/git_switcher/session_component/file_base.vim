" File: autoload/git_switcher/session_component/file_base.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#session_component#file_base#new(key) abort
  let obj = {'_self': 'file_base'}

  " initialize

  fun! obj.initialize(key) abort
    if match(a:key, ':') != -1
      throw 'invalid session name.'
    endif

    let self._key = a:key
  endf

  call call(obj.initialize, [a:key], obj)

  " initialize END

  fun! obj.basename() abort
    return self._key
  endf

  fun! obj.ext() abort
    return '.session.vim'
  endf

  fun! obj.actual_name() abort
    return substitute(self.basename(), '/', ':', '').self.ext()
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
