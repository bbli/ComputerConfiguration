let &packpath = &runtimepath
set runtimepath^=~/.vim runtimepath+=~/.vim/after
source ~/.vimrc
" Only available in neovim
set inccommand=nosplit
let g:vimsyn_embed= 'l'
" ************** Helper Functions **************%%%1
lua << EOF
P = function(v)
        print(vim.inspect(v))
        return
    end
EOF
nnoremap <leader><leader>e :source %<CR>

" ************  Neovim 0.5 Specific Plugins  ************%%%1
lua << EOF
require('packer').startup(function()
use '~/Desktop/random_things/lua_plugin'
-- Packer can manage itself
use 'wbthomason/packer.nvim'
-- ************  UTILITY LIBRARIES  ************ %%%2
use 'nvim-lua/popup.nvim'
use 'nvim-lua/plenary.nvim'
-- ************  Workflows  ************ %%%2
use { 'michaelb/sniprun', run = 'bash ./install.sh'}
use 'metakirby5/codi.vim'
-- These plugins don't really work as intended
--use {'ldelossa/litee.nvim'}
---- use {'ldelossa/litee-symboltree.nvim'}
--use {'ldelossa/litee-calltree.nvim',
--    config = function() require("plugins.litee") end,
--    requires = {{'ldelossa/litee.nvim'}}
--    }
use {'simrat39/symbols-outline.nvim',
    config = function() require("plugins.symbols-outline") end,
}
use {'sindrets/winshift.nvim',
    config = function() require("plugins.winshift") end,
}
use {'nvim-telescope/telescope.nvim',
    config = function() require("plugins.telescope") end,
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
-- need nvim 0.8
use {
    "cbochs/grapple.nvim",
    config = function() require("plugins.grapple") end
}
--use {
--  "princejoogie/dir-telescope.nvim",
--  -- telescope.nvim is a required dependency
--  requires = {"nvim-telescope/telescope.nvim"},
--  config = function() require("plugins.dir-telescope") end,
--}
--use {'LukasPietzschmann/telescope-tabs',
--    config = function() require("plugins.telescope-tabs") end,
--    }
use {'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    config = function() require("plugins.telescope-fzf-native") end,
    after = 'telescope.nvim',
    requires = {'nvim-telescope/telescope.nvim'}
    }
--use {'GustavoKatel/telescope-asynctasks.nvim',
--  requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}, {'nvim-telescope/telescope.nvim'}}
--  }

use {"AckslD/nvim-neoclip.lua", 
    config = function () require("plugins.nvim-neoclip") end,
    requires = {
        {'tami5/sqlite.lua', module = 'sqlite'},
        {'nvim-telescope/telescope.nvim'},
    },
}

--use {'stevearc/qf_helper.nvim'} --location tracking not working atm, but useful for toggling with no entries

-- the issue with harpoon is that I need to show it on some UI -> aka Telescope!
--use {'thePrimeagen/harpoon',
--    config = function() require("plugins.harpoon") end,
--    requires = 'nvim-lua/plenary.nvim',
--    after = 'telescope.nvim',
--}
use {'lewis6991/gitsigns.nvim',
    tag = "v0.5",
    config = function() require('plugins.gitsigns') end,
}
use 'f-person/git-blame.nvim'
-- ************  Text Manipulation/Movement  ************ %%%2
--use {"ggandor/lightspeed.nvim", 
--    config = function() require("plugins.lightspeed") end,
--}
use {"L3MON4D3/LuaSnip",
    after = "nvim-cmp",
    config = function() require("plugins.LuaSnip") end,
}
-- since above was hard to configure for my own snippets
--use {"dcampos/nvim-snippy",
 --   config = function() require("plugins.nvim-snippy") end,
--}

-- ************  LSP STUFF  ************ %%%2
-- TODO: check that mason-lspconfig works on mac, where language servers made not be installed?
use {"williamboman/mason.nvim",
}
use {"williamboman/mason-lspconfig.nvim",
    requires = {"williamboman/mason.nvim"},
}
use {'neovim/nvim-lspconfig',
    requires = {"williamboman/mason.nvim"},
}
use {'jose-elias-alvarez/null-ls.nvim',
    config = function () require("plugins.null-ls") end,
    requires = { "nvim-lua/plenary.nvim" },
}
-- use {'github/copilot.vim'}


