" File: autoload/git_switcher/special_session_state/nerdtree_state_handler.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! git_switcher#special_session_state#nerdtree_state_handler#new() abort
  let l:obj = {'_self': 'nerdtree_state_handler'}

  " private

  fun! l:obj._open_work_space() abort
    execute 'silent! tabnew'
  endf

  fun! l:obj._close_work_space() abort
    execute 'silent! quit'
  endf

  fun! l:obj._edit_buffer(buffer_number) abort
    execute 'silent! buffer' a:buffer_number
  endf

  fun! l:obj._extract_nerdtree_buffer_number(buffer_name) abort
    for l:buffer_number in range(1, bufnr('$'))
      if !bufexists(l:buffer_number)
        continue
      endif

      if bufname(l:buffer_number) ==# a:buffer_name
        return l:buffer_number
      endif
    endfor
  endf

  fun! l:obj._edit_nerdtree_buffer(nerdtree_file) abort
    let l:nerdtree_buffer_number = l:self._extract_nerdtree_buffer_number(a:nerdtree_file)
    call l:self._edit_buffer(l:nerdtree_buffer_number)
  endf

  fun! l:obj._extract_nerdtree_root_path(nerdtree_file) abort
    call l:self._edit_nerdtree_buffer(a:nerdtree_file)
    return fnameescape(b:NERDTreeRoot.path.str())
  endf

  " private END

  fun! l:obj.store(project_session) abort
    let l:cursor_pos = getpos('.')
    let l:current_tab_number = tabpagenr()

    let l:session_file_lines = a:project_session.readfile()
    let l:nerdtree_session_appended_lines = []

    call l:self._open_work_space()

    for l:line in l:session_file_lines
      if match(l:line, 'file NERD_tree_') != -1
        let l:nerdtree_file = matchstr(l:line, 'NERD_tree_.*')
        let l:nerdtree_root_path = l:self._extract_nerdtree_root_path(l:nerdtree_file)

        call add(l:nerdtree_session_appended_lines, l:line)
        call add(l:nerdtree_session_appended_lines, 'bwipeout '.l:nerdtree_file)
        call add(l:nerdtree_session_appended_lines, 'NERDTree '.l:nerdtree_root_path)
      else
        call add(l:nerdtree_session_appended_lines, l:line)
      endif
    endfor

    call l:self._close_work_space()

    call a:project_session.writefile(l:nerdtree_session_appended_lines)

    execute 'tabnext '.l:current_tab_number
    call setpos('.', l:cursor_pos)
  endf

  return l:obj
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
