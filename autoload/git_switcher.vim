" git-switcher
" Author:  Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#new(...)
  let obj = {}
  let obj.git   = git_switcher#git#new()
  let obj.state = git_switcher#state#new()
  if a:0
    let obj.session = git_switcher#session#new(obj.git.project().'/'.a:1)
  else
    let obj.session = git_switcher#session#new(obj.git.project().'/'.obj.git.current_branch())
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
      return
    endif

    call self.session.store()
    echo "save '".self.session.name."' session."
  endf

  fun! obj.load_session()
    if !self.inside_work_tree()
      return
    endif

    if !self.session.file_exist()
      silent! edit!
      echo 'session file does not exist.'
      return 0
    endif

    call self.state.delete_all_buffers()
    call self.session.restore()
    echo "load '".self.session.name."' session."
  endf

  fun! obj.autoload_session()
    if self.session.file_exist()
      \ && (g:gsw_session_autoload == 'yes' || (g:gsw_session_autoload == 'confirm' && confirm("load '".self.session.name."' session?", "&Yes\n&No", 1) == 1))
      call self.load_session()
    end
  endf

  fun! obj.switch(branch,bang)
    if !self.inside_work_tree()
      return
    endif

    if !a:bang && confirm("save '".self.session.name."' session?", "&Yes\n&No", 1) == 1
      call self.save_session()
    endif

    call self.git.switch(a:branch)

    let self.session = git_switcher#session#new(self.git.project().'/'.a:branch)
    call self.load_session()
  endf

  fun! obj.switch_remote(branch,bang)
    if !self.inside_work_tree()
      return
    endif
    
    if !a:bang && confirm("save '".self.session.name."' session?", "&Yes\n&No", 1) == 1
      call self.save_session()
    endif

    echo 'git fetch.'
    call self.git.fetch()
    echo 'checkout branch.'
    call self.clone_remote_branch(a:branch)
    call self.git.switch(a:branch)

    let self.session = git_switcher#session#new(self.git.project().'/'.a:branch)
    call self.load_session()
  endf

  fun! obj.stored_sessions()
    return self.session.stored_sessions()
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
  let git_switcher = call('git_switcher#new', a:000)
  call git_switcher.switch(a:branch,a:bang)
endf

fun! git_switcher#gsw_remote(branch,bang)
  let git_switcher = call('git_switcher#new', a:000)
  call git_switcher.switch_remote(a:branch,a:bang)
endf

fun! git_switcher#_stored_sessions(arg_lead, cmd_line, cursor_pos)
  let git_switcher = git_switcher#new()
  return filter(git_switcher.stored_sessions(), 'v:val =~ "^'.fnameescape(a:arg_lead).'"')
endf

let &cpo = s:cpo_save
unlet s:cpo_save
