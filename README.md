# Vivid.vim

**Vivid is the Next-Gen Vim Plugin Manager**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v0.10.8-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)

Vivid is a fork of the Vundle plugin manager for Vim. Vivid aims to extend and simplify the features of Vundle, to make a more powerful Plugin manager.
Vivid's main goal is to become fully cross platform, so that it can work as expected on all systems and Vim derivatives, including Neovim and Windows.

If you find any bugs or errors, please feel free to submit an issue as I cannot test Vivid on every possible system for problems. I would in the future like to add multi-language support to Vivid, help would be greatly appreciated, especially since Google Translate is not entirely accurate a lot of the time. For more information on contributing to Vivid see the [contributing document] and ensure that you read and agree to the [Code of Conduct].

## About

[Vivid] allows you to...

* Configure your plugins right from your ``$MYVIMRC``,
* Install configured plugins (a.k.a. scripts/bundle),
* Update configured plugins,
* Clean up unused plugins,
* Run the above actions in a *single keypress* with interactive mode.

[Vivid] automatically...

* manages the [runtime path] of your installed scripts,
* regenerates [help tags] after installing and updating.

![Vivid Update Screen](screenshots/vivid-shot-01.png) <!-- move to imgur -->

## Quick Start

### Dependencies

Vivid requires that [Git] and Curl to be installed on your system, and [Vim] or [Neovim].

### Install Vivid

There are two main ways to install Vivid, default install, and Vundle emulation/replacement. Vivid has Vundle emulation support built into the core, this allows Vivid to act as a drop in replacement for Vundle.
   
1. To install Vivid the default way, place this at the very top of your ```$MYVIMRC```.

   ```vim
   " Example Vim Config File ($MYVIMRC)
   " ==================================

   " Brief help
   " ----------
   " :PluginList       - Lists all configured plugins
   " :PluginUpdate     - Update all plugins to latest versions
   " :PluginInstall    - Installs plugins; append `!` to update or just :PluginUpdate
   " :PluginClean      - Remove unused plugins; append `!` to auto-approve removal
   " :help vivid       - View documentation from within Vim


   set rtp+=~/.vim/bundle/Vivid.vim/ " Append Vivid to the runtimepath
   call vivid#open()
   " Input Plugins Below this Line

     " The following are examples of different formats supported.
     "Plugin 'tpope/vim-fugitive' " Plugin from GitHub
     "Plugin 'git://git.wincent.com/command-t.git' " Git plugin not on GitHub
     "Plugin 'file:///home/user/path/to/plugin' Local git plugins
     "Plugin 'rstacruz/sparkup', {'rtp': 'vim/'} " Plugin is in a GitHub subdirectory
     "Plugin 'ascenator/L9', {'name': 'newL9'} " Avoid naming confilics

   " Input Plugins Above this Line
   call vivid#close()

   " Continue Vimrc after this line
   ```

   Then if you are on a UNIX based system run this command: ```git clone https://github.com/axvr/Vivid.vim ~/.vim/bundle/Vivid.vim``` This will download the latest version of Vivid. After completing that move to the section titled "[Using Vivid]".
 
2. The second install method would be to replace Vundle with Vivid, you can do this by replacing ```set rtp+=~/.vim/bundle/Vundle.vim/``` with ```set rtp+=~/.vim/bundle/Vivid.vim/```, from your ```$MYVIMRC```. Then run ```git clone https://github.com/axvr/Vivid.vim ~/.vim/bundle/Vivid.vim```.


### Other things

#### Things that Vivid manages by default

Vivid will change these [Vim] settings automatically to avoid errors from missing items in the ```$MYVIMRC```

#### Vivid auto-install script

This can be placed at the top of a ```$MYVIMRC``` to install Vivid when on a UNIX based computer, which does not have Vivid installed already. This makes your ```$MYVIMRC``` file more portable, and allow for instant use on other systems.

```vim
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
```

#### Shell Notes 

