" ---------------------------------------------------------------------------
" Syntax highlighting for the line which identifies the plugin.
" ---------------------------------------------------------------------------
syntax match VividPluginName '\v(^Updated Plugin: )@<=.*$'
highlight link VividPluginName Keyword

" ---------------------------------------------------------------------------
" Syntax highlighting for the 'compare at' line of each plugin.
" ---------------------------------------------------------------------------
syntax region VividCompareLine start='\v^Compare at: https:' end='\v\n'
    \ contains=VividCompareUrl
syntax match VividCompareUrl '\vhttps:\S+'
highlight link VividCompareLine Comment
highlight link VividCompareUrl Underlined

" ---------------------------------------------------------------------------
" Syntax highlighting for individual commits.
" ---------------------------------------------------------------------------
" The main commit line.
" Note that this regex is intimately related to the one for VividCommitTree,
" and the two should be changed in sync.
syntax match VividCommitLine '\v(^  [|*]( *[\\|/\*])* )@<=[^*|].*$'
    \ contains=VividCommitMerge,VividCommitUser,VividCommitTime
highlight link VividCommitLine String
" Sub-regions inside the commit message.
syntax match VividCommitMerge '\v Merge pull request #\d+.*'
syntax match VividCommitUser '\v(   )@<=\S+( \S+)*(, \d+ \w+ ago$)@='
syntax match VividCommitTime '\v(, )@<=\d+ \w+ ago$'
highlight link VividCommitMerge Ignore
highlight link VividCommitUser Identifier
highlight link VividCommitTime Comment
" The git history DAG markers are outside of the main commit line region.
" Note that this regex is intimately related to the one for VividCommitLine,
" and the two should be changed in sync.
syntax match VividCommitTree '\v(^  )@<=[|*]( *[\\|/\*])*'
highlight link VividCommitTree Label
