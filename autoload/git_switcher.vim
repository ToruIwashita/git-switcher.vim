" File: autoload/git_switcher.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#new(...) abort
  let l:obj = {'_self': 'git_switcher'}

  " initialize

  fun! l:obj.initialize(...) abort
    let l:self._save_confirmation            = g:gsw_save_session_confirm
    let l:self._load_confirmation            = g:gsw_load_session_confirm
    let l:self._switch_prev_confirmation     = g:gsw_switch_prev_confirm
    let l:self._autoload_session_behavior    = g:gsw_autoload_session
    let l:self._autodelete_sessions_bahavior = g:gsw_autodelete_sessions_if_branch_not_exists
    let l:self._default_project_name         = g:gsw_non_project_sessions_dir
    let l:self._default_session_name         = g:gsw_non_project_default_session_name

    let l:self.git = git_switcher#git#new()

    try
      let l:self._project_name = l:self.git.project()
    catch
      let l:self._project_name = l:self._default_project_name
    endtry

    if a:0
      let l:self._session_name = a:1
    else
      try
        let l:self._session_name = l:self.git.current_branch()
      catch
        let l:self._session_name = l:self._default_session_name
      endtry
    endif

    let l:self.project_session        = git_switcher#project_session#new(l:self._project_name, l:self._session_name)
    let l:self.project_prev_branch    = git_switcher#project_prev_branch#new(l:self._project_name, l:self._session_name)
    let l:self.state                  = git_switcher#state#new()
    let l:self.nerdtree_state_handler = git_switcher#special_session_state#nerdtree_state_handler#new()
    let l:self.tagbar_state_handler = git_switcher#special_session_state#tagbar_state_handler#new()
  endf

  call call(l:obj.initialize, a:000, l:obj)

  " initialize END

  " private

  fun! l:obj._save_confirmation_enabled() abort
    return l:self._save_confirmation ==# 'yes'
  endf

  fun! l:obj._load_confirmation_enabled() abort
    return l:self._load_confirmation ==# 'yes'
  endf

  fun! l:obj._switch_prev_confirmation_enabled() abort
    return l:self._switch_prev_confirmation ==# 'yes'
  endf

  fun! l:obj._autoload_enabled() abort
    return l:self._autoload_session_behavior ==# 'yes'
  endf

  fun! l:obj._autoload_enabled_with_confirmation() abort
    return l:self._autoload_session_behavior ==# 'confirm'
  endf

  fun! l:obj._autodelete_sessions_enabled() abort
    return l:self._autodelete_sessions_bahavior ==# 'yes'
  endf

  fun! l:obj._autodelete_sessions_enabled_with_confirmation() abort
    return l:self._autodelete_sessions_bahavior ==# 'confirm'
  endf

  fun! l:obj._non_project_default_session() abort
    return l:self._project_name == l:self._default_project_name && l:self._session_name == l:self._default_session_name
  endf

  fun! l:obj._prev_branch() abort
    return l:self.project_prev_branch.branch_name()
  endf

  fun! l:obj._refresh_prev_branch() abort
    call l:self.clear_prev_branch()
    call l:self.project_prev_branch.store()
  endf

  fun! l:obj._session_locked() abort
    if l:self.project_session.locked()
      throw "'".l:self.project_session.name()."' session has been locked."
    endif
  endf

  fun! l:obj._lock_session() abort
    try
      call l:self.project_session.lock_session()
    catch
      throw "lock '".l:self.project_session.name()."' session failed."
    endtry
  endf

  fun! l:obj._set_session_name(session_name) abort
    let l:self._project_name = l:self.git.project()
    let l:self._session_name = a:session_name
    let l:self.project_session = git_switcher#project_session#new(l:self._project_name, l:self._session_name)
    let l:self.project_pev_branch = git_switcher#project_prev_branch#new(l:self._project_name, l:self._session_name)
  endf

  " private END

  fun! l:obj.clear_prev_branch() abort
    call l:self.project_prev_branch.destroy_all()
  endf

  fun! l:obj.unlock_sessions() abort
    try
      call l:self.project_session.unlock_sessions()
    catch
      throw 'unlock sessions failed.'
    endtry
  endf

  fun! l:obj.session_list() abort
    echo l:self.project_session.stored_session_list()
  endf

  fun! l:obj.prev_branch_name() abort
    echo l:self._prev_branch()
  endf

  fun! l:obj.branch() abort
    echo l:self.git.branch()
  endf

  fun! l:obj.merged_branch() abort
    echo l:self.git.merged_branch()
  endf

  fun! l:obj.remote_tracking_branch() abort
    echo l:self.git.remote_tracking_branch()
  endf

  fun! l:obj.branches() abort
    try
      return l:self.git.branches()
    catch
      return []
    endtry
  endf

  fun! l:obj.remote_only_branches() abort
    try
      return l:self.git.remote_only_branches()
    catch
      return []
    endtry
  endf

  fun! l:obj.simple_fetch_project() abort
    call l:self.git.fetch()
  endf

  fun! l:obj.fetch_project(bang) abort
    echo 'fetching remote.'
    if a:bang
      call l:self.git.async_fetch({'exit_msg': 'fetched.'})
    else
      call l:self.simple_fetch_project()
      redraw!
      echo 'fetched.'
    endif
  endf

  fun! l:obj.pull_current_branch(bang) abort
    echo "pulling '".l:self.git.current_branch()."' branch."

    if a:bang
      call l:self.git.async_pull_current_branch({'exit_msg': 'pulled.'})
    else
      call l:self.git.pull_current_branch()
      silent! checktime
      redraw!
      echo 'pulled.'
    endif
  endf

  fun! l:obj.save_session() abort
    if l:self._non_project_default_session() && confirm("save '".l:self.project_session.name()."'(non project default) session?", "&Yes\n&No", 0) != 1
      return 1
    endif

    call l:self._session_locked()
    call l:self.project_session.store()
    call l:self.nerdtree_state_handler.store(l:self.project_session)
    call l:self.tagbar_state_handler.store(l:self.project_session)
    echo "saved '".l:self.project_session.name()."' session."

    if !l:self.git.inside_work_tree() || (l:self.project_session.session_name() != l:self.git.current_branch())
      return 1
    endif

    call l:self.unlock_sessions()
    call l:self._lock_session()
  endf

  fun! l:obj.load_session() abort
    call l:self._session_locked()
    if !l:self.project_session.exists()
      throw "'".l:self.project_session.name()."' session file does not exist."
    endif

    call l:self.clear_state()
    call l:self.unlock_sessions()
    call l:self.project_session.restore()
    echo "loaded '".l:self.project_session.name()."' session."

    call l:self._lock_session()
  endf

  fun! l:obj.autoload_session() abort
    if !l:self.git.inside_work_tree() || !l:self.project_session.exists()
      return 1
    endif
    call l:self._session_locked()

    if l:self._autoload_enabled() || (l:self._autoload_enabled_with_confirmation() && confirm("load '".l:self.project_session.name()."' session?", "&Yes\n&No", 0) == 1)
      call l:self.load_session()
    end
  endf

  fun! l:obj.autodelete_sessions_if_branch_not_exists() abort
    if !l:self.git.inside_work_tree()
      return 1
    endif

    let l:bang = 0
    if l:self._autodelete_sessions_enabled() | let l:bang = 1 | end

    if l:self._autodelete_sessions_enabled() || l:self._autodelete_sessions_enabled_with_confirmation()
      call l:self.delete_sessions_if_branch_not_exists(l:bang)
      redraw!
    end
  endf

  fun! l:obj.move_to(bang, branch) abort
    if !a:bang && confirm("move '".l:self.git.current_branch()."' branch to '".a:branch."'?", "&Yes\n&No", 0) != 1
      return 1
    endif

    call l:self.git.move_to(a:branch)
    redraw!
    echo "moved to '".a:branch."' branch."
  endf

  fun! l:obj.remove(bang, branch) abort
    if !a:bang && confirm("remove '".a:branch."' branch?", "&Yes\n&No", 0) != 1
      return 1
    endif

    call l:self.git.remove(a:branch)
    redraw!
    echo "removed '".a:branch."' branch."
  endf

  fun! l:obj.switch(bang, source, branch) abort
    if !l:self.git.branch_exists(a:branch) && a:source ==# 'remote'
      if confirm("create '".a:branch."' branch from remote branch?", "&Yes\n&No", 0) != 1
        return 1
      endif

      call l:self.simple_fetch_project()
      call l:self.git.create_remote_trancking_branch(a:branch)
    elseif !l:self.git.branch_exists(a:branch) && a:source ==# 'local'
      if confirm("create '".a:branch."' branch based on '".l:self.git.current_branch()."'?", "&Yes\n&No", 0) != 1
        return 1
      endif

      call l:self.git.create_branch(a:branch)
    endif

    if !a:bang && (l:self._save_confirmation_enabled() && confirm("save '".l:self.project_session.name()."' session?", "&Yes\n&No", 0) == 1)
      redraw!
      call l:self.save_session()
    endif

    redraw!
    echo "switching to '".a:branch."' branch."

    call l:self.git.switch(a:branch)
    call l:self._refresh_prev_branch()
    call l:self._set_session_name(a:branch)

    if a:bang
      silent! checktime
      redraw!
      echo "switched to '".a:branch."' branch."
      return 1
    endif

    if l:self.project_session.exists() && (l:self._load_confirmation_enabled() && confirm("load '".l:self.project_session.name()."' session?", "&Yes\n&No", 0) == 1)
      call l:self.load_session()
      let l:res_message = "switched to '".a:branch."' branch and loaded session."
    else
      redraw!
      silent! checktime
      let l:res_message = "switched to '".a:branch."' branch."
    endif

    redraw!
    echo l:res_message
  endf

  fun! l:obj.switch_prev(bang) abort
    let l:prev_branch = l:self._prev_branch()

    if len(l:prev_branch) == 0
      throw 'previous branch does not exist.'
    endif

    if l:self._switch_prev_confirmation_enabled() && confirm("switch to '".l:prev_branch."' branch?", "&Yes\n&No", 0) != 1
      return 1
    endif

    call l:self.switch(a:bang, 'local', l:prev_branch)
  endf

  fun! l:obj.stored_session_names() abort
    return l:self.project_session.stored_session_names()
  endf

  fun! l:obj.stored_project_sessions() abort
    return map(l:self.stored_session_names(), 'git_switcher#project_session#new(l:self._project_name, v:val)')
  endf

  fun! l:obj.delete_session(...) abort
    let l:bang = 0
    if a:0 | let l:bang = a:1 | endif

    if !l:bang && confirm("delete '".l:self.project_session.name()."' session?", "&Yes\n&No", 0) != 1
      return 1
    endif

    call l:self.project_session.destroy()
  endf

  fun! l:obj.remove_merged_branches(...) abort
    let l:bang = 1
    if a:0 | let l:bang = a:1 | endif

    call l:self.simple_fetch_project()

    for l:merged_branch in l:self.git.merged_branches()
      if l:self.git.current_branch() ==# l:merged_branch
        continue
      endif

      if !l:bang && confirm("delete '".l:merged_branch."' branch?", "&Yes\n&No", 0) != 1
        continue
      endif

      call l:self.git.remove(l:merged_branch)
    endfor
  endf

  fun! l:obj.delete_sessions_if_branch_not_exists(...) abort
    let l:bang = 1
    if a:0 | let l:bang = a:1 | endif

    for l:project_session in l:self.stored_project_sessions()
      if l:self.git.branch_exists(l:project_session.session_name())
        continue
      endif

      if !l:bang && confirm("delete '".l:project_session.name()."' session?", "&Yes\n&No", 0) != 1
        continue
      endif

      call l:project_session.destroy()
    endfor
  endf

  fun! l:obj.clear_state() abort
    call l:self.state.delete_all_buffers()
    call l:self.unlock_sessions()
    redraw!
    echo 'cleared session state.'
  endf

  return l:obj
