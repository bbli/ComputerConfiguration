local actions = require("telescope.actions")
return {
  "nvim-telescope/telescope.nvim",
  opts = {
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
  },
  config = function()
    vim.keymap.del("n", "<leader>fr")
  end,
  keys = {
    { "<leader>oo", "<cmd>Telescope git_files<CR>" },
    {
      "<leader>oa",
      "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--no-ignore-vcs', '--files', '--hidden', '-g', '!.git' , '-g', '!node_modules'}})<cr>",
    },
    { "<leader>ob", "<cmd>Telescope buffers<CR>" },
    { "<leader>oh", "<cmd>Telescope oldfiles<CR>" },
    { "<leader>om", "<cmd>Telescope help_tags<CR>" },
    { "<leader>oc", "<cmd>Telescope commands<CR>" },
    { "<leader>or", "<cmd>Telescope neoclip<CR>" },
    { "<leader>ok", "<cmd>Telescope keymaps<CR>" },
    { "<leader>ov", "<cmd>Telescope vim_options<CR>" },
    { "<leader>oq", "<cmd>Telescope quickfixhistory<CR>" },
  },
}
-- TODO: add Teelscop current buffer -> so you can send results to quickfix for saving your progress
