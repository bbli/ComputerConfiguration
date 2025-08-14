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
          adapter = "copilot",
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
  - As an expert debugging specialist, plan where to add log lines to best illuminate the callpath and runtime behavior relevant to the User's Goal.
  - Suggest log lines to monitor (along with a simplified code location) and explain the exact sequencing/ordering of these log lines that would confirm your implementation.
  - Use the following log line convention:
    - **There should IDEALLY ONLY BE 1 log line per function which logs the variables most relevant to the User's Goal.**
    - Prefix: the class/module name or abbreviation of User's Goal and order in callpath (e.g., `RESET_SEGMENT 1:`)
    - Function/class name
    - Semantic log message
  - Example:
    ```cpp
    PS_DIAG_INFO(d_, "RENDER_BUFFER 1: example_func - snapshot_cleanup_req after dropping filesystem. space_scan_key");
    ```
  - If there are existing log lines, modify them to have the prefix convention
  - Do not change anything else besides what the user requested
  - Use visualizations (such as sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) in your explanation to illustrate the expected log line sequencing and system behavior
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
### System Code Debugging Plan
You are a senior software engineer debugging issues based on the User's Problem. Follow these instructions precisely:

**IMPORTANT: All items marked with CRITICAL must be completed.**

## 1. **Context Gathering and Understanding**

**CRITICAL: Do NOT proceed to section 2 until the user explicitly says "move on to step 2" or "proceed to hypothesis generation"**

**CRITICAL: Begin building the Debugging Scratchpad (Section 3) from your first response and update it throughout this phase**

### 1.1 **Codebase Search and Analysis**
Search for files, functions, references, or tests relevant to the User's Problem:
- **Show Actual Code**: Include actual code snippets, not descriptions, to verify relevance
- **Relevance Analysis**: Explain how code relates to the bug based on actual implementation
- **Callpath Integration**: Identify how code fits into execution paths from tests or main functions

### 1.2 **Strategic Log Analysis Keywords**
Develop comprehensive strategy for searching log files:

**Primary Keywords:**
- Core domain terms, error messages, function/method names
- Transaction/request IDs, service/component names, timing markers

**Secondary Keywords:**
- Related operations, state indicators, user/session identifiers
- Configuration markers, resource indicators

**CRITICAL: Present your initial keyword list to the user and iterate until they're satisfied with the coverage for log analysis. Add the agreed-upon keywords to the Debugging Scratchpad for reference.**

### 1.3 **Apply Log Analysis Plan**
When user provides logs, systematically apply keywords:
- **Show Actual Results**: Include actual grep results/log excerpts, not summaries
- **Pattern Extraction**: Identify relevant sequences, temporal ordering, anomalies
- **CRITICAL: Expected vs Actual Analysis**: Compare what logs show versus expected system behavior
- **Cross-Reference**: Connect related entries across services/components
- **Update Scratchpad**: Add significant findings for ongoing reference

### 1.4 **System Architecture Discovery**
Using log analysis, collaboratively map the system:
- **End-to-End Flow**: Entry points, service boundaries, data flow, dependencies, exit points
- **Evidence-Based Diagram**: Create sequence/system flow diagram grounded in log findings

### 1.5 **Detailed Log Pattern Analysis**
- **Pattern Correlation**: Cause-effect relationships, frequency, timing, resource correlation
- **CRITICAL: Expected vs Actual Behavior**: Document discrepancies between expected system behavior and observed log patterns
- **Knowledge Gaps**: Document what's unclear for future investigation

**CRITICAL: Present your log analysis to the user and confirm they're ready to proceed to hypothesis generation. Ensure your Debugging Scratchpad contains a comprehensive summary of system understanding before moving to phase 2.**

---

## 2. **DEBUGGING INVESTIGATION PLAN**

**Only proceed after explicit user approval**

**CRITICAL: Base your debugging plan on insights from the Debugging Scratchpad and update the scratchpad with your hypotheses and investigation strategy**

### **Problem Analysis and Hypothesis Generation**
Each hypothesis must be grounded in actual code analysis:
- **CRITICAL**: Research specific callpaths from unit tests or main functions that would exercise the suspected buggy code
- **CRITICAL**: For each hypothesis, identify exact functions and code locations where you suspect the issue occurs
- **CRITICAL**: Show actual code snippets from these locations to support your hypothesis
- **CRITICAL: Rank your hypotheses in terms of relevance** based on code evidence strength and callpath likelihood

### **Visual Representation**
For each hypothesis, create appropriate visualization (sequence diagrams, state diagrams, component diagrams, flowcharts, ASCII art) showing expected vs actual/buggy scenarios.

### **Step-by-Step Investigation Strategy**
For each hypothesis:

**Hypothesis-Driven Code Analysis**:
- Trace callpath from test/main entry point through function sequence
- Identify critical decision points where hypothesis predicts bug manifests
- Show actual code for each reference to verify accuracy

**Targeted Logging Strategy**:
- **Hypothesis-Specific Logs**: Each log must directly test specific aspect of hypothesis
- **Callpath Position**: Prefix format: `HYPO[N]_[POSITION]:` (e.g., `HYPO2_ENTRY:`)
- **Verification Focus**: Log exact variables/state hypothesis claims will be incorrect
- **Minimal Logging**: Only 1-2 strategic lines per hypothesis for proof/disproof
- **Show Code Context**: Present proposed logs with surrounding code context
- **CRITICAL**: Avoid generic instrumentation - every log must serve specific hypothesis-testing purpose

**Expected Diagnostic Outcomes**: For each hypothesis, explain expected log sequences if correct vs incorrect.

### **Commit Strategy**
Commit changes after significant steps: `git add [files] && git commit -m "NEED_REVIEW: [message]"`

**CRITICAL: After presenting the plan and asking for approval, also ask the user: "Are you ready to move on to active debugging execution and begin implementing this plan, or would you prefer to refine the plan further?"**

**CRITICAL: Do NOT proceed to active debugging execution until the user explicitly says "yes, move on to evidence tracking", "proceed to active debugging", "begin implementation", or similar explicit confirmation. Continue asking this question in every response until the user provides explicit approval to move forward.**

---

