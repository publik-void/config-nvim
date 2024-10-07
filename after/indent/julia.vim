if !exists("g:my_features") ||
\ g:my_features["native_filetype_plugins_overrides"]

" I don't like the way Vim indents Julia code. At the time of writing this
" (2024-10-07), the indent file for Julia defines a function called
" `GetJuliaIndent` which is used with `indentexpr` to tell Vim the "correct"
" column to indent to. This is the way it's usually done in Vim and it's all
" great, except that I tend to prefer another indentation style as what this
" function outputs. I don't have the time to rewrite the whole function, and
" fully disabling it would (probably?) result in the loss of some indenting
" functionality that I would like to keep. (And who knows, maybe it will be
" improved in the future anyway. Then again, it might be part of some style
" guide or something). However, what I can do is remove some entries for the
" setting `indentkeys`, so that at least, the suggested indentation isn't
" performed in some cases where I usually don't want it. I think my biggest
" issue has been that I would have to re-align a whole line to my preference
" whenever I was closing some parenthesis.

set indentkeys-=),],}

endif

