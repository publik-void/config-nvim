" (the following line is a modeline)
" vim: foldmethod=marker

" NOTE: As a summary for the below notes: Getting iTerm2, tmux and Neovim (and
" possibly also other terminals and SSH/Mosh) to play nicely together so that
" the `background` option is always synchronized automatically is something
" people are definitely working on here and there, but it seems like the state
" of things is not quite ideal at the moment. I'll try to cover some reasonable
" cases but may have to set `background` manually in some instances.
" NOTE: Setting `background` should be done automatically by Neovim. This seems
" to depend on some `autocmd`, so deleting all autocommands in the beginning of
" the `.vimrc` file (like some do) breaks it. The detection uses an OSC11 escape
" sequence, which is basically a query to the Terminal about its background
" color.
" NOTE: iTerm2 sends `SIGWINCH` on profile changes and Neovim has an `autocmd
" Signal SIGWINCH`. I don't know if `SIGWINCH` triggers re-detection of
" background color already or if an extra `autocmd` needs to be added here.
" Also, I can't even get any such autocommand to work with my setup…
" NOTE: The automatic detection does not work inside `tmux`, as `tmux` does not
" respond to the OSC11 escape sequence. This is because `tmux` could be running
" in several terminals simultaneously. If the background color in `tmux` was set
" by the user, it does respond, but this means I would then need to manage the
" synchronization of `tmux`'s background color with the terminal's colors, which
" seems unnecessarily non-elegant and error-prone.
" NOTE: Neovim removed some code that used the environment variable `COLORFGBG`
" for detecting a light or dark background. This is unfortunate, as it should be
" possible to propagate this variable through `tmux`, `ssh`, etc. Still, another
" problem is that the variable won't be updated on changes.
" NOTE: As of 2023-07, the solution to get iTerm2 color presets to automatically
" change based on macOS's dark mode setting involves using a Python script that
" hooks into iTerm2's Python runtime. I could imagine that adapting such a
" script appropriately could allow me to also update the background settings of
" any Neovim child processes accordingly. However, I kind of expect some of
" these things to be sorted out over the coming years anyway, so I am not sure
" if I want to put in the effort of creating some hacky "solution" now.

" Let's put this into a function that can be extended with OSC11 and other
" utilities if I feel the need, and can perhaps be called on certain triggers.
function AttemptBackgroundDetect()
  if empty($COLORFGBG)
    set background=light
  else
    let [l:fg, l:bg] = split($COLORFGBG, ';')
    " So, what to include here and what not? Let's say white and bright colors
    " except bright black.
    let l:light_colors = ['7', '9', '10', '11', '12', '13', '14', '15']
    if index(l:light_colors, l:bg) >= 0
      set background=light
    else
      set background=dark
    endif
  endif
endfunction

" Run it once, now
call AttemptBackgroundDetect()

" And add it as an `autocmd`
augroup MyBackgroundDetect
  if has("nvim-0.7")
    " NOTE: the `++nested` is needed to re-apply the color scheme in response
    " to the `background` option's value changing
    autocmd Signal SIGWINCH ++nested call AttemptBackgroundDetect()
  endif

  "" These are a sad workaround because SIGWINCH doesn't seem to work for me
  "autocmd CursorHold * ++nested call AttemptBackgroundDetect()
  "autocmd CursorHoldI * ++nested call AttemptBackgroundDetect()
augroup END

