" File: autoload/git_switcher/session_component/file_base.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#session_component#file_base#new(key) abort
  let l:obj = {'_self': 'file_base'}

  " initialize

  fun! l:obj.initialize(key) abort
    if match(a:key, ':') != -1
      throw 'invalid session name.'
    endif

    let self._key = a:key
  endf

  call call(l:obj.initialize, [a:key], l:obj)

  " initialize END

  fun! l:obj.basename() abort
    return self._key
  endf

  fun! l:obj.ext() abort
    return '.session.vim'
  endf

  fun! l:obj.actual_name() abort
    return substitute(self.basename(), '/', ':', '').self.ext()
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
