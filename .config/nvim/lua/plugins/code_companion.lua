return {
  {
    "olimorris/codecompanion.nvim",
    strategies = {
      chat = {
        adaptor = "copilot",
      },
      inline = {
        adaptor = "copilot",
      },
      cmd = {
        adaptor = "copilot",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
      {
        "Davidyz/VectorCode",
        version = "*",
        build = "pipx upgrade vectorcode",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
      -- { "echasnovski/mini.pick", config = true },
      -- { "ibhagwan/fzf-lua", config = true },
    },
    keys = {
      { "<leader>at", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion" },
    },
    config = function()
      require("codecompanion").setup({})
    end,
  },
}
