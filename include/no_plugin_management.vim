" (the following line is a modeline)
" vim: foldmethod=marker

" Let's add putative plugin locations, as these can still be used without
" plugin management.

let s:config_dir = has("nvim-0.3") ? stdpath("config") :
\ has("nvim") ? (
\   has("win32") || has("win64") ? expand("$HOME/AppData/Local/nvim") :
\   expand("$HOME/.config/nvim")) : (
\   has("win32") || has("win64") ? expand("$HOME/vimfiles") :
\   expand("$HOME/.vim"))

let s:my_plugins_dir_basename = "plugins"
let s:my_plugins_dir =
\ StrCat(s:config_dir, "/", s:my_plugins_dir_basename, "/")

let s:plugin_root_dirs = [
\ s:my_plugins_dir,
\ expand("$HOME/.local/share/nvim/lazy/"),
\ StrCat(expand(g:my_init_path), s:my_plugins_dir_basename, "/"),
\ StrCat(expand("$HOME/.vim/"), s:my_plugins_dir_basename, "/")]

let s:plugin_root_dirs = filter(s:plugin_root_dirs, "isdirectory(v:val)")

function s:AddPluginDirIfExists(plugin)
  if has_key(a:plugin, "options") &&
    \ has_key(a:plugin["options"], "dependencies")
    for dependency in a:plugin["options"]["dependencies"]
      call s:AddPluginDirIfExists(dependency)
    endfor
  endif

  for plugin_root_dir in s:plugin_root_dirs
    let plugin_dir = StrCat(plugin_root_dir, a:plugin["name"])
    if isdirectory(plugin_dir)
      let &runtimepath = StrCat(&runtimepath, ",", plugin_dir)
      break
    endif
  endfor
endfunction

for [feature, plugin] in items(g:my_plugins)
  if g:my_features[feature] &&
    \ (!has_key(plugin, "options") ||
      \ !has_key(plugin["options"], "enabled") ||
      \ plugin["options"]["enabled"])
    call s:AddPluginDirIfExists(plugin)
  endif
endfor

" And let's furthermore write functions to do basic plugin pulls and removals
" NOTE: We could leverage `packadd` here, but since this section is kind of
" about legacy support, I think it makes more sense to avoid the native
" package support and rely on the above `runtimepath`-modifying code here.

function MyNativeSinglePluginInstall(plugin)
  let name = StrCat(a:plugin["author"], "/", a:plugin["name"])
  if (has_key(a:plugin, "options") &&
    \ has_key(a:plugin["options"], "enabled") &&
    \ !a:plugin["options"]["enabled"])
    echo StrCat("Plugin `", name, "` is disabled.")
    return
  endif

  if (has_key(a:plugin, "options") &&
    \ has_key(a:plugin["options"], "dependencies"))
    for dependency in a:plugin["options"]["dependencies"]
      call MyNativeSinglePluginInstall(dependency)
    endfor
  endif

  let path = StrCat(s:my_plugins_dir, a:plugin["name"])
  if isdirectory(path)
    echo StrCat("Plugin `", name, "` already exists.")
    return
  endif

  let command = "git clone"
  if (has_key(a:plugin, "options") && has_key(a:plugin["options"], "branch"))
    let command =
    \ StrCat(command, " --branch ", a:plugin["options"]["branch"])
  endif
  let command = StrCat(command, " https://github.com/", name, ".git")
  let command = StrCat(command, " ", path)
  echo system(command)
  "echo StrCat("Plugin `", name, "` git-cloned.")
  if (has_key(a:plugin, "options") && has_key(a:plugin["options"], "build"))
    echo StrCat("  NOTE: Build command has to be run manually: `",
    \ a:plugin["options"]["build"], "`")
  endif
endfunction

function MyNativePluginInstall()
  if !isdirectory(s:my_plugins_dir)
    call mkdir(s:my_plugins_dir, "p")
  endif
  for [feature, plugin] in items(g:my_plugins)
    if g:my_features[feature]
      call MyNativeSinglePluginInstall(plugin)
    endif
  endfor
  echo StrCat("`", s:my_plugins_dir, "` populated.")
endfunction

function MyNativePluginRemove()
  if isdirectory(s:my_plugins_dir)
    call delete(s:my_plugins_dir, "rf")
  endif
  echo StrCat("`", s:my_plugins_dir, "` deleted.")
endfunction

function MyNativePluginUpdate()
  call MyNativePluginRemove()
  call MyNativePluginInstall()
endfunction

