# git-switcher.vim  

Switching session based on git branch.  

## Installation  

Install either with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/gmarik/Vundle.vim), [NeoBundle](https://github.com/Shougo/neobundle.vim), or other plugin manager.  

## Usage  

![git_switcher_example](https://raw.githubusercontent.com/wiki/ToruIwashita/git-switcher.vim/images/git_switcher_example_new.gif)  

### Commands  

##### - `Gsw`  

Save a session and load the specify session after switching the branch. If specified branch does not exist, switch the branch after creating.  

##### - `Gsw!`  

Switch branches. If specified branch does not exist, switch branches after creating.  

##### - `GswRemote`  

Save a session and load the specify session after checkout remote branch.  

##### - `GswRemote!`  

Checkout remote branch.  

##### - `GswSave`  

Save a session. If an argument is given, save it in the name.  

#####・`GswLoad`  

Load a session. If an argument is given, load it in the name.  

##### - `GswFetch`  

Call git fetch command.  

##### - `GswPull`  

Call git pull command.  

##### - `GswBranch`  

Call git branch command.  

##### - `GswBranchRemote`  

Call git branch command with --remotes option.  

##### - `GswSessionList`  

Show stored session list.  

##### - `GswClearSession`  

Clear a session by deleting buffers.  

##### - `GswDeleteSession`  

Delete the specified session after confirming.  

##### - `GswDeleteSession!`  

Delete the specified session immediately.  

##### - `GswDeleteSessionIfBranchDoesNotExist`  

Delete sessions there is no branch in the project, after comfirming.  

##### - `GswDeleteSessionIfBranchDoesNotExist!`  

Delete sessions there is no branch in the project.  

### Options  

##### - `g:gsw_sessions_dir`  

Location of session file storing directory. Default value is `~/.cache/vim/git_switcher`  

##### - `g:gsw_autoload_session`  

Load a session automaticaly when you open no name buffer. Default value is `no`  

 - `yes`: Automatic loading immediately.  
 - `confirm`: Automatic loading after confirming.  
 - `no`: Disable automatic loading.  

##### - `g:gsw_autodelete_sessions_if_branch_does_not_exist`  

Delete sessions automaticaly when you open no name buffer. Default value is `no`  

 - `yes`: Automatic deleting immediately.  
 - `confirm`: Automatic deleting after confirming.  
 - `no`: Disable automatic deleting.  

##### - `gsw_switch_autostash`  

Automatically create a temporary stash and apply it after switching branches.  
