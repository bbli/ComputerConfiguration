-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- NOTE: Most of the code here is to modify Vim core's behavior, instead of plugins

-------------- 1. Individual deleting of unwanted LazyVim keymaps -----------------
vim.keymap.del("n", "<leader>gB")
vim.keymap.del("n", "<leader>ge")
vim.keymap.del("n", "<leader>gG")
vim.keymap.del("n", "<leader>gL")

-------------- 2. Workspace Keymaps -----------------
vim.api.nvim_set_keymap("n", "<leader>wk", ":tabc<CR>", { noremap = true, silent = true, desc = "Kill Workspace" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>wO",
  "<C-w>T",
  { noremap = true, silent = true, desc = "Tear off Buffer to new Workspace" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>wo",
  ":tab split<CR>",
  { noremap = true, silent = true, desc = "Open Buffer in new Workspace" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>wp",
  ":tabprevious<CR>",
  { noremap = true, silent = true, desc = "Previous workspace" }
)
vim.api.nvim_set_keymap("n", "<leader>wn", ":tabnext<CR>", { noremap = true, silent = true, desc = "Next workspace" })

-------------- 3. Buffer Keymaps -----------------
vim.api.nvim_set_keymap("n", "<leader>bs", "<C-^>", { noremap = true, silent = true, desc = "Next workspace" })
vim.api.nvim_set_keymap("n", "<leader>bk", ":bwipeout<CR>", { noremap = true, silent = true, desc = "Next workspace" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>bb",
  "<cmd>Telescope buffers<CR>",
  { noremap = true, silent = true, desc = "Next workspace" }
)
-------------- 4. Toggle Keymaps -----------------
vim.api.nvim_set_keymap(
  "n",
  "<leader>tt",
  "<cmd>AerialToggle<CR>",
  { noremap = true, silent = true, desc = "Next workspace" }
)

vim.g.toggle_qf = 0
function ToggleQuickFixList()
  if vim.g.toggle_qf == 0 then
    vim.g.toggle_qf = 1
    vim.cmd("copen")
  else
    vim.g.toggle_qf = 0
    vim.cmd("cclose")
  end
end
vim.api.nvim_set_keymap(
  "n",
  "<leader>tq",
  ":lua ToggleQuickFixList()<CR>",
  { noremap = true, silent = true, desc = "Toggle QuickFix List" }
)

-------------- 4. LocalLeader Keymaps -----------------
vim.g.maplocalleader = "-"
vim.api.nvim_set_keymap(
  "n",
  "<localleader>v",
  ":e ~/.vimrc<CR>",
  { noremap = true, silent = true, desc = "Open vimrc" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>b",
  ":e ~/.bash_aliases<CR>",
  { noremap = true, silent = true, desc = "Open bash aliases" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>t",
  ":e ~/.tmux.conf<CR>",
  { noremap = true, silent = true, desc = "Open bash aliases" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>g",
  ":e ~/.gitconfig<CR>",
  { noremap = true, silent = true, desc = "Open git config" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>g",
  ":e ~/.gitconfig<CR>",
  { noremap = true, silent = true, desc = "Open git config" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>n",
  ":e ~/.config/nvim/init.vim<CR>",
  { noremap = true, silent = true, desc = "Open init.vim" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>k",
  ":e ~/.config/kitty/kitty.conf<CR>",
  { noremap = true, silent = true, desc = "Open kitty conf" }
)
vim.api.nvim_set_keymap(
  "n",
  "<localleader>f",
  ":e ~/.config/fish/config.fish<CR>",
  { noremap = true, silent = true, desc = "Open kitty conf" }
)
