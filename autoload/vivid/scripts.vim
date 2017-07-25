" ---------------------------------------------------------------------------
" Complete names for bundles in the command line.
"
" a, c, d -- see :h command-completion-custom
" return  -- all valid plugin names from vim-scripts.org as completion
"            candidates, or all installed plugin names when running an 'Update
"            variant'. see also :h command-completion-custom
" ---------------------------------------------------------------------------
function! vivid#scripts#complete(a,c,d)
  if match(a:c, '\v^%(Plugin|Vivid)%(Install!|Update)') == 0
    " Only installed plugins if updating
    return join(map(copy(g:vivid#bundles), 'v:val.name'), "\n")
  else
    " Or all known plugins otherwise
    return join(s:load_scripts(0),"\n")
  endif
endfunction


" ---------------------------------------------------------------------------
" View the logfile after an update or installation.
" ---------------------------------------------------------------------------
function! s:view_log()
  if !exists('s:log_file')
    let s:log_file = tempname()
  endif

  if bufloaded(s:log_file)
    execute 'silent bdelete' s:log_file
  endif
  call writefile(g:vivid#log, s:log_file)
  execute 'silent pedit ' . s:log_file
  set bufhidden=wipe
  setl buftype=nofile
  setl noswapfile
  setl ro noma

  wincmd P | wincmd H
endfunction


" ---------------------------------------------------------------------------
" Parse the output from git log after an update to create a change log for the
" user.
" ---------------------------------------------------------------------------
function! s:create_changelog() abort
  let changelog = ['Updated Plugins:']
  for bundle_data in g:vivid#updated_bundles
    let initial_sha = bundle_data[0]
    let updated_sha = bundle_data[1]
    let bundle      = bundle_data[2]

    let cmd = 'cd '.vivid#installer#shellesc(bundle.path()).
          \              ' && git log --pretty=format:"%s   %an, %ar" --graph '.
          \               initial_sha.'..'.updated_sha

    let cmd = vivid#installer#shellesc_cd(cmd)

    let updates = system(cmd)

    call add(changelog, '')
    call add(changelog, 'Updated Plugin: '.bundle.name)

    if bundle.uri =~ "https://github.com"
      call add(changelog, 'Compare at: '.bundle.uri[0:-5].'/compare/'.initial_sha.'...'.updated_sha)
    endif

    for update in split(updates, '\n')
      let update = substitute(update, '\s\+$', '', '')
      call add(changelog, '  '.update)
    endfor
  endfor
  return changelog
endfunction


" ---------------------------------------------------------------------------
" View the change log after an update or installation.
" ---------------------------------------------------------------------------
function! s:view_changelog()
  if !exists('s:changelog_file')
    let s:changelog_file = tempname()
  endif

  if bufloaded(s:changelog_file)
    execute 'silent bdelete' s:changelog_file
  endif
  call writefile(s:create_changelog(), s:changelog_file)
  execute 'silent pedit' s:changelog_file
  set bufhidden=wipe
  setl buftype=nofile
  setl noswapfile
  setl ro noma
  setfiletype vividlog

  wincmd P | wincmd H
endfunction


" ---------------------------------------------------------------------------
" Create a list of 'Plugin ...' lines from a list of bundle names.
"
" names  -- a list of names (strings) of plugins
" return -- a list of 'Plugin ...' lines suitable to be written to a buffer
" ---------------------------------------------------------------------------
function! vivid#scripts#bundle_names(names)
  return map(copy(a:names), ' printf("Plugin ' ."'%s'".'", v:val) ')
endfunction


" ---------------------------------------------------------------------------
" Open a buffer to display information to the user.  Several special commands
" are defined in the new buffer.
"
" title   -- a title for the new buffer
" headers -- a list of header lines to be displayed at the top of the buffer
" results -- the main information to be displayed in the buffer (list of
"            strings)
" ---------------------------------------------------------------------------
function! vivid#scripts#view(title, headers, results)
  if exists('s:view') && bufloaded(s:view)
    execute s:view.'bd!'
  endif

  execute 'silent pedit [Vivid] '.a:title

  wincmd P | wincmd H

  let s:view = bufnr('%')
  "
  " make buffer modifiable
  " to append without errors
  set modifiable

  call append(0, a:headers + a:results)
  setl buftype=nofile
  setl noswapfile
  set bufhidden=wipe

  setl cursorline
  setl nonu ro noma
  if (exists('&relativenumber')) | setl norelativenumber | endif

  setl ft=vivid
  setl syntax=vim
  syntax keyword vimCommand Plugin
  syntax keyword vimCommand Bundle
  syntax keyword vimCommand Helptags

  command!  -buffer -bang -nargs=1 DeletePlugin
        \ call vivid#installer#run('vivid#installer#delete', split(<q-args>,',')[0], ['!' == '<bang>', <args>])

  command!  -buffer -bang -nargs=? InstallAndRequirePlugin
        \ call vivid#installer#run('vivid#installer#install_and_require', split(<q-args>,',')[0], ['!' == '<bang>', <q-args>])

  command!  -buffer -bang -nargs=? InstallPlugin
        \ call vivid#installer#run('vivid#installer#install', split(<q-args>,',')[0], ['!' == '<bang>', <q-args>])

  command!  -buffer -bang -nargs=0 InstallHelptags
        \ call vivid#installer#run('vivid#installer#docs', 'helptags', [])

  command!  -buffer -nargs=0 VividLog call s:view_log()

  command!  -buffer -nargs=0 VividChangelog call s:view_changelog()

  nnoremap <silent> <buffer> q :silent bd!<CR>
  nnoremap <silent> <buffer> D :execute 'Delete'.getline('.')<CR>

  nnoremap <silent> <buffer> add  :execute 'Install'.getline('.')<CR>
  nnoremap <silent> <buffer> add! :execute 'Install'.substitute(getline('.'), '^Plugin ', 'Plugin! ', '')<CR>

  nnoremap <silent> <buffer> i :execute 'InstallAndRequire'.getline('.')<CR>
  nnoremap <silent> <buffer> I :execute 'InstallAndRequire'.substitute(getline('.'), '^Plugin ', 'Plugin! ', '')<CR>

  nnoremap <silent> <buffer> l :VividLog<CR>
  nnoremap <silent> <buffer> u :VividChangelog<CR>
  nnoremap <silent> <buffer> h :h vivid<CR>
  nnoremap <silent> <buffer> ? :h vivid<CR>

  nnoremap <silent> <buffer> c :PluginClean<CR>
  nnoremap <silent> <buffer> C :PluginClean!<CR>

  nnoremap <silent> <buffer> R :call vivid#scripts#reload()<CR>

  " goto first line after headers
  execute ':'.(len(a:headers) + 1)
endfunction


" vim: set expandtab sts=2 ts=2 sw=2 tw=78 norl:
