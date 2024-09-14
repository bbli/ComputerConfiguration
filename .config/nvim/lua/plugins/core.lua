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
  }
}
