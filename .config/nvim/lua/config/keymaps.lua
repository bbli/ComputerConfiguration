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
]])
-- -- benson_lsp_status
