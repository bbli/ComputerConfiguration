return {
  {
    "cbochs/grapple.nvim",
    keys = {
      {
        "<leader>hh",
        function()
          require("grapple").toggle_tags()
        end,
        desc = "Open Grapple Select Window",
      },

      -- grapple log -> gl
      {
        "<leader>hl",
        function()
          require("grapple").tag({ name = "log" })
        end,
        desc = "Grapple Log Tag",
      },
      {
        "<leader>jl",
        function()
          require("grapple").select({ name = "log" })
        end,
        desc = "Jump to Log Tag",
      },
      {
        "<leader>rl",
        function()
          require("grapple").untag({ name = "log" })
        end,
      },

      -- grapple main(for inserting debug/pinning before a bunch of jump to definition calls) -> gm
      {
        "<leader>hm",
        function()
          require("grapple").tag({ name = "main" })
        end,
        desc = "Grapple Main Tag",
      },
      {
        "<leader>jm",
        function()
          require("grapple").select({ name = "main" })
        end,
        desc = "Jump to Test Tag",
      },
      {
        "<leader>rm",
        function()
          require("grapple").untag({ name = "main" })
        end,
      },

      -- grapple test
      {
        "<leader>ht",
        function()
          require("grapple").tag({ name = "test" })
        end,
        desc = "Grapple Test Tag",
      },
      {
        "<leader>jt",
        function()
          require("grapple").select({ name = "test" })
        end,
        desc = "Jump to Test Tag",
      },
      {
        "<leader>rt",
        function()
          require("grapple").untag({ name = "test" })
        end,
      },

      -- grapple file
      {
        "<leader>hf",
        function()
          require("grapple").tag({ name = "file" })
        end,
        desc = "Grapple File Tag",
      },
      {
        "<leader>jf",
        function()
          require("grapple").select({ name = "file" })
        end,
        desc = "Jump to File Tag",
      },
      {
        "<leader>rf",
        function()
          require("grapple").untag({ name = "file" })
        end,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "cbochs/grapple.nvim" },
    },
    opts = {
      sections = {
        lualine_x = { require("grapple").statusline },
      },
    },
  },
}
