vim.g.toggleGitBase = true
function toggleGitBase()
  if vim.g.toggleGitBase then
    vim.g.toggleGitBase = false
    require("gitsigns").change_base("area/foundation")
  else
    vim.g.toggleGitBase = true
    require("gitsigns").change_base()
  end
end

local function showGitBase()
  if vim.g.toggleGitBase then
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
