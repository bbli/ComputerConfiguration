require("benson-util")
function ConvertFromContainer(container_filename)
  local root = FindGitRoot()
  return string.gsub(container_filename, "/home/ir/iridium", root)
end

function mysplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

-- Lua version of JumpToFile
function JumpToFile()
  local cword = vim.fn.expand("<cWORD>")
  local fileline = cword:gsub("^%s*(.-)%s*$", "%1") -- trim
  local array = mysplit(fileline, ":")
  if #array > 1 then
    local container_filename = array[1]
    local linenumber = array[2]
    local filename = ConvertFromContainer(container_filename)
    vim.cmd("FloatermHide")
    local s = "edit +" .. linenumber .. " " .. filename
    vim.cmd(s)
  end
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

Last_Term_String = ""
-- vim.cmd("command -nargs=+ ShellSend :lua BensonFloatTermSend(<q-args>)")
vim.api.nvim_exec(
  [[
augroup MakeFloatTermBufferVisible
 autocmd FileType floaterm call setbufvar(bufnr('%'), '&buflisted', 1) 
augroup END
]],
  false
)
function BensonFloatTermSend(term_string)
  -- 1. First let us just try to get command with spaces into Lua
  -- SC: vimscript does this with cword?
  -- SC: check how other plugins do this!!!(harpoon)
  -- Telescope: does this by calling vimscript "getcmdline"
  --
  -- 2. Now just save it as last invocation
  Last_Term_String = term_string

  -- 3. And finally forward it to FloatTermSend
  -- SC: grep pack directory to see if anyone else uses "nvim_cmd"!!!
  vim.api.nvim_command("FloatermShow test")
  vim.api.nvim_command("FloatermSend --name=test " .. term_string)
end

function SendLastStringToTestTerm()
  vim.api.nvim_command("FloatermShow test")
  vim.api.nvim_command("FloatermSend --name=test " .. Last_Term_String)
  -- vim.api.nvim_cmd({cmd="FloatermSend",args={Last_Term_String}},{})
end

-- SC: How does Telescope command_history remember current session + old commands?
function SendStringFromHistory()
  local history_string = vim.fn.execute("history cmd")
  local history_list = vim.split(history_string, "\n")
  local results = {}
  for i = #history_list, 3, -1 do
    local item = history_list[i]
    local _, finish = string.find(item, "%d+ +")
    if finish then
      local actual_cmd_string = string.sub(item, finish + 1)
      if string.find(actual_cmd_string, "ShellSend") then
        table.insert(results, actual_cmd_string)
      end
    end
  end

  require("fzf-lua").fzf_exec(results, {
    prompt = "ShellSend Command History> ",
    actions = {
      -- <CR>: run the command
      ["default"] = function(selected)
        pcall(function()
          vim.api.nvim_command(selected[1])
        end)
      end,
      -- <C-e>: feed command to command line
      ["ctrl-e"] = function(selected)
        pcall(function()
          vim.api.nvim_feedkeys(":" .. selected[1], "n", false)
        end)
      end,
      -- <C-d>: delete from history and reload picker
      ["ctrl-d"] = function(selected, opts)
        vim.fn.histdel("cmd", selected[1])
        return { reload = true }
      end,
    },
  })
end

-- vim.keymap.set('n','<leader>ss',
--     function() SaveCommandToList() end
--     )

function ToggleTerminalCreator(type)
  local on_start = 0
  return function()
    if on_start == 0 then
      on_start = 1
      vim.cmd("FloatermNew --name=" .. type .. " --cwd=<root>")
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(bufnr, type .. "_terminal")
    else
      vim.cmd("FloatermToggle " .. type)
    end
  end
end

local toggleShellTerminal = ToggleTerminalCreator("shell")
local toggleTestTerminal = ToggleTerminalCreator("test")
local toggleAITerminal = ToggleTerminalCreator("claude")
return {
  {
    "voldikss/vim-floaterm",
    event = "VimEnter",
    config = function()
      vim.g.floaterm_opener = "edit"
      vim.g.floaterm_autoclose = 0
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.95
    end,
    keys = {
      { "<leader>os", toggleShellTerminal, desc = "Open Shell Terminal" },
      { "<leader>ot", toggleTestTerminal, desc = "Open Test Terminal" },
      { "<leader>oa", toggleAITerminal, desc = "Open AI Terminal" },
      --{ "<leader>sn", "<cmd>FloatermNext", desc = "Next Terminal" },
      --{ "<leader>sN", "<cmd>FloatermPrev", desc = "Previous Terminal" },
      { "<leader>rl", ":ShellSend ", desc = "Send a String to ShellSend" },
      { "<leader>rr", SendLastStringToTestTerm, desc = "Send Shell Command to Test Term" },
      { "<leader>rh", SendStringFromHistory, desc = "Fuzzy Search Shell Command History" },
      { "gl", JumpToFile, desc = "Jump to Line in File" },
    },
  },
}