--use({
--  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
--  config = function()
--    require("lsp_lines").setup()
--  end,
--})
-- use 'ldelossa/calltree.nvim'
use 'andersevenrud/cmp-tmux'
use'hrsh7th/cmp-nvim-lsp'
use'hrsh7th/cmp-buffer'
use'hrsh7th/cmp-path' -- kinda useless
use'hrsh7th/cmp-cmdline' -- also kinda useless
use 'hrsh7th/cmp-nvim-lsp-signature-help'
--  use 'hrsh7th/cmp-vsnip' -- make lsp status not show warnings
--  use 'hrsh7th/vim-vsnip'
use 'saadparwaiz1/cmp_luasnip'
use {'hrsh7th/nvim-cmp',
    config = function() require("plugins.nvim-cmp") end,
}
use {'quangnguyen30192/cmp-nvim-tags', requires = 'hrsh7th/nvim-cmp' }
  --use {'tzachar/cmp-fuzzy-buffer', requires = {'hrsh7th/nvim-cmp', 'tzachar/fuzzy.nvim'}}
-- copilot LSP interferes with regular LSP
use {
    "zbirenbaum/copilot.lua" ,
    config = function()
        require("copilot").setup()
    end
}
use {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    requires = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    config = function()
         require("plugins.copilot_chat")
    end
}

use {'onsails/lspkind-nvim'}
--use 'glepnir/lspsaga.nvim'
use {'kosayoda/nvim-lightbulb',
    config = function() require("plugins.nvim-lightbulb") end,
}
use 'simrat39/rust-tools.nvim'
use {'bbli/nvim-code-action-menu',
    config = function() require("plugins.nvim-code-action-menu") end,
}
--use {"ray-x/lsp_signature.nvim",
--    config = function() require("lsp_signature").setup() end,
--} --I prefer snippet solution better as it doesn't clutter the above line -> but snippet doesn't always work
-- tagbar/vista is better b/c it shows the current hovered function
--use 'simrat39/symbols-outline.nvim'
---- ************  TREE SITTER  ************ %%%2
use { 'nvim-treesitter/nvim-treesitter',
  config = function() require('plugins.nvim-treesitter') end,
  run = ':TSUpdate'
}

use {'nvim-treesitter/nvim-treesitter-textobjects',
  requires = {'nvim-treesitter/nvim-treesitter'},
}
----use 'haringsrob/nvim_context_vt'
---- use 'RRethy/nvim-treesitter-textsubjects'
----use 'mizlan/iswap.nvim'
----use 'JoosepAlviste/nvim-ts-context-commentstring'
use {'romgrk/nvim-treesitter-context',
    requires = {'nvim-treesitter/nvim-treesitter'},
    config = function() require('plugins.nvim-treesitter-context') end,
}
use {'andymass/vim-matchup',
    requires = {'nvim-treesitter/nvim-treesitter'},
}
  -- ************  DEBUGGER  ************ %%%2
  --use 'mfussenegger/nvim-dap'
  --use 'mfussenegger/nvim-dap-python' --Actualy, supposedly vim-ultest will cover this?
  --use 'theHamsta/nvim-dap-virtual-text'
  --use 'nvim-telescope/telescope-dap.nvim'

  -- ************  GIT  ************ %%%2
  --use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
use {'sindrets/diffview.nvim',
    config = function() require("plugins.diffview") end,
  }
  -- ************  LUA PLUGIN DEVELOPMENT  ************ %%%2
  use 'euclidianAce/BetterLua.vim'
  use 'rafcamlet/nvim-luapad'
  use 'folke/neodev.nvim'
  -- ************  MISC/AESTHETICS  ************ %%%2
use {'folke/trouble.nvim',
    config = function() require("plugins.trouble") end,
    requires = 'kyazdani42/nvim-web-devicons'
}
use {'folke/todo-comments.nvim',
    config = function() require"plugins.todo-comments" end,
    requires = "nvim-lua/plenary.nvim"
    }
use {'windwp/nvim-autopairs',
    config = function() require("plugins.nvim-autopairs") end,
}
use {
  "folke/zen-mode.nvim",
  config = function() require("zen-mode").setup {
      kitty = {
          enabled = false,
          font = "+4", -- font size increment
        },
    } end
}
use {"lukas-reineke/indent-blankline.nvim",
    config = function() require("plugins.blankline") end
}
use {
    'kyazdani42/nvim-web-devicons',
    config = function() require('nvim-web-devicons').setup{default = true} end,
}
use {'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  config = function() require("plugins.lualine") end
}
use {'kdheepak/tabline.nvim',
    requires = {  'nvim-lualine/lualine.nvim', 'kyazdani42/nvim-web-devicons' },
    config = function() require("plugins.tabline") end
}
use {'folke/lsp-colors.nvim',
    config = function() require("lsp-colors").setup() end,
}
-- lsp status as virtual text at bottom left
use {'j-hui/fidget.nvim',
    config = function() require("plugins.fidget") end,
} 
  --use {
--      "folke/twilight.nvim",
 --     config = function() require("twilight").setup { } end
  --}
