local cmp = require'cmp'
local lspkind = require'lspkind'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            --vim.fn["vsnip#anonymous"](args.body) 
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        --['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        --['<C-f>'] = cmp.mapping.confirm({ select = true }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(),{'i','c','s'}),
        ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(),{'i','c','s'}),
    },
    sources = cmp.config.sources({
        { name = 'luasnip', keyword_length = 2},
        { name = 'nvim_lsp_signature_help'},
        { name = 'nvim_lsp', keyword_length = 2, max_item_count = 5 },
        --{ name = 'ultisnips' }, -- For ultisnips users.
        { name = 'buffer', keyword_length = 1, max_item_count = 5,
            option = {
                keyword_pattern = [[\k\+]] -- lsp gettings sigils without this
            }
        },
        -- {name = 'tags', max_item_count = 6}, -- only turn on if no lsp
        {name = 'tmux', keyword_length = 2, max_item_count = 3},
        { name = 'path', keyword_length = 2, max_item_count = 3},
        --{ name = 'vsnip', max_item_count = 3 },
    }),
    formatting = {
        format = require("lspkind").cmp_format({
            with_text = true,
            menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                path = "[Path]",
                tags = "[Tags]",
                tmux = "[Tmux]",
                luasnip = "[LuaSnip]",
                --nvim_lua = "[Lua]",
                --latex_symbols = "[Latex]",
            })
        }),
    },
    experimental = {
        ghost_text = true,
    }
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
sources = cmp.config.sources({
  { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
}, {
  { name = 'buffer' },
})
})
-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({'/','?'}, {
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'buffer' }
    }, {
            { name = 'cmdline' }
        })
})
