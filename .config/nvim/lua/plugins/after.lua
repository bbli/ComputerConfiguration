function GetAllBuffers()
  return vim.api.nvim_list_bufs()
end

function PrintTable(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(k .. ":")
      PrintTable(v)
    else
      print(k .. ": " .. tostring(v))
    end
  end
end
vim.cmd([[
nnoremap <silent> <leader>al :call matchadd('Search', '\%'.line('.').'l')<CR>
nnoremap <silent> <leader>ac :call clearmatches()<CR>
]])

local function cpp_format_on_exit(job_id, data, event)
  vim.cmd("bufdo e")
end

vim.cmd([[autocmd BufWritePost *.cpp lua make_async()]])
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.cpp, *.h" },
  callback = function()
    local handle = vim.loop.spawn("make clang-format-patch-stack", {
      on_exit = cpp_format_on_exit,
    })
  end,
})

return {
  --  "LazyVim/LazyVim",
}
