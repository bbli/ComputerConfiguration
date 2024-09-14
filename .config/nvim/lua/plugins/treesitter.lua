return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "cpp", "rust", "python", "perl", "vim", "lua" },
      sync_install = false,
      auto_install = true,
    }

  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VimEnter",
    -- config = function(_, opts)
    --   vim.cmd('autocmd BufEnter * TSContextEnable')
    -- end,
    keys = {
      {
        "<leader>tc",
        function()
          vim.cmd('TSContextToggle')
        end,
        desc = "Toggle Treesitter Context",
      },
    }
  }
}
