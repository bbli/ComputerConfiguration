local g = vim.g
require'lightspeed'.setup {
    ignore_case = true,
    }
vim.keymap.set('n','s','<Plug>Lightspeed_s')
vim.keymap.set('n','S','<Plug>Lightspeed_S')
g.lightspeed_no_default_keymaps = 1

