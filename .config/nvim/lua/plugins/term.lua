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
vim.cmd("command -nargs=+ ShellSend :lua BensonFloatTermSend(<q-args>)")
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
function SendStringFromHistory(opts)
  -- -- Option 1: Open Telescope commands with BensonFloatTerm already prepopulated
  --     -- TrySomething: call feedkeys after Telescope to see what happens
  --         -- keys did not seem to be sent
  -- vim.api.nvim_cmd({cmd="Telescope",args={"command_history"}},{})
  -- vim.api.nvim_feedkeys("BensonFloatTerm ",'i',false)
  -- Option 2: Create own list of just BensonFloatTerm stuff
  local history_string = vim.fn.execute("history cmd")
  local history_list = vim.split(history_string, "\n")

  local results = {}
  for i = #history_list, 3, -1 do --Beginning has some fluff
    local item = history_list[i]
    local _, finish = string.find(item, "%d+ +")
    local actual_cmd_string = string.sub(item, finish + 1)
    if string.find(actual_cmd_string, "ShellSend") then
      table.insert(results, string.sub(item, finish + 1))
    end
  end
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "FloatSend Command History",
      finder = finders.new_table(results),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<C-e>", function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_feedkeys(":" .. selection[1], "n", false)
        end)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          -- print(vim.inspect(selection))
          vim.api.nvim_command(selection[1])
        end)
        return true
      end,
    })
    :find()
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
    else
      vim.cmd("FloatermToggle " .. type)
    end
  end
end

local toggleShellTerminal = ToggleTerminalCreator("shell")
local toggleTestTerminal = ToggleTerminalCreator("test")
return {
  {
    "voldikss/vim-floaterm",
    config = function()
      vim.g.floaterm_opener = "edit"
      vim.g.floaterm_autoclose = 0
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.95
    end,
    keys = {
      { "<leader>os", toggleShellTerminal, desc = "Open Shell Terminal" },
      { "<leader>ot", toggleTestTerminal, desc = "Open Test Terminal" },
      { "<leader>sn", "<cmd>FloatermNext", desc = "Next Terminal" },
      { "<leader>sN", "<cmd>FloatermPrev", desc = "Previous Terminal" },
      { "<leader>sl", ":ShellSend ", desc = "Send a String to ShellSend" },
      { "<leader>ss", SendLastStringToTestTerm, desc = "Send Shell Command to Test Term" },
      { "<leader>sh", SendStringFromHistory, desc = "Fuzzy Search Shell Command History" },
      { "gl", JumpToFile, desc = "Jump to Line in File" },
    },
  },
}
