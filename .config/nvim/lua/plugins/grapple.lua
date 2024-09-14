return {
  {
    "cbochs/grapple.nvim",
    keys = {
      { "<leader>hh", function() require("grapple").toggle_tags() end },

      -- grapple log -> gl
      { "<leader>hl", function() require("grapple").tag({ name = "log" }) end },
      { "<leader>jl", function() require("grapple").select({ name = "log" }) end },
      { "<leader>rl", function() require("grapple").untag({ name = "log" }) end },

      -- grapple main(for inserting debug/pinning before a bunch of jump to definition calls) -> gm
      { "<leader>hm", function() require("grapple").tag({ name = "main" }) end },
      { "<leader>jm", function() require("grapple").select({ name = "main" }) end },
      { "<leader>rm", function() require("grapple").untag({ name = "main" }) end },

      -- grapple test
      { "<leader>ht", function() require("grapple").tag({ name = "test" }) end },
      { "<leader>jt", function() require("grapple").select({ name = "test" }) end },
      { "<leader>rt", function() require("grapple").untag({ name = "test" }) end },

      -- grapple file
      { "<leader>hf", function() require("grapple").tag({ name = "file" }) end },
      { "<leader>jf", function() require("grapple").select({ name = "file" }) end },
      { "<leader>rf", function() require("grapple").untag({ name = "file" }) end }
    }
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "cbochs/grapple.nvim" }
    },
    opts = function(_, opts)
      table.insert(opts.sections.lualine_b, { require("grapple").statusline })
    end,
  }
}
