" File: git-switcher.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#new(...)
  let obj = {}
  let obj.git = git_switcher#git#new()
  let obj.state = git_switcher#state#new()
  if a:0
    let obj.project_session = git_switcher#project_session#new(obj.git.project(), a:1)
  else
    let obj.project_session = git_switcher#project_session#new(obj.git.project(), obj.git.current_branch())
  endif

  fun! obj.inside_work_tree()
    if !self.git.inside_work_tree()
      echo 'working directory is not a git repository.'
      return 0
    endif

    return 1
  endf

  fun! obj.save_session()
    if !self.inside_work_tree()
      return 0
    endif

    call self.project_session.store()
    echo "saved '".self.project_session.name()."' session."
    return 1
  endf

  fun! obj.load_session()
    if !self.inside_work_tree()
      return 0
    endif

    if !self.project_session.file_exists()
      silent! edit!
      echo 'session file does not exist.'
      return 0
    endif

    call self.state.delete_all_buffers()
    call self.project_session.restore()
    echo "loaded '".self.project_session.name()."' session."
    return 1
  endf

  fun! obj.autoload_session()
    if self.project_session.file_exists()
      \ && (g:gsw_session_autoload == 'yes' || (g:gsw_session_autoload == 'confirm' && confirm("load '".self.project_session.name()."' session?", "&Yes\n&No", 1) == 1))
      call self.load_session()
    end
  endf

  fun! obj.switch(source, branch, bang)
    if !self.inside_work_tree()
      return 0
    endif

    if !self.git.branch_exists(a:branch)
      if confirm("create '".a:branch."' branch?", "&Yes\n&No", 1) != 1
        return 1
      endif

      redraw!

      if a:source ==# 'remote'
        echo 'fetching remote.'
        call self.git.fetch()
        let create_branch_res = self.git.create_remote_trancking_branch(a:branch)
        redraw!
      elseif a:source ==# 'local'
        let create_branch_res = self.git.create_branch(a:branch)
      end

      if !create_branch_res
        echo "creating '".a:branch."' branch failed."
        return 0
      end
    endif

    if !a:bang && confirm("save '".self.project_session.name()."' session?", "&Yes\n&No", 1) == 1
      redraw!
      call self.save_session()
    endif

    redraw!
    echo "checking out files."
    if !self.git.switch(a:branch)
      redraw!
      echo "switching '".a:branch."' branch failed."
      return 0
    endif

    if a:bang
      return 1
    endif

    let self.project_session = git_switcher#project_session#new(self.git.project(), a:branch)
    redraw!

    let load_session_res = self.load_session()
    redraw!

    if load_session_res
      echo "switched to '".a:branch."' branch and loaded session."
    else
      echo "switched to '".a:branch."' branch."
    endif

    return 1
  endf

  fun! obj.stored_sessions()
    return self.project_session.stored_sessions()
  endf

  fun! obj.delete_session()
    if confirm("delete '".self.project_session.name()."' session?", "&Yes\n&No", 1) != 1
      return 1
    endif

    if !self.project_session.destroy()
      echo "deleting '".self.project_session.name()."' session failed."
      return 0
    endif

    return 1
  endf

  return obj
endf

fun! git_switcher#save_session(...)
  let git_switcher = call('git_switcher#new', a:000)
  call git_switcher.save_session()
endf

fun! git_switcher#load_session(...)
  let git_switcher = call('git_switcher#new', a:000)
  call git_switcher.load_session()
endf

fun! git_switcher#autoload_session()
  let git_switcher = git_switcher#new()
  call git_switcher.autoload_session()
endf

fun! git_switcher#gsw(branch,bang)
  let git_switcher = git_switcher#new()
  call git_switcher.switch('local', a:branch, a:bang)
endf

fun! git_switcher#gsw_remote(branch,bang)
  let git_switcher = git_switcher#new()
  call git_switcher.switch('remote', a:branch, a:bang)
endf

fun! git_switcher#delete_session(branch)
  let git_switcher = git_switcher#new(a:branch)
  call git_switcher.delete_session()
endf

fun! git_switcher#_stored_sessions(arg_lead, cmd_line, cursor_pos)
  let git_switcher = git_switcher#new()
  return filter(git_switcher.stored_sessions(), 'v:val =~ "^'.fnameescape(a:arg_lead).'"')
endf

let &cpo = s:cpo_save
unlet s:cpo_save
