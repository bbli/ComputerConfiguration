-- print("loaded nvim-lspconfig")
-- General
local new_default_capabilities = require('cmp_nvim_lsp').default_capabilities()
--clangd
require'lspconfig'.clangd.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
}
-- FUTURE: create lua variable to store the home path expansion
require('lspconfig').elixirls.setup {
  cmd = { "/home/benson/.local/bin/language_server.sh" },
  -- on_attach = new_default_on_attach
}
--require'lspconfig'.ccls.setup {
--    on_attach = new_default_on_attach,
   capabilities = new_default_capabilities,
--  init_options = {
--    cache = {
--      directory = ".ccls-cache";
--    };
--  }
--}
--cmake
require'lspconfig'.cmake.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
}

--vimls
require'lspconfig'.vimls.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
}

-- Rust Tools
require('rust-tools').setup({
    server = {
        -- on_attach = new_default_on_attach,
        capabilities = new_default_capabilities,
    }

})

require("neodev").setup({
    -- add any options here, or leave empty to use the default settings
})
-- Lua Language Server
local sumneko_binary = "/usr/bin/lua-language-server"
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary},
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}
--perl
local util = require 'lspconfig/util'
--require'lspconfig'.perlpls.setup{
--    cmd = { "pls" },
--    on_attach = new_default_on_attach,
   capabilities = new_default_capabilities,
--
--    filetypes = { "perl" },
--    --root_dir = ".",
-- root_dir = function(fname)
--      return util.root_pattern(".git")(fname) or vim.fn.getcwd()    
--      end,
--    settings = {
--      perl = {
--        perlcritic = {
--          enabled = true
--        }
--      }
--  }
--}
require'lspconfig'.perlls.setup{
    cmd = { "perl", "-MPerl::LanguageServer", "-e", "Perl::LanguageServer::run", "--", "--port 13603", "--nostdio 0", "--version 2.1.0" },
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,

    filetypes = { "perl" },
--    root_dir = ".",
    settings = {
      perl = {
        fileFilter = { ".pm", ".pl" },
        ignoreDirs = ".git",
        perlCmd = "perl",
        perlInc = " "
      }
  }
}

--pylsp
require'lspconfig'.pyright.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
}
--gopls
require'lspconfig'.gopls.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
}
