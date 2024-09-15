vim.g.toggleGitBase = true
function toggleGitBase()
  if vim.g.toggleGitBase then
    vim.g.toggleGitBase = false
    require('gitsigns').change_base('area/foundation')
  else
    vim.g.toggleGitBase = true
    require('gitsigns').change_base()
  end
end

local function showGitBase()
  if vim.g.toggleGitBase then
    return "index"
  else
    return "foundation"
  end
end

return {
  -------------- 1. Gitsigns -----------------
  {

    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach                    = function() end, -- disable LazyVim's code, which will set keymaps which I don't want
      signs                        = {
        add          = { text = '+' },
        change       = { text = '│' },
        delete       = { text = '-' },
        topdelete    = { text = '‾' },
        changedelete = { text = '│' },
        untracked    = { text = '+' },
      },
      --base                         = "area/foundation",
      signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
      linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir                 = {
        interval = 1000,
        follow_files = true
      },
      attach_to_untracked          = true,
      current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority                = 100,
      update_debounce              = 100,
      status_formatter             = nil,   -- Use default
      max_file_length              = 40000, -- Disable if file is longer than this (in lines)
      preview_config               = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    },
    keys = {
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview Git hunk" },
      --{ "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Git Blame on Current Line" },
      { "<leader>gn", "<cmd>Gitsigns next_hunk<CR>",    desc = "Next git hunk" },
      { "<leader>gN", "<cmd>Gitsigns prev_hunk<CR>",    desc = "Prev git hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",   desc = "Stage git hunk" },
      { "<leader>gu", "<cmd>Gitsigns reset_hunk<CR>",   desc = "Undo git hunk" },
      { "<leader>tb", toggleGitBase,                    desc = "Toggle Git Base" }
    }
  },

  -------------- 2. Integrate Base of Gitsigns with Lualine -----------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "cbochs/grapple.nvim" }
    },
    opts = {
      sections = {
        lualine_x = { showGitBase }
      }
    }
    -- opts = function(_, opts)
    --   table.insert(opts.sections.lualine_x, { showGitBase })
    -- end,
  },

  -------------- 3. Neogit -----------------
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
    keys = {
      { "<leader>gm", "<cmd>Neogit<CR>", desc = "Open Magit" },
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Magit" },
    }
  },

  -------------- 4. Diffview -----------------
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "Open diffview" },
    }
  },

  -------------- 4. Fugitive(for git diff, blame, and git log) -----------------

  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gd", ":Gvdiff",               desc = "Git Diff this file" },
      { "<leader>gb", "<cmd>Git blame<CR>",    desc = "Git Blame" },
      { "<leader>gl", "<cmd>Gclog -10000<CR>", desc = "Git log" },
    }
  },
}