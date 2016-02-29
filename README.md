# git-switcher.vim

Switching session based on git branch.

## Installation

Install either with [Pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/gmarik/Vundle.vim), [NeoBundle](https://github.com/Shougo/neobundle.vim), or other plugin manager.

## Usage

![git_switcher_example](https://raw.githubusercontent.com/wiki/ToruIwashita/git-switcher.vim/images/git_switcher_example.gif)

### Commands

 - `Gsw` Swich branch with a save confirmation and load session
 - `Gsw!` Swich branch and load session
 - `GswSave` Save session
 - `GswLoad` Load session

### Options

#### `g:gsw_sessions_dir_path`

Location of session file storing directory. Default value is `~/.cache/vim/git_switcher/`

