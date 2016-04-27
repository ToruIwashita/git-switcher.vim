" File: autoload/git_switcher/git.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#git#new()
  let obj = {'_self': 'git'}

  fun! obj.exec(cmd)
    return substitute(system('\'.self._self.' '.a:cmd.' 2>/dev/null'), '\n$', '', '')
  endf

  fun! obj.exec_and_return_exit_status(cmd)
    return !system('\'.self._self.' '.a:cmd.' >/dev/null 2>&1; echo $?')
  endf

  fun! obj.short_status()
    return self.exec('status --short')
  endf
  
  fun! obj.fetch()
    return self.exec_and_return_exit_status('fetch')
  endf

  fun! obj.pull_current_branch()
    return self.exec_and_return_exit_status('pull origin '.self.current_branch())
  endf

  fun! obj.save_stash()
    return self.exec('stash save') !=# 'No local changes to save'
  endf

  fun! obj.pop_stash()
    return self.exec_and_return_exit_status('stash pop')
  endf

  fun! obj.branch()
    return self.exec('branch')
  endf

  fun! obj.remote_tracking_branch()
    return self.exec('branch --remotes')
  endf

  fun! obj.branches()
    return filter(split(self.branch()), 'v:val != "*"')
  endf

  fun! obj.remote_tracking_branches()
    return map(filter(split(self.remote_tracking_branch(), '\n'), 'v:val !~ "->"'), 'matchstr(v:val, "^\\(  origin/\\|  \\)\\zs\\(.*\\)\\ze", 0)')
  endf

  fun! obj.remote_only_branches()
    let local_branches = self.branches()
    let remote_only_branches = []

    for remote_tracking_branch in self.remote_tracking_branches()
      if match(local_branches, '\<'.remote_tracking_branch.'\>') == -1
        call add(remote_only_branches, remote_tracking_branch)
      endif
    endfor

    return remote_only_branches
  endf

  fun! obj.current_branch()
    return self.exec('symbolic-ref --short HEAD')
  endf

  fun! obj.branch_exists(branch)
    return match(self.branches(), '\<'.a:branch.'\>') != -1
  endf

  fun! obj.create_branch(branch_key)
    if self.branch_exists(fnamemodify(a:branch_key, ':t'))
      return 0
    endif

    if !self.exec_and_return_exit_status('branch '.a:branch_key)
      return 0
    endif

    if !self.branch_exists(fnamemodify(a:branch_key, ':t'))
      return 0
    endif

    return 1
  endf

  fun! obj.create_remote_trancking_branch(branch)
    return self.create_branch(a:branch.' origin/'.a:branch)
  endf

  fun! obj.switch(branch)
    if !self.branch_exists(a:branch)
      return 0
    endif

    if !self.exec_and_return_exit_status('checkout '.a:branch)
      return 0
    endif

    if self.current_branch() != a:branch
      return 0
    endif

    return 1
  endf

  fun! obj.project()
    return fnamemodify(self.exec('rev-parse --show-toplevel'), ':t')
  endf

  fun! obj.inside_work_tree()
    return self.exec('rev-parse --is-inside-work-tree') ==# 'true'
  endf

  fun! obj.both_modified_file_exists()
    return !empty(self.both_modified_files())
  endf

  fun! obj.both_modified_files()
    return map(filter(split(self.short_status(), '\n'), 'v:val =~ "^UU"'), 'matchstr(v:val, "^UU \\zs\\(.*\\)\\ze", 0)')
  endf

  return obj
endf

let &cpo = s:cpo_save
unlet s:cpo_save
