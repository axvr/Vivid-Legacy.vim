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
