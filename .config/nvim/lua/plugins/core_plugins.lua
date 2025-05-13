function ToggleNoiceHistory()
  if check_filetype("noice") then
    CloseWindowWithFileType("noice")
  else
    vim.cmd("NoiceHistory")
  end
end

function AsyncFormatCppCode()
  local Job = require("plenary.job")
  Job:new({
    command = "make",
    args = { "clang-format-patch-stack" },
    on_exit = function(job, return_val)
      vim.schedule(function()
        vim.cmd("e")
      end)
    end,
  }):start()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.b.autoformat = false
  end,
})

return {
  -- add my colorscheme to LazyVim
  { "sainnhe/edge" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      preset = "classic",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "edge",
      defaults = {
        keymaps = false,
      },
    },
    keys = {
      { "<leader>a", "", desc = "+ai" },
      { "<leader>b", "", desc = "+buffer" },
      { "<leader>w", "", desc = "+workspace" },
      { "<leader>s", "", desc = "+search" },
      { "<leader>r", "", desc = "+run" },
      { "<leader>j", "", desc = "+jump" },
      { "<leader>f", "", desc = "+find" },
      { "<leader>g", "", desc = "+git" },
      { "<leader>t", "", desc = "+toggle" },
      { "<leader>o", "", desc = "+open" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- You can customize some of the format options for the filetype (:help conform.format)
        cpp = { "git-clang-format", lsp_format = "fallback" },
      },
    },
    keys = {
      {
        "<leader>bf",
        function()
          require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
        end,
        desc = "Format file or range (in visual mode)",
      },
    },
  },
  --{
  --  "nvim-tree/nvim-tree.lua",
  -- config = function()
  --  require("nvim-tree").setup()
  --end,
  --keys = {
  --{ "<leader>tn", ":NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
  --},
  --},

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
