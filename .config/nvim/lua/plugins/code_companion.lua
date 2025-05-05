 return {
  {
    "olimorris/codecompanion.nvim",
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
      --{ "echasnovski/mini.pick", config = true },
      --{ "ibhagwan/fzf-lua", config = true },
    },
    opts = {
 strategies = {
    chat = {
      adapter = "gemini",
    },
    inline = {
      adapter = "gemini",
    },
    cmd = {
      adapter = "gemini",
    }
  },
      extensions = {
        vectorcode = {
          opts = { add_tool = true, add_slash_command = true, tool_opts = {} },
        },
      }
    },
    keys = {
      { "<leader>at", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion" },
    },
  },
}
