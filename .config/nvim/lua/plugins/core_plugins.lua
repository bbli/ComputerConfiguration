return {
  -- add my colorscheme to LazyVim
  { "sainnhe/edge" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "edge",
    },
    keys = {
      { "<leader>a", "", desc = "+ai" },
      { "<leader>b", "", desc = "+buffer" },
      { "<leader>w", "", desc = "+workspace" },
      { "<leader>s", "", desc = "+search/send" },
      { "<leader>j", "", desc = "+jump" },
      { "<leader>f", "", desc = "+find" },
      { "<leader>g", "", desc = "+git" },
      { "<leader>t", "", desc = "+toggle" },
      { "<leader>o", "", desc = "+open" },
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
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>wr", ":BufferLineTabRename ", desc = "Rename Workspace" },
    },
  },
}