## 3. **PERSISTENT DEBUGGING SCRATCHPAD**

**CRITICAL: This section must appear at the END of EVERY response throughout the entire debugging process, starting from phase 1.**

### **Scratchpad as Single Source of Truth**
Every grep command, logging strategy, hypothesis, and investigation step must be justified by referencing specific scratchpad items.

### **Required Content**
- **Current System Understanding**: Architecture insights, code analysis results, log patterns, ASCII diagrams
- **CRITICAL: Expected vs Actual Analysis**: Clear comparison between expected system behavior and what logs actually show, including gaps and discrepancies
- **Active Theories**: Ranked hypotheses with supporting evidence, testing status, callpath analysis
- **Investigation Progress**: Status-tracked activities with visual indicators (see format below)
- **Evidence Repository**: Key findings, code snippets, log entries, test results

### **Investigation Progress Format**
Use the following checkbox system to track all investigation activities:

**Status Indicators:**
- `[ ]` = Not started
- `[🔄]` = Currently working on
- `[✅]` = Completed
- `[❌]` = Blocked/Failed
- `[⚠️]` = Needs review/attention

**Example Format:**
```
#### Investigation Tasks
- [✅] Initial log analysis and keyword identification
- [🔄] Hypothesis 1: Space cleanup timing issue
  - [✅] Code review of cleanup functions
  - [ ] Add logging to verify cleanup triggers
  - [ ] Test with reduced timeouts
- [ ] Hypothesis 2: Race condition in replication
  - [ ] Analyze concurrent access patterns
  - [ ] Review locking mechanisms
- [⚠️] Log correlation analysis (missing SpaceTuplesTrace.log)
```

### **Format Requirements**
- Markdown organization with headers, bullets, formatting
- ASCII diagrams for visual understanding
- Free-form analysis combining structure with narrative
- Chronological integrity with logical organization
- Cross-references linking related items
- **Visual progress tracking with checkboxes for all investigation activities**

**CRITICAL: When proposing any grep command, logging strategy, hypothesis, or investigation step, you must explicitly reference the specific scratchpad items that justify this decision. Example: "Based on Hypothesis 2 in the scratchpad regarding state pollution, I propose adding logging to function_x to verify the state transition pattern identified in the log analysis section."**

**CRITICAL: The scratchpad must be presented at the end of every single response, formatted consistently, and serve as the definitive guide for all subsequent debugging activities.**

**CRITICAL: All investigation activities must be tracked using the checkbox system, with status updates in each response showing progress through the investigation.**

### User's Goal
I am trying to debug <description>
Trace the callpath and present to me what is happening in chronological order.
<check_setup>
Outline what you think the issue is and present a sequence diagram to the user to confirm your understanding.

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

1. **First Clarify the User's Question:**
  - Center your explanation specifically on the User's Question, avoiding general or unrelated information.
  - Try to understand the user's motivation and present the user with a generalized version of their question, as they can often times have tunnel vision and ask questions that are not strictly necessary for their goal. To do so, ask the user clarifying questions, especially if there is anything unclear or could be interpreted in multiple ways in the User's Question. **WAIT UNTIL THEY HAVE RESPONDED** before proceeding with the plan below.

2. **Context Gathering via Codebase Search:**
   - Conduct a search of the codebase to collect relevant context that directly informs the User's Question.
   - For each source found, summarize how it relates to the User's Question. If a source is not relevant, briefly note and disregard it.
   - **Identify Critical Code Segments:** As you analyze the code, identify specific functions, classes, or code blocks that are:
     - Central to answering the user's question
     - Potentially problematic or confusing
     - Have complex logic or unexpected behavior
     - Appear to be workarounds or have TODO/FIXME comments
   - **For these critical segments ONLY, request git blame information in the format: `git blame -L <line_number>,<line_number> <file_path>`
   - Perform this action in a seperate task if possible, so as to not clutter the current context window. This task should return the files it deems most applicable to the User's Question.

