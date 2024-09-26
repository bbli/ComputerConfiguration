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
  { noremap = true, silent = true, desc = "Break Out Buffer to new Workspace" }
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
vim.api.nvim_set_keymap(
  "n",
  "<leader>bs",
  "<C-^>",
  { noremap = true, silent = true, desc = "Switch to Alternate Buffer" }
)
vim.api.nvim_set_keymap("n", "<leader>bk", ":bwipeout<CR>", { noremap = true, silent = true, desc = "Kill Buffer" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>bb",
  "<cmd>Telescope buffers<CR>",
  { noremap = true, silent = true, desc = "Fuzzy Search Buffers" }
)
-------------- 4. Toggle Keymaps -----------------
function check_filetype(filetype)
  local win_ids = vim.api.nvim_list_wins()
  for _, win_id in ipairs(win_ids) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")
    if buf_filetype == filetype then
      return true
    end
  end
  return false
end

function ToggleQuickFixList()
  local is_quickfix_open = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      is_quickfix_open = true
      break
    end
  end

  if is_quickfix_open then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end
vim.api.nvim_set_keymap(
  "n",
  "<leader>tq",
  ":lua ToggleQuickFixList()<CR>",
  { noremap = true, silent = true, desc = "Toggle QuickFix List" }
)

vim.api.nvim_set_keymap("n", "<leader>tf", "<leader>uf", { desc = "Toggle AutoFormat" })
vim.api.nvim_set_keymap("n", "<leader>td", "<leader>ud", { desc = "Toggle LSP Diagnostics" })

-------------- 4. LocalLeader Keymaps -----------------
vim.cmd([[
nnoremap <localleader>v :e ~/.vimrc<CR>
nnoremap <localleader>b :e ~/.bash_aliases<CR>
nnoremap <localleader>t :e ~/.tmux.conf<CR>
nnoremap <localleader>g :e ~/.gitconfig<CR>
nnoremap <localleader>n :e ~/.config/nvim/lua/plugins/after.lua<CR>
nnoremap <localleader>k :e ~/.config/kitty/kitty.conf<CR>
nnoremap <localleader>f :e ~/.config/fish/config.fish<CR>
nnoremap <localleader>x :e ~/.config/xmonad/xmonad.hs<CR>
nnoremap <localleader>l :e ~/.init.lua<CR>
]])

-------------- 5. Modifier Keys Keymaps -----------------
vim.cmd([[
nnoremap <M-k> :m .-2<CR>==
nnoremap <M-j> :m .+1<CR>==
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

nnoremap <C-w><Space> <C-w>=
nnoremap <C-w>; <C-w>p
]])

-------------- 5. Semicolon Keymaps -----------------
vim.cmd([[
inoremap ;c <C-c>
vnoremap ;c <C-c>
inoremap ;; ;
vnoremap ;w <C-c>:w<CR>
inoremap ;w <C-c>:w<CR>
" nnoremap ;q <C-z>
nnoremap ;q :q<CR>
nnoremap ;z :q!<CR>
nnoremap ;w <C-c>:w<CR>
nnoremap ;n :bn<CR>
nnoremap ;N :bp<CR>
nnoremap <silent> ;d :bwipeout<CR>
nnoremap ;D :bwipeout!<CR>
"inoremap <C-m> <C-C>la
inoremap <C-l> <C-c>la
]])

-------------- 6. Normal Mode Keymaps -----------------
vim.cmd([[
" nnoremap <unique> k gk
" nnoremap <unique> j gj
nnoremap <unique> gk k
nnoremap <unique> gj j
"nnoremap EE @

nnoremap <unique> C c$
nnoremap <unique> D d$
nnoremap Y y$
nnoremap <unique> E $
nnoremap <unique> gE g$
"nnoremap <unique> W 0w
" to jump between brackets/parantheses
nnoremap S %
nnoremap w W
nnoremap W w
nnoremap b B
nnoremap B b
nnoremap n nzz
nnoremap N Nzz

nnoremap <unique> gb gi

" "Training vim skip
" nnoremap <unique> h <Nop>
" nnoremap <unique> l <Nop>
" nnoremap <unique> <C-g> <cmd>close<CR>
" vnoremap <unique> <C-g> <ESC>
"
vnoremap > >gv
vnoremap < <gv
cnoremap sE %s
tmap ;c <Esc><Esc>
]])

-------------- 7. Utility Keymaps -----------------
vim.cmd([[
nnoremap <leader>pp :echo expand('%:p')<CR>
nnoremap <leader><leader>p :echo expand('%:p')<CR>
nmap <leader><leader>c gcc
vmap <leader><leader>c gc
vnoremap Y :'<,'>w ~/copy.txt

nnoremap <leader><leader>m @m
]])

-------------- 7. Jump/LSP Keymaps -----------------
vim.cmd([[
" nnoremap <leader>jd <cmd>Telescope lsp_definitions<CR>
nnoremap <leader>jd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>jD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>jr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>je <cmd>lua vim.diagnostic.goto_next({float=true})<CR>
nnoremap <leader>jE <cmd>lua vim.diagnostic.goto_prev({float=true})<CR>


nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>jo <cmd>lua vim.lsp.buf.outgoing_calls()<CR>
"though references is better -> will also show from test files too
nnoremap <leader>ji <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <leader>jh <cmd>CclsDerivedHierarchy<CR>

" nnoremap <leader>fr <cmd>lua vim.lsp.buf.rename()<CR>
" nnoremap <leader>js :vs<CR>:lua vim.lsp.buf.definition()<CR>
" nnoremap <leader>jr <cmd>lua vim.lsp.buf.incoming_calls()<CR>
" nnoremap <leader>ji <cmd>lua vim.lsp.buf.implementation()<CR>
]])
