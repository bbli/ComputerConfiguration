function CopilotQuickChat()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input)
  end
end

vim.api.nvim_command('command! CopilotQuickChat lua CopilotQuickChat()')

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- Change Prompt Actions to <leade> a h
    -- Leave default toggle
    -- Unmap everything else
    keys = {
      { "<leader>ax", false },
      { "<leader>aq", false },
      {
        "<leader>ac",
        CopilotQuickChat,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },

    }
  }
}
