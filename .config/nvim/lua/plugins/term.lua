vim.cmd([[
function! JumpToFile()
    let cword = expand("<cWORD>")
    echom cword
    let fileline = trim(cword,":")
    let array = split(fileline,':')
    if len(array) > 1
        " echom "file and line"
        let filename = array[0]
        let linenumber=array[1]
        FloatermHide
        let s = "edit +" . linenumber . " " . filename
        " echom s
        execute s
    else
        " echom "just file"
        let filename = array[0]
        FloatermHide
        let s = "edit " .. filename
        " echom s
        execute s
    endif
endfunction
nnoremap gl :call JumpToFile()<CR>
]])
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

Last_Term_String = ""
vim.cmd("command -nargs=+ ShellSend :lua BensonFloatTermSend(<q-args>")
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
  -- vim.api.nvim_cmd({cmd="FloatermSend",args={term_string}},{})
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
  -- local on_start = 0
  return function()
    if on_start == 0 then
      on_start = 1
      vim.cmd("FloatermNew --name=" .. type .. " --cwd=<root>")
      --vim.cmd("FloatermNew --cwd=<root> --name=shell")
      vim.cmd("bn")
      vim.cmd("normal <C-o>")
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
    },
  },
}
