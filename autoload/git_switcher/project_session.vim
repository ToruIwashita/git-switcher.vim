" File: autoload/git_switcher/project_session.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#new(project_key, session_key)
  let obj = {'_self': 'project_session'}
  let obj.project_dir = git_switcher#project_session#project_dir#new(a:project_key)
  let obj.session_file = git_switcher#project_session#session_file#new(a:session_key)

  fun! obj.session_name()
    return self.session_file.basename() 
  endf

  fun! obj.project_name()
    return self.project_dir.name()
  endf

  fun! obj.name()
    return self.project_name().'/'.self.session_name()
  endf

  fun! obj.file_path()
    return self.project_dir.path().self.session_file.name()
  endf

  fun! obj.file_exists()
    return filereadable(self.file_path())
  endf

  fun! obj.store()
    call self.project_dir.create()

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
    redraw!
  endf

  fun! obj.destroy()
    return delete(self.file_path()) == 0
  endf

  fun! obj.stored_session_names()
    return map(split(expand(self.project_dir.path().'/*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.self.session_file.escaped_ext().'$", 0)')
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
