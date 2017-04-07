# Vivid.vim

**Vivid is the next generation of Vundle**

Vivid is a fork of the Vundle Vim Plugin manager. Vivid aims to extend the
features of Vundle, to make the most powerful Plugin manager, possible.
Vivid's main goal is to become fully cross platform, so that it can work as
expected on all systems and Vim derivatives, including Neovim and Windows.

## About

[Vivid] allows you to...

* Keep track of and [configure] your plugins right in the ``~/.vimrc``
* [Install] configured plugins (a.k.a. scripts/bundle)
* [Update] configured plugins
* [Search] by name all available [Vim scripts]
* [Clean] unused plugins up
* run the above actions in a *single keypress* with [interactive mode]

[Vivid] automatically...

* manages the [runtime path] of your installed scripts
* regenerates [help tags] after installing and updating

![Vundle-installer](http://i.imgur.com/Rueh7Cc.png)

## Quick Start

1. Introduction:

   Installation requires [Git] and triggers [``git clone``] for each configured repository to `~/.vim/bundle/` by default.
   Curl is required for search.

2. Configure Plugins:

  Put this at the top of your ``~/.vimrc`` to use Vivid. Remove plugins you don't need (some of them will not work), they are for illustration purposes. It does not have to be stricly at the top, but if it isn't Vim will give errors and will take longer to open.

  ```vim
  " Example Vim Config File (~/.vimrc)
  " ==================================

  " Brief help
  " ----------
  " :PluginList       - Lists all configured plugins
  " :PluginInstall    - Installs plugins; append `!` to update or just :PluginUpdate
  " :PluginSearch foo - Searches for foo; append `!` to refresh local cache
  " :PluginClean      - Remove unused plugins; append `!` to auto-approve removal
  " :help vivid       - View documentation from within Vim

  set nocompatible    " Remove Vi backwards compatibility
  syntax on           " Enable syntax highlighting
  filetype off        " Temporarily disable the 'filetype' setting

  " Auto Install Vivid and Plugins
  let vivid_checkfile=expand('~/.vim/bundle/Vivid.vim/test-files/checkfile.txt')
  if (!filereadable(vivid_checkfile))
    echo "Installing Vivid.vim & plugins"
    silent !git clone https://github.com/axvr/Vivid.vim.git ~/.vim/bundle/Vivid.vim
    :source $MYVIMRC
    :PluginInstall
    :source $MYVIMRC
    :q
  endif

  set rtp+=~/.vim/bundle/Vivid.vim/ " Append Vivid to the runtimepath
  call vivid#begin()
  " Input Plugins Below this Line

    Plugin 'axvr/Vivid.vim' " let Vivid manage Vivid (Do not remove)

    " The following are examples of different formats supported.
    Plugin 'tpope/vim-fugitive' " Plugin from GitHub
    Plugin 'L9' " Plugin from http://vim-scripts.org/vim/scripts.html
    Plugin 'git://git.wincent.com/command-t.git' " Git plugin not on GitHub
    Plugin 'file:///home/user/path/to/plugin' Local git plugins
    Plugin 'rstacruz/sparkup', {'rtp': 'vim/'} " Plugin is in a GitHub subdirectory
    Plugin 'ascenator/L9', {'name': 'newL9'} " Avoid naming confilics

  " Input Plugins Above this Line
  call vivid#end()
  filetype plugin indent on   " Enable 'filetype' seting

  " Continue Vimrc after this line
  ```

  NOTE: For those using the fish shell: add ``set shell=/bin/bash`` to the top of your ``~/.vimrc``

3. Install Plugins:

   Launch ``vim`` and run ``:PluginInstall``

   To install from command line: ``vim +PluginInstall +qall``


See the [``:help vivid``](https://github.com/axvr/Vivid.vim/blob/master/doc/vivid.txt) Vimdoc for more details.

See the [changelog]

*Thank you!*

* Vivid was developed and tested with [Vim] 8.0 on Linux
* Vundle was developed and tested with [Vim] 7.3 on OS X, Linux and Windows
* Vivid follows the [KISS] principle, with a few exceptions which make it more
  powerful than any other vim plugin manager.

## TODO:
[Vivid] is a fork of Vundle, this has resulted in it becoming a major work in progress.

* [x] Restructure repository
* [ ] Restructure files
* [x] Rebrand Vundle fork to Vivid
* [x] Rename components
* [ ] Remove redundant code
* [ ] Modularise the Vundle base
* [ ] Add full Neovim support
* [ ] Replace and modernise Vundle base
* [ ] Improve involvement from the community
* [ ] Speed up and optimise the plugin manager
* [ ] Fix all of the bugs in Vundle base
* [ ] Improve Windows support
* [ ] Add GitLab support (maybe add BitBucket support)
* [ ] Add update and install progress bar (for YCM especially)
* [ ] Add support for switching and testing between http:// git:// & https://
* [ ] Add support for Mercurial repos
* [ ] Increase security and mitigate MITM attacks
* [ ] Allow users to choose to update using latest commit or tag
* [ ] Comment all of the code
* [ ] Improve documentation
* [ ] Add multi-language support
* [ ] Disconnect from Vundle upstream
* [ ] Fix plugin repo deletion bug where credentials are required
* [ ] Make a Github 'organisation' for contributers to join & get commit access
* [ ] Replace old README and vim help menu
* [ ] Improve the test files from Vundle
* [x] Attempt to use ``https`` before ``http``
* [ ] Finish what Vundle set out to do:
  * [x] activate newly added bundles on `.vimrc` reload or after `:PluginInstall`
  * [x] use preview window for search results
  * [x] Vim documentation
  * [x] put Vundle in `bundles/` too (will fix Vundle help)
  * [x] tests
  * [x] improve error handling
  * [ ] allow specifying revision/version?
  * [ ] handle dependencies
  * [ ] show description in search results
  * [ ] search by description as well
  * [ ] make it rock!
* [ ] And many more things


[Vivid]:https://github.com/axvr/Vivid.vim/
[Vundle]:https://github.com/VundleVim/Vundle.vim/
[changelog]:https://github.com/axvr/Vivid.vim/blob/master/CHANGELOG.md/
[Vim]:http://www.vim.org
[Git]:http://git-scm.com
[``git clone``]:http://gitref.org/creating/#clone
[KISS]:https://wikipedia.org/wiki/KISS_principle
[Vim scripts]:http://vim-scripts.org/vim/scripts.html
[help tags]:http://vimdoc.sourceforge.net/htmldoc/helphelp.html#:helptags
[runtime path]:http://vimdoc.sourceforge.net/htmldoc/options.html#%27runtimepath%27

<!--

Old Vundle Vimrc Example:


   ```vim
   set nocompatible              " be iMproved, required
   filetype off                  " required

   " set the runtime path to include Vundle and initialize
   set rtp+=~/.vim/bundle/Vundle.vim
   call vundle#begin()
   " alternatively, pass a path where Vundle should install plugins
   "call vundle#begin('~/some/path/here')

   " let Vundle manage Vundle, required
   Plugin 'VundleVim/Vundle.vim'

   " The following are examples of different formats supported.
   " Keep Plugin commands between vundle#begin/end.
   " plugin on GitHub repo
   Plugin 'tpope/vim-fugitive'
   " plugin from http://vim-scripts.org/vim/scripts.html
   " Plugin 'L9'
   " Git plugin not hosted on GitHub
   Plugin 'git://git.wincent.com/command-t.git'
   " git repos on your local machine (i.e. when working on your own plugin)
   Plugin 'file:///home/gmarik/path/to/plugin'
   " The sparkup vim script is in a subdirectory of this repo called vim.
   " Pass the path to set the runtimepath properly.
   Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
   " Install L9 and avoid a Naming conflict if you've already installed a
   " different version somewhere else.
   " Plugin 'ascenator/L9', {'name': 'newL9'}

   " All of your Plugins must be added before the following line
   call vundle#end()            " required
   filetype plugin indent on    " required
   " To ignore plugin indent changes, instead use:
   "filetype plugin on
   "
   " Brief help
   " :PluginList       - lists configured plugins
   " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
   " :PluginSearch foo - searches for foo; append `!` to refresh local cache
   " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
   "
   " see :h vundle for more details or wiki for FAQ
   " Put your non-Plugin stuff after this line
   ```


[Windows setup]:https://github.com/VundleVim/Vundle.vim/wiki/Vundle-for-Windows
[FAQ]:https://github.com/VundleVim/Vundle.vim/wiki
[Tips]:https://github.com/VundleVim/Vundle.vim/wiki/Tips-and-Tricks
[configure]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L126-L233
[install]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L234-L254
[update]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L255-L265
[search]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L266-L295
[clean]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L303-L318
[interactive mode]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L319-L360
[interface change]:https://github.com/VundleVim/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L372-L396
-->
