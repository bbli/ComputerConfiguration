local M = {}
local group = vim.api.nvim_create_augroup("CodeCompanionCustom", { clear = true })
vim.g.mcphub_auto_approve = true

function CodeCompanionNext()
  -- 1. insert text
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  vim.api.nvim_feedkeys(
    "i@cmd_runner Do the next step in the plan OR @editor fix the error from the output OR @editor apply the edit"
      .. esc,
    "n",
    false
  )
  vim.api.nvim_feedkeys(cr, "n", false)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionChatOpened",
  group = group,
  callback = function(event)
    -- The event data contains the buffer number
    local bufnr = event.data.bufnr
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      vim.bo[bufnr].buflisted = true
    end
  end,
})

function CodeCompanionChatFullscreen()
  vim.cmd("CodeCompanionChat Toggle")
  vim.cmd("only")
end
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "olimorris/codecompanion.nvim",
    lazy = false,
    -- init = function()
    --   M:init()
    -- end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
      { "j-hui/fidget.nvim" },
      {
        "Davidyz/VectorCode",
        version = "*",
        build = "pipx upgrade vectorcode",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
      --{ "echasnovski/mini.pick", config = true },
      { "ibhagwan/fzf-lua" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
      },
      display = {
        action_palette = {
          provider = "default",
          opts = {
            show_default_actions = false, -- Show the default actions in the action palette?
            show_default_prompt_library = false, -- Show the default prompt library in the action palette?
          },
        },
      },
      extensions = {
        vectorcode = {
          opts = { add_tool = true, add_slash_command = true, tool_opts = {} },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
            make_vars = true, -- make chat #variables from MCP server resources
            make_slash_commands = true, -- make /slash_commands from MCP server prompts
          },
        },
      },
      prompt_library = {
        ["Chat"] = {
          condition = function()
            return false
          end,
        },
        ["Workspace File"] = {
          opts = {
            is_default = false,
          },
        },
        ["Custom Prompt"] = {
          condition = function()
            return false
          end,
        },
        ["Fix code"] = {
          opts = {
            auto_submit = false, -- false so I can give a hint before submitting
          },
        },
        ["Next"] = {
          condition = function()
            return false
          end,
          strategy = "chat",
          description = "tell the LLM to proceed to the next step",
          opts = {
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "next", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = true, -- Automatically submit to LLM without waiting
            user_prompt = false, -- Whether to ask for user input before submitting
          },
          prompts = {
            {
              role = "user",
              content = "@cmd_runner Do the next step in the plan OR @editor fix the error from the output OR @editor apply the edit",
            },
          },
        },
        ["Reflect"] = {
          condition = function()
            return false
          end,
          strategy = "chat",
          description = "Encourage the LLM to pursue another path",
          opts = {
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "reflect", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = true, -- Automatically submit to LLM without waiting
            user_prompt = false, -- Whether to ask for user input before submitting
          },
          prompts = {
            {
              role = "user",
              content = "Consider if there could be alternative viewpoints. <user_proposal>",
            },
          },
        },
        ["Add Log Lines"] = {
          strategy = "chat",
          description = "generates a prompt to tell the llm to apply the generated code to the file",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "log", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = true, -- Automatically submit to LLM without waiting
            user_prompt = false, -- Whether to ask for user input before submitting
          },
          prompts = {
            {
              role = "user",
              content = function(context)
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return string.format(
                  [[
### System Plan
- You will be acting as an expert debugging expert with knowledge of logging best practices.
- Your job is to instrument the content so the user can understand which callpath the code executed at runtime. Generally we want to log every conditional path the code can take, but I will leave it up to you to decide the best places to add log lines
- Try to following the following convention:
  - The log line begins with a prefix(here "UNIT_TEST").
  - Afterwards it records the name of the function/class this log line was in.
  - Finally it has the actual semantic content we want to log
```cpp
void example_func(){
  PS_DIAG_INFO(d_, "UNIT_TEST: snapshot_cleanup_req after dropping filesystem. " "space_scan_key=%%", k);
}
```
- If there are existing log lines, modify them to have the prefix convention
- Do not change anything else besides what the user requested

### Content
```%s
%s
```
@editor add log lines to all the class methods of <object> based on the control flow
          from buffer %d:
]],
                  context.filetype,
                  code,
                  context.bufnr
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Debug Code"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "AI assisted Debugging",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "debug", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
            modes = { "n" },
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### System Plan

You are expert software engineer that is trying to debug the Code Input.
To do so, you will do the following:

- Start by systematically examining the code’s execution flow
- Identify possible root causes through logical analysis of each step
- Propose specific fixes based on your analysis.
- Explain your reasoning behind the solution


### Code Input
I would like you to trace <context>
]]
              end,
            },
          },
        },
        ["Understand Code"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "AI assisted Understanding",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "understand", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
            modes = { "n" },
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### System Plan

You are expert software engineer that is trying to explain the Code Input to a colleague.
In your analysis, do the following:

- **Focus on the user's question** instead of a general explanation.
- Provide a step by step break down
- Justify your reasoning with Code Snippets from the input
- @mcp Use Serena to look up definitions and referencing code snippets if not in the current context

### User's Question
Explain how <code_object> works, especially in regards to <context>

### Code Input
<code_input>

]]
              end,
            },
          },
        },
        ["Unit Tests"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Generate Additonal Unit Test to see gaps in Test Coverage",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "tests", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
            modes = { "n", "v" },
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### System Plan

You are expert software engineer that is trying to ensure correctness of the code input by writing a comprehensive test suite.
Your tests should cover typical cases and edge cases, especially in regards to interactions with the following services:
  - <service1>
  - <service2>

Above each test, provide a summary of what the test does in comments
Furthermore, log each step from the user's goal.
@mcp use serena to look up referencing code snippets if lacking in the current context
Each unit test should be in a separate code snippet
Always spend a few sentences explaining background context, assumptions, and step by step thinking.
Do not change anything else besides what the user requested

Use <example_unit_test> as a reference.
#### User's Goal
I would like you to write a test <context>

]]
              end,
            },
          },
        },
        ["Code Review"] = {
          strategy = "chat",
          description = "generates a prompt to tell the llm to apply the generated code to the file",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            modes = { "n" },
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "review", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            user_prompt = false, -- Whether to ask for user input before submitting
          },
          prompts = {
            {
              role = "user",

              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### System Role
You will be acting as a senior software engineer performing a code review for a colleague. You should focus on:

- Correctness issues, particular in regards to data races and asynchronous operations.
- Think about edge cases for the newly implemented code and point out any gaps in test coverage
- Point out any changes to existing log lines, and critique the addition of new log lines(whether it is needed, or if more should be added, especially if they affect control flow).

### Plan to Follow
- Decide if you need to provide any feedback on the changes. **Ask the user for more context if needed**
- If a code change is required, then mention the original code, and then propose a code change to fix it.
- If not, do not add a comment for that file
- Lastly, provide a one to two summary of your feedback at the end.

Here is an example of your output format
Notice how it includes the starting line number for the change.
It also shows a code snippet for the proposed change
Also remember to format newlines.
<example>
### filename.js:20
The name of this variable is unclear.

Original:
```js
const x = getAllUsers();
```

Suggestion:
```js
const allUsers = getAllUsers();
```
</example>

Think through your feedback step by step before replying.

### Content
To obtain the diff, use @cmd_runner to compare the git diff between <old_branch> and <new_branch>. <intent>


]]
              end,
              opts = {
                auto_submit = false,
              },
            },
          },
        },
        ["Code workflow"] = {
          condition = function()
            return false
          end,
        },
        ["Code Workflow"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "generates code as per user specifications until there are no more lsp diagnostics",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "code", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### Plan to Follow

You are a senior software engineer and an expert in code diagnostics. You will write code to achieve the user's goal following the instructions provided above and test the correctness by checking lsp diagnostics. Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE you try to answer a question. Don't be verbose in your answers, but do provide details and examples where it might help the explanation.

#### Phase 1
1. Think about how to implement the users goal and explain each code snippet you plan to add
2. The next step is to use @mcp serena to make the edits
3. When you are finished with the edits, use the neovim MCP server to check the workspace diagnostics for compile errors. Ignore diagnostics that are not related to your change
4. For each of these filtered diagnostics:
  - explain what they mean
  - explain your fix
  - then fix them
5. Go back to step 3

We'll repeat this cycle until there are no more error diagnostics.
Ensure no deviations from these steps.
Do not change anything else besides what the user requested

### Users Goal


]]
              end,
            },
          },
        },
      },
    },

    keys = {
      { "<leader>aa", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
      { "<leader>ab", ":CodeCompanionChat<cr>", desc = "New CodeCompanion Chat Buffer" },
      { "<leader>ap", ":CodeCompanionActions<cr>", desc = "Toggle CodeCompanion Action Palette", mode = { "n", "v" } },
      { "<leader>aa", ":CodeCompanionChat Add<cr>", desc = "Add Visually Selected text to Chat", mode = { "v" } },
      {
        "<leader>an",
        "}",
        desc = "Next CodeCompanion Chat",
        mode = { "n" },
        remap = true,
        ft = { "codecompanion" },
      },
      {
        "<leader>aN",
        "{",
        desc = "Previous CodeCompanion Chat",
        mode = { "n" },
        remap = true,
        ft = { "codecompanion" },
      },
      {
        "<leader>at",
        ":CodeCompanion /tests<CR>",
        desc = "Generate Unit Tests",
        mode = { "n" },
      },
      {
        "<leader>af",
        ":CodeCompanion /fix<CR>",
        desc = "Fix Code",
        mode = { "v" },
      },
      {
        "<leader>ac",
        ":CodeCompanion /code<CR>",
        desc = "Edit Code Workflow",
        mode = { "n" },
      },
      {
        "<leader>au",
        ":CodeCompanion /understand<CR>",
        desc = "Understand Code",
        mode = { "n" },
      },
      {
        "<leader>ad",
        ":CodeCompanion /debug<CR>",
        desc = "Debug Code",
        mode = { "n" },
      },
    },
    init = function()
      require("fidget-llm-spinner"):init()
    end,
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- uncomment the following line to load hub lazily
    --cmd = "MCPHub",  -- lazy load
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    keys = {
      { "<leader>m", "<cmd>MCPHub<CR>", desc = "Open MCPHub" },
    },
    config = function()
      require("mcphub").setup({
        -- log = {
        --   level = vim.log.levels.TRACE, -- or DEBUG for even more detailed logs
        --   to_file = true, -- set to true if you want logs in a file
        --   file_path = "mcphub.log", -- specify a file path if to_file is true
        --   prefix = "MCPHub",
        -- },
      })
    end,
  },
}
