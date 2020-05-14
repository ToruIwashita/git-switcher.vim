" File: autoload/git_switcher/special_session_state/tagbar_state_handler.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#special_session_state#tagbar_state_handler#new() abort
  let l:obj = {'_self': 'tagbar_state_handler'}

  " private

  fun! l:obj._open_work_space() abort
    execute 'silent! tabnew'
  endf

  fun! l:obj._close_work_space() abort
    execute 'silent! quit'
  endf

  " private END

  fun! l:obj.store(project_session) abort
    let l:cursor_pos = getpos('.')
    let l:current_tab_number = tabpagenr()

    let l:session_file_lines = a:project_session.readfile()
    let l:tagbar_session_appended_lines = []

    call l:self._open_work_space()

    for l:line in l:session_file_lines
      if match(l:line, 'file __Tagbar__') != -1
        call add(l:tagbar_session_appended_lines, 'file __Tagbar__.tmp')
        call add(l:tagbar_session_appended_lines, 'silent! bwipeout __Tagbar__.tmp')
        call add(l:tagbar_session_appended_lines, 'TagbarOpen')
      else
        call add(l:tagbar_session_appended_lines, l:line)
      endif
    endfor

    call l:self._close_work_space()

    call a:project_session.writefile(l:tagbar_session_appended_lines)

    execute 'tabnext '.l:current_tab_number
    call setpos('.', l:cursor_pos)
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
