# git-switcher.vim  

Switching session based on git branch.  

## Installation  

Install either with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/gmarik/Vundle.vim), [NeoBundle](https://github.com/Shougo/neobundle.vim), or other plugin manager.  

## Usage  

![git_switcher_example](https://raw.githubusercontent.com/wiki/ToruIwashita/git-switcher.vim/images/git_switcher_example_new.gif)  

### Commands  

##### - `Gsw`  

Switch branches with save confirmation and load the session. If specified branch does not exist, switch after creating branch.  

##### - `Gsw!`  

Switch branches. If specified branch does not exist, switch branches after creating branch.  

##### - `GswRemote`  

Clone remote branch with save confirmation and load the session. If specified branch does not exist, switch branches after creating branch.  

##### - `GswRemote!`  

Clone remote branch and load the session. If specified branch does not exist, switch branches after creating branch.  

##### - `GswSave`  

Save a session. If receiving an argument, save a session with that name.  

#####・`GswLoad`  

Load a session. If receiving an argument, load a session with that name.  

##### - `GswFetch`  

Call git fetch command.  

##### - `GswClearSession`  

Clear the session by deleting the buffer.  

##### - `GswDeleteSession`  

Delete a saved session.  

### Options  

##### - `g:gsw_sessions_dir`  

Location of session file storing directory. Default value is `~/.cache/vim/git_switcher`  

##### - `g:gsw_session_autoload`  

Load the session automaticaly when you open no name buffer. Default value is `no`  

 - `yes`: Automatic loading immediately.  
 - `confirm`: Automatic loading after confirming.  
 - `no`: Disable automatic loading.  

##### - `gsw_switch_autostash`  

Automatically create a temporary stash and apply it in switching branches.  
