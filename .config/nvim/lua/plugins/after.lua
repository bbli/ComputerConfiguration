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

function AutoFormatOnSave()
  local Job = require("plenary.job")
  Job:new({
    command = "make",
    args = { "clang-format-patch-stack" },
    on_exit = function(job, return_val)
      vim.cmd("bufdo checktime")
    end,
  }):start()
end
vim.cmd([[
autocmd BufWritePost *.cpp,*.h lua AutoFormatOnSave()
]])

return {
  --  "LazyVim/LazyVim",
}
