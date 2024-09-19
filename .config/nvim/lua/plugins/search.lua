vim.cmd([[
if executable("rg")
  set grepprg=rg
  set grepformat=%f:%l:%c:%m
endif
]])

local rg_options = '--vimgrep --hidden -g "!.git" -g "!output.log" -g "!Triage/" -g "!.ccls-cache/"'
function RipGrepProjectHelper(pattern, path)
  -- we cannot use shell escape b/c it will SINGLE QUOTE the pattern ->
  -- which prevents passing ADDITIONAL ARGUMENTS
  vim.cmd("grep " .. rg_options .. " " .. pattern .. " " .. path)
  vim.cmd("copen")
end

function RipGrepCurrentFile(pattern)
  local file = vim.fn.expand("%:p")
  vim.cmd("grep " .. rg_options .. " " .. pattern .. " " .. file)
  vim.cmd("copen")
end

function FindGitRoot()
  local handle = io.popen("git rev-parse --show-toplevel")
  local git_root = handle:read("*a"):gsub("\n", "")
  handle:close()
  return git_root
end
function GetPathOfCurrentFile()
  return vim.fn.expand("%p:h")
end
vim.cmd([[
command! -nargs=1 RipGrepProject lua RipGrepProjectHelper(<q-args>,FindGitRoot())
command! -nargs=1 RipGrepCurrentDirectory lua RipGrepProjectHelper(<q-args>,GetPathOfCurrentFile())
command! -nargs=1 RipGrepCurrentFile lua RipGrepCurrentFile(<q-args>)
nnoremap <leader>fr :RipGrepCurrentFile 
nnoremap <leader>fp :RipGrepProject 
nnoremap <leader>fa :RipGrepCurrentDirectory 
nnoremap <leader>fw :RipGrepProject "\b<C-r><C-w>\b"<CR>
]])

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search Current Buffer" },
    { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Search LSP Symbols" },
  },
}
-- TODO: get autocomplete on command line
