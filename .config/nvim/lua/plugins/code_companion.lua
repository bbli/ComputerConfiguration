return {
  {
    "olimorris/codecompanion.nvim",
    strategies = {
      chat = {
        adaptor = "copilot",
        tools = {
          vectorcode = {
            description = "Run VectorCode to retrieve the project context.",
            callback = function()
              return require("vectorcode.integrations").codecompanion.chat.make_tool()
            end,
          },
        },
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
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
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