endf

fun! git_switcher#session_list()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.session_list()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#prev_branch_name()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.prev_branch_name()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#branch()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.branch()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#merged_branch()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.merged_branch()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#remote_tracking_branch()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.remote_tracking_branch()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#fetch_project(bang)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.fetch_project(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#pull_current_branch(bang)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.pull_current_branch(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#save_session(...)
  try
    let l:git_switcher = call('git_switcher#new', a:000)
    call l:git_switcher.save_session()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#load_session(...)
  try
    let l:git_switcher = call('git_switcher#new', a:000)
    call l:git_switcher.load_session()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#gsw_move(bang, branch)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.move_to(a:bang, a:branch)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#gsw_remove(bang, branch)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.remove(a:bang, a:branch)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#gsw(bang, branch)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.switch(a:bang, 'local', a:branch)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#gsw_remote(bang, branch)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.switch(a:bang, 'remote', a:branch)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#gsw_prev(bang)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.switch_prev(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#clear_stete()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.clear_state()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#delete_session(bang, branch)
  try
    let l:git_switcher = git_switcher#new(a:branch)
    call l:git_switcher.delete_session(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#remove_merged_branches(bang)
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.remove_merged_branches(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#delete_sessions_if_branch_not_exists(bang)
  try
    let l:git_switcher = git_switcher#new()
    return l:git_switcher.delete_sessions_if_branch_not_exists(a:bang)
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#autocmd_for_vim_enter()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.autodelete_sessions_if_branch_not_exists()
    call l:git_switcher.autoload_session()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#autocmd_for_vim_leave()
  try
    let l:git_switcher = git_switcher#new()
    call l:git_switcher.clear_prev_branch()
    call l:git_switcher.unlock_sessions()
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#_branches(...)
  try
    let l:git_switcher = git_switcher#new()
    return filter(l:git_switcher.branches(), 'v:val =~# "^'.fnameescape(a:1).'"')
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#_remote_only_branches(...)
  try
    let l:git_switcher = git_switcher#new()
    return filter(l:git_switcher.remote_only_branches(), 'v:val =~# "^'.fnameescape(a:1).'"')
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! git_switcher#_stored_session_names(...)
  try
    let l:git_switcher = git_switcher#new()
    return filter(l:git_switcher.stored_session_names(), 'v:val =~# "^'.fnameescape(a:1).'"')
  catch
    redraw!
    echo v:exception
  endtry
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
