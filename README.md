# git-switcher.vim  

Switching session based on git branch.  

## Installation  

Install either with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/gmarik/Vundle.vim), [NeoBundle](https://github.com/Shougo/neobundle.vim), or other plugin manager.  

## Usage  

![git_switcher_example](https://raw.githubusercontent.com/wiki/ToruIwashita/git-switcher.vim/images/git_switcher_example_new.gif)  

### Commands  

#####・`Gsw`  

Swich branch with save confirmation and load session. If specified branch does not exist, switch after creating branch.  

#####・`Gsw!`  

Swich branch. If specified branch does not exist, switch after creating branch.  

#####・`GswRemote`  

Clone remote branch with save confirmation and load session. If specified branch does not exist, switch after creating branch.  

#####・`GswRemote!`  

Clone remote branch and load session. If specified branch does not exist, switch after creating branch.  

#####・`GswSave`  

Save session. If receiving an argument, save session with that name.  

#####・`GswLoad`  

Load session. If receiving an argument, load session with that name.  

#####・`GswFetch`  

Call git fetch command.  

#####・`GswDeleteSession`  

Delete saved session.  

### Options  

#####・`g:gsw_sessions_dir`  

Location of session file storing directory. Default value is `~/.cache/vim/git_switcher`  

#####・`g:gsw_session_autoload`  

Load the session automaticaly when you open no name buffer. Default value is `no`  

 - `yes`: Automatic loading immediately.  
 - `confirm`: Automatic loading after confirming.  
 - `no`: Disable automatic loading.  
