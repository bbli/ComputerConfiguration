require("todo-comments").setup{
    signs = false,
}
local api = vim.api
-- vim.keymap.set("c", "tn",
--     function()
--         require("todo-comments").jump_next{keywords = {"TODO"}}

--         local key = api.nvim_replace_termcodes('<CR>',true,false,true)
--         api.nvim_feedkeys(key,'n',false)
--     end,
--     { desc = "Next todo comment" }
-- )

-- vim.keymap.set("c", "tp",
--     function()
--         require("todo-comments").jump_prev{keywords = {"TODO"}}

--         local key = api.nvim_replace_termcodes('<CR>',true,false,true)
--         api.nvim_feedkeys(key,'n',false)
--     end,
--     { desc = "Previous todo comment" }
-- )