3. **Step-by-Step Breakdown:**
   - Now use the additional context and think hard about the user's question. Decide if there could be multiple possible explainations and if so present both to the user. **Rank your hypotheses in terms of relevance to the issue.**
   - Structure your explanation using Markdown headers for each step.
   - For each step, justify your reasoning with direct code snippets from the input, along with the associated line numbers/filename. In other words, cite sources and do not hallucinate.
   - Demonstrate how code from tests/upstream caller triggers or interacts with code from the main codebase. Use the format below to show the connection:
        Production Code Exercised:
        - Simplified description of the action
        ```
        // Relevant code snippet from test or caller
        What this triggers in production:
        - From [filename] (the actual code being executed)
        ```
        // Relevant code snippet from the triggered function/method
        ```
   - **CRITICAL: PROVIDE CONCRETE, ACTIONABLE EXAMPLES** from the codebase:
     * Show complete, working code snippets that the user could adapt
     * Include multiple patterns/variations from different test files
     * Demonstrate argument construction with real values, not placeholders
     * Show the "before and after" state of data structures
     * Include error handling and edge cases
     * Provide template code the user can copy and modify
   - If any definitions or context are missing, or you do not have strong confidence in any anser, explicitly state this. Do not infer or invent missing information. I repeat, **DO NOT HALLUCINATE**.

4. **SUMMARY Section:**
   - Conclude your response with a `SUMMARY` section, formatted as a Markdown header.
   - Use bullet points to concisely present the main findings and insights.
   - Include a relevant visualization (such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify KEY CONCEPTS. **Analogies would be helpful as well**

After your analysis, suggest log lines to add to the codebase. For each log line, show:
- The simplified code location (function/method name with minimal context)
- The log message itself
- **The exact, step by step execution sequence of these log lines to help the user understand your explanation**
Then ask the user to verify this behavior experimentally.

Also suggest **specific follow up topics/questions** and explain how they would help deepen the user's understanding, especially if there were ambiguities above. 
**Finally, ask the user if they would like to add this newfound understanding to LEARNINGS.md**

**NOTE: Always prioritize and thoroughly address any bullets marked with CRITICAL - these are essential requirements for a complete response.**

### User's Question
**My main goal is** <main_goal>
<first_step> (i.e "Additional Search Folders" in the UI)
<ask_ai_for_its_base_understanding>

]]
              end,
            },
          },
        },
        ["Explain Architecture"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Explain the Architecture of the Codebase",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "architecture", -- Used for calling via :CodeCompanion /mycustom
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
### System Plan - Codebase Architecture Analysis
You are a senior software architect explaining the architecture of a codebase to a colleague.
In your analysis, do the following:

1. **First Clarify the Architecture Question**:
  - Focus specifically on the architectural aspects the user wants to understand (e.g., overall structure, specific patterns, component interactions, data flow, etc.).
  - If there is anything unclear or could be interpreted in multiple ways in the User's Question, ask the user to clarify this and **WAIT UNTIL THEY HAVE RESPONDED** before proceeding with the plan below. Furthermore, try to understand the user's motivation and present the user with a generalized version of their question, as they can often times have tunnel vision and ask questions that are not strictly necessary for their goal.
  - **Ask clarifying questions and WAIT FOR RESPONSE before proceeding**
  - Understand whether they need:
    - High-level system overview
    - Detailed component relationships
    - Specific architectural patterns used
    - Module boundaries and responsibilities

2. **Context Gathering via Codebase Search**:
  - Search for key architectural indicators, such as but not limited to:
    - **Entry and Exit points (main files, rpc handlers, interfaces)**
    - Core abstractions and base classes
    - Dependency injection or service registration
    - Router/controller definitions
  - For each source found, explain its architectural significance
  - Focus on files that reveal structural decisions rather than implementation details


3. **Step-by-Step Architectural Breakdown**:
  - Structure explanation using these Markdown headers:
    - System Overview
    - Core Components
    - **Data Flow(especially for "handoff points" between layers)**
    - Key Design Patterns
    - Module Dependencies
    - Lifecycle of Services
  - For each section:
    - Include relevant code snippets and line numbers showing architectural decisions. This is to make sure they you DO NOT HALLUCINATE.
    - Show how components interact through actual code examples
    - **If there are multiple interpretations, present them all to the user. Rank them in terms of relevance.**
    - Provide concrete examples/documentation/tutorials of typical use cases and how data flows through them
    - Use visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to help you illustrate:
      - Component relationships
      - Data flow directions
      - System boundaries
      - External dependencies

4. **Summary/Further Investigation**:
  - Give a critique of the architecture
  - Use bullet points to concisely present the main findings and insights, using analogies if you find that helpful.
  - After your analysis, suggest log lines to add to the codebase. For each log line, show:
    - The simplified code location (function/method name with minimal context)
    - The log message itself
    - The exact execution sequence to help the user understand your explanation
  - Also suggest specific follow up topics/questions and explain how they would help deepen the user's understanding, especially if there were ambiguities above. 
  - **Finally, ask the user if they would like to add this newfound understanding to LEARNINGS.md**
### User's Question
<main_flow>

]]
              end,
            },
          },
        },
        ["Summarize Code Block"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Summarize the code block",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
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
### Incremental End-to-End Test Development Plan

**⚠️ IMPORTANT: This is an INTERACTIVE, MULTI-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**📌 INSTRUCTION PRIORITY: Any section marked with "CRITICAL" requires special attention and strict adherence. These are the most important parts of this process that must not be overlooked or abbreviated.**

**Confidence Level Quick Reference:**
- ⚠️LOW = Major assumptions, high risk
- 🟡MEDIUM = Some assumptions, moderate risk  
- 🟢HIGH = Minor uncertainty, low risk

You are an expert software engineer tasked with creating an incremental end-to-end testing strategy. Your goal is to test complete workflows from the start, progressively adding complexity dimensions to the same end-to-end test.

**This process has TWO distinct phases with MANDATORY stops:**
- **PHASE 1:** Analysis and Planning with Uncertainty Identification (STOP - await approval)  
- **PHASE 2:** Implementation (only after explicit approval) with stops after each increment

**Process Flow:**
```
PHASE 1: Analysis → Present Plan & Uncertainties → 🛑 STOP (await approval)
                                                          ↓
PHASE 2: Test Harness Setup → Commit → 🛑 STOP (await "continue")
              ↓
         E2E Test (Happy Path) → Commit → 🛑 STOP (await "continue")
              ↓ (same test, add complexity)
         E2E Test + Data Variety → Commit → 🛑 STOP (await "continue")
              ↓ (same test, add complexity)
         E2E Test + Edge Cases → Commit → 🛑 STOP (await "continue")
              ↓ (same test, add complexity)
         E2E Test + Error Handling → Commit → 🛑 STOP (await "continue")
              ↓ (same test, add complexity)
         ... (continue adding complexity dimensions) ...
                                               ↓
         Final Validation → Complete
