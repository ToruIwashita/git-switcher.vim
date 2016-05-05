" File: autoload/git-switcher.vim
" Author: Toru Hoyano <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! git_switcher#new(...)
  let obj = {
    \ '_self': 'git_switcher',
    \ '_autostash_enabled': g:gsw_switch_autostash
  \ }
  let obj.git = git_switcher#git#new()
  let obj.state = git_switcher#state#new()
  if a:0
    let obj.project_session = git_switcher#project_session#new(obj.git.project(), a:1)
  else
    let obj.project_session = git_switcher#project_session#new(obj.git.project(), obj.git.current_branch())
  endif

  fun! obj.autostash_enabled()
    return self._autostash_enabled == 1
  endf

  fun! obj.inside_work_tree()
    if !self.git.inside_work_tree()
      echo 'working directory is not a git repository.'
      return 0
    endif

    return 1
  endf

  fun! obj.branch()
    if !self.inside_work_tree()
      return 0
    endif

    echo self.git.branch()
    return 1
  endf

  fun! obj.remote_tracking_branch()
    if !self.inside_work_tree()
      return 0
    endif

    echo self.git.remote_tracking_branch()
    return 1
  endf

  fun! obj.branches()
    if !self.inside_work_tree()
      return []
    endif

    return self.git.branches()
  endf

  fun! obj.remote_only_branches()
    if !self.inside_work_tree()
      return []
    endif

    return self.git.remote_only_branches()
  endf

  fun! obj.fetch_project()
    if !self.inside_work_tree()
      return 0
    endif

    echo 'fetching remote.'
    let fetch_res = self.git.fetch()
    redraw!

    if !fetch_res
      echo 'fetching failed.'
      return 0
    endif

    echo 'fetched.'
    return 1
  endf

  fun! obj.pull_current_branch()
    if !self.inside_work_tree()
      return 0
    endif

    echo "pulling '".self.git.current_branch()."' branch."
    let pull_current_branch_res = self.git.pull_current_branch()
    redraw!

    if !pull_current_branch_res
      echo 'pulling failed.'
      return 0
    endif

    echo 'pulled.'
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
      if confirm("create '".a:branch."' branch based on '".self.git.current_branch()."'?", "&Yes\n&No", 1) != 1
        return 1
      endif

      redraw!
      let create_branch_res = 0

      if a:source ==# 'remote'
        if !self.fetch_project()
          return 0
        endif

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

    let save_stash_res = 0

    if self.autostash_enabled()
      let save_stash_res = self.git.save_stash()
    endif

    redraw!
    echo "checking out files."

    if !self.git.switch(a:branch)
      redraw!
      echo "switching '".a:branch."' branch failed."
      return 0
    endif

    let pop_stash_res = 0
    if self.autostash_enabled() && save_stash_res
      let pop_stash_res = self.git.pop_stash()
    endif

    let self.project_session = git_switcher#project_session#new(self.git.project(), a:branch)

    if a:bang
      redraw!
      echo "switched to '".a:branch."' branch."
      return 1
    endif

    redraw!
    if self.load_session()
      let res_message = "switched to '".a:branch."' branch and loaded session."
    else
      let res_message = "switched to '".a:branch."' branch."
    endif

    redraw!
    echo res_message
    if self.git.both_modified_file_exists()
      echo pop_stash_res
    endif

    return 1
  endf

  fun! obj.stored_session_names()
    return self.project_session.stored_session_names()
  endf

  fun! obj.stored_project_sessions()
    return map(self.stored_session_names(), 'git_switcher#project_session#new(self.git.project(), v:val)')
  endf

  fun! obj.delete_session(...)
    if !self.inside_work_tree()
      return 0
    endif

    let bang = 0
    if a:0 | let bang = a:1 | endif

    if !bang && confirm("delete '".self.project_session.name()."' session?", "&Yes\n&No", 1) != 1
      return 1
    endif

    if !self.project_session.destroy()
      echo "deleting '".self.project_session.session_name()."' session failed."
      return 0
    endif

    return 1
  endf

  fun! obj.delete_sessions_if_branch_does_not_exist(...)
    if !self.inside_work_tree()
      return 0
    endif

    let bang = 0
    if a:0 | let bang = a:1 | endif
    
    for project_session in self.stored_project_sessions()
      if self.git.branch_exists(project_session.session_name())
        continue
      endif

      if !bang && confirm("delete '".project_session.session_name()."' session?", "&Yes\n&No", 1) != 1
        continue
      endif

      if !project_session.destroy()
        echo "deleting '".project_session.session_name()."' session failed."
        return 0
      endif
    endfor

    return 1
  endf

  fun! obj.clear_state()
    call self.state.delete_all_buffers()
    echo 'cleared session state.'
    return 1
  endf

  return obj
endf

fun! git_switcher#branch()
  let git_switcher = git_switcher#new()
  call git_switcher.branch()
endf

fun! git_switcher#remote_tracking_branch()
  let git_switcher = git_switcher#new()
  call git_switcher.remote_tracking_branch()
endf

fun! git_switcher#fetch_project()
  let git_switcher = git_switcher#new()
  call git_switcher.fetch_project()
endf

fun! git_switcher#pull_current_branch()
  let git_switcher = git_switcher#new()
  call git_switcher.pull_current_branch()
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

fun! git_switcher#clear_stete()
  let git_switcher = git_switcher#new()
  call git_switcher.clear_state()
endf

fun! git_switcher#delete_session(bang,branch)
  let git_switcher = git_switcher#new(a:branch)
  call git_switcher.delete_session(a:bang)
endf

fun! git_switcher#delete_sessions_if_branch_does_not_exist(bang)
  let git_switcher = git_switcher#new()
  return git_switcher.delete_sessions_if_branch_does_not_exist(a:bang) 
endf

fun! git_switcher#_branches(...)
  let git_switcher = git_switcher#new()
  return filter(git_switcher.branches(), 'v:val =~ "^'.fnameescape(a:1).'"')
endf

fun! git_switcher#_remote_only_branches(...)
  let git_switcher = git_switcher#new()
  return filter(git_switcher.remote_only_branches(), 'v:val =~ "^'.fnameescape(a:1).'"')
endf

fun! git_switcher#_stored_sessions(...)
  let git_switcher = git_switcher#new()
  return filter(git_switcher.stored_session_names(), 'v:val =~ "^'.fnameescape(a:1).'"')
endf

let &cpo = s:cpo_save
unlet s:cpo_save
