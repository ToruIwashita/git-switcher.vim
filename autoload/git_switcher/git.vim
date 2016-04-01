" File: git.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#git#new()
  let obj = {'_self': 'git'}

  fun! obj.exec(cmd)
    return substitute(system(self._self.' '.a:cmd.' 2>/dev/null'), '\n$', '', '')
  endf

  fun! obj.chomp_exec(cmd)
    return substitute(self.exec(a:cmd), '\n', '', 'g')
  endf

  fun! obj.short_status()
    return self.exec('status --short')
  endf
  
  fun! obj.fetch()
    call self.exec('fetch')
    return 1
  endf

  fun! obj.save_stash()
    return self.exec('stash save')
  endf

  fun! obj.pop_stash()
    return self.exec('stash pop')
  endf

  fun! obj.create_branch(branch_key)
    if self.branch_exists(fnamemodify(a:branch_key, ':t'))
      return 0
    endif

    call self.exec('branch '.a:branch_key)

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

    call self.exec('checkout '.a:branch)

    if self.current_branch() != a:branch
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

  fun! obj.both_modified_file_exists()
    return !empty(self.both_modified_files())
  endf

  fun! obj.both_modified_files()
    return map(filter(split(self.short_status(), '\n'), 'v:val =~ "^UU"'), 'matchstr(v:val, "^UU \\zs\\(.*\\)\\ze", 0)')
  endf

  fun! obj.branch_exists(branch)
    return match(self.branches(), '\<'.a:branch.'\>') != -1
  endf

  fun! obj.current_branch()
    return self.chomp_exec('symbolic-ref --short HEAD')
  endf

  fun! obj.branches()
    return filter(split(self.exec('branch')), 'v:val != "*"')
  endf

  fun! obj.remote_tracking_branches()
    return map(filter(split(self.exec('branch --remotes'), '\n'), 'v:val !~ "->"'), 'matchstr(v:val, "^\\(  origin/\\|  \\)\\zs\\(.*\\)\\ze", 0)')
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
