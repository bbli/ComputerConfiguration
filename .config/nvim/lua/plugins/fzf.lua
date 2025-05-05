return {
{
  "ibhagwan/fzf-lua",
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  -- opts = {}
  --config = function (opts)
    -- delete during config to try to be as late as possible
    --vim.keymap.del("n", "<leader>fr")
    --vim.keymap.del("n", "<leader>ff")
    --vim.keymap.del("n", "<leader><leader>")
  --end
  keys = {
    { "<leader>ss", "<cmd>FzfLua git_files<CR>" , desc = "FZF git files"},
    {
      "<leader>sa",
      function ()
        require('fzf-lua').files({ cwd = vim.fn.expand('%:p:h') })
      end,
      desc = "FZF files in current directory"
    },
    { "<leader>sh", "<cmd>FzfLua oldfiles<CR>", desc = "FZF Recent History" },
    { "<leader>sm", "<cmd>FzfLua helptags<CR>" , desc = "FZF Help Manual"},
    { "<leader>sc", "<cmd>FzfLua commands<CR>" , desc = "FZF Commands"},
    { "<leader>sk", "<cmd>FzfLua keymaps<CR>" , desc = "FZF keymaps"},
    { "<leader>sv", "<cmd>FzfLua nvim_options<CR>" , desc = "FZF vim options"},
    -- { "<leader>vv", "<cmd>FzfLua nvim_options<CR>" },
    { "<leader>sq", "<cmd>FzfLua quickfix_stack<CR>" , desc = "FZF quickfix history"},
  },
},


}
