" =================================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     http://github.com/VividVim/Vivid-Legacy.vim
" Readme:       http://github.com/VividVim/Vivid-Legacy.vim/blob/master/README.md
" Version:      0.10.7
" =================================================================================


" Plugin Commands
command! -nargs=+  -bar   Plugin
\ call vivid#config#bundle(<args>)

command! -nargs=* -bang -complete=custom,vivid#scripts#complete PluginInstall
\ call vivid#installer#new('!' == '<bang>', <f-args>)

"command! -nargs=? -bang -complete=custom,vivid#scripts#complete PluginSearch
"\ call vivid#scripts#all('!' == '<bang>', <q-args>)

command! -nargs=? -bang   PluginClean
\ call vivid#installer#clean('!' == '<bang>')

command! -nargs=0         PluginDocs
\ call vivid#installer#helptags(g:vivid#bundles)

" Aliases
command! -nargs=* -complete=custom,vivid#scripts#complete PluginUpdate PluginInstall! <args>


" Set up the signs used in the installer window. (See :help signs)
if (has('signs'))
  sign define Vv_error    text=!  texthl=Error
  sign define Vv_active   text=>  texthl=Comment
  sign define Vv_todate   text=.  texthl=Comment
  sign define Vv_new      text=+  texthl=Comment
  sign define Vv_updated  text=*  texthl=Comment
  sign define Vv_deleted  text=-  texthl=Comment
  sign define Vv_helptags text=H  texthl=Comment
  sign define Vv_pinned   text==  texthl=Comment
endif

" Set up Vivid.  This function has to be called from the users vimrc file.
" This will force Vim to source this file as a side effect which wil define
" the :Plugin command.  After calling this function the user can use the
" :Plugin command in the vimrc.  It is not possible to do this automatically
" because when loading the vimrc file no plugins where loaded yet.

function! vivid#prepare() abort
  set nocompatible
  filetype off
  if !exists("g:syntax_on")
    syntax enable
  endif
endfunction

function! vivid#finish() abort
  filetype plugin indent on
endfunction


" Alternative to vivid#rc, offers speed up by modifying rtp (RunTimePath) only when end()
" called later.
function! vivid#open(...) abort
  call vivid#prepare()
  let g:vivid#lazy_load = 1
  if a:0 > 0
    let g:vivid#bundle_dir = expand(a:1, 1)
  endif
  call vivid#config#init()
endfunction

" Finishes putting plugins on the rtp.
function! vivid#close(...) abort
  unlet g:vivid#lazy_load
  call vivid#config#activate_bundles()
  call vivid#finish()
endfunction


" Initialize some global variables used by Vivid.
let vivid#bundle_dir = expand('$HOME/.vim/bundle', 1)
let vivid#bundles = []
let vivid#lazy_load = 0
let vivid#log = []
let vivid#updated_bundles = []

