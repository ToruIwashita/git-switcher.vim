" File: autoload/git_switcher/git.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#git#new() abort
  let obj = {'_self': 'git'}

  fun! obj.exec_and_return_exit_code(cmd) abort
    return system('\'.self._self.' '.a:cmd.' >/dev/null 2>&1; echo $?')
  endf

  fun! obj.exec_and_return_list_of_splited_stdout_with_exit_code(cmd) abort
    return split(system('\'.self._self.' '.a:cmd.'; echo $?'), "\n")
  endf

  fun! obj.exec(cmd) abort
    if self.exec_and_return_exit_code('rev-parse')
      throw 'failed because not a git repository.'
    endif

    let results = self.exec_and_return_list_of_splited_stdout_with_exit_code(a:cmd)
    let exit_code = remove(results, -1)
    let output = join(results, "\n")

    if exit_code
      throw 'failed to '.a:cmd."\n".output
    endif

    return output
  endf

  fun! obj.short_status() abort
    return self.exec('status --short')
  endf
  
  fun! obj.fetch() abort
    return self.exec('fetch --prune')
  endf

  fun! obj.pull_current_branch() abort
    return self.exec('pull origin '.self.current_branch())
  endf

  fun! obj.branch() abort
    return self.exec('branch')
  endf

  fun! obj.remote_tracking_branch() abort
    return self.exec('branch --remotes')
  endf

  fun! obj.branches() abort
    return filter(split(self.branch()), 'v:val != "*"')
  endf

  fun! obj.remote_tracking_branches() abort
    return filter(map(filter(split(self.remote_tracking_branch(), '\n'), 'v:val !~ "->"'), 'matchstr(v:val, "^\\(  origin/\\|  \\)\\zs\\(.*\\)\\ze", 0)'), 'v:val != ""')
  endf

  fun! obj.remote_only_branches() abort
    let local_branches = self.branches()
    let remote_only_branches = []

    for remote_tracking_branch in self.remote_tracking_branches()
      if match(local_branches, '\<'.remote_tracking_branch.'\>') == -1
        call add(remote_only_branches, remote_tracking_branch)
      endif
    endfor

    return remote_only_branches
  endf

  fun! obj.current_branch() abort
    return self.exec('symbolic-ref --short HEAD')
  endf

  fun! obj.branch_exists(branch) abort
    return match(self.branches(), '\<'.a:branch.'\>') != -1
  endf

  fun! obj.create_branch(branch_key) abort
    if self.branch_exists(fnamemodify(a:branch_key, ':t'))
      throw "'".a:branch_key."' branch already exists."
    endif

    call self.exec('branch '.a:branch_key)
  endf

  fun! obj.create_remote_trancking_branch(branch) abort
    return self.create_branch(a:branch.' origin/'.a:branch)
  endf

  fun! obj.switch(branch) abort
    if !self.branch_exists(a:branch)
      throw "'".a:branch."' branch not exists."
    endif

    call self.exec('checkout '.a:branch)
  endf

  fun! obj.project() abort
    return fnamemodify(self.exec('rev-parse --show-toplevel'), ':t')
  endf

  fun! obj.inside_work_tree() abort
    try
      call self.exec('rev-parse')
    catch
      return 0
    endtry

    return 1
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
