# NOTE: It looks like a `.vim` file with a big dictionary definition in an
# `if`-`else` branch that is *not* executed takes a lot longer to source than
# when the branch is not there in the first place. Furthermore, it looks like a
# straight `.lua` file is a little faster than a "heredoc" block in a `.vim`
# file. Thus, I should make two separate files and only source the appropriate
# one and not have them both sit in `after/plugin/`…
# Further, it turns out that `json_decode` is a lot faster than a VimScript
# definition, so let's include that as well…

as_comment(str; signifier) =
  signifier * " " * join(split(str, "\n"), "\n" * signifier * " ")

function as_vimscript(dict, variable_name)
  str = as_comment(info_comment; signifier = "\"")
  str *= "\n\n"
  # str *= """
  #   if exists("g:my_features") &&
  #     \\ has_key(g:my_features, "$feature_name") &&
  #     \\ g:my_features["$feature_name"]
    # """
  str *= "let g:$variable_name = {"
  is_first_entry = true
  for (k, v) in sort(collect(pairs(dict)))
    if is_first_entry
      is_first_entry = false
    else
      str *= ","
    end
    if contains(v, '\\')
      str *= "\n\\ '$k': \"$v\""
    else
      str *= "\n\\ '$k': '$v'"
    end
  end
  str *= "}\n"
  # str *= "endif\n"
  return str
end

function as_lua(dict, variable_name)
  str = as_comment(info_comment; signifier = "--")
  str *= "\n\n"
  # str *= """
  #   if vim.g.my_features ~= nil and
  #       vim.g.my_features["$feature_name"] == 1 then
  #   """
  str *= "vim.g.$variable_name = {"
  is_first_entry = true
  for (k, v) in sort(collect(pairs(dict)))
    if is_first_entry
      is_first_entry = false
    else
      str *= ","
    end
    str *= "\n  [\"$k\"] = \"$v\""
  end
  str *= "}\n"
  # str *= "end\n"
  return str
end

function as_json(dict, ::Any)
  str = "{"
  is_first_entry = true
  for (k, v) in sort(collect(pairs(dict)))
    if is_first_entry
      is_first_entry = false
    else
      str *= ","
    end
    str *= "\n \"$k\": \"$v\""
  end
  str *= "}\n"
  return str
end

symbol_dict = Dict{String, String}(
  # "\\0" => "\\0",
  # "\\a" => "\\a",
  # "\\n" => "\\n",
  # "\\r" => "\\r",
  # "\\v" => "\\v",
  "\\t" => "\\t")

using REPL.REPLCompletions: latex_symbols, emoji_symbols
using Dates: now, UTC
symbol_dict = merge(latex_symbols, emoji_symbols, symbol_dict)
symbol_dict = Dict((k[2:end] => v for (k, v) in pairs(symbol_dict))...)
variable_name = "my_symbol_dict"
# feature_name = "symbol_dict_sourcing"
info_comment = """
This file was autogenerated
* from `$(basename(@__FILE__))`
* using Julia $VERSION
* on $(now(UTC)) UTC"""

for (ext, as_language) in zip(("vim", "lua", "json"),
                              (as_vimscript, as_lua, as_json))
  open(joinpath(@__DIR__, "symbol-dict.$ext");
      write = true) do io
    write(io, as_language(symbol_dict, variable_name))
  end
end
