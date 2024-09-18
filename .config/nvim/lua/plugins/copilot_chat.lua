local M = {}
function M.pick(kind)
  return function()
    local actions = require("CopilotChat.actions")
    local items = actions[kind .. "_actions"]()
    if not items then
      LazyVim.warn("No " .. kind .. " found on the current line")
      return
    end
    local ok = pcall(require, "fzf-lua")
    require("CopilotChat.integrations." .. (ok and "fzflua" or "telescope")).pick(items)
  end
end
function CopilotQuickChat()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input)
  end
end

vim.api.nvim_command("command! CopilotQuickChat lua CopilotQuickChat()")

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      { "<leader>ax", false },
      { "<leader>aq", false },
      {
        "<leader>aa",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle CopilotChat",
        mode = { "n", "v" },
      },
      -- Show help actions with telescope
      { "<leader>ad", M.pick("help"), desc = "Diagnostic Help (CopilotChat)", mode = { "n", "v" } },
      -- Show prompts actions with telescope
      { "<leader>ap", M.pick("prompt"), desc = "Prompt Actions (CopilotChat)", mode = { "n", "v" } },
      {
        "<leader>ac",
        CopilotQuickChat,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
    },
  },
}
