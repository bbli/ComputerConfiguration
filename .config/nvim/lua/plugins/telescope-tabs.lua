require('telescope-tabs').setup{}
vim.keymap.set('n','<leader>ot','<cmd>Telescope telescope-tabs list_tabs<CR>')
vim.keymap.set('n','<leader>ws',"<cmd>lua require('telescope-tabs').go_to_previous<CR>")
