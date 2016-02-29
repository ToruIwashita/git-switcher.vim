" git-switcher
" Author:  Toru Hoyano <toru.iwashita@gmail.com>
" License: This file is placed in the public domain.

command! -nargs=? -complete=customlist,git_switcher#git#_branches GswSave call git_switcher#save_session(<f-args>)
command! -nargs=? -complete=customlist,git_switcher#git#_branches GswLoad call git_switcher#load_session(<f-args>)
command! -bang -nargs=1 -complete=customlist,git_switcher#git#_branches Gsw call git_switcher#gsw(<f-args>,<bang>0)
