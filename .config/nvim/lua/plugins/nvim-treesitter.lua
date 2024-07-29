require'nvim-treesitter.configs'.setup{
    auto_install = true,

    --highlight = {
    --    enable = true,
    --    --custom_captures = {
    --        -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
    --        -- ["keyword"] = "TSString", -- for testing if tresitter works
    --        --},
    --    additional_vim_regex_highlighting = true,
    --},
    --incremental_selection = {
    --enable = true,
    --keymaps = {
    --init_selection = "gnn",
    --node_incremental = "grn",
    --scope_incremental = "grc",
    --node_decremental = "grm",
    --},
    --},
    indent = {
        enable = true
    },
    -- since I don't use operator pending that often/when I do want exact
    -- textsubjects = {
    -- enable = true,
    -- keymaps = {
    --     ['t'] = 'textsubjects-smart',
    --     ['T'] = 'textsubjects-container-outer',
    --     }
    -- },
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
            set_jumps = true, -- whether to set jumps in the jumplist
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
}
vim.cmd[[
autocmd BufEnter * TSBufEnable highlight
]]

require'nvim-treesitter.configs'.setup{
    matchup = {
        enable = true,
    },
}
