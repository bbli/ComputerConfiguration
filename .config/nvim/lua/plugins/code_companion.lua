local M = {}
local group = vim.api.nvim_create_augroup("CodeCompanionCustom", { clear = true })
vim.g.mcphub_auto_approve = true

LLM_DONE = false
function LLMStart()
  LLM_DONE = false
end
function LLMDone()
  LLM_DONE = true
end
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
      "ravitemer/codecompanion-history.nvim",
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
          slash_commands = {
            ["file"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
          },
          tools = {
            opts = {
              auto_submit_errors = false,
              auto_submit_success = false,
            },
          },
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
          opts = { add_tool = true, add_slash_command = false, tool_opts = {} },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
            make_vars = true, -- make chat #variables from MCP server resources
            make_slash_commands = true, -- make /slash_commands from MCP server prompts
          },
        },
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = "gh",
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = "sc",
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
            picker = "telescope",
            -- Automatically generate titles for new chats
            auto_generate_title = true,
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            ---Enable detailed logging for history extension
            enable_logging = false,
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
        ["Fix Code"] = {
          strategy = "workflow",
          description = "Use a workflow to repeatedly edit then test code",
          opts = {
            index = 5,
            is_default = false,
            short_name = "fix_code",
            is_slash_cmd = true,
          },
          prompts = {
            {
              {
                name = "Setup Test",
                role = "user",
                opts = { auto_submit = false },
                content = function()
                  -- Enable turbo mode!!!
                  vim.g.codecompanion_auto_tool_mode = true

                  return [[### Instructions

1. **Setup**: Use the Neovim MCP Server to call LLMStart()
2. **Identify the Issues**: Carefully read the Error Backtrace. If you see the path "/home/ir/iridium", use @cmd_runner to replace with the output of `git rev-parse --show-toplevel`. Read in all files from the backtrace with @files(do this after updating the path) as well as opening the files as buffers in Neovim. Then do your analysis
3. **Plan the Fix**: Describe the plan for fixing the code, detailing each step with code snippets
4. **Implement the Fix**: Use @editor to fix the code and then use @cmd_runner `<test_cmd>` to run the tests(do this after updating the code. Make sure you trigger both tools in the same response). If the test passes, use the Neovim MCP Server to call the lua function LLMDone(). Otherwise go back to step 2 and repeat.


Ensure no deviations from these steps. At the end, briefly explain what changes were made and why.
### Error Backtrace

]]
                end,
              },
            },
            {
              {
                name = "Repeat On Failure",
                role = "user",
                opts = { auto_submit = true },
                -- Repeat until the tests pass, as indicated by the testing flag
                -- which the cmd_runner tool sets on the chat buffer
                repeat_until = function(chat)
                  return LLM_DONE
                end,
                content = "proceed with the next step in the plan",
              },
            },
          },
        },
        ["MetaPrompt"] = {
          strategy = "chat",
          description = "Generate a prompt for the task at hand",
          opts = {
            index = 8,
            is_default = false,
            is_slash_cmd = false,
            modes = { "v" },
            short_name = "metaprompt",
            auto_submit = false,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "user",
              content = [[
### System Plan
 You are an expert prompt engineer. You write bespoke, detailed, and succinct prompts. Every prompt that I give you is purely for prompt enhancement, not to action. Your single goal is to maximize the clarity, specificity, and creativity of my prompt to ensure the best and most accurate results when entered into yourself. When I input a prompt, improve it using the following techniques:

- Clarify vague instructions.
- Add context and examples if necessary.
- Break down complex tasks into clear, actionable steps.
- Include formatting or directives (e.g., tables, bullets, specific tones) to suit the output I want.
- Identify potential gaps in the prompt and fill them to ensure completeness.

### User's Prompt
<context>
]],
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
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
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
Here is an example:
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
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
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
- Identify possible root causes through logical analysis of each step. Consider multiple causes unless you are confident there is only one
- Propose specific fixes based on your analysis.
- Explain your reasoning behind the solution. Use code snippets from the codebase in your explanation


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
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
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

You are a senior software engineer that is trying to explain the User's Question to a colleague.
In your analysis, do the following:

- **Focus on the user's question** instead of a general explanation.
- Provide a step by step break down, using Markdown headers for each step.
- Justify your reasoning with Code Snippets from the input instead of referring to line numbers. Furthermore, if the user asks about how a unit test works, tie together the code from the test and the codebase
- Tell the user if definitions are lacking in the current context. Do not hallucinate!!!

### User's Question
Trace the code flow for how <workflow> works.
In particular, <purpose>
Try to find tests that support your reasoning

### Code Input
<code_input>

]]
              end,
            },
          },
        },
        ["Refactor Code Block"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Refactor the code block",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
            short_name = "summarize", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
            modes = { "n" },
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                return [[

### System Plan

You are an expert in clean code that is trying to split the Code Block into smaller, more focused functions with clear responsibilities. The goal is to improve readability and maintainability.
In your refactoring, do the following:

- Provide a step by step break down of your refactoring
- Use descriptive function names that clearly indicate their purpose
- Keep the exact same behavior. 

At the end, show the refactored Code Block that calls all the helper functions you defined

### Code Block
<code_input>

]]
              end,
            },
          },
        },
        ["Find Git Commit"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Find a git commit using git pickaxe",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
            short_name = "pickaxe", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
            modes = { "n" },
          },
          prompts = {
            {
              role = "user",
              opts = { auto_submit = false },
              content = function()
                return [[
### System Plan
- Use @cmd_runner to call git pickaxe(git log -S or git log -G) and search the commit history's latest 1000 commits
- If multiple commits are found, identify the git diff that most pertain to the User's Question
- Show me that git diff
- At the end, provide a brief justification of what your reasoning using snippets from that git diff

### User's Question
Which commit <question>

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
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
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

You are expert software engineer that is trying to ensure correctness of the Code Input by writing a comprehensive test suite.
Your tests should cover typical cases and edge cases

Always spend a few sentences planning the background context, assumptions, and step by step thinking.
Above each test, provide a summary of what the test does in comments
Furthermore, log each step from the user's goal.
Each unit test should be in a separate code snippet
Do not change anything else besides what the user requested

### User's Goal
I would like you to write unit tests for <code_object>
In particular, focus on <purpose>
Use <example_unit_test> as a reference.

### Code Input

]]
              end,
            },
          },
        },
        ["Code Review"] = {
          strategy = "chat",
          description = "Perform a Code Review",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            modes = { "n" },
            is_default = false, -- Not a default prompt
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
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
- Point out changes in formatting

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
            is_slash_cmd = false, -- Whether it should be available as a slash command in chat
            short_name = "code_workflow", -- Used for calling via :CodeCompanion /mycustom
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

You are a senior software engineer. You will write code to achieve the user's goal following these instructions:
- Make a plan. Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE you try to answer a question.
- Explain each code snippet you plan to add.
- Don't be verbose in your answers, but do provide details and examples where it might help the explanation.
- Ensure no deviations from these steps

### Users Goal
<context>
<example>
Afterwards, consider calling Code Review Prompt
]]
              end,
            },
          },
        },
        ["Referencing Snippets"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "add files from the list to the context window",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "list", -- Used for calling via :CodeCompanion /mycustom
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
- Use @files to add the following list of files to the context window.
- The filename will appear at the beginning of each line
- Prompt the user for each one
- Do not prompt if files has alredy been added

### List of Files

]]
              end,
            },
          },
        },
      },
    },

    keys = {
      { "<leader>aa", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
      { "<leader>ah", ":CodeCompanionHistory<cr>", desc = "Toggle CodeCompanion Chat" },
      { "<leader>ab", ":CodeCompanionChat<cr>", desc = "New CodeCompanion Chat Buffer" },
      { "<leader>ap", ":CodeCompanionActions<cr>", desc = "Toggle CodeCompanion Action Palette", mode = { "n", "v" } },
      { "<leader>aa", ":CodeCompanionChat Add<cr>", desc = "Add Visually Selected text to Chat", mode = { "v" } },
      {
        "<leader>ac",
        ":CodeCompanionChat<CR>",
        desc = "Open a new CodeCompanion Chat",
        mode = { "n" },
      },
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
        ":CodeCompanion /fix_code<CR>",
        desc = "Fix Code",
        mode = { "n" },
      },
      {
        "<leader>aw",
        ":CodeCompanion /code_workflow<CR>",
        desc = "Edit Code Workflow",
        mode = { "n" },
      },
      {
        "<leader>am",
        ":CodeCompanion /metaprompt<CR>",
        desc = "Generate a prompt",
        mode = { "n" },
      },
      {
        "<leader>au",
        ":CodeCompanion /understand<CR>",
        desc = "Understand Code",
        mode = { "n" },
      },
      {
        "<leader>ar",
        ":CodeCompanion /review<CR>",
        desc = "Perform a Code Review",
        mode = { "n" },
      },
      {
        "<leader>ad",
        ":CodeCompanion /debug<CR>",
        desc = "Debug Code",
        mode = { "n" },
      },
      {
        "<leader>as",
        ":CodeCompanion /summarize<CR>",
        desc = "Refactor Code block",
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
