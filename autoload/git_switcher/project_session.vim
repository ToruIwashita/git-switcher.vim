" File: autoload/git_switcher/project_session.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_session#new(project_key, session_key) abort
  let obj = {'_self': 'project_session'}

  " initialize

  fun! obj.initialize(project_key, session_key) abort
    let self.project_dir = git_switcher#session_component#project_dir#new(a:project_key)
    let self.session_file = git_switcher#session_component#session_file#new(a:session_key)
    let self.lock_file = git_switcher#session_component#lock_file#new(a:session_key)
  endf

  call call(obj.initialize, [a:project_key, a:session_key], obj)

  " initialize END

  " private

  fun! obj._project_name() abort
    return self.project_dir.name()
  endf

  fun! obj._file_path() abort
    return self.project_dir.path().self.session_file.name()
  endf

  fun! obj._current_session_lock_file_path() abort
    return self.project_dir.path().self.lock_file.name()
  endf

  fun! obj._current_session_lock_file_exists() abort
    return filereadable(self._current_session_lock_file_path())
  endf

  fun! obj._same_process_lock_file_paths() abort
    let lock_file_paths = split(expand(self.project_dir.path().'*'.self.lock_file.ext()))

    if !filereadable(lock_file_paths[0])
      return []
    endif

    return lock_file_paths
  endf

  fun! obj._already_existing_current_session_lock_file_paths() abort
    let lock_file_paths = split(expand(self.project_dir.path().self.lock_file.glob_name()))

    if !filereadable(lock_file_paths[0])
      return []
    endif

    return lock_file_paths
  endf

  fun! obj._one_of_already_existing_current_session_lock_file_paths() abort
    let already_existing_current_session_lock_file_paths = self._already_existing_current_session_lock_file_paths()

    if len(already_existing_current_session_lock_file_paths) == 0
      return ''
    endif

    return self._already_existing_current_session_lock_file_paths()[0]
  endf

  fun! obj._already_existing_current_session_lock_file_exists() abort
    return filereadable(self._one_of_already_existing_current_session_lock_file_paths())
  endf

  " private END

  fun! obj.session_name() abort
    return self.session_file.basename()
  endf

  fun! obj.name() abort
    return self._project_name().'/'.self.session_name()
  endf

  fun! obj.exists() abort
    return filereadable(self._file_path())
  endf

  fun! obj.lock_session() abort
    exec 'redir > '.self._current_session_lock_file_path()
    if !self._current_session_lock_file_exists()
      throw 'failed to create lock file.'
    endif
  endf

  fun! obj.unlock_sessions() abort
    for lock_file_path in self._same_process_lock_file_paths()
      if delete(lock_file_path) != 0
        throw 'failed to delete lock files.'
      endif
    endfor
  endf

  fun! obj.locked() abort
    if !self._already_existing_current_session_lock_file_exists() || self._current_session_lock_file_path() == self._one_of_already_existing_current_session_lock_file_paths()
      return 0
    else
      return 1
    endif
  endf

  fun! obj.store() abort
    call self.project_dir.create()

    let result = 1
    let current_ssop = &sessionoptions
    try
      set ssop-=options
      exec 'mksession!' self._file_path()
    catch
      let result = 0
    finally
      let &sessionoptions = current_ssop
    endtry

    if !result
      throw "faild to store '".self.name()."' session."
    endif
  endf

  fun! obj.restore() abort
    let result = 1

    try
      exec 'source' self._file_path()
    catch
      let result = 0
    finally
      checktime
      redraw!
    endtry

    if !result
      throw "faild to restore '".self.name()."' session."
    endif
  endf

  fun! obj.destroy() abort
    if delete(self._file_path()) != 0
      throw "failed to destroy '".self.name()."' session."
    endif
  endf

  fun! obj.stored_session_names() abort
    return filter(map(split(expand(self.project_dir.path().'*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.self.session_file.escaped_ext().'$", 0)'), 'v:val != ""')
  endf

  fun! obj.stored_session_list() abort
    return join(self.stored_session_names(), "\n")
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
