
-- Use for jumping to the current TODO -> in TDD
vim.keymap.set('n','<leader>ha',
    function() require("harpoon.mark").add_file() end
    )

require("telescope").load_extension("harpoon")
vim.keymap.set('n',"<leader>hh",
    "<cmd>Telescope harpoon marks<CR>"
    )
vim.keymap.set('n',"<leader>hm",
    function() require("harpoon.ui").toggle_quick_menu() end
    )
