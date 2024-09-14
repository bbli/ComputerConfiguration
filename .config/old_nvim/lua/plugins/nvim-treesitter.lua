require 'nvim-treesitter.configs'.setup {
  auto_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,

      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true,       -- whether to set jumps in the jumplist
      goto_next_start = {
        --["ll"] = "@comment.outer",
        ["lf"] = "@function.outer",
        ["lb"] = "@block.outer",

        ["C-n"] = "@statement.outer",
        ["lc"] = "@class.outer",
      },
      goto_previous_start = {
        --["hh"] = "@comment.outer",
        ["hf"] = "@function.outer",
        ["hb"] = "@block.outer",

        ["C-p"] = "@statement.outer",
        ["hc"] = "@class.outer",
      },

      -- below don't matter as much
      goto_next_end = {
        --["lL"] = "@statement.outer",
        ["lF"] = "@function.outer",

        --["lC"] = "@comment.outer",
        ["lC"] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    context_commentstring = {
      enable = true
    },
  },
  matchup = {
    enable = true,
  },
}
vim.cmd [[
autocmd BufEnter * TSBufEnable highlight
]]
