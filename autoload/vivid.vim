" =============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     http://github.com/axvr/Vivid.vim
" Readme:       http://github.com/axvr/Vivid.vim/blob/master/README.md
" Version:      0.10.3
" =============================================================================


" Plugin Commands
com! -nargs=+  -bar   Plugin
\ call vivid#config#bundle(<args>)

com! -nargs=* -bang -complete=custom,vivid#scripts#complete PluginInstall
\ call vivid#installer#new('!' == '<bang>', <f-args>)

com! -nargs=? -bang -complete=custom,vivid#scripts#complete PluginSearch
\ call vivid#scripts#all('!' == '<bang>', <q-args>)

com! -nargs=0 -bang PluginList
\ call vivid#installer#list('!' == '<bang>')

com! -nargs=? -bang   PluginClean
\ call vivid#installer#clean('!' == '<bang>')

com! -nargs=0         PluginDocs
\ call vivid#installer#helptags(g:vivid#bundles)

" Aliases
com! -nargs=* -complete=custom,vivid#scripts#complete PluginUpdate PluginInstall! <args>

" These will be removed and replaced, they are currently here for reference
" purposes.
"
" Vundle Aliases
"com! -nargs=? -bang -complete=custom,vundle#scripts#complete VundleInstall PluginInstall<bang> <args>
"com! -nargs=? -bang -complete=custom,vundle#scripts#complete VundleSearch  PluginSearch<bang> <args>
"com! -nargs=? -bang                                          VundleClean   PluginClean<bang>
"com! -nargs=0                                                VundleDocs    PluginDocs
"com!                                                         VundleUpdate  PluginInstall!
"com! -nargs=*       -complete=custom,vundle#scripts#complete VundleUpdate  PluginInstall! <args>

" Deprecated Commands
"com! -nargs=+                                                Bundle        call vundle#config#bundle(<args>)
"com! -nargs=? -bang -complete=custom,vundle#scripts#complete BundleInstall PluginInstall<bang> <args>
"com! -nargs=? -bang -complete=custom,vundle#scripts#complete BundleSearch  PluginSearch<bang> <args>
"com! -nargs=0 -bang                                          BundleList    PluginList<bang>
"com! -nargs=? -bang                                          BundleClean   PluginClean<bang>
"com! -nargs=0                                                BundleDocs    PluginDocs
"com!                                                         BundleUpdate  PluginInstall!

" Set up the signs used in the installer window. (See :help signs)
if (has('signs'))
  sign define Vu_error    text=!  texthl=Error
  sign define Vu_active   text=>  texthl=Comment
  sign define Vu_todate   text=.  texthl=Comment
  sign define Vu_new      text=+  texthl=Comment
  sign define Vu_updated  text=*  texthl=Comment
  sign define Vu_deleted  text=-  texthl=Comment
  sign define Vu_helptags text=*  texthl=Comment
  sign define Vu_pinned   text==  texthl=Comment
endif


" Completely remove vivid#rc and replace fully with vivid#begin

" Set up Vivid.  This function has to be called from the users vimrc file.
" This will force Vim to source this file as a side effect which wil define
" the :Plugin command.  After calling this function the user can use the
" :Plugin command in the vimrc.  It is not possible to do this automatically
" because when loading the vimrc file no plugins where loaded yet.
func! vivid#rc(...) abort
  if a:0 > 0
    let g:vivid#bundle_dir = expand(a:1, 1)
  endif
  call vivid#config#init()
endf

" Alternative to vivid#rc, offers speed up by modifying rtp (RunTimePath) only when end()
" called later.
func! vivid#begin(...) abort
  let g:vivid#lazy_load = 1
  call call('vivid#rc', a:000)
endf

" Finishes putting plugins on the rtp.
func! vivid#end(...) abort
  unlet g:vivid#lazy_load
  call vivid#config#activate_bundles()
endf

" Initialize some global variables used by Vivid.
let vivid#bundle_dir = expand('$HOME/.vim/bundle', 1)
let vivid#bundles = []
let vivid#lazy_load = 0
let vivid#log = []
let vivid#updated_bundles = []

" vim: set expandtab sts=2 ts=2 sw=2 tw=78 norl:
