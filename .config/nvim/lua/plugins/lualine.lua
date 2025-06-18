local function showGitBase()
  return vim.g.git_base
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
          { "searchcount" },
          -- {
          --   require("noice").api.statusline.mode.get,
          --   cond = require("noice").api.statusline.mode.has,
          --   color = { fg = "#ff9e64" },
          -- },
        },
        lualine_z = { showGitBase },
      },
    },
  },
}
