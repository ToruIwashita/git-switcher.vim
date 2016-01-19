" git-switcher
" Author:  ToruIwashita <toru.iwashita@gmail.com>
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
    redraw
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

  return obj
endf

fun! git_switcher#git#_branches(arg_lead, cmd_line, cursor_pos)
  let git = git_switcher#git#new()
  return filter(git.branches(), 'v:val =~ "^'.fnameescape(a:arg_lead).'"')
endf

let &cpo = s:cpo_save
unlet s:cpo_save
