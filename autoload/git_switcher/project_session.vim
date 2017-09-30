" File: autoload/git_switcher/project_session.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#project_session#new(project_key, session_key) abort
  let l:obj = {'_self': 'project_session'}

  " initialize

  fun! l:obj.initialize(project_key, session_key) abort
    let l:self.project_dir = git_switcher#session_component#project_dir#new(a:project_key)
    let l:self.session_file = git_switcher#session_component#session_file#new(a:session_key)
    let l:self.lock_file = git_switcher#session_component#lock_file#new(a:session_key)
  endf

  call call(l:obj.initialize, [a:project_key, a:session_key], l:obj)

  " initialize END

  " private

  fun! l:obj._project_name() abort
    return l:self.project_dir.name()
  endf

  fun! l:obj._file_path() abort
    return l:self.project_dir.path().l:self.session_file.actual_name()
  endf

  fun! l:obj._lock_file_path() abort
    return l:self.project_dir.path().l:self.lock_file.actual_name()
  endf

  fun! l:obj._lock_file_exists() abort
    return filereadable(l:self._lock_file_path())
  endf

  fun! l:obj._same_process_lock_file_paths() abort
    let l:lock_file_paths = split(expand(l:self.project_dir.path().'*'.l:self.lock_file.ext()))

    if empty(l:lock_file_paths) || !filereadable(l:lock_file_paths[0])
      return []
    endif

    return l:lock_file_paths
  endf

  fun! l:obj._already_existing_lock_file_paths() abort
    let l:lock_file_paths = split(expand(l:self.project_dir.path().l:self.lock_file.glob_name()))

    if empty(l:lock_file_paths) || !filereadable(l:lock_file_paths[0])
      return []
    endif

    return l:lock_file_paths
  endf

  fun! l:obj._one_of_already_existing_lock_file_paths() abort
    let l:already_existing_lock_file_paths = l:self._already_existing_lock_file_paths()

    if len(l:already_existing_lock_file_paths) == 0
      return ''
    endif

    return l:self._already_existing_lock_file_paths()[0]
  endf

  fun! l:obj._already_existing_lock_file_exists() abort
    return filereadable(l:self._one_of_already_existing_lock_file_paths())
  endf

  " private END

  fun! l:obj.session_name() abort
    return l:self.session_file.basename()
  endf

  fun! l:obj.name() abort
    return l:self._project_name().'/'.l:self.session_name()
  endf

  fun! l:obj.exists() abort
    return filereadable(l:self._file_path())
  endf

  fun! l:obj.lock_session() abort
    exec 'redir > '.l:self._lock_file_path()
    if !l:self._lock_file_exists()
      throw 'failed to create lock file.'
    endif
  endf

  fun! l:obj.unlock_sessions() abort
    for l:lock_file_path in l:self._same_process_lock_file_paths()
      if delete(l:lock_file_path) != 0
        throw 'failed to delete lock files.'
      endif
    endfor
  endf

  fun! l:obj.locked() abort
    if !l:self._already_existing_lock_file_exists() || l:self._lock_file_path() == l:self._one_of_already_existing_lock_file_paths()
      return 0
    else
      return 1
    endif
  endf

  fun! l:obj.store() abort
    call l:self.project_dir.create()

    let l:result = 1
    let l:current_ssop = &sessionoptions
    try
      set sessionoptions-=options
      exec 'mksession!' l:self._file_path()
    catch
      let l:result = 0
    finally
      let &sessionoptions = l:current_ssop
    endtry

    if !l:result
      throw "faild to store '".l:self.name()."' session."
    endif
  endf

  fun! l:obj.restore() abort
    let l:result = 1

    try
      exec 'source' l:self._file_path()
    catch
      let l:result = 0
    finally
      checktime
      redraw!
    endtry

    if !l:result
      throw "faild to restore '".l:self.name()."' session."
    endif
  endf

  fun! l:obj.destroy() abort
    if delete(l:self._file_path()) != 0
      throw "failed to destroy '".l:self.name()."' session."
    endif
  endf

  fun! l:obj.stored_session_names() abort
    let l:actual_names = map(split(expand(l:self.project_dir.path().'*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.l:self.session_file.escaped_ext().'$", 0)')
    let l:session_names = map(l:actual_names, "substitute(v:val, ':', '/', '')")
    return filter(l:session_names, "v:val !=# ''")
  endf

  fun! l:obj.stored_session_list() abort
    return join(l:self.stored_session_names(), "\n")
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
