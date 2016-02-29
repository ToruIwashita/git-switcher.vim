" git-switcher
" Author:  Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#session#new(session)
  let obj = {'name': a:session}

  fun! obj.get_name()
    return self.name
  endf

  fun! obj.root_dir_path()
    if !exists('g:gsw_sessions_dir_path')
      return $HOME.'/.cache/vim/git_switcher/'
    else
      return g:gsw_sessions_dir_path.'/'
    endif
  endf

  fun! obj.file_path()
    return self.root_dir_path().self.name.'.session.vim'
  endf

  fun! obj.file_exist()
    return filereadable(self.file_path())
  endf

  fun! obj.dir_path()
    return fnamemodify(self.file_path(), ':h')
  endf

  fun! obj.dir_exist()
    return isdirectory(self.dir_path())
  endf

  fun! obj.create_dir()
    if !self.dir_exist()
      return mkdir(self.dir_path(), 'p')
    endif
  endf

  fun! obj.store()
    call self.create_dir()

    let current_ssop = &sessionoptions
    try
      set ssop-=options
      exec 'mksession!' self.file_path()
    finally
      let &sessionoptions = current_ssop
    endtry
  endf

  fun! obj.restore()
    exec 'source' self.file_path()
    redraw
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
