" File: autoload/git_switcher/project_session.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#new(project_key, session_key)
  let obj = {'_self': 'project_session'}
  let obj.project_dir = git_switcher#project_session#project_dir#new(a:project_key)
  let obj.session_file = git_switcher#project_session#session_file#new(a:session_key)
  let obj.lock_file = git_switcher#project_session#lock_file#new(a:session_key)

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

  fun! obj.exists()
    return filereadable(self.file_path())
  endf

  fun! obj.current_lock_file_path()
    return self.project_dir.path().self.lock_file.name()
  endf

  fun! obj.current_lock_file_exists()
    return filereadable(self.current_lock_file_path())
  endf

  fun! obj.same_process_lock_file_paths()
    let lock_file_paths = split(expand(self.project_dir.path().'*'.self.lock_file.ext()))

    if !filereadable(lock_file_paths[0])
      return []
    endif

    return lock_file_paths
  endf

  fun! obj.already_existing_lock_file_paths()
    let lock_file_paths = split(expand(self.project_dir.path().self.lock_file.glob_name()))

    if !filereadable(lock_file_paths[0])
      return []
    endif

    return lock_file_paths
  endf

  fun! obj.one_of_already_existing_lock_file_paths()
    let already_existing_lock_file_paths = self.already_existing_lock_file_paths()

    if len(already_existing_lock_file_paths) == 0
      return ''
    endif

    return self.already_existing_lock_file_paths()[0]
  endf

  fun! obj.already_existing_lock_file_exists()
    return filereadable(self.one_of_already_existing_lock_file_paths())
  endf

  fun! obj.create_lock_file()
    exec 'redir > '.self.current_lock_file_path()
    return self.current_lock_file_exists()
  endf

  fun! obj.delete_lock_files()
    for lock_file_path in self.same_process_lock_file_paths()
      if delete(lock_file_path) != 0
        return 0
      endif
    endfor

    return 1
  endf

  fun! obj.locked()
    if !self.already_existing_lock_file_exists() || self.current_lock_file_path() == self.one_of_already_existing_lock_file_paths()
      return 0
    else
      return 1
    endif
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
    return filter(map(split(expand(self.project_dir.path().'*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.self.session_file.escaped_ext().'$", 0)'), 'v:val != ""')
  endf

  fun! obj.stored_session_list()
    return join(self.stored_session_names(), "\n")
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
