local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
local config = {
    -- Enable virtual text
    virtual_text = true,
    virtual_lines = false;
    -- show signs
    signs = {
        active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
}
--vim.fn.sign_define("LspDiagnosticsSignError", {text = "", numhl = "LspDiagnosticsDefaultError"})
--vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", numhl = "LspDiagnosticsDefaultWarning"})
--vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "", numhl = "LspDiagnosticsDefaultInformation"})
--vim.fn.sign_define("LspDiagnosticsSignHint", {text = "", numhl = "LspDiagnosticsDefaultHint"})

vim.diagnostic.config(config)

require("mason").setup{
    log_level = vim.log.levels.DEBUG
    }
require("lspconfig")

require("mason-lspconfig").setup({
    ensure_installed = {"vimls","bashls","perlnavigator","pyright"},
    automatic_installation = true,
})

-- General
vim.lsp.set_log_level("info")
local new_default_capabilities = require('cmp_nvim_lsp').default_capabilities()
-- FUTURE: create lua variable to store the home path expansion
-- require('lspconfig').elixirls.setup {
--   cmd = { "/home/benson/.local/bin/language_server.sh" },
--   -- on_attach = new_default_on_attach
-- }
-- less_capabilities = vim.lsp.protocol.make_client_capabilities()
-- less_capabilities.workspace.symbol = nil
 require'lspconfig'.ccls.setup {
     -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
    init_options = {
     cache = {
       directory = ".ccls-cache";
     };
   },
--   handlers = {
--     ["workspace/symbol"] =  function(...)
--       return nil
--     end
--   }
 }

-- clangd
--require'lspconfig'.clangd.setup{
--    cmd = {"clangd"},
--    -- cmd = {"clangd","--log=verbose"},
--    -- on_attach = new_default_on_attach,
--    capabilities = new_default_capabilities,
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
local sumneko_binary = "lua-language-server"
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
   -- capabilities = new_default_capabilities,
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
require'lspconfig'.perlnavigator.setup{
   capabilities = new_default_capabilities,
}
-- require'lspconfig'.perlls.setup{
--     cmd = { "perl", "-MPerl::LanguageServer", "-e", "Perl::LanguageServer::run", "--", "--port 13603", "--nostdio 0", "--version 2.1.0" },
--     -- on_attach = new_default_on_attach,
--     capabilities = new_default_capabilities,

--     filetypes = { "perl" },
-- --    root_dir = ".",
--     settings = {
--       perl = {
--         fileFilter = { ".pm", ".pl" },
--         ignoreDirs = ".git",
--         perlCmd = "perl",
--         perlInc = " "
--       }
--   }
-- }

--pylsp
require'lspconfig'.pyright.setup{
    -- on_attach = new_default_on_attach,
    capabilities = new_default_capabilities,
    root_dir = function(fname)
             return util.root_pattern(".git")(fname) or vim.fn.getcwd()    
         end,
}
--gopls
-- require'lspconfig'.gopls.setup{
--     -- on_attach = new_default_on_attach,
--     capabilities = new_default_capabilities,
-- }
-- require'lspconfig'.ccls.setup {
--    capabilities = new_default_capabilities,
--   -- init_options = {
--   --   cache = {
--   --     directory = ".ccls-cache";
--   --   };
--   -- }
-- }

-- require('litee.lib').setup({})
-- require('litee.calltree').setup({
--     on_open = "panel",
--     panel = {
--         panel_size = 50
--     }
-- })
-- require('litee.symboltree').setup({})
