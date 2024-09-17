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

-------------- 2. Toggle Keymaps -----------------
vim.api.nvim_set_keymap(
  "n",
  "<leader>tt",
  "<cmd>AerialToggle<CR>",
  { noremap = true, silent = true, desc = "Next workspace" }
)
