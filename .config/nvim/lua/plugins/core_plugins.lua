return {
  -- add my colorscheme to LazyVim
  { "sainnhe/edge" },
  {

    "LazyVim/LazyVim",
    opts = {
      colorscheme = "edge",
    },
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      {
        "<leader>tu",
        "<cmd>UndotreeToggle<CR>",
        desc = "Toggle Undotree"
      }
    }
  },


  -- diable flash.nvim
  {
    "folke/flash.nvim",
    enabled = false
  },

  -- Neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      toggle = true,
    },
    keys = {
      { "<leader>tn", ":Neotree toggle<CR>", desc = "Toggle Neotree" }
    }
  },

  -- visual star search
  {
    'bronson/vim-visual-star-search'
  }
}
