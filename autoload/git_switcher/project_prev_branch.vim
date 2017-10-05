" File: autoload/git_switcher/project_prev_branch.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#project_prev_branch#new(project_key, branch_key) abort
  let l:obj = {'_self': 'project_prev_branch'}

  " initialize

  fun! l:obj.initialize(project_key, branch_key) abort
    let l:self.project_dir = git_switcher#session_component#project_dir#new(a:project_key)
    let l:self.prev_branch_file = git_switcher#session_component#prev_branch_file#new(a:branch_key)
  endf

  call call(l:obj.initialize, [a:project_key, a:branch_key], l:obj)

  " initialize END

  " private

  fun! l:obj._file_path() abort
    return l:self.project_dir.path().l:self.prev_branch_file.actual_name()
  endf

  fun! l:obj._file_exists() abort
    return filereadable(l:self._file_path())
  endf

  fun! l:obj._same_process_file_paths() abort
    let l:file_paths = split(expand(l:self.project_dir.path().'*'.l:self.prev_branch_file.ext()))

    if empty(l:file_paths) || !filereadable(l:file_paths[0])
      return []
    endif

    return l:file_paths
  endf

  fun! l:obj._branch_names() abort
    let l:actual_names = map(split(expand(l:self.project_dir.path().'*')), 'matchstr(fnamemodify(v:val, ":t"), "^\\zs\\(.*\\)\\ze'.l:self.prev_branch_file.escaped_glob_ext().'$", 0)')
    let l:branch_names = map(l:actual_names, "substitute(v:val, ':', '/', '')")
    return filter(l:branch_names, "v:val !=# ''")
  endf

  " private END

  fun! l:obj.store() abort
    call l:self.project_dir.create()

    exec 'redir > '.l:self._file_path()
    if !l:self._file_exists()
      throw 'failed to store previous branch.'
    endif
  endf

  fun! l:obj.destroy_all() abort
    for l:file_path in l:self._same_process_file_paths()
      if delete(l:file_path) != 0
        throw 'failed to destroy all previous branches.'
      endif
    endfor
  endf

  fun! l:obj.branch_name() abort
    let l:branch_names = l:self._branch_names()

    if len(l:branch_names) == 0
      return ''
    else
      return l:self._branch_names()[0]
    endif
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
