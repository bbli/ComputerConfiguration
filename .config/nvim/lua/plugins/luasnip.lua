local luasnip = require("luasnip")
-- local types = require("luasnip.util.types")

-- require("luasnip.loaders.from_lua").load({
--     paths = "~/Dropbox/Code/dotfiles/my-snippets"
-- })
require("luasnip.loaders.from_snipmate").lazy_load()
-- 1. CONFIGURATION
luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})

-- press <Tab> to expand or jump in a snippet. These can also be mapped separately
-- via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
-- imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
-- vim.cmd[[
-- imap <silent> zz <cmd>lua require('luasnip').expand()<Cr>
-- ]]
vim.keymap.set("i", "zz", function()
  require("luasnip").expand()
end)

vim.cmd([[
inoremap <silent> <C-l> <cmd>lua require'luasnip'.jump(1)<Cr>
inoremap <silent> <C-h> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <C-l> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <C-h> <cmd>lua require('luasnip').jump(-1)<Cr>
]])

-- For changing choices in choiceNodes (not strictly necessary for a basic setup).
vim.cmd([[
imap <silent><expr> <C-e> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-e>'
smap <silent><expr> <C-e> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-e>'
]])

local ls = require("luasnip")
-- some shorthands...
local snip = ls.snippet
local func = ls.function_node
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet

local date = function()
  return { os.date("%Y-%m-%d") }
end

-- Example of creating a function node
local same = function(index)
  return f(
    function(arg)
      return arg[1]
    end, -- takes function as first parameter
    { index } -- and TABLE of INDEX/INDEXES to pass to the first paramter function(will be in value form)
  )
end
ls.add_snippets(nil, {
  all = {
    snip({ trig = "date", namr = "Date", dscr = "Date in the form of YYYY-MM-DD" }, { func(date, {}) }),
    -- Example of passing a function
    snip("sametest", fmt("example: {}, function: {} ", { i(1), same(1) })),
  },
  rust = {
    snip("sd", fmt([[// **************** {} ****************]], i(1, ""))),
  },
  lua = {
    -- Example of using rep(), which is a higher order function
    snip(
      { trig = "asdfd", dscr = "Top Level Comment with Vim Level 1 Fold Marker" },
      fmt("Text to insert {} and stuff {}", { i(1, "default"), rep(1) })
    ),
    snip("sd", fmt([[-- **************** {} ****************]], i(1, ""))),
  },
  python = {
    snip("sd", fmt([[# **************** {} ****************]], i(1, ""))),
  },
  cpp = {
    snip("sd", fmt([[// **************** {} ****************]], i(1, ""))),
    snip("dd", fmt([[PS_DIAG_INFO(d_,"BENSON_DEBUG:: %%:%%  {}:{}",__FILE__, __LINE__);]], { i(1, ""), i(2, "") })),
    snip(
      "dv",
      fmt([[PS_DIAG_INFO(d_,"BENSON_DEBUG:: %%:%%  {}:{}=%%",__FILE__, __LINE__,{});]], { i(1, ""), i(2, ""), rep(2) })
    ),
  },
})
return {
  -- just use LazyVim's configuration, as we just wanted to add keymaps and snippets
}
