local actions = require("telescope.actions")
return {
  "nvim-telescope/telescope.nvim",
  config = function()
    vim.keymap.del("n", "<leader>fr")
    vim.keymap.del("n", "<leader>ff")
    vim.keymap.del("n", "<leader><leader>")
    require("telescope").setup({
      defaults = {
        --      file_ignore_patterns = {'build'},
        mappings = {
          n = {
            ["q"] = actions.close,
            ["<C-f>"] = actions.preview_scrolling_up,
            ["<C-b>"] = actions.preview_scrolling_down,
          },
          i = {
            ["<C-g>"] = actions.close,
            ["<C-c>"] = actions.close,

            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-l>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<C-h>"] = actions.complete_tag,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
            ["<C-b>"] = actions.preview_scrolling_up,
            ["<C-f>"] = actions.preview_scrolling_down,
          },
        },
        wrap_results = true,
        layout_config = {
          preview_width = 75,
        },
      },
    })
  end,

}
