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

      -- clear all tags
      {
        "<leader>hc",
        function()
          require("grapple").reset()
        end,
        desc = "Clear All Harpoon Tags",
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

      -- grapple second: secondary file to main file
      {
        "<leader>ho",
        function()
          require("grapple").tag({ name = "second" })
        end,
        desc = "Grapple Second Tag",
      },
      {
        "<leader>jo",
        function()
          require("grapple").select({ name = "second" })
        end,
        desc = "Jump to Second Tag",
      },
      -- grapple other file: for example of code to copy
      {
        "<leader>hs",
        function()
          require("grapple").tag({ name = "other" })
        end,
        desc = "Grapple Other Tag",
      },
      {
        "<leader>js",
        function()
          require("grapple").select({ name = "other" })
        end,
        desc = "Jump to Other Tag",
      },
    },
  },
}