Shell notes (If you don't know what this means, ignore this):

* Bash works out of the box,
* Zsh should work perfectly fine with Vivid,
* for those using Fish shell: add ``set shell=/bin/bash`` to the top of your ``$MYVIMRC``.


### Using Vivid and the $MYVIMRC file

#### Open $MYVIMRC

Launch ```vim``` then run ```:edit $MYVIMRC```

#### Load $MYVIMRC

Close Vim and reopen it, or run ```:source $MYVIMRC```

#### Install Plugins

Launch ``vim`` and run ``:PluginInstall``

To install from command line: ``vim +PluginInstall +qall``


#### Update Plugins

Launch ``vim`` and run ``:PluginUpdate``


#### Remove Plugins

Remove the plugin you wish to delete from your ```$MYVIMRC```, then run ```:source $MYVIMRC```, and finally: ```:PluginClean```


#### View Documentation

See the [``:help vivid``](https://github.com/axvr/Vivid.vim/blob/master/doc/vivid.txt) Vimdoc for more details.

See the [changelog]


## Attribution

To all of the [Vundle contributors], and the [Vivid contributors],  **Thank you!**

* Vivid was developed and tested with [Vim] 8.0 on Linux
* Vundle was developed and tested with [Vim] 7.3 on OS X, Linux and Windows
* Vivid follows the [KISS] principle, with a few exceptions which make it more
  powerful than any other vim plugin manager.


---


## TODO:
[Vivid] is a fork of Vundle, this has resulted in it becoming a major work in progress.

* [x] Restructure repository
* [x] Restructure files
* [x] Rebrand Vundle fork to Vivid
* [x] Rename components
* [x] Remove redundant code
* [x] Improve human readability of source
* [ ] Add full Neovim support ([in progress])
* [ ] Replace and modernise the old Vundle base ([in progress])
* [ ] Speed up and optimise the plugin manager ([in progress])
* [ ] Fix the bugs in Vundle base
* [x] Vundle backwards compatibility via emulation
* [ ] Improve Windows support ([in progress])
* [ ] Add GitLab support (maybe add BitBucket support) ([in progress])
* [ ] Add update and install progress bar (for YCM especially)
* [ ] Add support for switching and testing between http:// git:// & https:// ([in progress])
* [ ] Add support for Mercurial repos ([in progress])
* [x] Increase security and mitigate MITM attacks
* [ ] Allow users to choose to update using latest commit or tag ([in progress])
* [x] Comment all of the code ([in progress])
* [ ] Improve documentation ([in progress])
* [ ] Add multi-language support
* [x] Disconnect from Vundle upstream
* [ ] Fix plugin repo deletion bug where credentials are required ([in progress])
* [x] Make a Github 'organisation' for contributers to join & get commit access
* [x] Replace old README and vim help menu
* [x] Improve the test files from Vundle
* [x] Attempt to use ``https`` before ``http``
* [ ] Finish what Vundle set out to do:
  * [x] activate newly added bundles on `.vimrc` reload or after `:PluginInstall`
  * [x] ~use preview window for search results~ (removed search feature)
  * [x] Vim documentation
  * [x] put Vundle in `bundles/` too (will fix Vundle help)
  * [x] test files
  * [x] improve error handling
  * [ ] allow specifying revision/version?
  * [ ] handle dependencies
  * [x] ~show description in search results~ (removed search feature)
  * [x] ~search by description as well~ (removed search feature)
  * [ ] make it rock!
* [ ] And many more things


[Vivid]:https://github.com/axvr/Vivid.vim/
[Vundle]:https://github.com/VundleVim/Vundle.vim/
[changelog]:https://github.com/axvr/Vivid.vim/blob/master/CHANGELOG.md/
[Vim]:http://www.vim.org
[Neovim]:https://neovim.io/
[Git]:http://git-scm.com
[``git clone``]:http://gitref.org/creating/#clone
[KISS]:https://wikipedia.org/wiki/KISS_principle
[Vim scripts]:http://vim-scripts.org/vim/scripts.html
[help tags]:http://vimdoc.sourceforge.net/htmldoc/helphelp.html#:helptags
[runtime path]:http://vimdoc.sourceforge.net/htmldoc/options.html#%27runtimepath%27
[Vundle contributors]:https://github.com/VundleVim/Vundle.vim/graphs/contributors
[Vivid contributors]:https://github.com/axvr/Vivid.vim/graphs/contributors
[in progress]:https://github.com/axvr/Vivid.vim/
[Using Vivid]:https://github.com/axvr/Vivid.vim#using-vivid
[Code of Conduct]:https://github.com/axvr/Vivid.vim/blob/master/CODE_OF_CONDUCT.md
[contributing document]:https://github.com/axvr/Vivid.vim/blob/master/CONTRIBUTING.md

