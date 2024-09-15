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
        function()
          vim.cmd("UndotreeToggle")
        end,
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
}
