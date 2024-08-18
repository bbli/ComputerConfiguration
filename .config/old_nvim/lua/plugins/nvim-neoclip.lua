require('telescope').load_extension('neoclip')
require('neoclip').setup({
    enable_persistent_history = true,
    preview = true,
    default_register = '"',
    enable_macro_history = false,
    content_spec_column = true,
    on_paste = {
        set_reg = true,
    },
    keys = {
        telescope = {
            i = {
                select = '<c-y>',
                paste = '<cr>',
            },
            n = {
                select = 'y',
                paste = '<cr>',
                --- It is possible to map to more than one key.
                -- paste = { 'p', '<c-p>' },
                delete = 'd',
            },
        },
    },
})
