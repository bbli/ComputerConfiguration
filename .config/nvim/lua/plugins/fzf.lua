return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "echasnovski/mini.icons" },
    -- opts = {}
    config = function(opts)
      --delete during config to try to be as late as possible
      vim.keymap.del("n", "<leader>fb")
      -- vim.keymap.del("n", "<leader>fc")
      vim.keymap.del("n", "<leader>fr")
      vim.keymap.del("n", "<leader>ff")
      require("fzf-lua").register_ui_select()

      vim.ui.select = require("fzf-lua").ui_select
    end,
    keys = {
      { "<leader>sg", "<cmd>FzfLua git_files<CR>", desc = "FZF git files" },
      { "<leader>oo", "<cmd>FzfLua git_files<CR>", desc = "FZF git files" },
      {
        "<leader>oO",
        function()
          require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "FZF files in current directory",
      },
      { "<leader>sh", "<cmd>FzfLua oldfiles<CR>", desc = "FZF Recent History" },
      { "<leader>oh", "<cmd>FzfLua oldfiles<CR>", desc = "FZF Recent History" },
      { "<leader>sm", "<cmd>FzfLua helptags<CR>", desc = "FZF Man Pages" },
      { "<leader>om", "<cmd>FzfLua helptags<CR>", desc = "FZF Man Pages" },
      { "<leader>sc", "<cmd>FzfLua commands<CR>", desc = "FZF Commands" },
      { "<leader>oc", "<cmd>FzfLua commands<CR>", desc = "FZF Commands" },
      { "<leader>sk", "<cmd>FzfLua keymaps<CR>", desc = "FZF keymaps" },
      { "<leader>ok", "<cmd>FzfLua keymaps<CR>", desc = "FZF keymaps" },
      { "<leader>sr", "<cmd>FzfLua registers<CR>", desc = "FZF Registers" },
      { "<leader>or", "<cmd>FzfLua registers<CR>", desc = "FZF Registers" },
      { "<leader>fs", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "FZF Workspace Symbols" },
      { "<leader>sv", "<cmd>FzfLua nvim_options<CR>", desc = "FZF vim options" },
      { "<leader>ov", "<cmd>FzfLua nvim_options<CR>", desc = "FZF vim options" },
      -- { "<leader>vv", "<cmd>FzfLua nvim_options<CR>" },
      { "<leader>sq", "<cmd>FzfLua quickfix_stack<CR>", desc = "FZF quickfix history" },
      { "<leader>oq", "<cmd>FzfLua quickfix_stack<CR>", desc = "FZF quickfix history" },
      { "<leader>bb", "<cmd>FzfLua buffers<CR>", desc = "FZF buffers" },

      -- Overiding FZF keymaps
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage git hunk" },
    },
  },
}
