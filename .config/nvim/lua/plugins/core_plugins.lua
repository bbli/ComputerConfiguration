return {
  -- add my colorscheme to LazyVim
  { "sainnhe/edge" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "edge",
    },
    keys = {
      { "<leader>a", "",  desc = "+ai" },
      { "<leader>b", "",  desc = "+buffer" },
      { "<leader>w", "",  desc = "+workspace" },
      { "<leader>s", "",  desc = "+search/send" },
      { "<leader>j", "",  desc = "+jump" },
      { "<leader>f", "",  desc = "+find" },
      { "<leader>g", "",  desc = "+git" },
      { "<leader>t", "",  desc = "+toggle" },
      { "<leader>o", "",  desc = "+open" },
    },
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      {
        "<leader>tu",
        "<cmd>UndotreeToggle<CR>",
        desc = "Toggle Undotree",
      },
    },
  },

  -- diable flash.nvim
  {
    "folke/flash.nvim",
    enabled = false,
  },

  -- Neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      toggle = true,
    },
    keys = {
      { "<leader>tn", ":Neotree toggle<CR>", desc = "Toggle Neotree" },
    },
  },

  -- visual star search
  {
    "bronson/vim-visual-star-search",
  },

  -- vim-qf
  { "romainl/vim-qf" },

  -- tmuxline
  {
    "edkolev/tmuxline.vim",
    config = function()
      -- local in_tmux = os.execute("echo $TMUX")
      -- if in_tmux ~= "" then
      --   vim.cmd("Tmuxline vim_statusline_3")
      -- end
    end,
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>wr", ":BufferLineTabRename ", desc = "Rename Workspace" },
    },
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>od", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Open Buffer Diagnostic" },
      { "<leader>oD", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Open Project Diagnostic" },
      { "<leader>tt", "<cmd>Trouble symbols toggle=false<CR>",            desc = "Toggle Trouble TagBar" },
    },
  },
}
