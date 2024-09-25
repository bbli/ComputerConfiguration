return {
  -- add my colorscheme to LazyVim
  { "sainnhe/edge" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "edge",
    },
    keys = {
      { "<leader>a", "", desc = "+ai" },
      { "<leader>b", "", desc = "+buffer" },
      { "<leader>w", "", desc = "+workspace" },
      { "<leader>s", "", desc = "+search/send" },
      { "<leader>j", "", desc = "+jump" },
      { "<leader>f", "", desc = "+find" },
      { "<leader>g", "", desc = "+git" },
      { "<leader>t", "", desc = "+toggle" },
      { "<leader>o", "", desc = "+open" },
    },
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      {
        "<leader>tu",
        "<cmd>UndotreeToggle<CR>",
        desc = "Toggle Undotree",
      },
    },
  },

  -- diable flash.nvim
  {
    "folke/flash.nvim",
    enabled = false,
  },

  -- Neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      toggle = true,
    },
    keys = {
      { "<leader>tn", ":Neotree toggle<CR>", desc = "Toggle Neotree" },
    },
  },

  -- visual star search
  {
    "bronson/vim-visual-star-search",
  },

  -- add ccls language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ccls = {},
      },
    },
  },
  -- vim-qf
  { "romainl/vim-qf" },

  -- tmuxline
  {
    "edkolev/tmuxline.vim",
    config = function()
      local in_tmux = os.getenv("TMUX")
      if in_tmux ~= nil then
        vim.cmd("Tmuxline vim_statusline_3")
      end
    end,
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>wr", ":BufferLineTabRename ", desc = "Rename Workspace" },
    },
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>od", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Open Buffer Diagnostic" },
      { "<leader>oD", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open Project Diagnostic" },
      { "<leader>tt", "<cmd>Trouble symbols toggle=false<CR>", desc = "Toggle Trouble TagBar" },
    },
  },

  -- noice
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.presets = {
        command_palette = {
          views = {
            cmdline_popup = {
              position = {
                row = "50%",
                col = "50%",
              },
              size = {
                min_width = 60,
                width = "auto",
                height = "auto",
              },
            },
            popupmenu = {
              relative = "editor",
              position = {
                row = 23,
                col = "50%",
              },
              size = {
                width = 60,
                height = "auto",
                max_height = 15,
              },
              border = {
                style = "rounded",
                padding = { 0, 1 },
              },
              win_options = {
                winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
              },
            },
          },
        },
      }
      opts.lsp.signature = {
        opts = { size = { max_height = 15 } },
      }
    end,
  },
}
