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
        desc = "Jump to Main Tag",
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

      -- grapple other: secondary file to main file
      {
        "<leader>ho",
        function()
          require("grapple").tag({ name = "other" })
        end,
        desc = "Grapple Other Tag",
      },
      {
        "<leader>jo",
        function()
          require("grapple").select({ name = "other" })
        end,
        desc = "Jump to Other Tag",
      },
      {
        "<leader>ro",
        function()
          require("grapple").untag({ name = "other" })
        end,
      },
      -- grapple similar file -> gs
      {
        "<leader>hs",
        function()
          require("grapple").tag({ name = "similar" })
        end,
        desc = "Grapple Similar Tag",
      },
      {
        "<leader>js",
        function()
          require("grapple").select({ name = "similar" })
        end,
        desc = "Jump to Similar Tag",
      },
      {
        "<leader>rl",
        function()
          require("grapple").untag({ name = "similar" })
        end,
      },
    },
  },
}
