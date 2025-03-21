local orgmode = require("orgmode")
local nvim_treesitter_configs = require('nvim-treesitter.configs')

-- TODO: The below code is mostly just copied from the plugin readme file.
-- -> Configure this.

-- Load custom treesitter grammar for org filetype
orgmode.setup_ts_grammar()

-- Treesitter configuration
nvim_treesitter_configs.setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop,
  -- highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    -- Required for spellcheck, some LaTex highlights and
    -- code block highlights that do not have ts grammar
    additional_vim_regex_highlighting = {'org'},
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require('orgmode').setup({
  org_agenda_files = {},
  org_default_notes_file = '~/refile.org',
})
