" ---------------------------------------------------------------------------
" Vundle Emulation
" ---------------------------------------------------------------------------


" Add backwards compatibility with Vundle
function! vundle#begin(...) abort
    call call('vivid#open', a:000)
endfunction

function! vundle#end(...) abort
    call call('vivid#close', a:000)
endfunction


" Vundle Aliases
com! -nargs=? -bang -complete=custom,vivid#scripts#complete VundleInstall PluginInstall<bang> <args>
com! -nargs=? -bang                                          VundleClean   PluginClean<bang>
com! -nargs=0                                                VundleDocs    PluginDocs
com!                                                         VundleUpdate  PluginInstall!
com! -nargs=*       -complete=custom,vivid#scripts#complete VundleUpdate  PluginInstall! <args>

" Deprecated Commands
com! -nargs=+                                                Bundle        call vivid#config#bundle(<args>)
com! -nargs=? -bang -complete=custom,vivid#scripts#complete BundleInstall PluginInstall<bang> <args>
com! -nargs=0 -bang                                          BundleList    PluginList<bang>
com! -nargs=? -bang                                          BundleClean   PluginClean<bang>
com! -nargs=0                                                BundleDocs    PluginDocs
com! BundleUpdate PluginInstall!