--use { 'pwntester/octo.nvim',
--  requires = {
--    'nvim-lua/plenary.nvim',
--    'nvim-telescope/telescope.nvim',
--    'kyazdani42/nvim-web-devicons',
--  },
--  config = function ()
--    require"octo".setup()
--  end
--} 
  end
)
require("benson-lsp")
EOF
" ************  Vimscript Functions  ************%%%1
" No point since this is default behavior anyways
" Aka existing vim instance will not be updated b/c it
" only reads once during startup
" function! s:update_oldfiles(file)
"   if g:startify_locked || !exists('v:oldfiles')
"     return
"   endif
"   let idx = index(v:oldfiles, a:file)
"   if idx != -1
"     call remove(v:oldfiles, idx)
"   endif
"   call insert(v:oldfiles, a:file, 0)
" endfunction
function! AutoZenMode()
    if getcmdwintype() == ''
        lua require("benson").autoZenMode()
    endif
endfunction
" autocmd BufEnter *  call AutoZenMode()
nnoremap <leader>tz :ZenMode<CR>
" ************  Misc Neovim Specific Things  ************%%%1

"tnoremap ;c <C-\><C-n>
" number of old files needs to be set higher given I use vim as manpager
set shada='200
if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

" for treesitter
"luafile ~/.init.lua
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
"nnoremap <leader>lt :write | edit | TSBufEnable highlight


" autocmd BufDelete,BufWipeout *
"           \ call s:update_oldfiles(expand('<afile>:p'))

command! Scratch lua require'tools'.makeScratch()
"au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}
" lua text will be syntax highlighted!
let g:vimsyn_embed = 'l'


""From: https://www.reddit.com/r/neovim/comments/l00zzb/improve_style_of_builtin_lsp_diagnostic_messages/
"" Errors in Red
"hi LspDiagnosticsVirtualTextError guifg=Red ctermfg=Red
"" Warnings in Yellow
"hi LspDiagnosticsVirtualTextWarning guifg=Yellow ctermfg=Yellow
"" Info and Hints in White
"hi LspDiagnosticsVirtualTextInformation guifg=White ctermfg=White
"hi LspDiagnosticsVirtualTextHint guifg=White ctermfg=White

"" Underline the offending code
"hi LspDiagnosticsUnderlineError guifg=NONE ctermfg=NONE cterm=underline gui=underline
"hi LspDiagnosticsUnderlineWarning guifg=NONE ctermfg=NONE cterm=underline gui=underline
"hi LspDiagnosticsUnderlineInformation guifg=NONE ctermfg=NONE cterm=underline gui=underline
"hi LspDiagnosticsUnderlineHint guifg=NONE ctermfg=NONE cterm=underline gui=underline

" lua << EOF
" vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
"  vim.lsp.diagnostic.on_publish_diagnostics, {
"    -- Enable underline, use default values
"    underline = true,
"    -- Enable virtual text only on Warning or above, override spacing to 2
"    virtual_text = {
"      spacing = 2,
"      severity_limit = "Warning",
"    },
" --   virtual_text = false,
"    signs = true,
"    update_in_insert = false,
"  }
" )
" EOF

"autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
" nnoremap <unique> <leader>ot :Telescope<CR>

nnoremap <leader>jd <cmd>Telescope lsp_definitions<CR>
" nnoremap <leader>js :vs<CR>:lua vim.lsp.buf.definition()<CR>
" nnoremap <leader>js <cmd>lua require("benson").smartJumpSplit()<CR>
nnoremap <leader>jD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>jr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <leader>jr <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <leader>ji <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>je <cmd>lua vim.diagnostic.goto_next({float=true})<CR>
nnoremap <leader>jE <cmd>lua vim.diagnostic.goto_prev({float=true})<CR>

" nnoremap <leader>fr <cmd>lua vim.lsp.buf.rename()<CR>

nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>jo <cmd>lua vim.lsp.buf.outgoing_calls()<CR>
"though references is better -> will also show from test files too
nnoremap <leader>ji <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <leader>jh <cmd>CclsDerivedHierarchy<CR>
" nnoremap K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
" nnoremap <leader>k <cmd>lua vim.lsp.buf.signature_help()<CR> "Don't really understand this
" nnoremap <silent> ls <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>

"nnoremap <leader>wa <cmd>lua vim.lsp.buf.add_workspace_folder()<CR>
"nnoremap <leader>wl <cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>
"Q: make autocmd on save since asynchronous? Nah since I want
"diagonistic errors and this will only delay
" ****Rest of Lanuage Server****

"nnoremap <leader>lt :write | edit | TSBufEnable highlight
" using indirection since TSBufEnable won't be available until vim fully finishes starting up
" -> Or can put this in an "after directory"?
let @T = "write | edit | TSBufEnable highlight"
nnoremap <leader>lt :<C-R>T<CR>
" nnoremap <leader>lt :GutentagsUpdate!<CR>
" nnoremap <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <unique> <leader><leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
" nnoremap <leader>ll <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
nnoremap <unique> <leader>ls :lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
nnoremap <leader>lr :LspRestart<CR>
"--nnoremap <leader>fr <cmd>lua vim.lsp.buf.rename()<CR>
"nnoremap <leader>jt <cmd>lua vim.lsp.buf.type_definition()<CR> "What is this used for?
"nnoremap <leader>ct <cmd>lua vim.lsp.buf.outgoing_calls()<CR> "Just one level BFS


" Sometimes cmp popup menu will not close
set completeopt=menu,menuone,noselect
" inoremap <expr> <C-j> pumvisible() ?"<C-n>":"<C-j>"
" inoremap <expr> <C-k> pumvisible() ?"<C-p>":"<C-k>"

" ************** Compiling/Running/Terminal Interaction **************%%%1
" nnoremap <leader>pp <cmd>lua require('telescope').extensions.asynctasks.all()<CR>
" nnoremap <leader>pi <cmd>AsyncTaskMacro<CR>
" nnoremap <localleader>a :AsyncTaskEdit<CR>
" ************** Terminal Stuff ************** %%%1
tnoremap <Esc> <C-\><C-n>
tnoremap ;c <C-\><C-n>
let g:terminal_scrollback_buffer_size = 50000
" ************  Rest  ************%%%1
nnoremap <leader>oa <cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--no-ignore-vcs', '--files', '--hidden', '-g', '!.git' , '-g', '!node_modules'}})<cr>
" nnoremap <leader>oa <cmd>Telescope find_files<cr>
nnoremap <leader>oo <cmd>Telescope git_files<cr>
"nnoremap <leader>ug <cmd>Telescope live_grep<cr>
nnoremap <leader>ob <cmd>Telescope buffers<cr>
nnoremap <leader>oh <cmd>Telescope oldfiles<cr>
nnoremap <leader>om <cmd>Telescope help_tags<cr>
nnoremap <leader>oc <cmd>Telescope commands<cr>
nnoremap <M-;> <cmd>Telescope commands<cr>
" TODO: Telescope way better here compared to FZF b/c of preview  -> Harpoon will probably replace though
nnoremap <leader>ul <cmd>Telescope marks<cr>
"TODO: why is the below  not filtering?
nnoremap <leader>or <cmd>Telescope neoclip<cr>
nnoremap <leader>oy <cmd>Telescope neoclip<cr>
"Disable since this is laggy when called at work
" nnoremap <leader>ot <cmd>TodoTrouble<CR>
" nnoremap <leader>ok <cmd>Telescope keymaps<cr>

" These will check out the selected commit/branch
" nnoremap <leader>gb <cmd>Telescope git_branchs<CR>
" Fugitive is better this quickfix does nothing
" nnoremap <leader>gc <cmd>Telescope git_commits<CR>

" nnoremap <leader>ov <cmd>Telescope vim_options<cr>
nnoremap <leader>ok <cmd>Telescope keymaps<cr>
"Use after ripgrep for faster narrowing!
" nnoremap <leader>vv <cmd>Telescope quickfix<cr>
" nnoremap <leader>vl <cmd>Telescope loclist<cr>

nnoremap <leader>jd <cmd>Telescope lsp_definitions<cr>
nnoremap <leader>ji <cmd>Telescope lsp_implementations<cr>
nnoremap <leader>CA <cmd>lua vim.lsp.buf.code_action()<CR>

" imap <silent> zz <cmd>lua require'luasnip'expand()<Cr>
