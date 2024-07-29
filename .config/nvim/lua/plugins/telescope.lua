local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
--      file_ignore_patterns = {'build'},
    mappings = {
      n = {
          [ "q" ] = actions.close,
          ["<C-f>"] = actions.preview_scrolling_up,
          ["<C-b>"] = actions.preview_scrolling_down,
      },
     i = {
          [ "<C-g>" ] = actions.close,
          [ "<C-j>" ] = actions.move_selection_next,
          [ "<C-k>" ] = actions.move_selection_previous,
          [ "<C-l>" ] = actions.smart_send_to_qflist + actions.open_qflist,
          [ "<C-h>" ] = actions.complete_tag,
          [ "<C-u>" ] = false,
          [ "<C-d>" ] = false,
          [ "<C-b>" ] = actions.preview_scrolling_up,
          [ "<C-f>" ] = actions.preview_scrolling_down,

     },
    },
      layout_config = {
          preview_width = 75
      }
  },
   extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      -- "false" is better as "true" priorities file name too much
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
