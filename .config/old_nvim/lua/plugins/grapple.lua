--require("grapple").setup({
--    -- Your configuration goes here
--    -- Leave empty to use the default configuration
--    -- Please see the Configuration section below for more information
--})
vim.keymap.set('n','<leader>hr',
    function() require("grapple").untag() end,{}
    )
vim.keymap.set('n','<leader>hh',
    function() require("grapple").toggle_tags() end,{}
    )

-- grapple log -> gl
-- open log
vim.keymap.set('n','<leader>hl',
    function() require("grapple").tag({name="log"}) end
    )
vim.keymap.set('n','<leader>jl',
    function() require("grapple").select({name="log"}) end
    )
vim.keymap.set('n','<leader>rl',
    function() require("grapple").untag({name="log"}) end
    )

-- grapple main(for inserting debug/pinning before a bunch of jump to definition calls) -> gm
-- open main
vim.keymap.set('n','<leader>hm',
    function() require("grapple").tag({name="main"}) end,{}
    )
vim.keymap.set('n','<leader>jm',
    function() require("grapple").select({name="main"}) end,{}
    )
vim.keymap.set('n','<leader>rm',
    function() require("grapple").untag({name="main"}) end,{}
    )

-- grapple test -> gt
-- open test
vim.keymap.set('n','<leader>ht',
    function() require("grapple").tag({name="test"}) end,{}
    )
vim.keymap.set('n','<leader>jt',
    function() require("grapple").select({name="test"}) end,{}
    )
vim.keymap.set('n','<leader>rt',
    function() require("grapple").untag({name="test"}) end,{}
    )

-- grapple file -> gg
-- open file

vim.keymap.set('n','<leader>hf',
    function() require("grapple").tag({name="file"}) end,{}
    )
vim.keymap.set('n','<leader>jf',
    function() require("grapple").select({name="file"}) end,{}
    )
vim.keymap.set('n','<leader>rf',
    function() require("grapple").untag({name="file"}) end,{}
    )
