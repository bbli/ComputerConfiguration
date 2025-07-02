vim.g.git_base = "index"
vim.api.nvim_create_user_command("ChangeGitBase", function(opts)
  if opts.args == "" then
    vim.g.git_base = "index"
    require("gitsigns").change_base(nil, true)
  else
    vim.g.git_base = opts.args
    require("gitsigns").change_base(opts.args, true)
  end
end, { nargs = "?" })
function toggleGitBase()
  if vim.g.toggleGitBase == 0 then
    vim.g.toggleGitBase = 1
    require("gitsigns").change_base("area/foundation")
  else
    vim.g.toggleGitBase = 0
    require("gitsigns").change_base()
  end
end

return {
  -------------- 1. Gitsigns -----------------
  {

    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function() end, -- disable LazyVim's code, which will set keymaps which I don't want
      -- signs                        = {
      --   add          = { text = '+' },
      --   change       = { text = '│' },
      --   delete       = { text = '-' },
      --   topdelete    = { text = '‾' },
      --   changedelete = { text = '│' },
      --   untracked    = { text = '+' },
      -- },
      --base                         = "area/foundation",
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 100,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
    keys = {
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview Git hunk" },
      { "<leader>tg", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Git Blame on Current Line" },
      { "<leader>gn", "<cmd>Gitsigns next_hunk<CR>", desc = "Next git hunk" },
      { "<leader>gN", "<cmd>Gitsigns prev_hunk<CR>", desc = "Prev git hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage git hunk" },
      { "<leader>gu", "<cmd>Gitsigns reset_hunk<CR>", desc = "Undo git hunk" },
      { "<leader>tb", ":ChangeGitBase ", desc = "Change Git Base" },
      {
        "<leader>th",
        function()
          require("gitsigns").change_base("HEAD~1")
        end,
        desc = "Change Git Base",
      },
      { "<leader>gq", ":lua require('gitsigns').setqflist()<CR>", desc = "Load hunks into Quickfix List" },
    },
  },

  -------------- 2. Neogit/Magit -----------------
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      --"sindrets/diffview.nvim",
      "ibhagwan/fzf-lua", -- optional
    },
    config = true,
    opts = {
      mappings = {
        status = {
          ["E"] = "GoToFile",
          ["<CR>"] = "Toggle",
          ["<c-n>"] = "GoToNextHunkHeader",
          ["<c-p>"] = "GoToPreviousHunkHeader",
        },
      },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit" },
    },
  },

  {
    "jreybert/vimagit",
    keys = {
      { "<leader>gm", "<cmd>Magit<CR>", desc = "Open Magit" },
    },
  },

  -------------- 4. Diffview -----------------
  {
    "sindrets/diffview.nvim",
    event = "VimEnter",
    keys = {
      { "<leader>gD", ":DiffviewOpen ", desc = "Open diffview" },
      { "<leader>gf", ":DiffviewFileHistory %<CR>", desc = "Open diffview on this file" },
    },
  },

  -------------- 4. Fugitive(for git diff, blame, and git log) -----------------

  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gd", ":Gvdiff", desc = "Git Diff this file" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git Blame" },
      { "<leader>gl", "<cmd>Gclog -1000<CR>", desc = "Git Log" },
      { "<leader>gS", ":Gclog -1000 -S ", desc = "Git Pickaxe" },
    },
  },
}
