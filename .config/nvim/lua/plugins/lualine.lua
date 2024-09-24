local function showGitBase()
  if vim.g.toggleGitBase == 0 then
    return "index"
  else
    return "foundation"
  end
end
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "cbochs/grapple.nvim" },
      { "lewis6991/gitsigns.nvim" },
    },
    opts = {
      options = {
        globalstatus = false,
      },
      sections = {
        lualine_x = {
          { require("grapple").statusline },
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
        lualine_z = { showGitBase },
      },
    },
  },
}
