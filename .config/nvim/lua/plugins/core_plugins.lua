function close_window_with_filetype(filetype)
  local win_ids = vim.api.nvim_list_wins()
  for _, win_id in ipairs(win_ids) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")
    if buf_filetype == filetype then
      vim.api.nvim_win_close(win_id, false)
      return true
    end
  end
  return false
end

function ToggleNoiceHistory()
  if check_filetype("noice") then
    close_window_with_filetype("noice")
  else
    vim.cmd("NoiceHistory")
  end
end

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
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup()
    end,
    keys = {
      { "<leader>tn", ":NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
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

  -- zen mode
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 200,
      },
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      { "<leader>tz", "<cmd>ZenMode<CR>", desc = "Toggle ZenMode" },
    },
  },
  -- zen mode
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        B_TODO = { color = "info" },
        B_HACK = { color = "warning" },
        B_FUTURE = { color = "info" },
      },
    },
    keys = {
      { "<leader>tt", ":TodoQuickFix keywords=B_HACK,B_TODO,B_FUTURE<CR>", desc = "Toggle Todo-Comments" },
    },
  },

  -- diable flash.nvim
  {
    "folke/flash.nvim",
    enabled = false,
  },

  -- -- Neotree
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   opts = {
  --     toggle = true,
  --     window = {
  --       mappings = {
  --         ["<TAB>"] = "toggle_node",
  --       },
  --     },
  --   },
  --   keys = {
  --     { "<leader>tn", ":Neotree toggle<CR>", desc = "Toggle Neotree" },
  --   },
  -- },

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
    },
  },

  -- Aerial Symbols
  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>ts", "<cmd>AerialToggle<CR>", desc = "Toggle Symbols" },
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
    keys = {
      { "<leader>vl", ToggleNoiceHistory, desc = "Toggle NoiceHistory" },
    },
  },
}
