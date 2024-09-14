--require'treesitter-context'.setup{
--    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--    throttle = true, -- Throttles plugin updates (may improve performance)
--}
-- hb -> go to block
-- hf -> go to function
-- hc -> go to class

vim.keymap.set("n", "<leader>ht", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })
