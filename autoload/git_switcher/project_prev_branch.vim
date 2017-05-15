" File: autoload/git_switcher/project_prev_branch.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#project_prev_branch#new(project_key, branch_key) abort
  let obj = {'_self': 'project_prev_branch'}

  " initialize

  fun! obj.initialize(project_key, branch_key) abort
    let self.project_dir = git_switcher#session_component#project_dir#new(a:project_key)
    let self.prev_branch_file = git_switcher#session_component#prev_branch_file#new(a:branch_key)
  endf

  call call(obj.initialize, [a:project_key, a:branch_key], obj)

  " initialize END

  " private

  fun! obj._file_path() abort
    return self.project_dir.path().self.prev_branch_file.actual_name()
  endf

  fun! obj._file_exists() abort
    return filereadable(self._file_path())
  endf

  fun! obj._same_process_file_paths() abort
    let file_paths = split(expand(self.project_dir.path().'*'.self.prev_branch_file.ext()))

    if !filereadable(file_paths[0])
      return []
    endif

    return file_paths
  endf

  fun! obj._branch_names() abort
    let actual_names = map(split(expand(self.project_dir.path().'*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.self.prev_branch_file.escaped_glob_ext().'$", 0)')
    let branch_names = map(actual_names, 'substitute(v:val, ":", "/", "")')
    return filter(branch_names, 'v:val != ""')
  endf

  " private END

  fun! obj.store() abort
    exec 'redir > '.self._file_path()
    if !self._file_exists()
      throw 'failed to store previous branch.'
    endif
  endf

  fun! obj.destroy_all() abort
    for file_path in self._same_process_file_paths()
      if delete(file_path) != 0
        throw 'failed to destroy all previous branches.'
      endif
    endfor
  endf

  fun! obj.branch_name() abort
    let branch_names = self._branch_names()

    if len(branch_names) == 0
      return ''
    else
      return self._branch_names()[0]
    endif
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
