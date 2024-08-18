vim.keymap.set('n','<leader>tc',
    "<cmd>CopilotChatToggle<CR>"
)

vim.keymap.set("n",'<leader>ce',
    "<cmd>CopilotChatExplain<CR>")
vim.keymap.set('n','<leader>ct',
    "<cmd>CopilotChatTests<CR>")
vim.keymap.set('n','<leader>cr',
    "<cmd>CopilotChatOptimize<CR>")



vim.keymap.set("v",'<leader>ce',
    "<cmd>CopilotChatExplain<CR>")
vim.keymap.set('v','<leader>ct',
    "<cmd>CopilotChatTests<CR>")
vim.keymap.set('v','<leader>cr',
    "<cmd>CopilotChatOptimize<CR>")



vim.keymap.set('n','<leader>cf',
    "<cmd>CopilotChatFix<CR>"
)
vim.keymap.set('v','<leader>cf',
    "<cmd>CopilotChatFix<CR>"
)

require("CopilotChat").setup({debug = true})
