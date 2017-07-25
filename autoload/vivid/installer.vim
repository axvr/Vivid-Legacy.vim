" ---------------------------------------------------------------------------
" Try to clone all new bundles given (or all bundles in g:vivid#bundles by
" default) to g:vivid#bundle_dir.  If a:bang is 1 it will also update all
" plugins (git pull).
"
" bang   -- 1 or 0
" ...    -- any number of bundle specifications (separate arguments)
" ---------------------------------------------------------------------------
function! vivid#installer#new(bang, ...) abort
  " No specific plugins are specified. Operate on all plugins.
  if a:0 == 0
    let bundles = g:vivid#bundles
    " Specific plugins are specified for update. Update them.
  elseif (a:bang)
    let bundles = filter(copy(g:vivid#bundles), 'index(a:000, v:val.name) > -1')
    " Specific plugins are specified for installation. Install them.
  else
    let bundles = map(copy(a:000), 'vivid#config#bundle(v:val, {})')
  endif

  if empty(bundles)
    echoerr 'No bundles were selected for operation'
    return
  endif

  let names = vivid#scripts#bundle_names(map(copy(bundles), 'v:val.name_spec'))
  call vivid#scripts#view('Installer',['" Installing plugins to '.expand(g:vivid#bundle_dir, 1)], names +  ['Helptags'])

  " This calls 'add' as a normal mode command. This is a buffer local mapping
  " defined in vivid#scripts#view(). The mapping will call a buffer local
  " command InstallPlugin which in turn will call vivid#installer#run() with
  " vivid#installer#install().
  call s:process(a:bang, (a:bang ? 'add!' : 'add'))

  call vivid#config#require(bundles)
endfunction


" ---------------------------------------------------------------------------
" Iterate over all lines in a Vivid window and execute the given command for
" every line.  Used by the installation and cleaning functions.
"
" bang   -- not used (FIXME)
" cmd    -- the (normal mode) command to execute for every line as a string
" ---------------------------------------------------------------------------
function! s:process(bang, cmd)
  let msg = ''

  redraw
  sleep 1m

  let lines = (getline('.','$')[0:-2])

  for line in lines
    redraw

    execute ':norm '.a:cmd

    if 'error' == s:last_status
      let msg = 'With errors; press l to view log'
    endif

    if 'updated' == s:last_status && empty(msg)
      let msg = 'Plugins updated; press u to view changelog'
    endif

    " goto next one
    execute ':+1'

    setl nomodified
  endfor

  redraw
  echo 'Done! '.msg
endfunction


" ---------------------------------------------------------------------------
" Call another function in the different Vivid windows.
"
" func_name -- the function to call
" name      -- the bundle name to call func_name for (string)
" ...       -- the argument to be used when calling func_name (only the first
"              optional argument will be used)
" return    -- the status returned by the call to func_name
" ---------------------------------------------------------------------------
function! vivid#installer#run(func_name, name, ...) abort
  let n = a:name

  echo 'Processing '.n
  call s:sign('active')

  sleep 1m

  let status = call(a:func_name, a:1)

  call s:sign(status)

  redraw

  if status == 'new'
    echo n.' installed'
  elseif status == 'updated'
    echo n.' updated'
  elseif status == 'todate'
    echo n.' already installed'
  elseif status == 'deleted'
    echo n.' deleted'
  elseif status == 'helptags'
    echo n.' regenerated'
  elseif status == 'pinned'
    echo n.' pinned'
  elseif status == 'error'
    echohl Error
    echo 'Error processing '.n
    echohl None
    sleep 1
  else
    throw 'ERROR: unknown status:'.status
  endif

  let s:last_status = status

  return status
endfunction


" ---------------------------------------------------------------------------
" Put a sign on the current line, indicating the status of the installation
" step.
"
" status -- string describing the status
" ---------------------------------------------------------------------------
function! s:sign(status)
  if (!has('signs'))
    return
  endif

  exe ":sign place ".line('.')." line=".line('.')." name=Vv_". a:status ." buffer=" . bufnr("%")
endfunction


" ---------------------------------------------------------------------------
" Install a plugin, then add it to the runtimepath and source it.
"
" bang   -- 1 or 0, passed directly to vivid#installer#install()
" name   -- the name of a bundle (string)
" return -- the return value from vivid#installer#install()
" ---------------------------------------------------------------------------
function! vivid#installer#install_and_require(bang, name) abort
  let result = vivid#installer#install(a:bang, a:name)
  let b = vivid#config#bundle(a:name, {})
  call vivid#installer#helptags([b])
  call vivid#config#require([b])
  return result
endfunction


" ---------------------------------------------------------------------------
" Install or update a bundle given by its name.
"
" bang   -- 1 or 0, passed directly to s:sync()
" name   -- the name of a bundle (string)
" return -- the return value from s:sync()
" ---------------------------------------------------------------------------
function! vivid#installer#install(bang, name) abort
  if !isdirectory(g:vivid#bundle_dir) | call mkdir(g:vivid#bundle_dir, 'p') | endif

  let n = substitute(a:name,"['".'"]\+','','g')
  let matched = filter(copy(g:vivid#bundles), 'v:val.name_spec == n')

  if len(matched) > 0
    let b = matched[0]
  else
    let b = vivid#config#init_bundle(a:name, {})
  endif

  return s:sync(a:bang, b)
endfunction


" ---------------------------------------------------------------------------
" Call :helptags for all bundles in g:vivid#bundles.
"
" return -- 'error' if an error occurred, else return 'helptags'
" ---------------------------------------------------------------------------
function! vivid#installer#docs() abort
  let error_count = vivid#installer#helptags(g:vivid#bundles)
  if error_count > 0
    return 'error'
  endif
  return 'helptags'
endfunction


" ---------------------------------------------------------------------------
" Call :helptags for a list of bundles.
"
" bundles -- a list of bundle dictionaries for which :helptags should be
"            called.
" return  -- the number of directories where :helptags failed
" ---------------------------------------------------------------------------
function! vivid#installer#helptags(bundles) abort
  let bundle_dirs = map(copy(a:bundles),'v:val.rtpath')
  let help_dirs = filter(bundle_dirs, 's:has_doc(v:val)')

  call s:log('')
  call s:log('Helptags:')

  let statuses = map(copy(help_dirs), 's:helptags(v:val)')
  let errors = filter(statuses, 'v:val == 0')

  call s:log('Helptags: '.len(help_dirs).' plugins processed')

  return len(errors)
endfunction


" ---------------------------------------------------------------------------
" List and remove all directories in the bundle directory which are not
" activated (added to the bundle list).
"
" bang   -- 0 if the user should be asked to confirm every deletion, 1 if they
"           should be removed unconditionally
" ---------------------------------------------------------------------------
function! vivid#installer#clean(bang) abort
  let bundle_dirs = map(copy(g:vivid#bundles), 'v:val.path()')
  let all_dirs = (v:version > 702 || (v:version == 702 && has("patch51")))
        \   ? split(globpath(g:vivid#bundle_dir, '*', 1), "\n")
        \   : split(globpath(g:vivid#bundle_dir, '*'), "\n")
  let x_dirs = filter(all_dirs, '0 > index(bundle_dirs, v:val)')

  if empty(x_dirs)
    let headers = ['" All clean!']
    let names = []
  else
    let headers = ['" Removing Plugins:']
    let names = vivid#scripts#bundle_names(map(copy(x_dirs), 'fnamemodify(v:val, ":t")'))
  end

  call vivid#scripts#view('clean', headers, names)
  redraw

  if (a:bang || empty(names))
    call s:process(a:bang, 'D')
  else
    call inputsave()
    let response = input('Continue? [Y/n]: ')
    call inputrestore()
    if (response =~? 'y' || response == '')
      call s:process(a:bang, 'D')
    endif
  endif
endfunction


" ---------------------------------------------------------------------------
" Delete to directory for a plugin.
"
" bang     -- not used
" dir_name -- the bundle directory to be deleted (as a string)
" return   -- 'error' if an error occurred, 'deleted' if the plugin folder was
"             successfully deleted
" ---------------------------------------------------------------------------
function! vivid#installer#delete(bang, dir_name) abort

  let cmd = ((has('win32') || has('win64')) && empty(matchstr(&shell, 'sh'))) ?
        \           'rmdir /S /Q' :
        \           'rm -rf'

  let bundle = vivid#config#init_bundle(a:dir_name, {})
  let cmd .= ' '.vivid#installer#shellesc(bundle.path())

  let out = s:system(cmd)

  call s:log('')
  call s:log('Plugin '.a:dir_name)
  call s:log(cmd, '$ ')
  call s:log(out, '> ')

  if 0 != v:shell_error
    return 'error'
  else
    return 'deleted'
  endif
endfunction


" ---------------------------------------------------------------------------
" Check if a bundled plugin has any documentation.
"
" rtp    -- a path (string) where the plugin is installed
" return -- 1 if some documentation was found, 0 otherwise
" ---------------------------------------------------------------------------
function! s:has_doc(rtp) abort
  return isdirectory(a:rtp.'/doc')
        \   && (!filereadable(a:rtp.'/doc/tags') || filewritable(a:rtp.'/doc/tags'))
        \   && (v:version > 702 || (v:version == 702 && has("patch51")))
        \     ? !(empty(glob(a:rtp.'/doc/*.txt', 1)) && empty(glob(a:rtp.'/doc/*.??x', 1)))
        \     : !(empty(glob(a:rtp.'/doc/*.txt')) && empty(glob(a:rtp.'/doc/*.??x')))
endfunction


" ---------------------------------------------------------------------------
" Update the helptags for a plugin.
"
" rtp    -- the path to the plugin's root directory (string)
" return -- 1 if :helptags succeeded, 0 otherwise
" ---------------------------------------------------------------------------
function! s:helptags(rtp) abort
  " it is important to keep trailing slash here
  let doc_path = resolve(a:rtp . '/doc/')
  call s:log(':helptags '.doc_path)
  try
    execute 'helptags ' . doc_path
  catch
    call s:log("> Error running :helptags ".doc_path)
    return 0
  endtry
  return 1
endfunction


" ---------------------------------------------------------------------------
" Get the URL for the remote called 'origin' on the repository that
" corresponds to a given bundle.
"
" bundle -- a bundle object to check the repository for
" return -- the URL for the origin remote (string)
" ---------------------------------------------------------------------------
function! s:get_current_origin_url(bundle) abort
  let cmd = 'cd '.vivid#installer#shellesc(a:bundle.path()).' && git config --get remote.origin.url'
  let cmd = vivid#installer#shellesc_cd(cmd)
  let out = s:strip(s:system(cmd))
  return out
endfunction


" ---------------------------------------------------------------------------
" Get a short sha of the HEAD of the repository for a given bundle
"
" bundle -- a bundle object
" return -- A 15 character log sha for the current HEAD
" ---------------------------------------------------------------------------
function! s:get_current_sha(bundle)
  let cmd = 'cd '.vivid#installer#shellesc(a:bundle.path()).' && git rev-parse HEAD'
  let cmd = vivid#installer#shellesc_cd(cmd)
  let out = s:system(cmd)[0:15]
  return out
endfunction


" ---------------------------------------------------------------------------
" Create the appropriate sync command to run according to the current state of
" the local repository (clone, pull, reset, etc).
"
" In the case of a pull (update), also return the current sha, so that we can
" later check that there has been an upgrade.
"
" bang   -- 0 if only new plugins should be installed, 1 if existing plugins
"           should be updated
" bundle -- a bundle object to create the sync command for
" return -- A list containing the command to run and the sha for the current
"           HEAD
" ---------------------------------------------------------------------------
function! s:make_sync_command(bang, bundle) abort
  let git_dir = expand(a:bundle.path().'/.git/', 1)
  if isdirectory(git_dir) || filereadable(expand(a:bundle.path().'/.git', 1))

    let current_origin_url = s:get_current_origin_url(a:bundle)
    if current_origin_url != a:bundle.uri
      call s:log('Plugin URI change detected for Plugin ' . a:bundle.name)
      call s:log('>  Plugin ' . a:bundle.name . ' old URI: ' . current_origin_url)
      call s:log('>  Plugin ' . a:bundle.name . ' new URI: ' . a:bundle.uri)
      " Directory names match but the origin remotes are not the same
      let cmd_parts = [
            \ 'cd '.vivid#installer#shellesc(a:bundle.path()) ,
            \ 'git remote set-url origin ' . vivid#installer#shellesc(a:bundle.uri),
            \ 'git fetch',
            \ 'git reset --hard origin/HEAD',
            \ 'git submodule update --init --recursive',
            \ ]
      let cmd = join(cmd_parts, ' && ')
      let cmd = vivid#installer#shellesc_cd(cmd)
      let initial_sha = ''
      return [cmd, initial_sha]
    endif

    if !(a:bang)
      " The repo exists, and no !, so leave as it is.
      return ['', '']
    endif

    let cmd_parts = [
          \ 'cd '.vivid#installer#shellesc(a:bundle.path()),
          \ 'git pull',
          \ 'git submodule update --init --recursive',
          \ ]
    let cmd = join(cmd_parts, ' && ')
    let cmd = vivid#installer#shellesc_cd(cmd)

    let initial_sha = s:get_current_sha(a:bundle)
  else
    let cmd = 'git clone --recursive '.vivid#installer#shellesc(a:bundle.uri).' '.vivid#installer#shellesc(a:bundle.path())
    let initial_sha = ''
  endif
  return [cmd, initial_sha]
endfunction


" ---------------------------------------------------------------------------
" Install or update a given bundle object with git.
"
" bang   -- 0 if only new plugins should be installed, 1 if existing plugins
"           should be updated
" bundle -- a bundle object (dictionary)
" return -- a string indicating the status of the bundle installation:
"            - todate  : Nothing was updated or the repository was up to date
"            - new     : The plugin was newly installed
"            - updated : Some changes where pulled via git
"            - error   : An error occurred in the shell command
"            - pinned  : The bundle is marked as pinned
" ---------------------------------------------------------------------------
function! s:sync(bang, bundle) abort
  " Do not sync if this bundle is pinned
  if a:bundle.is_pinned()
    return 'pinned'
  endif

  let [ cmd, initial_sha ] = s:make_sync_command(a:bang, a:bundle)
  if empty(cmd)
    return 'todate'
  endif

  let out = s:system(cmd)
  call s:log('')
  call s:log('Plugin '.a:bundle.name_spec)
  call s:log(cmd, '$ ')
  call s:log(out, '> ')

  if 0 != v:shell_error
    return 'error'
  end

  if empty(initial_sha)
    return 'new'
  endif

  let updated_sha = s:get_current_sha(a:bundle)

  if initial_sha == updated_sha
    return 'todate'
  endif

  call add(g:vivid#updated_bundles, [initial_sha, updated_sha, a:bundle])
  return 'updated'
endfunction


" ---------------------------------------------------------------------------
" Escape special characters in a string to be able to use it as a shell
" command with system().
"
" cmd    -- the string holding the shell command
" return -- a string with the relevant characters escaped
" ---------------------------------------------------------------------------
function! vivid#installer#shellesc(cmd) abort
  if ((has('win32') || has('win64')) && empty(matchstr(&shell, 'sh')))
    return '"' . substitute(a:cmd, '"', '\\"', 'g') . '"'
  endif
  return shellescape(a:cmd)
endfunction


" ---------------------------------------------------------------------------
" Fix a cd shell command to be used on Windows.
"
" cmd    -- the command to be fixed (string)
" return -- the fixed command (string)
" ---------------------------------------------------------------------------
function! vivid#installer#shellesc_cd(cmd) abort
  if ((has('win32') || has('win64')) && empty(matchstr(&shell, 'sh')))
    let cmd = substitute(a:cmd, '^cd ','cd /d ','')  " add /d switch to change drives
    return cmd
  else
    return a:cmd
  endif
endfunction


" ---------------------------------------------------------------------------
" Make a system call.  This can be used to change the way system calls
" are made during developing, without searching the whole code base for
" actual system() calls.
"
" cmd    -- the command passed to system() (string)
" return -- the return value from system()
" ---------------------------------------------------------------------------
function! s:system(cmd) abort
  return system(a:cmd)
endfunction


" ---------------------------------------------------------------------------
" Add a log message to Vivid's internal logging variable.
"
" str    -- the log message (string)
" prefix -- optional prefix for multi-line entries (string)
" return -- a:str
" ---------------------------------------------------------------------------
function! s:log(str, ...) abort
  let prefix = a:0 > 0 ? a:1 : ''
  let fmt = '%Y-%m-%d %H:%M:%S'
  let lines = split(a:str, '\n', 1)
  let time = strftime(fmt)
  let entry_prefix = '['. time .'] '. prefix
  for line in lines
    " Trim trailing whitespace
    let entry = substitute(entry_prefix . line, '\m\s\+$', '', '')
    call add(g:vivid#log, entry)
  endfor
  return a:str
endfunction


" ---------------------------------------------------------------------------
" Remove leading and trailing whitespace from a string
"
" str    -- The string to rid of trailing and leading spaces
" return -- A string stripped of side spaces
" ---------------------------------------------------------------------------
function! s:strip(str)
  return substitute(a:str, '\%^\_s*\(.\{-}\)\_s*\%$', '\1', '')
endfunction

" vim: set expandtab sts=2 ts=2 sw=2 tw=78 norl:
