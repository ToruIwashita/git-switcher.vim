" git-switcher
" Author:  Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#git#new()
  let obj = {'name': 'git'}

  fun! obj.exec(cmd)
    return system(self.name.' '.a:cmd.' 2>/dev/null')
  endf

  fun! obj.chomp_exec(cmd)
    return substitute(self.exec(a:cmd), '\n', '', 'g')
  endf
  
  fun! obj.fetch()
    call self.exec('fetch')
  endf

  fun! obj.create_branch(branch_key)
    if self.branch_exist(fnamemodify(a:branch_key, ':t'))
      echo "'".a:branch_key."' already exists."
      return 0
    endif

    call self.exec('branch '.a:branch_key)

    if !self.branch_exist(fnamemodify(a:branch_key, ':t'))
      echo "create '".a:branch_key."' failed."
      return 0
    endif

    return 1
  endf

  fun! obj.create_remote_trancking_branch(branch)
    return self.create_branch(a:branch.' origin/'.a:branch)
  endf

  fun! obj.switch(branch)
    if !self.branch_exist(a:branch)
      echo "'".a:branch."' does not exist."
      return 0
    endif

    call self.exec('checkout '.a:branch)

    if self.current_branch() != a:branch
      echo 'switch branch failed.'
      return 0
    endif

    return 1
  endf

  fun! obj.project()
    return fnamemodify(self.chomp_exec('rev-parse --show-toplevel'), ':t')
  endf

  fun! obj.inside_work_tree()
    return self.chomp_exec('rev-parse --is-inside-work-tree') == 'true'
  endf

  fun! obj.branch_exist(branch)
    return match(self.branches(), '\<'.a:branch.'\>') != -1
  endf

  fun! obj.current_branch()
    return self.chomp_exec('symbolic-ref --short HEAD')
  endf

  fun! obj.branches()
    return filter(split(self.exec('branch')), 'v:val != "*"')
  endf

  fun! obj.remote_tracking_branches()
    return map(filter(split(self.exec('branch --remotes'), '\n'), 'v:val !~ "->"'), 'substitute(v:val, "^\\(  origin/\\|  \\)", "", "")')
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

  return obj
endf

fun! git_switcher#git#_branches(arg_lead, cmd_line, cursor_pos)
  let git = git_switcher#git#new()
  return filter(git.branches(), 'v:val =~ "^'.fnameescape(a:arg_lead).'"')
endf

fun! git_switcher#git#_remote_only_branches(arg_lead, cmd_line, cursor_pos)
  let git = git_switcher#git#new()
  return filter(git.remote_only_branches(), 'v:val =~ "^'.fnameescape(a:arg_lead).'"')
endf

let &cpo = s:cpo_save
unlet s:cpo_save
