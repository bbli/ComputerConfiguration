-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.hidden = true
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.cedit = "<C-e>"
vim.opt.timeoutlen = 200
vim.opt.ttimeoutlen = 50
-- vim.opt.foldmethod = "manual"
--vim.g.autoformat = false
vim.g.maplocalleader = "-"
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = "%%%,%%%"
vim.g.lazyvim_picker = "fzf"
vim.g.markdown_folding = 1
