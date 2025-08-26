-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.cmd([[
autocmd BufEnter * lua vim.diagnostic.config({virtual_text = false})
autocmd BufEnter term://* stopinsert
]])

vim.cmd([[
autocmd BufEnter * nnoremap w w
autocmd BufEnter * nnoremap W W
autocmd BufEnter * nnoremap H H
autocmd BufEnter * nnoremap L L
]])
