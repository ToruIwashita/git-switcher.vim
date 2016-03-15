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

  fun! obj.switch(branch)
    call self.exec('checkout '.a:branch)
    redraw!
  endf
  
  fun! obj.fetch()
    call self.exec('fetch')
  endf

  fun! obj.clone_remote_branch(branch)
    call self.exec('branch '.a:branch.' origin/'.a:branch)
  endf

  fun! obj.project()
    return fnamemodify(self.chomp_exec('rev-parse --show-toplevel'), ':t')
  endf

  fun! obj.inside_work_tree()
    return self.chomp_exec('rev-parse --is-inside-work-tree') == 'true'
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

    for branch in self.remote_tracking_branches()
      if match(local_branches, '\<'.branch.'\>') == -1
        call add(remote_only_branches, branch)
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
