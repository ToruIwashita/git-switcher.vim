" File: autoload/git_switcher/git.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#git#new() abort
  let l:obj = {'_self': 'git'}

  " private

  fun! l:obj._exec_and_return_exit_code(cmd) abort
    call system('bash -c "'.l:self._self.' '.a:cmd.' >/dev/null 2>&1"')
    return v:shell_error
  endf

  fun! l:obj._exec_and_return_list_of_splited_stdout_with_exit_code(cmd) abort
    return add(split(system('bash -c "'.l:self._self.' '.a:cmd.'"'), "\n"), v:shell_error)
  endf

  fun! l:obj._exec(cmd) abort
    if l:self._exec_and_return_exit_code('rev-parse')
      throw 'failed because not a git repository.'
    endif

    let l:results = l:self._exec_and_return_list_of_splited_stdout_with_exit_code(a:cmd)
    let l:exit_code = remove(l:results, -1)
    let l:output = join(l:results, "\n")

    if l:exit_code
      throw 'failed to '.a:cmd."\n".l:output
    endif

    return l:output
  endf

  fun! l:obj._async_exec(cmd, exit_msg) abort
    if l:self._exec_and_return_exit_code('rev-parse')
      throw 'failed because not a git repository.'
    endif

    call job_start('bash -c "'.l:self._self.' '.a:cmd.' >/dev/null 2>&1"', {
      \ 'exit_cb': {
      \   channel, status -> [
      \     execute('checktime'),
      \     execute("if ".status." == 0 | echo '".a:exit_msg."' | else | echo 'failed to ".a:cmd.".' | endif", '')
      \   ]
      \ }
    \ })
  endf

  fun! l:obj._remote_tracking_branches() abort
    return filter(map(filter(split(l:self.remote_tracking_branch(), '\n'), "v:val !~# '->'"), 'matchstr(v:val, "^\\s*\\(origin/\\|\\)\\zs\\(.*\\)\\ze", 0)'), "v:val !=# ''")
  endf

  " private END

  fun! l:obj.fetch() abort
    call l:self._exec('fetch --prune')
  endf

  fun! l:obj.async_fetch(msg_dict) abort
    call l:self._async_exec('fetch --prune', a:msg_dict['exit_msg'])
  endf

  fun! l:obj.pull_current_branch() abort
    call l:self._exec('pull origin '.l:self.current_branch())
  endf

  fun! l:obj.async_pull_current_branch(msg_dict) abort
    call l:self._async_exec('pull origin '.l:self.current_branch(), a:msg_dict['exit_msg'])
  endf

  fun! l:obj.branch() abort
    return l:self._exec('branch')
  endf

  fun! l:obj.remote_tracking_branch() abort
    return l:self._exec('branch --remotes')
  endf

  fun! l:obj.merged_branch() abort
    return l:self._exec('branch --merged')
  endf

  fun! l:obj.branches() abort
    return filter(split(l:self.branch()), "v:val !=# '*'")
  endf

  fun! l:obj.merged_branches() abort
    return filter(split(l:self.merged_branch()), "v:val !=# '*'")
  endf

  fun! l:obj.remote_only_branches() abort
    let l:local_branches = l:self.branches()
    let l:remote_only_branches = []

    for l:remote_tracking_branch in l:self._remote_tracking_branches()
      if match(l:local_branches, '\<'.l:remote_tracking_branch.'\>') == -1
        call add(l:remote_only_branches, l:remote_tracking_branch)
      endif
    endfor

    return l:remote_only_branches
  endf

  fun! l:obj.current_branch() abort
    return l:self._exec('rev-parse --abbrev-ref HEAD')
  endf

  fun! l:obj.branch_exists(branch) abort
    return match(l:self.branches(), '\<'.a:branch.'\>') != -1
  endf

  fun! l:obj.create_branch(branch_key) abort
    if l:self.branch_exists(a:branch_key)
      throw "'".a:branch_key."' branch already exists."
    endif

    call l:self._exec('branch '.a:branch_key)
  endf

  fun! l:obj.create_remote_trancking_branch(branch) abort
    return l:self.create_branch(a:branch.' origin/'.a:branch)
  endf

  fun! l:obj.move_to(branch) abort
    if l:self.branch_exists(a:branch)
      throw "'".a:branch."' branch already exists."
    endif

    call l:self._exec('branch --move '.a:branch)
  endf

  fun! l:obj.remove(branch) abort
    if !l:self.branch_exists(a:branch)
      throw "'".a:branch."' branch does not exist."
    endif

    call l:self._exec('branch -D '.a:branch)
  endf

  fun! l:obj.switch(branch) abort
    if !l:self.branch_exists(a:branch)
      throw "'".a:branch."' branch not exists."
    endif

    call l:self._exec('checkout '.a:branch)
  endf

  fun! l:obj.project() abort
    return fnamemodify(l:self._exec('rev-parse --show-toplevel'), ':t')
  endf

  fun! l:obj.inside_work_tree() abort
    try
      call l:self._exec('rev-parse')
    catch
      return 0
    endtry

    return 1
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