```

## PHASE 1: Analysis and Planning

1. **Context Gathering via Codebase Search**:
   - Conduct a targeted search to understand:
     - The complete workflow from entry point to final output
     - All components involved in the end-to-end flow
     - Integration points and data transformations
   - For each source found, note its role in the complete workflow.
   - Create a map showing the entire end-to-end flow.

2. **Workflow Analysis and Complexity Decomposition**:
   - Analyze the gathered context to identify the complete end-to-end workflows.
   - Map out the full workflow from start to finish (e.g., A → B → C → D).
   - **⚠️ CRITICAL: Do NOT decompose into path segments (A→B, B→C, etc.). Every test must be complete end-to-end.**
   - **Decompose complexity into progressive layers for the SAME complete workflow**:
     - **Test Harness (Increment 0)**: Infrastructure setup, mocks, helpers, validation
     - **Baseline (Increment 1)**: Minimal data, default configuration, no errors
     - **Data Variations (Increment 2)**: Different input types, sizes, formats
     - **Edge Cases (Increment 3)**: Boundary values, empty data, special characters
     - **Error Scenarios (Increment 4)**: Network failures, invalid inputs, timeouts
     - **Concurrent Operations (Increment 5)**: Multiple simultaneous executions
     - **Performance/Load (Increment 6)**: High volume, stress conditions
   - Each increment tests the COMPLETE workflow with added complexity
   - Present this analysis to the user with your proposed complexity progression.

3. **🔍 Uncertainty and Assumption Identification** (CRITICAL STEP):
   Before finalizing the test plan, explicitly identify:
   - **Low Confidence Areas**: Components or interactions you don't fully understand
   - **Assumptions Made**: Any guesses about how components work or interact
   - **Missing Knowledge**: Information that would help create better tests
   - **Complex Interactions**: Areas where the behavior might be non-obvious
   - **External Dependencies**: Services or systems you're unsure how to mock/handle
   
   **Format this as a clear "Uncertainty Report" with confidence levels:**
   ```
   ⚠️ AREAS OF UNCERTAINTY:
   
   Summary: 3 ⚠️LOW | 1 🟡MEDIUM | 0 🟢HIGH uncertainties identified
   
   1. [Component/Interaction]: [What you're unsure about]
      - Confidence Level: [⚠️LOW/🟡MEDIUM/🟢HIGH]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   
   2. [Component/Interaction]: [What you're unsure about]
      - Confidence Level: [⚠️LOW/🟡MEDIUM/🟢HIGH]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   ```
   
   **Confidence Level Guide:**
   - **⚠️LOW**: Major assumptions made. High risk of incorrect test behavior. Tests likely need adjustment without clarification.
   - **🟡MEDIUM**: Some assumptions but based on common patterns. Moderate risk.
   - **🟢HIGH**: Minor uncertainty only. Low risk but clarification would still help.
   
   **Be SPECIFIC about uncertainties. 
   Bad example: "I'm not sure how authentication works"
   Good example: 
   "AuthService.validateToken() behavior: I'm uncertain whether this method checks token expiration internally or if the calling code needs to check this separately.
   - Confidence Level: ⚠️LOW
   - Assumption: The method checks expiration internally
   - Would benefit from: Seeing the method implementation or documentation
   - Impact if wrong: Tests might pass with expired tokens when they shouldn't"**
   
   **Sort uncertainties by severity (⚠️LOW items first) to help users prioritize their responses.**
   
   **Remember: Identifying uncertainty is a sign of thoroughness, not weakness. The user WANTS to know where you need help.**

4. **Incremental Test Planning and User Collaboration**:
   - Create a DETAILED INCREMENTAL TEST PLAN including:
     - **Problem Overview:** Briefly describe the components and workflow being tested.
     - **Workflow Diagram:** Visual representation of the complete end-to-end flow.
     - **⚠️ Uncertainty Report:** (From step 3) - Present all areas of low confidence PROMINENTLY
     - **Incremental Complexity Strategy:**
       - **Complexity-based** (complete flow with increasing complexity)
       - List each complexity increment for the same workflow:
       
       **Increment 0: Test Harness Setup (Infrastructure Only)**
       - **Complete E2E workflow**: Full workflow will be testable but not yet tested
       - **Complexity added**: None - this is pure infrastructure
       - **Test harness components**:
         - Complete test infrastructure for the E2E workflow
         - Handling for external dependencies (mocks, stubs, or real services)
         - Test environment configuration
         - **Helper functions for**:
           - Building test inputs
           - Managing test data lifecycle
           - Asserting on workflow outputs
           - Controlling test scenarios
         - Utilities for test execution and reporting
       - **Setup validation**: Infrastructure validation that verifies:
         - All necessary components can be initialized
         - External dependencies are properly handled
         - Test data management works correctly
         - Helper functions operate as expected
         - The complete E2E workflow can be invoked without errors
       - **Code examples**: Include actual code snippets for key infrastructure pieces
       - **NO ACTUAL TESTS YET** - only infrastructure and validation
       - **Confidence level**: [⚠️LOW/🟡MEDIUM/🟢HIGH] for harness implementation
       
       - For each subsequent complexity increment (1-6), specify:
         - **Increment number and name**: (e.g., "Increment 1: Baseline Happy Path")
         - **Complete E2E workflow**: (e.g., "User request → API → Router → Tool → Response → User")
         - **Complexity added**: What makes this increment more complex than the previous
         - **Test scenarios**: Specific cases to test at this complexity level
         - **Test data examples**: Concrete examples of inputs/outputs
         - **Assertions focus**: What new behaviors to verify
         - **Infrastructure changes**: How test harness needs to evolve
         - **Confidence level**: [⚠️LOW/🟡MEDIUM/🟢HIGH] for this specific test implementation
     - **Commit Strategy:** Each complexity increment gets its own commit with a checkpoint:
       - Format: `git add [test_files] && git commit -m "E2E TEST: [workflow] - [complexity level]"`
       - **After each commit: STOP and wait for user inspection/approval**
       - Example progression with checkpoints:
         - Commit 0: "E2E TEST: User Purchase Flow - Test harness setup (🟡MEDIUM confidence)" → STOP
         - Commit 1: "E2E TEST: User Purchase Flow - Baseline happy path (🟢HIGH confidence)" → STOP
         - Commit 2: "E2E TEST: User Purchase Flow - Multiple payment methods (🟢HIGH confidence)" → STOP
         - Commit 3: "E2E TEST: User Purchase Flow - Edge cases & boundaries (🟡MEDIUM confidence)" → STOP
         - Commit 4: "E2E TEST: User Purchase Flow - Error handling & recovery (⚠️LOW confidence)" → STOP
         - Commit 5: "E2E TEST: User Purchase Flow - Concurrent operations (⚠️LOW confidence)" → STOP
   - **Present this plan WITH the Uncertainty Report prominently displayed at the beginning**
   - **Order uncertainties by confidence level** (⚠️LOW first, then 🟡MEDIUM, 🟢HIGH)
   - **Ask the user to:**
     1. **First, review and address the uncertainty areas, especially ⚠️LOW confidence items** 
     2. Then approve the overall testing approach
   - **DO NOT minimize or hide uncertainties - they should be the first thing the user sees**

**🛑 STOP HERE - PHASE 1 CHECKPOINT**
- You have now presented:
  1. The complete incremental test plan (including Increment 0 infrastructure details)
  2. **The Uncertainty Report with confidence levels (⚠️LOW → 🟡MEDIUM → 🟢HIGH)**
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address ⚠️LOW confidence uncertainties first**
  - **Explain components or interactions you're uncertain about**
  - **Clarify assumptions you've made**
  - Adjust the testing order
  - Add or remove test cases
  - Modify the incremental approach
- WAIT for the user to address uncertainties AND provide explicit approval like "looks good", "proceed", or "go ahead"

---

## PHASE 2: Implementation (Only proceed after explicit Phase 1 approval)

**⚠️ CRITICAL: This phase includes multiple checkpoints - you will STOP after each commit for user inspection.**

**⚠️ VERIFY: Have you received explicit approval for the test plan? If not, STOP and wait for approval.**

### 5. Implementation Process

**a. Implementation Order**
- Always start with Increment 0 (Test Harness Setup)
- Validate infrastructure before writing any actual tests
- Build each increment on top of the previous one
- Never skip increments or combine them

**b. For Each Increment**

1. **Build/Extend**:
   - For Increment 0: Create test infrastructure per the approved plan
   - For Increments 1+: Extend existing infrastructure for new complexity
   - Add one complexity dimension at a time
   - Reuse existing helpers and extend them as needed
   - Document which complexity dimension is being added

2. **Execute and Validate**:
   - Run all tests for the current increment
   - Verify the complete E2E workflow executes successfully
   - Check that all assertions pass
   - For Increment 0: Run infrastructure validation checks
   - For Increments 1+: Ensure previous tests still pass

3. **Debug if Needed**:
   - If tests fail, analyze and fix the issue
   - Document the problem and solution
   - Re-run tests to confirm fix
   - Only proceed when all tests pass

4. **Handle New Uncertainties**:
   - **⚠️LOW uncertainties**: STOP and ask for guidance before proceeding
   - **🟡MEDIUM uncertainties**: Document assumption, continue, flag for review
   - **🟢HIGH uncertainties**: Note minor uncertainty and continue
   - Never make assumptions about critical behavior

5. **Commit and Checkpoint**:
   ```bash
   git add [test_files]
   git commit -m "E2E TEST: [workflow name] - [complexity level] (confidence level)"
   ```
   
   **🛑 MANDATORY STOP - INCREMENT CHECKPOINT**
   
   Present to the user:
   - What was just implemented (infrastructure or complexity added)
   - Summary of test scenarios/validations at this level
   - Any issues encountered and resolutions
   - New uncertainties discovered (if any)
   - What comes next (if not the final increment)
   
   **WAIT for explicit user signal** (e.g., "continue", "next", "proceed")
   
   The user may want to:
   - Review the code
   - Run tests themselves  
   - Request modifications
   - Skip remaining increments
   - Address new uncertainties
   
   **DO NOT proceed without explicit approval**

**c. Special Considerations by Increment**

- **Increment 0 (Test Harness)**:
  - Focus on infrastructure validation, not business logic
  - Show actual validation code that proves harness works
  - No actual tests yet - only setup and validation

- **Increments 1+ (Actual Tests)**:
  - Each builds on previous increment
  - Add new test cases, don't replace existing ones
  - Make complexity explicit in test names and comments
  - Maintain all previous validations

### 6. Key Implementation Principles

**Core Requirements**:
- ✅ Start with infrastructure (Increment 0) before any tests
- ✅ Test the complete E2E workflow in every increment
- ✅ Add only one complexity dimension per increment
- ✅ Stop after EVERY commit for user inspection
- ✅ Never proceed without explicit approval

**Technical Approach**:
- Build on previous increments, never replace them
- Extend test infrastructure to handle new complexity
- Use descriptive test names indicating complexity level
- Prefer real component interactions over heavy mocking
- Document what each increment adds and why

**Uncertainty Handling**:
- Always flag new uncertainties with confidence levels
- For ⚠️LOW confidence issues: stop and ask for help
- Document all assumptions made during implementation
- The user values knowing what you're uncertain about

**Output Format**:
- Present each increment's code in separate blocks
- Use clear comments showing the E2E workflow
- Include a summary table of test progression
- Document any debugging steps taken

---

## 🚨 CRITICAL PROCESS REMINDERS

**This is a TWO-PHASE process with mandatory stops:**

1. **Phase 1**: Analyze → Identify Uncertainties → Present Plan → **🛑 STOP** (await approval)
2. **Phase 2**: Implement Incrementally → **🛑 STOP after EACH commit** (await "continue")

**You MUST:**
- Wait for explicit approval before starting Phase 2
- Stop after EVERY commit in Phase 2
- Never skip checkpoints or assume approval
- Always present uncertainties prominently

**Remember**: Identifying what you don't understand is just as valuable as planning what you do understand. The user EXPECTS and VALUES uncertainty identification.

### System Under Test
<system_under_test>
<base_test> (ask AI if you can't think of one)
<example_unit_test>

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
  -   If any part of the User's Goal is ambiguous or could be interpreted in multiple ways, ask the user for clarification and **WAIT FOR THEIR RESPONSE** before proceeding. **Furthermore ask the user clarifying questions to ensure the implementation aligns with the user's intentions.**, such as but not limited to:
  - Then either confirm the user's suspicions or explain where their thinking went wrong. If the user is right, make a fix for that


3. **Step by Step Breakdown**
  - Structure your explanation using Markdown headers for each step
  - For each step, justify your reasoning with direct code snippets from the input rather than line numbers, noting the filename. If any definitions or context is missing, explicitly state this. Do not infer or invent missing information.
  - When applicable, demonstrate how different parts of the codebase interact, using code snippets from both
  - Add relevant visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify key concepts
  - **If there are multiple options for how things work, present them all to the user. Rank the options in terms of relevance.**

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
**For all these areas, only add a comment if something needs to be addressed**
If a code change is required, show the original code and propose a specific fix
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

4. **Address Gaps and Conflicts**:
  - If any definitions, context, or dependencies are missing, explicitly state this
  - If there is conflicting evidence or unclear intent, point that out and suggest follow-up questions
  - Do not infer or invent missing information


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
Use @cmd to run `git show <commit>` to get the diff. Then use @files to read in the files from this diff at once before responding to the user. Trigger all necessary tool calls together


]]
              end,
              opts = {
                auto_submit = false,
              },
            },
          },
        },
        ["Gather Findings"] = {
          strategy = "chat",
          description = "Gather Findings for the Curent Conversation",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            modes = { "n" },
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "gather", -- Used for calling via :CodeCompanion /mycustom
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
### System Summarizing Plan
You are a seasoned Senior Software Engineer who specializes in debugging complex systems. You have a methodical approach to problem-solving and excellent documentation habits. Your colleagues rely on your clear, insightful debugging logs to understand what's been tried and what to attempt next. You think like a detective - every failed attempt is a clue that brings you closer to the solution.

**Your Task**:
You're maintaining the team's debugging journal for a challenging codebase issue. You need to summarize the latest debugging session and append it to the existing documentation.

**Instructions**:
1. **First, review the existing debugging log like you're catching up on a case file**:
  - **What's the User's Goal? (What are we trying to debug/understand?)**
  - What approaches have your colleagues already tried?
  - What's the current state of the investigation?
  - Are there any patterns emerging from previous attempts?


2. ****************Analyze today's debugging session and document it with your characteristic clarity**:
```markdown
## [5-7 word summary of what steps were taken]

### Overview
[State or restate the debugging objective/user's goal - what problem are we trying to solve?]
[Your brief assessment of what was attempted in this session - write like you're updating a colleague who just joined the investigation]

### Steps Taken

1. **[Action/Approach Name]**
   - What we tried: [High-level description] + [Simplified Code Snippet]
   - Reasoning: [Why we thought this would work - include your engineering intuition]
   - Outcome: [Success/Failure and what we learned]

2. **[Action/Approach Name]**
   - What we tried: [High-level description] + [Simplified Code Snippet]
   - Reasoning: [Why we thought this would work - include your engineering intuition]
   - Outcome: [Success/Failure and what we learned]

[Continue for each significant step...]

### What Worked
**Only include items that directly relate to the User's Goal. If nothing worked toward the goal, leave this section empty.**
- [Successful approach]: [Why we tried it] → [How it advanced our goal]
- [Successful approach]: [Why we tried it] → [How it advanced our goal]

### What Didn't Work
**Only include failed attempts that were aimed at solving the User's Goal. Omit any unrelated failures.**
- [Failed approach]: [Your hypothesis for trying it] → [What the failure taught us about the goal]
- [Failed approach]: [Your hypothesis for trying it] → [What the failure taught us about the goal]

### Key Insights
**Only document insights that directly relate to understanding or solving the User's Goal. Skip any tangential learnings.**
- [New understanding about the system's behavior related to the goal]
- [Patterns you've noticed across sessions]
- [Any assumptions that were proven wrong]

### TODO List
**This should be the complete, aggregated TODO list from all sessions. Copy all items from the most recent TODO list in the file, update their status, and add new items below the separator.**
* [x] [Items completed in this session - mark with x]
* [x] [Previously completed items - keep marked with x]
* [ ] [Existing incomplete items that still need attention]
* [ ] [Items from previous sessions that remain incomplete]
----
* [ ] [New proposed action based on today's findings]
* [ ] [Another proposed action with rationale from insights gained]
* [ ] [Additional items to investigate]

### Overview and Next Steps
[Your assessment of where we stand now, combining what was attempted today with recommended next moves. Write this as a brief narrative that ties together the session's outcomes with the proposed TODO items above, explaining why these next steps make sense given what we've learned.]

```
3. **Your documentation style**:
  - Always keep the user's goal as your north star - every action should relate back to it
  - Write as if explaining to a smart colleague who wasn't present
  - Focus on the "why" behind each attempt - your engineering reasoning is valuable
  - Treat failures as valuable data points, not setbacks
  - Connect dots between current findings and previous sessions
  - Keep it high-level but insightful


4. **When appending to the log**:
  - Add your entry at the END of the file
  - Maintain the investigative narrative
  - If the goal has evolved or changed during debugging, note this explicitly

5. **Remember**: You're building a knowledge base. Each session builds on the last, and your careful documentation helps the entire team stay focused on solving the actual problem.

Please review the existing debugging log, analyze our conversation, and add your session summary following this approach.


### User's Goal
<user's goal>

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
### Integrated System Code Implementation Plan with Test Development

**⚠️ IMPORTANT: This is an INTERACTIVE, THREE-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before implementation begins.**

You are a senior software engineer tasked with analyzing, planning tests for, and implementing solutions based on the User's Goal.

**This process has THREE distinct phases with MANDATORY stops:**
- **PHASE 1:** Analysis and Implementation Planning with Uncertainty Identification (STOP - await approval)
- **PHASE 2:** Test Development Planning with E2E Test Strategy (STOP - await approval)
- **PHASE 3:** Implementation with Testing (only after explicit approval of both plans)

**Process Flow:**
```
PHASE 1: Analysis → Implementation Plan & Uncertainties → 🛑 STOP (await approval)
                                                               ↓
PHASE 2: Test Planning → E2E Test Strategy & Test Uncertainties → 🛑 STOP (await approval)  
                                                               ↓
PHASE 3: Implementation → Code + Tests per Step → 🛑 STOP after each commit
```

## PHASE 1: Analysis and Implementation Planning

1. **Context Gathering and Codebase Search**
   - Search the codebase for files, functions, references, or tests directly relevant to the User's Goal.
   - For each source found:
     - Summarize its relevance.
     - If not relevant, briefly note and disregard.
   - Return a list of the most applicable files or code snippets for further analysis.

2. **🔍 Implementation Uncertainty and Assumption Identification** (CRITICAL STEP):
   Before finalizing the implementation plan, explicitly identify:
   - **Low Confidence Areas**: Components or interactions you don't fully understand
   - **Assumptions Made**: Any guesses about how components work or should interact
   - **Missing Knowledge**: Information that would help create better implementation
   - **Complex Interactions**: Areas where the behavior might be non-obvious
   - **External Dependencies**: Services or systems you're unsure how to integrate
   
   **Format this as a clear "Implementation Uncertainty Report" with confidence levels:**
   ```
   ⚠️ IMPLEMENTATION UNCERTAINTIES:
   
   Summary: X 🔴 CRITICAL | X 🟠 LOW | X 🟡 MEDIUM | X 🟢 HIGH uncertainties identified
   
   1. [Component/Feature]: [What you're unsure about]
      - Confidence Level: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   ```
   
   **Confidence Level Guide:**
   - **🔴 CRITICAL**: No understanding, pure guessing. Implementation will likely be wrong without clarification.
   - **🟠 LOW**: Major assumptions made. High risk of incorrect implementation.
   - **🟡 MEDIUM**: Some assumptions but based on common patterns. Moderate risk.
   - **🟢 HIGH**: Minor uncertainty only. Low risk but clarification would still help.

3. **Create a DETAILED IMPLEMENTATION PLAN**
   - Before writing any code, provide a comprehensive plan. This plan should include:
     - **⚠️ Implementation Uncertainty Report:** Present the uncertainty report PROMINENTLY at the beginning
     - **Problem Overview:** Briefly restate the problem or goal based on the user's request and the gathered context.
     - **Proposed Solution Outline:** Describe the overall technical approach you will take to address the problem.
       - **If there is a change to an existing function, check that its callers expect this behavior and list these callers out for the user to confirm**
       - **If there are multiple implementation options or approaches, present them for the user to decide.**
       - Use visualizations (such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify key concepts, system interactions, or data flow related to the changes.
     - **🔧 STEP 1 (MANDATORY FIRST COMMIT): Core Plumbing Setup**
       - Implement the fundamental infrastructure, interfaces, or "API skeleton" first
       - Create minimal working version with basic connectivity/structure
       - Establish data flow pathways without complex logic
       - Set up error handling framework
       - **This step should result in a compilable, testable foundation even if features aren't complete**
       - **Confidence level**: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH] for core plumbing implementation
       - **🧪 Testing strategy**: [TO BE FILLED IN PHASE 2]
       - **Files to modify/create**: [List specific files for the plumbing step]
       - **Log lines**: As an expert debugging specialist, plan specific log lines for this step to illuminate the callpath and runtime behavior. Use the following convention:
         - ideally 1 log line per function 
         - with prefix (class/module + User's Goal abbreviation + call order), function name, and semantic message. Example format: `PS_DIAG_INFO(d_, "RENDER_BUFFER 1: example_func - semantic message with relevant variables");` 
         - If existing log lines are present, modify them to follow the prefix convention.
         - CRITICAL: afterwards explain how this sequence of log lines illuminates the callpath
       - **Commit message**: "NEED_REVIEW: Add core plumbing for [feature/goal]"
     - **Step-by-Step Feature Implementation:** After core plumbing, break down remaining features into manageable tasks:
       - For each subsequent step:
         - Describe the specific task to be performed.
         - Identify the file(s) that will be modified or created.
         - Explain the specific code changes or logic you intend to implement within those files → and **how they contribute to the overall goal**
         - **Confidence level**: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH] for this specific implementation step
         - **🧪 Testing strategy**: [TO BE FILLED IN PHASE 2]
         - **Log lines**: Plan specific log lines for this step to monitor the callpath and confirm the implementation works. Follow the same logging convention as Step 1. Explain the sequencing/ordering of these log lines.
         - **Build incrementally**: Each step should add ONE clear piece of functionality to the working foundation
         - **If there are multiple options for implementation, present them all to the user. Rank the options in terms of relevance.**
     - **Commit Strategy:** Reiterate that you will commit changes (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`) after completing logical units of work. **The FIRST commit will always be the core plumbing setup.**
   - **Order uncertainties by confidence level** (🔴 CRITICAL first, then 🟠 LOW, 🟡 MEDIUM, 🟢 HIGH)
   - Present this plan clearly to the user, formatted using Markdown.

**🛑 STOP HERE - PHASE 1 CHECKPOINT**
- You have now presented:
  1. **The Implementation Uncertainty Report with confidence levels (🔴 CRITICAL → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH)**
  2. The complete implementation plan **starting with Step 1: Core Plumbing Setup**
  3. **Each step with placeholder for testing strategy (TO BE FILLED IN PHASE 2)**
- DO NOT PROCEED to test planning without explicit approval
- The user may want to:
  - **Address 🔴 CRITICAL and 🟠 LOW confidence uncertainties first**
  - **Clarify assumptions you've made**
  - Choose between implementation options
  - Adjust the implementation approach
  - Modify the step ordering
- WAIT for the user to address uncertainties AND provide explicit approval like "looks good", "proceed to test planning", or "go ahead to Phase 2"

---

## PHASE 2: Test Development Planning (Only proceed after explicit Phase 1 approval)

**⚠️ VERIFY: Have you received explicit approval for the implementation plan? If not, STOP and wait for approval.**

4. **Test Context Gathering and E2E Workflow Analysis**:
   - Analyze the approved implementation plan to understand the complete end-to-end workflow
   - Map out how each implementation step contributes to the overall user journey
   - Identify all integration points and data transformations across steps
   - Create a comprehensive view of the workflow from entry point to final output

5. **🔍 Test Planning Uncertainty and Assumption Identification** (CRITICAL STEP):
   Before finalizing the test plan, explicitly identify testing-specific uncertainties:
   - **Test Environment Setup**: What you're unsure about regarding test infrastructure
   - **Mock/Stub Strategy**: Components you're uncertain how to simulate or isolate
   - **Test Data Management**: Uncertainties about test data creation, cleanup, or state management
   - **Assertion Strategy**: What outputs/behaviors you're unsure how to validate
   - **Integration Testing**: Uncertainties about testing component interactions
   
   **Format this as a clear "Test Planning Uncertainty Report" with confidence levels:**
   ```
   🧪 TEST PLANNING UNCERTAINTIES:
   
   Summary: X 🔴 CRITICAL | X 🟠 LOW | X 🟡 MEDIUM | X 🟢 HIGH test uncertainties identified
   
   1. [Test Aspect/Component]: [What you're unsure about for testing]
      - Confidence Level: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH]
      - Assumption: [What you're assuming about testing approach]
      - Would benefit from: [What information would help with testing]
      - Impact if wrong: [What testing issues could arise if assumption is incorrect]
   ```

6. **E2E Test Strategy Development**:
   - **Problem Overview**: Briefly describe the complete workflow being tested and how it maps to implementation steps
   - **Complete E2E Workflow Diagram**: Visual representation of the full end-to-end flow showing all implementation steps
   - **⚠️ Test Planning Uncertainty Report**: (From step 5) - Present all areas of low testing confidence PROMINENTLY
   - **Step-by-Step Test Planning**: For each implementation step from Phase 1, develop:
   
   **For Step 1 (Core Plumbing Setup):**
   - **E2E Workflow ASCII Diagram**: Show how the plumbing enables the complete workflow
   ```
   [User Request] → [Step 1 Infrastructure] → [Future Steps] → [Final Output]
                         ↓
                   [Test validates basic connectivity and error handling]
   ```
   - **Test Infrastructure Setup**: 
     - Test environment configuration for this step
     - Mock/stub requirements for external dependencies
     - Test data management approach
     - Helper functions for validation
   - **Test Scenarios**: Infrastructure validation tests:
     - Connectivity verification
     - Error handling framework validation
     - Basic data flow confirmation
   - **Assertions Strategy**: What to validate at this infrastructure level
   - **Confidence level**: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH] for testing this step
   
   **For Each Subsequent Implementation Step:**
   - **E2E Workflow ASCII Diagram**: Show the complete workflow with this step's contribution highlighted
   ```
   [User Request] → [Step 1] → [Step 2] → [Step N] → [Final Output]
                                  ↑
                            [Current step being tested]
                                  ↓
                    [Test validates complete workflow through this step]
   ```
   - **Test Infrastructure Evolution**: How test harness needs to evolve for this step
   - **E2E Test Scenarios**: Complete workflow tests that exercise:
     - Happy path through all implemented steps
     - Data variations relevant to this step
     - Error conditions introduced by this step
   - **Step-Specific Validations**: What new behaviors to verify at this step
   - **Integration Points**: How this step interacts with previous steps in tests
   - **Confidence level**: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH] for testing this step
   
   - **Test Execution Strategy**: 
     - Order of test execution
     - Test data lifecycle management
     - Cleanup and state management between tests
   - **Commit Strategy for Tests**: Each step's tests get committed with the implementation:
     - Format: `git add [implementation_files] [test_files] && git commit -m "NEED_REVIEW: [step] + E2E tests"`

**🛑 STOP HERE - PHASE 2 CHECKPOINT**
- You have now presented:
  1. **The Test Planning Uncertainty Report with confidence levels**
  2. **Complete E2E test strategy with ASCII diagrams for each implementation step**
  3. **Test infrastructure evolution plan**
  4. **Specific test scenarios and assertions for each step**
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address 🔴 CRITICAL and 🟠 LOW confidence test uncertainties first**
  - **Clarify testing assumptions you've made**
  - **Modify test scenarios or approaches**
  - **Adjust test infrastructure plans**
- WAIT for the user to address test uncertainties AND provide explicit approval like "test plan looks good", "proceed to implementation", or "go ahead to Phase 3"

---

## PHASE 3: Implementation with Testing (Only proceed after explicit approval of both Phase 1 and Phase 2)

**⚠️ VERIFY: Have you received explicit approval for BOTH the implementation plan AND the test plan? If not, STOP and wait for approval.**

7. **Implementation Process with Integrated Testing**:
   - **Build incrementally from simple to complex**:
     - Start with Step 1 (Core Plumbing Setup) + its E2E infrastructure tests
     - Add each subsequent step + its complete E2E tests
     - Verify each addition works before proceeding
   - **Handle uncertainties during implementation**:
     - For 🔴 CRITICAL uncertainties (implementation or testing): STOP and ask for clarification
     - For 🟠 LOW uncertainties: Document and seek guidance before proceeding
     - For 🟡 MEDIUM/🟢 HIGH: Note assumption and continue, flag for review

8. **Implementation**:
   - For each planned implementation step (with its corresponding test strategy from Phase 2):
     - **Implement the step according to the approved plan**
     - **Implement the E2E tests for that step according to the approved test strategy**
     - **Run tests to verify the complete workflow through this step**
     - **Debug if needed**: If tests fail, analyze and fix issues in implementation or tests
     - **Commit both implementation and tests together**:
       ```bash
       git add [implementation_files] [test_files]
       git commit -m "NEED_REVIEW: [step description] + E2E tests"
       ```
     
     **🛑 MANDATORY STOP - STEP CHECKPOINT**
     
     Present to the user:
     - What was implemented (step description)
     - What E2E tests were added
     - Test results (pass/fail with details)
     - Any issues encountered and resolutions
     - New uncertainties discovered (if any)
     - ASCII diagram showing current workflow test coverage
     - What comes next (if not the final step)
     
     **WAIT for explicit user signal** (e.g., "continue", "next", "proceed")
     
     The user may want to:
     - Review the implementation code
     - Review the test code
     - Run tests themselves
     - Request modifications
     - Address new uncertainties
     
     **DO NOT proceed without explicit approval**

**🚨 CRITICAL PROCESS REMINDERS**

**This is a THREE-PHASE process with mandatory stops:**

1. **Phase 1**: Analyze → Present Implementation Plan & Uncertainties → **🛑 STOP** (await approval)
2. **Phase 2**: Test Planning → Present E2E Test Strategy & Test Uncertainties → **🛑 STOP** (await approval)
3. **Phase 3**: Implement → Code + Tests per Step → **🛑 STOP after EACH commit** (await "continue")

**You MUST:**
- Wait for explicit approval before starting each phase
- Stop after EVERY commit in Phase 3
- Never skip checkpoints or assume approval
- Always present both implementation AND testing uncertainties prominently
- Create E2E tests that validate the complete workflow at each step

**Remember**: Identifying what you don't understand (for both implementation AND testing) is just as valuable as planning what you do understand. The user EXPECTS and VALUES uncertainty identification in both domains.

### **User's Goal:**  
<Users_Goal>  
<Example/First_Step>
<Base Implementation>  
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
        "<leader>ao",
        ":CodeCompanion /architecture<CR>",
        desc = "Explain Architecture",
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
        "<leader>ag",
        ":CodeCompanion /gather<CR>",
        desc = "Gather Findings from the Conversation",
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
      {
        "<leader>as",
        ":CodeCompanion /summarize<CR>",
        desc = "Summarize Code block",
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
