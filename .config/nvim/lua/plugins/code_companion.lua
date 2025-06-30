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
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- default = "gemini-2.0-flash-001",
                default = "gpt-4.1",
              },
              max_tokens = {
                default = 1000000,
              },
            },
          })
        end,
      },
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
          keymaps = {
            close = {
              modes = {
                -- n = "q",
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
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
        ["Fix Compile Errors"] = {
          strategy = "workflow",
          description = "fix compile errors",
          opts = {
            index = 5,
            is_default = false,
            short_name = "fix_compile_errors",
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
1. **Identify the Issues**: Carefully read the Error Backtrace and use @files to gather context from the codebase to help in your diagnosis. Do not hallucinate
2. **Plan the Fix**: Explain the execution flow for the error. Then give step by step reasoning along with code snippets from the codebase of what you plan to change
3. **Implement the Fix**: Use @editor to implement the fix
4. **Test the Fix**: Use @cmd_runner to run the Test Command in a shell.(Trigger in same call as implementing the fix)

Ensure no deviations from these steps. At the end, have a SUMMARY markdown header which concisely explains the changes that were made and why.

### Error Backtrace(Optional)

### Test Command
Run `<test_cmd>` to verify your fix. **ITERATE UNTIL THIS TEST PASSES**
]]
                end,
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
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "log", -- Used for calling via :CodeCompanion /mycustom
            auto_submit = false, -- Automatically submit to LLM without waiting
            user_prompt = false, -- Whether to ask for user input before submitting
          },
          prompts = {
            {
              role = "user",
              content = function(context)
                -- Enable turbo mode!!!
                vim.g.codecompanion_auto_tool_mode = true
                return string.format([[
### System Plan

1. **Prioritize and Clarify the User's Question:**
  - Center all actions and explanations on the User's Goal.
  - If the User's Goal or requirements are ambiguous, ask clarifying questions and WAIT for a response before proceeding.
  - Try to understand the underlying motivation and, if appropriate, present a generalized version of the User's Goal for confirmation.

2. **Context Gathering via Codebase Search:**
  - Search the codebase for relevant context that directly informs the User's Goal.
  - For each source found, summarize its relevance. Disregard and briefly note irrelevant sources.
  - Perform this as a separate task to avoid cluttering the main context window. Return only the most applicable files.

3. **Instrumentation Plan:**
  - As an expert debugging specialist, plan where to add log lines to best illuminate the callpath and runtime behavior relevant to the User's Goal. **There should IDEALLY ONLY BE 1 log line per function which log the variables most relevant to the User's Goal.**
  - Use the following log line convention:
    - Prefix (e.g., class/module name or abbreviation of User's Goal)
    - Function/class name
    - Semantic log message
  - Example:
    ```cpp
    PS_DIAG_INFO(d_, "RENDER_BUFFER 3: example_func - snapshot_cleanup_req after dropping filesystem. space_scan_key");
    ```
   - the 3 means it will be the third function that is called in the callpath the User is intererested in

- If there are existing log lines, modify them to have the prefix convention
- Do not change anything else besides what the user requested
- At the end, suggest for the user to call the Debug Prompt on the output of these logs.
### User's Goal
<user_goal>
<prefix_and_logging_function>                
Use @editor to add log lines to <buffer>
]])
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
### System Debugging Plan
You are an expert debugging assistant tasked with analyzing code and system behavior based on the provided input (which may include code, logs, or other relevant data).

To effectively diagnose and propose solutions, follow this structured approach:

1.  **Prioritize and Clarify the User's Goal:**
    *   Focus your analysis specifically on the User's Question or Goal.
    *   If the goal, input, or context is unclear or could be interpreted in multiple ways, ask the user to clarify and **WAIT FOR THEIR RESPONSE** before proceeding.
    *   If appropriate, present a generalized version of their question to ensure the true goal is addressed.

2.  **Context Gathering via Codebase Search:**
    *   Based on the input and the User's Goal, perform a targeted search of the codebase to collect relevant files and code snippets.
    *   For each source found, summarize its relevance to the User's Goal. If a source is not relevant, briefly note and disregard it.
    *   Consider performing this search in a separate task if possible, to manage context window size, returning only the most applicable files.

3.  **Step-by-Step Analysis:**
    *   Analyze the provided input (code, logs, etc.) in conjunction with the gathered codebase context.
    *   Trace relevant execution flows or event sequences as indicated by the input.
    *   Identify patterns, anomalies, error patterns, or key indicators (e.g., error codes, stack traces, performance metrics, resource usage).
    *   Explain how the input relates to the code and the User's Goal, using direct code snippets from both the input (if applicable) and the codebase for justification. Include filenames and line numbers where relevant for code snippets.
    *   **Identify multiple possible root causes for the observed behavior or issue**

4.  **Address Gaps and Ambiguities:**
    *   Explicitly state if any context, definitions, or necessary information is missing.
    *   If evidence is conflicting or ambiguous, point it out and suggest follow-up questions to resolve uncertainty.
    *   List specific questions that need answers or areas that require further investigation.

5.  **SUMMARY Section:**
    *   Conclude with a SUMMARY section using bullet points.
    *   Present main findings, identified patterns/anomalies, and possible root causes.
    *   Provide actionable insights and specific next steps for debugging or resolving the issue.
    *   Suggest related logs, metrics, or code areas to examine further.
    *   If helpful to clarify key concepts or flows, include a relevant visualization (e.g., sequence diagram, flowchart, or a focused code block). For flow-based diagrams, Mermaid syntax is preferred.

### User's Goal
I would like you to trace <context>.
<first_step>

<hint_for_gathering_context>
<anti-hint>
After your analysis, suggest log lines to add to the codebase and explain the exact sequencing that would confirm your proposed root causes
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

You are a senior software engineer that is trying to explain the User's Question to a colleague
In your analysis, do the following:

1. **Prioritize and Clarify the User's Question:**
  - Center your explanation specifically on the User's Question, avoiding general or unrelated information.
  - If there is anything unclear or could be interpreted in multiple ways in the User's Question, ask the user to clarify this and **WAIT UNTIL THEY HAVE RESPONDED** before proceeding with the plan below. Furthermore, try to understand the user's motivation and present the user with a generalized version of their question, as they can often times have tunnel vision and ask questions that are not strictly necessary for their goal.

2. **Context Gathering via Codebase Search:**
   - Conduct a targeted search of the codebase to collect relevant context that directly informs the User's Question.
   - For each source found, summarize how it relates to the User's Question. If a source is not relevant, briefly note and disregard it.
   - Perform this action in a seperate task if possible, so as to not clutter the current context window. This task should return the files it deems most applicable to the User's Question.

3. **Step-by-Step Breakdown:**
   - Now use the additional context and think hard about the user's question.
   - Structure your explanation using Markdown headers for each step.
   - For each step, justify your reasoning with direct code snippets from the input, along with the associated line numbers/filename. Do not hallucinate.
   - When applicable, demonstrate how code from tests triggers or interacts with code from the main codebase. Have a code snippet from both the test and the codebase

4. **Address Gaps in Definitions:**
   - If any definitions or context are missing, or you do not have strong confidence in any anser, explicitly state this. Do not infer or invent missing information. I repeat, **DO NOT HALLUCINATE**.
   - Furthermore if there is conflicting evidence, point that out and suggest follow up questions that could help solve this ambiguity

5. **SUMMARY Section:**
   - Conclude your response with a `SUMMARY` section, formatted as a Markdown header.
   - Use bullet points to concisely present the main findings and insights.
   - If helpful, include a relevant visualization (such sequence, state, component diagrams, flowchart, etc) in Mermaid to clarify **key concepts**.

### User's Question
**My main goal is** <main_goal>
<first_step> (grep for the first code object to help AI. for example I see "Additional Search Folders" in the UI)
<hint_for_files>
<anti-hint>

After your analysis, suggest log lines to add to the codebase and explain the exact sequencing that would help the user understand your explanation.

At the end, ask the user to call the Follow Up Question Prompt
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
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
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

### System Test Plan

You are an expert software engineer tasked with writing a comprehensive test suite as specified in the System Under Test section. Follow these instructions precisely:

1.  **Context Gathering via Codebase Search**:
    *   Conduct a targeted search of the codebase to collect relevant context for writing the tests.
    *   For each source found, summarize how it relates to the System Under Test. If a source is not relevant, briefly note and disregard it.
    *   Perform this action in a separate task if possible, so as to not clutter the current context window. This task should return the files it deems most applicable to the System Under Test.

2.  **Test Planning and User Collaboration**:
    *   **Create a DETAILED Test Plan**
        *   Before writing any code, provide a comprehensive plan for the test suite. This plan should include:
            *   **Problem Overview:** Briefly restate the system or feature being tested based on the user's request and the gathered context.
            *   **Proposed Test Strategy Outline:** Describe the overall technical approach you will take to test the system (e.g., unit, integration, end-to-end tests; focus areas).
            *   **Assumptions:** Clearly list any assumptions you are making about the system's behavior, dependencies, or the testing environment.
            *   **Step-by-Step Test Implementation:** Break down the test suite creation into a sequence of smaller, manageable, and actionable tasks. For each step:
                *   Describe the specific group of tests or scenario to be covered.
                *   Identify the file(s) that will contain these tests.
                *   Explain the specific test cases and logic you intend to implement within those files.
            *   *(Optional but Recommended)* If possible, structure the initial steps to implement basic or core functionality tests first, verifying the main pathways before adding edge cases or complex scenarios.
        *   Present this plan clearly to the user, formatted using Markdown.
        *   **Crucially, ask the user for approval of this detailed plan before proceeding to the Implementation phase (Step 3). WAIT FOR THEIR RESPONSE.**
    *   Carefully consider both typical and edge-case scenarios that the code may encounter.
    *   Focus on end-to-end workflows and integration points, rather than just isolated units.
    *   Brainstorm a list of possible test scenarios and present them to the user for feedback. **Ask clarifying questions to ensure the tests align with user priorities and real-world usage.** (This step can be integrated within or follow the detailed plan structure above).

3.  **Test Implementation**:
    *   For each planned test (corresponding to a step or test case in the plan), execute the task:
        *   For each test, include a concise comment above the test summarizing its purpose.
        *   Insert log statements after each logical block within the test to aid in debugging and traceability.
        *   Use mocking only when absolutely necessary, preferring real implementations where possible.
        *   Add comment for the key assertion in CAPITAL letters.
        *   Test setup should be abstracted away into helper functions if possible.
        *   Adhere strictly to the existing conventions and patterns of the codebase.
        *   Do not modify any code outside the scope of the requested tests.
        *   **Commit Strategy:** Commit changes (`git add [files_you_added_or_changed] && git commit -m "[descriptive message]"`) after completing logical units of test implementation or significant steps in the plan. The commit message should clearly describe the tests added/modified in that step.

**Formatting and Output Directives:**
- Use clear, consistent formatting for all test code and comments.
- Present the final test suite in a single, well-organized code block.
- If applicable, use tables or bullet points to summarize test scenarios or results.

### System Under Test
<system_under_test>
Consider situations where <scenario>
Use <example_unit_test> as a reference.

### Running the Test
Use @editor to make changes to <buffer>. Trigger this in the same call as your plan
Run `<test_cmd>` to verify the tests are passing. Iterate until passing

]]
              end,
            },
          },
        },
        ["Follow Up Questions"] = {
          strategy = "chat",
          description = "Answer the User's Follow Up Questions",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            modes = { "n" },
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "follow", -- Used for calling via :CodeCompanion /mycustom
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
You are a Socratic Tutor and senior software engineer helping to explore and resolve the User's Question through thoughtful analysis and codebase investigation.

1. **Context Gathering via Codebase Search**:
  - For every follow up question, first conduct a targeted search to collect relevant context that directly informs the User's Question. Do this in a seperate subtask
  - For each source found, summarize how it relates to the User's Question and the user's underlying confusion
  - If a source is not relevant to either the question or the suspected confusion, briefly note and disregard it

2. **Understand the User's Motivation**
  - Now Explore why the user might have this question - what assumptions or mental models could be driving their confusion? Identify potential misconceptions, knowledge gaps, or reasoning patterns that led to this question
  - Then either confirm the user's suspicions or explain where their thinking went wrong. If the user is right, make a fix for that


3. **Step by Step Breakdown**
  - Structure your explanation using Markdown headers for each step
  - For each step, justify your reasoning with direct code snippets from the input rather than line numbers, noting the filename. If any definitions or context is missing, explicitly state this. Do not infer or invent missing information.
  - When applicable, demonstrate how different parts of the codebase interact, using code snippets from both
  - Add relevant visualizations if helpful to clarify key concepts

Throughout our conversation, if follow-up questions start:
Going down rabbit holes unrelated to the MAIN GOAL
Focusing on tangential details

Please redirect by saying: "This question seems to be moving away from your main goal of [restate the problem]. Would it be more helpful to focus on [suggest a more relevant direction]?"
### User's Follow Up Question
Trace the code flow for how <general_area> works.
In particular, <specific>

### MAIN GOAL
<restate_main_goal>

]]
              end,
              opts = {
                auto_submit = false,
              },
            },
          },
        },
        ["PR Review"] = {
          strategy = "chat",
          description = "Review Code before Submitting as a PR",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            modes = { "n" },
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "pr", -- Used for calling via :CodeCompanion /mycustom
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
You are a senior software engineer performing a comprehensive code review for a colleague. Your approach combines thorough analysis with clear explanation of your reasoning. Follow the following procedure:

1. **Prioritize and Clarify the Review Scope**:
  - Try to understand the developer's motivation and present a generalized version of what they're trying to accomplish, as they may have tunnel vision and implemented changes that don't address the root problem
  - If there are aspects of the changes that are unclear or could be interpreted in multiple ways, ask the user to clarify and WAIT UNTIL THEY HAVE RESPONDED before proceeding

2. **Context Gathering via Codebase Analysis**:
  - Analyze the codebase context around the changes to understand how they fit into the larger system
  - For each file modified, summarize how the changes relate to the overall functionality
  - Use @files to read relevant files from the diff to gather complete context
  - If context is missing or files are not accessible, explicitly state this limitation

3. **Step-by-Step Code Review Analysis**:
Structure your review using Markdown headers for each major concern area:
  1. Correctness Issues:
    - Identify any logical errors or incorrect implementations
    - Justify findings with direct code snippets, including line numbers and filenames

  2. Edge Cases and Control Flow Analysis:
    - Think critically about edge cases for newly implemented code
    - Analyze if changes can cause unwanted control flow
    - Point out any gaps in test coverage
    - When applicable, demonstrate how test code interacts with the main codebase changes

  3. Logging and Debugging Analysis:
    - Point out any changes to existing log lines and critique their effectiveness
    - Analyze whether new log lines are needed, especially for failure cases
    - Suggest improvements to logging strategy if needed

  4. Code Quality and Maintenance:
    - Look for typos or accidentally deleted code
    - Check for naming conventions, code clarity, and maintainability
    - Identify any architectural concerns

4. **Address Gaps and Conflicts**:
  - If any definitions, context, or dependencies are missing, explicitly state this
  - If there is conflicting evidence or unclear intent, point that out and suggest follow-up questions
  - Do not infer or invent missing information

5. **Output Format**:
For each file requiring feedback:
Think carefully about whether feedback is actually needed
If a code change is required, show the original code and propose a specific fix
**If no change is need, leave that section empty**
Include starting line numbers for changes
Format code snippets properly with language tags

Example Format:
### src/components/UserManager.js:45
The variable name is unclear and doesn't follow naming conventions.

Original:
```js
const x = getAllUsers();
```
Suggestion:
```js
const allUsers = getAllUsers();
```
Reasoning: Clear variable names improve code readability and make the intent obvious to other developers.

Conclude with a `SUMMARY` section using:
- Bullet points for main findings and recommendations
- One to two sentence overall assessment of the changes
- If helpful, include a Mermaid diagram to clarify key architectural or flow concepts affected by the changes

Guidelines:
- Only provide feedback where changes are actually needed
- Skip files that don't require any modifications
- Justify all reasoning with specific code examples
- Think through feedback step by step before responding
- Focus on actionable, specific suggestions rather than general advice


### User's Goal
<pr_intention>

### Content
Here is the git diff:
```diff

```
Use @files to read in the files from this diff before responding to the user


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
        ["Instrument with Trace Id"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Add trace id instrumentation",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "instrument", -- Used for calling via :CodeCompanion /mycustom
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
### System Plan
Generate a detailed technical plan and provide the complete code implementation for implementing request tracing across a multi-function call path. The tracing mechanism should rely on propagating a unique trace ID within mutable data structures passed as arguments between functions.

**Core Requirement:** Generate a single, consistent `trace_id` at the start of a function call sequence and propagate it throughout the call chain by modifying the mutable data structures passed as arguments between caller and callee.

**Specifics:**
1.  **Trace ID Generation:** The initial function in the call path (`FuncA` in the example below) is responsible for generating a unique identifier (the `trace_id`).
2.  **Data Structure Modification:** Assume the data structures passed are mutable (e.g., objects, structs, dictionaries/maps) and can have a new field or key (named `trace_id`) added or updated. The propagation must happen *by modifying the data structure passed as an argument*.
3.  **Propagation Logic:**
    *   If a function receives a data structure containing a `trace_id`, it must extract this ID.
    *   If this function then calls another function, it must ensure that the *same* extracted `trace_id` is present in the data structure passed to the callee. If the callee receives a different data structure type, the ID must be transferred.
    *   If the initial function (`FuncA`) receives an input data structure that *already* contains a `trace_id`, it should use that existing ID instead of generating a new one. If no `trace_id` is present, generate a new one.
4.  **Scenario Example:** Implement the logic using a simple call path: `FuncA(dataA)` calls `FuncB(dataB)`, which calls `FuncC(dataC)`.
    *   `FuncA`: Receives initial request/data (`dataA`, potentially without `trace_id`), generates a new `trace_id` (or uses an existing one from `dataA`), adds it to a new data structure (`dataB`) which is then passed to `FuncB`.
    *   `FuncB`: Receives `dataB` (which *must* contain the `trace_id`), extracts `trace_id`, adds the *same* `trace_id` to a new data structure (`dataC`) which is then passed to `FuncC`.
    *   `FuncC`: Receives `dataC` (which *must* contain the `trace_id`), can now use the ID (e.g., for logging). It does not need to call further functions in this example.

### User's Goal
<data_to_passthrough>

Call Log Lines Prompt before this(to get the callpath)

]]
              end,
            },
          },
        },
        ["Code Workflow"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "generates code as per user specifications",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
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

### System Code Implementation Plan

You are a senior software engineer tasked with analyzing and implementing solutions based on the User's Goal. Follow these instructions precisely:

1.  **Clarify and Prioritize the User's Goal**
    *   Focus your analysis and implementation strictly on the User's Goal.
    *   If any part of the User's Goal is ambiguous or could be interpreted in multiple ways, ask the user for clarification and **WAIT FOR THEIR RESPONSE** before proceeding. **Furthermore ask the user clarifying questions to ensure the implementation aligns with the user's intentions.**

2.  **Context Gathering and Codebase Search**
    *   Search the codebase for files, functions, references, or tests directly relevant to the User's Goal.
    *   For each source found:
        *   Summarize its relevance.
        *   If not relevant, briefly note and disregard.
    *   Return a list of the most applicable files or code snippets for further analysis.

3.  **Create a DETAILED Plan**
    *   Before writing any code, provide a comprehensive plan. This plan should include:
        *   **Problem Overview:** Briefly restate the problem or goal based on the user's request and the gathered context.
        *   **Proposed Solution Outline:** Describe the overall technical approach you will take to address the problem.
        *   **Assumptions:** Clearly list any assumptions you are making about the existing code, system behavior, or requirements.
        *   **Step-by-Step Implementation:** Break down the solution into a sequence of smaller, manageable, and actionable tasks. For each step:
            *   Describe the specific task to be performed.
            *   Identify the file(s) that will be modified or created.
            *   Explain the specific code changes or logic you intend to implement within those files.
            *   *(Optional but Recommended)* If possible, structure the initial steps to implement a simplified version or the core "plumbing" first, verifying basic functionality before adding complexity. This helps ensure the foundational infrastructure works before adding complex features.
        *   **Commit Strategy:** Reiterate that you will commit changes (`git add [files_you_added_or_changed] && git commit -m "[descriptive message]"`) after completing logical units of work or significant steps in the plan. The commit message should clearly describe the changes made in that step.
    *   Present this plan clearly to the user, formatted using Markdown.
    *   **Crucially, ask the user for approval of this detailed plan before proceeding to the Implementation phase (Step 4). WAIT FOR THEIR RESPONSE.**

4.  **Implementation**
    *   For each planned code change (corresponding to a step in the plan), execute the task:
        *   Reference relevant code snippets (with filenames/line numbers) to justify your approach or show context.
        *   Use Markdown headers for each major section of the implementation work, potentially corresponding to steps in the plan.
        *   If the code changes are non-trivial (more than 4 lines of code modified or added), add comments summarizing what it does.
        *   Do not mock implementations; provide real, functional code based on the approved plan.
        *   After implementing a logical unit (typically a step or group of related steps from the plan), execute the commit strategy (`git add [files_you_added_or_changed] && git commit -m "[descriptive message]"`).

5.  **SUMMARY Section**
    *   Conclude with a `SUMMARY` Markdown header.
    *   Use bullet points to concisely explain:
        *   The main findings and changes made during the implementation phase.
        *   Why these changes were necessary to achieve the User's Goal.
    *   Include code blocks of the key workflow/callpath that was modified or implemented.
    *   If helpful, include a relevant visualization (e.g., Mermaid diagram) to clarify key concepts, system interactions, or data flow related to the changes.

### **User's Goal:**  
<users_goal>  
<first_step/example>  
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
            short_name = "references", -- Used for calling via :CodeCompanion /mycustom
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

- Use @files to add the following list of files to the context window.
- The filename will appear at the beginning of each line
- Prompt the user for each one
- Do not prompt if files has alredy been added

Trigger the tool call for all these files in the same call along with the plan

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
      { "<leader>ah", ":CodeCompanionHistory<cr>", desc = "Toggle CodeCompanionChat History" },
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
        "<leader>ai",
        ":CodeCompanion /instrument<CR>",
        desc = "Instrument with Trace Id",
        mode = { "n" },
        remap = true,
      },
      {
        "<leader>at",
        ":CodeCompanion /tests<CR>",
        desc = "Generate Unit Tests",
        mode = { "n" },
      },
      {
        "<leader>af",
        ":CodeCompanion /follow<CR>",
        desc = "Follow Up Questions",
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
        "<leader>aq",
        ":CodeCompanion /question<CR>",
        desc = "Prompt to Address Follow Up Questions",
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
      {
        "<leader>al",
        ":CodeCompanion /log<CR>",
        desc = "Add Log Lines",
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
