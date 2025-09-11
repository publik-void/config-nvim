let g:slime_target = "tmux"

let g:slime_default_config = {
\ "socket_name": get(g:tmux, "socket", "default"),
\ "target_pane": "{last}"}

" I think it's better to let it ask, because it serves as a reminder that no
" pane has been set yet.
" let g:slime_dont_ask_default = 1

" May need to disable this for certain filetypes if their corresponding REPLs
" have issues with bracketed paste.
let g:slime_bracketed_paste = 1

" Get the pane ID from the pane that would be moved to by the `key` under my
" `tmux` key mappings.
function MyGetTmuxPaneIdByKey(key)
  let mappings = {
\   "h": "{left-of}",
\   "l": "{right-of}",
\   "j": "{down-of}",
\   "k": "{up-of}",
\   ";": "{last}"}
  let token = get(mappings, a:key, "")
  if token == ""
    error(join(["key mapping for `", a:key, "` unknown"]))
  endif
  let out = systemlist(
\   ["tmux", "display-message", "-p", "-t", token, "#{pane_id}"])
  let id = v:shell_error ? "" : get(out, 0, "")
  if id == ""
    error("tmux pane id could not be obtained")
  endif
  return id
endfunction

" Select target pane by key and write the selected pane into the config so that
" subsequent non-"directed" sends continue to send to that pane.
function MySlimeDirectedTmuxSend(key, command)
  let id = MyGetTmuxPaneIdByKey(a:key)

  if !exists("b:slime_config")
    let b:slime_config = copy(g:slime_default_config)
  endif

  let b:slime_config["target_pane"] = id

  call feedkeys(join([v:count ? v:count : "", "\<Plug>", a:command], ""))
endfunction

nmap <c-c>v <Plug>SlimeConfig

nmap <c-c>c <Plug>SlimeMotionSend
xmap <c-c>c <Plug>SlimeRegionSend
nmap <c-c><c-c> <Plug>SlimeLineSend

if v:version > 800 " NOTE: Version is a guess
  nmap <c-c>hc <cmd>call MySlimeDirectedTmuxSend("h", "SlimeMotionSend")<cr>
  nmap <c-c>lc <cmd>call MySlimeDirectedTmuxSend("l", "SlimeMotionSend")<cr>
  nmap <c-c>jc <cmd>call MySlimeDirectedTmuxSend("j", "SlimeMotionSend")<cr>
  nmap <c-c>kc <cmd>call MySlimeDirectedTmuxSend("k", "SlimeMotionSend")<cr>
  nmap <c-c>;c <cmd>call MySlimeDirectedTmuxSend(";", "SlimeMotionSend")<cr>
  xmap <c-c>hc <cmd>call MySlimeDirectedTmuxSend("h", "SlimeRegionSend")<cr>
  xmap <c-c>lc <cmd>call MySlimeDirectedTmuxSend("l", "SlimeRegionSend")<cr>
  xmap <c-c>jc <cmd>call MySlimeDirectedTmuxSend("j", "SlimeRegionSend")<cr>
  xmap <c-c>kc <cmd>call MySlimeDirectedTmuxSend("k", "SlimeRegionSend")<cr>
  xmap <c-c>;c <cmd>call MySlimeDirectedTmuxSend(";", "SlimeRegionSend")<cr>
  nmap <c-c>h<c-c> <cmd>call MySlimeDirectedTmuxSend("h", "SlimeLineSend")<cr>
  nmap <c-c>l<c-c> <cmd>call MySlimeDirectedTmuxSend("l", "SlimeLineSend")<cr>
  nmap <c-c>j<c-c> <cmd>call MySlimeDirectedTmuxSend("j", "SlimeLineSend")<cr>
  nmap <c-c>k<c-c> <cmd>call MySlimeDirectedTmuxSend("k", "SlimeLineSend")<cr>
  nmap <c-c>;<c-c> <cmd>call MySlimeDirectedTmuxSend(";", "SlimeLineSend")<cr>
else
  nmap <expr> <c-c>hc MySlimeDirectedTmuxSend("h", "SlimeMotionSend")
  nmap <expr> <c-c>lc MySlimeDirectedTmuxSend("l", "SlimeMotionSend")
  nmap <expr> <c-c>jc MySlimeDirectedTmuxSend("j", "SlimeMotionSend")
  nmap <expr> <c-c>kc MySlimeDirectedTmuxSend("k", "SlimeMotionSend")
  nmap <expr> <c-c>;c MySlimeDirectedTmuxSend(";", "SlimeMotionSend")
  xmap <expr> <c-c>hc MySlimeDirectedTmuxSend("h", "SlimeRegionSend")
  xmap <expr> <c-c>lc MySlimeDirectedTmuxSend("l", "SlimeRegionSend")
  xmap <expr> <c-c>jc MySlimeDirectedTmuxSend("j", "SlimeRegionSend")
  xmap <expr> <c-c>kc MySlimeDirectedTmuxSend("k", "SlimeRegionSend")
  xmap <expr> <c-c>;c MySlimeDirectedTmuxSend(";", "SlimeRegionSend")
  nmap <expr> <c-c>h<c-c> MySlimeDirectedTmuxSend("h", "SlimeLineSend")
  nmap <expr> <c-c>l<c-c> MySlimeDirectedTmuxSend("l", "SlimeLineSend")
  nmap <expr> <c-c>j<c-c> MySlimeDirectedTmuxSend("j", "SlimeLineSend")
  nmap <expr> <c-c>k<c-c> MySlimeDirectedTmuxSend("k", "SlimeLineSend")
  nmap <expr> <c-c>;<c-c> MySlimeDirectedTmuxSend(";", "SlimeLineSend")
endif

" There is also `SlimeCellSend`, but I wonder if the better way if I ever use
" code cells would be to have a motion that selects the whole cell, to be used
" with `SlimeMotionSend` as well as any other motion-compatible operations.
