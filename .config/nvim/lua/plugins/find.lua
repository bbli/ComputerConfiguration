require("benson-util")
vim.cmd([[
if executable("rg")
  set grepprg=rg
  set grepformat=%f:%l:%c:%m
endif
]])

local rg_options = '--vimgrep --hidden -g "!.git" -g "!*.log" -g "!Triage/" -g "!.ccls-cache/"'
local only_nfs_options =
  '-g "!system/" -g "!ir_test/" -g "!ui/" -g "!tpc/" -g "!ir_test/" -g "!http/" -g "!environment/" -g "!infra/" -g "!hardware/" -g "!platform/" -g "!tools/" -g "!patches/" -g "!pb/"'
function RipGrepProjectHelper(pattern, path)
  -- we cannot use shell escape b/c it will SINGLE QUOTE the pattern ->
  -- which prevents passing ADDITIONAL ARGUMENTS
  vim.cmd("silent grep " .. rg_options .. " " .. pattern .. " " .. path)
  vim.cmd("copen")
end

function RipGrepHelperOnlyNFS(pattern, path)
  -- we cannot use shell escape b/c it will SINGLE QUOTE the pattern ->
  -- which prevents passing ADDITIONAL ARGUMENTS
  vim.cmd("silent grep " .. rg_options .. " " .. only_nfs_options .. " " .. pattern .. " " .. path)
  vim.cmd("copen")
end

function RipGrepCurrentFile(pattern)
  local file = vim.fn.expand("%:p")
  vim.cmd("silent grep " .. rg_options .. " " .. pattern .. " " .. file)
  vim.cmd("copen")
end

function GetPathOfCurrentFile()
  return vim.fn.expand("%p:h")
end

function KeepOnlyNFS()
  vim.cmd("Reject system/")
  vim.cmd("Reject ir_test/")
  vim.cmd("Reject ui/")
  vim.cmd("Reject tpc/")
  vim.cmd("Reject ir_test/")
  vim.cmd("Reject http/")
  vim.cmd("Reject environment/")
  vim.cmd("Reject infra/")
  vim.cmd("Reject hardware/")
  vim.cmd("Reject platform/")
  vim.cmd("Reject tools/")
  vim.cmd("Reject patches/")
  vim.cmd("Reject pb/")
end
vim.cmd([[
command! -nargs=1 RipGrepProject lua RipGrepProjectHelper(<q-args>,FindGitRoot())
command! -nargs=1 RipGrepCurrentDirectory lua RipGrepProjectHelper(<q-args>,GetPathOfCurrentFile())
command! -nargs=1 RipGrepCurrentFile lua RipGrepCurrentFile(<q-args>)
autocmd FileType qf command! -nargs=0 OnlyNFS lua KeepOnlyNFS()
command! -nargs=1 RipGrepNFS lua RipGrepHelperOnlyNFS(<q-args>,FindGitRoot())
nnoremap <leader>fp :RipGrepProject 
nnoremap <leader>fa :RipGrepCurrentDirectory 
nnoremap <leader>fw :RipGrepProject "\b<C-r><C-w>\b"<CR>
]])

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>fl", ":RipGrepCurrentFile " },
    { "<leader>fn", ":RipGrepNFS " },
  },
}
-- TODO: get autocomplete on command line
