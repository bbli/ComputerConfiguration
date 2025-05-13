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
  pattern = "CodeCompanionChatCreated",
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
        ["Custom Prompt"] = {
          condition = function()
            return false
          end,
        },
        ["Add Log Lines"] = {
          strategy = "chat",
          description = "generates a prompt to tell the llm to apply the generated code to the file",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "apply", -- Used for calling via :CodeCompanion /mycustom
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
### Plan to Follow
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
        ["Unit Tests"] = {
          strategy = "chat", -- change from inline to chat
          opts = {
            modes = { "n" },
            auto_submit = false,
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
            short_name = "apply", -- Used for calling via :CodeCompanion /mycustom
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
You will be acting as a senior software engineer performing a code review for a colleague.Do not include a greeting. Immediately begin reviewing the changes. You should focus on:

- Correctness issues, particular in regards to data races and asynchronous operations.
- Think about edge cases for the newly implemented code and point out any gaps in test coverage
- Point out any changes to existing log lines, and critique the addition of new log lines(whether it is needed, or if more should be added).

### Plan to Follow
Use @files to read all the files in the diff into your context.
Then for each file, decide if you need to provide any feedback on the changes. 
If so, outline the feedback using one or two sentences.
If a code change is required, then mention the original code, and
then propose a code change to fix it.
Do not add any other text after the suggestion.
If you have no feedback on a file, do not add a comment for that file.
Lastly, provide a one to two summary of your feedback at the end.

Here is an example of your output format
Notice how it includes the starting line number for the change.
It also shows a code snippet of the suggestion
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
                auto_submit = true,
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
          description = "Generates code as per user specifications until there are no more lsp diagnostics",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "code", -- Used for calling via :CodeCompanion /mycustom
            --auto_submit = true, -- Automatically submit to LLM without waiting
            --user_prompt = false, -- Whether to ask for user input before submitting. Will open small floating window
          },
          prompts = {
            {
              name = "Setup Test",
              role = "user",
              opts = { auto_submit = false },
              content = function()
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true

                return [[

### Plan to Follow

You are expert software engineer that will write code following the instructions provided above and test the correctness by checking lsp diagnostics. Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE you try to answer a question. Don't be verbose in your answers, but do provide details and examples where it might help the explanation.

#### Phase 1
1. Think about how to implement the users goal and explain each code snippet you plan to add
2. Update the code in #buffer{watch} using the @editor tool
3. Then use the #neovim://diagnostics/current resource to check if there are any compile errors.
4. If there are errors in the output, explain what they mean and then fix them using step 2

We'll repeat this cycle until there are no more error diagnostics.

#### Phase 2(very similar to Phase 1)
1. Use the #neovim://diagnostics/workspace resource to check if there are any compile errors. If not we are done.
2. If there are errors in the output, explain what they mean and then fix them by updating the code in #buffer{watch} using the @editor tool
3. Go back to step 1


Ensure no deviations from these steps.

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
      { "<leader>ap", ":CodeCompanionActions<cr>", desc = "Toggle CodeCompanion Action Palette", mode = { "n", "v" } },
      { "<leader>aa", ":CodeCompanionChat Add<cr>", desc = "Add Visually Selected text to Chat", mode = { "v" } },
      {
        "<leader>an",
        CodeCompanionNext,
        desc = "Prompt CodeCompanion to go to next step",
        mode = { "n" },
        ft = { "codecompanion" },
      },
      {
        "<leader>at",
        ":CodeCompanion /tests<CR>",
        desc = "Generate Unit Tests",
        mode = { "n", "v" },
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
        mode = { "n", "v" },
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
