# git-switcher.vim  

git-switcher provide the save and load of the session based on the switching branches. If even outside the git working directory, management of session is possible.  

## Installation  

Install either with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/gmarik/Vundle.vim), [NeoBundle](https://github.com/Shougo/neobundle.vim), or other plugin manager.  

## Usage  

![git_switcher_example](https://raw.githubusercontent.com/wiki/ToruIwashita/git-switcher.vim/images/git_switcher_example_new.gif)  

### Commands  

##### - `Gsw[!]`  

Switch branches. When switching branches, If the session that the same name as the branch has been saved, the session is loaded. With a '!' bang, it only switch branches. If there is no switching destination branch, create new branch and switch to it. This command is equipped with branch names completion.  

##### - `GswRemote[!]`  

Checkout a remote branch. At that time, if the session that the same name as the remote branch has been saved, the session is loaded. With a '!' bang, it only checkout a remote branch. This command is equipped with remote branch names completion.  

##### - `GswSave`  

If this command is run with no arguments, then save the session in the current working branch name. With an argument, then save the given string as the session name. This command is equipped with session names completion that has already been saved. In addition, this command will also work on the directory that are not managed by git, that case is to save the session using `g:gsw_non_project_sessions_dir` and `g:gsw_non_project_default_session_name` option.  

#####・`GswLoad`  

If this command is run with no arguments, then load the session in the current working branch name. With an argument, then load the given string as the session name. This command is equipped with saved session names completion. In addition, this command will also work on the directory that are not managed by git, that case is to load the session using `g:gsw_non_project_sessions_dir` and `g:gsw_non_project_default_session_name` option.  

##### - `GswFetch`  

Execute git fetch.  

##### - `GswPull`  

Execute git pull.  

##### - `GswBranch`  

This command display a list of branch in the local repositry.  

##### - `GswBranchRemote`  

This command display a list of branch in the remote repositry.  

##### - `GswSessionList`  

This command display a list of saved session names.  

##### - `GswClearState`  

This command initialize Vim's window, tab, buffer.  

##### - `GswDeleteSession[!]`  

This command removes the specified session. This command is equipped with saved session names completion.  

##### - `GswDeleteSessionIfBranchDoesNotExist[!]`  

This command removes saved sessions there is no branch of the same name in the local repositry.  

### Options  

##### - `g:gsw_sessions_dir`  

Directory path where saving the session.  

Default: `g:gsw_sessions_dir = $HOME.'/.cache/vim/git_switcher'`  

##### - `g:gsw_non_project_sessions_dir`  

This is the project (directory) name to use when saving the session outside of the repository.  

Default: `g:gsw_non_project_sessions_dir = 'non_project'`  

##### - `g:gsw_non_project_default_session_name`  

This is the default session name to use when saving the session outside of the repository.  

Default: `g:gsw_non_project_default_session_name = 'default'`  

##### - `g:gsw_save_session_confirm`  

It is setting of whether or not to confirm the save of the session when the Gsw command is executed.  

 - `yes`: Enable the save confrimation.  
 - `no`: Disable the save confrimation.  

Default: `g:gsw_save_session_confirm = 'yes'`  

##### - `g:gsw_autoload_session`  

Session automatic load settings on startup. It is on the git repository to load the session with the same name as the working branch name, is outside the git repository to load the default session that is specified in the `g:gsw_non_project_default_session_name`.  

 - `yes`: Automatic loading immediately.  
 - `confirm`: Automatic loading after confirming.  
 - `no`: Disable automatic loading.  

Default: `g:gsw_autoload_session = 'no'`  

##### - `g:gsw_autodelete_sessions_if_branch_not_exist`  

During start-up, to remove saved sessions there is no branch of the same name in the local repositry.  

 - `yes`: Automatic deleting immediately.  
 - `confirm`: Automatic deleting after confirming.  
 - `no`: Disable automatic deleting.  

Default: `g:gsw_autodelete_sessions_if_branch_not_exist = 'no'`  
