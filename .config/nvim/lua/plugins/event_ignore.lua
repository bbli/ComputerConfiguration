vim.g.toggle_event_ignore = 0
function ToggleEventIgnore()
  if vim.g.toggle_event_ignore == 0 then
    vim.g.toggle_event_ignore = 1
    vim.cmd("setlocal eventignore=all")
  else
    vim.g.toggle_event_ignore = 0
    vim.cmd("setlocal eventignore=")
  end
end
vim.api.nvim_set_keymap(
  "n",
  "<leader>te",
  ":lua ToggleEventIgnore()<CR>",
  { noremap = true, silent = true, desc = "Toggle QuickFix List" }
)

local function ShowEventIgnore()
  if vim.g.toggle_event_ignore == 1 then
    return "I"
  else
    return ""
  end
end
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {},
    opts = function(_, opts)
      table.insert(opts.sections.lualine_b, { ShowEventIgnore })
    end,
  },
}
