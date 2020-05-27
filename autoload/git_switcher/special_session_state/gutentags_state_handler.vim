" File: autoload/git_switcher/special_session_state/gutentags_state_handler.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#special_session_state#gutentags_state_handler#new() abort
  let l:obj = {'_self': 'gutentags_state_handler'}

  " private

  fun! l:obj._open_work_space() abort
    execute 'silent! tabnew'
  endf

  fun! l:obj._close_work_space() abort
    execute 'silent! quit'
  endf

  " private END

  fun! l:obj.store(project_session) abort
    if !exists('g:gutentags_enabled')
      return 1
    endif

    let l:cursor_pos = getpos('.')
    let l:current_tab_number = tabpagenr()

    let l:session_file_lines = a:project_session.readfile()
    let l:gutentags_session_appended_lines = []

    call l:self._open_work_space()

    for l:line in l:session_file_lines
      if match(l:line, 'doautoall SessionLoadPost') != -1
        call add(l:gutentags_session_appended_lines, 'let g:gutentags_enabled = '.g:gutentags_enabled)
        call add(l:gutentags_session_appended_lines, 'doautoall SessionLoadPost')
      else
        call add(l:gutentags_session_appended_lines, l:line)
      endif
    endfor

    call l:self._close_work_space()

    call a:project_session.writefile(l:gutentags_session_appended_lines)

    execute 'tabnext '.l:current_tab_number
    call setpos('.', l:cursor_pos)
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
