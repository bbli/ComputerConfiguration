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
You are a senior software engineer tasked with debugging and fixing issues based on the User's Problem. Follow these instructions precisely to understand the problem deeply before implementing any fixes:

1. **First Clarify the User's Problem**:
  - Ask specific questions about:
    - Expected vs actual behavior
    - Steps to reproduce the issue
    - When the problem started occurring
    - Any recent changes that might be related(or a working git commit to compare to)
  - Try to understand the user's motivation and present the user with a generalized version of their question, as they can often times have tunnel vision and ask questions that are not strictly necessary for their goal. To do so, ask the user clarifying questions, especially if there is anything unclear or could be interpreted in multiple ways in the User's Question. **WAIT UNTIL THEY HAVE RESPONDED before proceeding with step 2.**


2. **Context Gathering and Codebase Search**:
  - Search the codebase for files, functions, references, or tests directly relevant to the User's Problem.
  - For each source found:
    - Summarize its relevance to the bug
    - Identify potential entry points and code paths that could be involved
  - Return a list of the most applicable files or code snippets for debugging investigation.

3. **DEBUGGING INVESTIGATION PLAN**:
  - Create a comprehensive debugging plan. This plan should include:
  - **Problem Analysis and Hypothesis Generation**: Restate the problem and give your initial hypothesis on potential root causes. Think broadly but at the same time the hypothesis needs to have a clear chain of reasoning. **Rank your hypotheses in terms of relevance to the issue.**. Here are examples of types of hypotheses to consider, but most importantly your hypotheses should tie back to the User's Goal:
    - **Setup Verification**: CRITICAL: This is often the reason for bugs involving tests, so please include some checks for this. Based off the context from the user, verify each step in the call path. If unclear what to check, ask the user questions for guidance on what to check. Are all preconditions satisfied before the assert? We cannot check every line of code, **so suggest functions/locations in the code to verify based off the symptoms the problem is exhibiting. Be skeptical that a function does what it intends to do just from the function name. Also be skeptical of what the user said, as they may think certain actions has been performed when in actuality they haven't**
    - **Unset/Misconfigured Variables**: Missing environment variables, uninitialized tunables, default values being used instead of intended configurations, or configuration files not being loaded properly.
    - **Timing and Race Conditions**: Asynchronous operations completing in unexpected order, missing await/synchronization, concurrent access to shared resources, or timing-dependent behavior that only manifests under certain conditions.
    - **State Pollution**: Previous tests or operations leaving behind state, caches not cleared, database transactions not rolled back, or global variables modified.
    - **Cascading Failures**: One component failure triggering system-wide issues
  - **Step-by-Step Investigation Strategy**: For each hypothesis, break down into actionable tasks/hypotheses:
    - **Add Strategic Logging**: Identify where to add temporary debug logs to trace execution flow and variable states. The log lines should follow the following format:
      - There should IDEALLY ONLY BE 1 log line per function which logs the variables most relevant to the User's Goal.
      - Prefix/Abbreviation of the Hypothesis(e.g ZERO_FILESYSTEM_ID)
      - Function/class name
      - Semantic Log Message
      - Order in the Callpath(1,2,3...)
      - Present the log lines you plan to add to the user in the form of simplified code snippets
    - **For each task/hypotheses you create, explain all the different Sequencing of these Log Lines that could be possible outcomes. Your explaination should take the following form:**
```markdown
## Expected Diagnostic Outcomes

### If Hypothesis 3 is Correct (Most Likely)
**After snapshot restore**:
```
HYPO3_REPORT_positive_est: Added estimated_deleted_shared_logical=5120 to sum, running total=5120
HYPO3_REPORT_positive_est: Added estimated_deleted_shared_logical=3072 to sum, running total=8192
```

**After dedup cleanup**:
```
HYPO3_REPORT_negative_est: Ignoring negative estimated_deleted_shared_logical=-5120 for segment_id=100, medium_id=50
HYPO3_REPORT_negative_est: Ignoring negative estimated_deleted_shared_logical=-3072 for segment_id=101, medium_id=50
HYPO3_REPORT_final: Final filesystem_space_query result cold_usable_capacity=8192
```

**Result**: Shared space stays at 8192 instead of going to 0 because negative decrements are ignored!

### If Hypothesis 1 is Correct
```
HYPO1_DEDUP_no_extents: No extents found for processing
HYPO2_TIMING_batch_complete: Processed 0 dedup_cleanup tuples in batch
```

### If Hypothesis 2 is Correct
```
HYPO2_TIMING_batch_complete: Processed 10 dedup_cleanup tuples in batch
HYPO2_TIMING_extents_tombstoned: Tombstoned 8 extents in this batch
[Multiple batches over time showing ongoing work]
```
```
  -   **Commit Strategy:** Commit changes (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`) after completing significant steps in the plan. The commit message should clearly describe the tests added/modified in that step.
  - Present this plan clearly to the user, formatted using Markdown. Crucially, **ASK THE USER FOR APPROVAL** of this debugging plan before proceeding to implement.


Important Notes:

- Don't assume anything - verify your understanding through testing
- Be willing to be wrong about your initial hypothesis
- Document unexpected findings even if they don't lead to the fix
- Sometimes the "obvious" fix isn't the right one - dig deeper
- Use the debugging process to improve your understanding of the system
- The primary purpose is planning how to learn about the system and the bug

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
   - **PROVIDE CONCRETE EXAMPLES/DOCUMENTATION/TUTORIALS/TESTS** from the codebase of typical use cases and how data flows through them. Examples can be simplified, as long as they get the main idea across.
   - If any definitions or context are missing, or you do not have strong confidence in any anser, explicitly state this. Do not infer or invent missing information. I repeat, **DO NOT HALLUCINATE**.

4. **SUMMARY Section:**
   - Conclude your response with a `SUMMARY` section, formatted as a Markdown header.
   - Use bullet points to concisely present the main findings and insights, using analogies if you find that helpful.
   - Include a relevant visualization (such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify KEY CONCEPTS

After your analysis, suggest log lines to add to the codebase. For each log line, show:
- The simplified code location (function/method name with minimal context)
- The log message itself
- **The exact, step by step execution sequence of these log lines to help the user understand your explanation**
Then ask the user to verify this behavior experimentally.

Also suggest **specific follow up topics/questions** and explain how they would help deepen the user's understanding, especially if there were ambiguities above. 
**Finally, ask the user if they would like to add this newfound understanding to LEARNINGS.md**

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
### System Test Plan

**⚠️ IMPORTANT: This is an INTERACTIVE, MULTI-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before implementation begins.**

You are an expert software engineer tasked with creating an incremental testing strategy for recently implemented code changes. Your goal is to build tests progressively, starting with the smallest testable component interactions and expanding to full workflows. 

**This process has TWO distinct phases with MANDATORY stops:**
- **PHASE 1:** Analysis and Planning with Uncertainty Identification (STOP - await approval)  
- **PHASE 2:** Implementation (only after explicit approval)

## PHASE 1: Analysis and Planning

1. **Context Gathering via Codebase Search**:
   - Conduct a targeted search to understand:
     - The modified components and their interfaces
     - Components that directly interact with the modified code
     - Full workflow paths that include the modified components
   - For each source found, note how components interact and their dependencies.
   - Create a component interaction map showing the call chains.

2. **Dependency Analysis and Path Decomposition**:
   - Analyze the gathered context to create a complete interaction map.
   - Identify all workflow paths that involve the recently implemented changes.
   - **Decompose workflows into progressively larger testable paths**:
     - Start with the first meaningful interaction in the workflow
     - Progressively extend to include more components
     - Examples:
       - Linear flow (A → B → C): Test A→B first, then extend to A→B→C
       - Branching flow (A → B → C and A → B → D): Test A→B, then A→B→C, then A→B→D
       - Cyclic flow (A → B → C → B → A): Test A→B, then A→B→C, then A→B→C→B, finally full cycle
   - The key principle: Each test builds upon the previous, adding one logical step
   - Present this analysis to the user with your proposed testing order.

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
   
   1. [Component/Interaction]: [What you're unsure about]
      - Confidence Level: [HIGH/MEDIUM/LOW/CRITICAL]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   
   2. [Component/Interaction]: [What you're unsure about]
      - Confidence Level: [HIGH/MEDIUM/LOW/CRITICAL]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   ```
   
   **Confidence Level Guide:**
   - **CRITICAL**: No understanding, pure guessing. Tests will likely be wrong without clarification.
   - **LOW**: Major assumptions made. High risk of incorrect test behavior.
   - **MEDIUM**: Some assumptions but based on common patterns. Moderate risk.
   - **HIGH**: Minor uncertainty only. Low risk but clarification would still help.
   
   **Be SPECIFIC about uncertainties. Bad example: "I'm not sure how authentication works"
   Good example: "I'm uncertain whether the AuthService.validateToken() method checks token expiration internally or if the calling code needs to check this separately. I'm assuming it checks internally, but this affects whether my test needs to mock expired tokens."**
   
   **Remember: Identifying uncertainty is a sign of thoroughness, not weakness. The user WANTS to know where you need help.**

4. **Incremental Test Planning and User Collaboration**:
   - Create a DETAILED INCREMENTAL TEST PLAN including:
     - **Problem Overview:** Briefly describe the components modified and their role in the system.
     - **Component Interaction Map:** Visual or textual representation of how components interact.
     - **⚠️ Uncertainty Report:** (From step 3) - Present all areas of low confidence PROMINENTLY
     - **Incremental Testing Strategy:**
       - Identify the starting point(s) of workflows
       - List each testable path, progressively extending from start to end
       - For each path increment, specify:
         - The exact component interactions being tested
         - What was tested in the previous increment (if applicable)
         - What new interaction/component this increment adds
         - Test harness setup required (minimal mocks, dependency injection)
         - Specific test cases and assertions
         - How this test will be extended in the next increment
         - **Confidence level**: [CRITICAL/LOW/MEDIUM/HIGH] for this specific test implementation
     - **Commit Strategy:** Each incremental path gets its own commit:
       - Format: `git add [test_files] && git commit -m "TEST: [path] - [description]"`
       - Example progressions:
         - Linear: 
           - Commit 1: "TEST: A→B - Initial workflow validation"
           - Commit 2: "TEST: A→B→C - Extended workflow validation"
         - With modifications in B,C:
           - Commit 1: "TEST: B→C - Direct interaction between modified components"
           - Commit 2: "TEST: A→B→C - Full forward path validation"
           - Commit 3: "TEST: A→B→C→B→A - Complete cycle validation"
   - **Present this plan WITH the Uncertainty Report prominently displayed at the beginning**
   - **Order uncertainties by confidence level** (CRITICAL first, then LOW, MEDIUM, HIGH)
   - **Ask the user to:**
     1. **First, review and address the uncertainty areas, especially CRITICAL and LOW confidence items** 
     2. Then approve the overall testing approach
   - **DO NOT minimize or hide uncertainties - they should be the first thing the user sees**

**🛑 STOP HERE - PHASE 1 CHECKPOINT**
- You have now presented:
  1. The complete incremental test plan
  2. **The Uncertainty Report with confidence levels (CRITICAL → LOW → MEDIUM → HIGH)**
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address CRITICAL and LOW confidence uncertainties first**
  - **Explain components or interactions you're uncertain about**
  - **Clarify assumptions you've made**
  - Adjust the testing order
  - Add or remove test cases
  - Modify the incremental approach
- WAIT for the user to address uncertainties AND provide explicit approval like "looks good", "proceed", or "go ahead"

---

## PHASE 2: Implementation (Only proceed after explicit Phase 1 approval)

**⚠️ VERIFY: Have you received explicit approval for the test plan? If not, STOP and wait for approval.**

5. **General Implementation Guidelines**:
   - **Test simpler cases before complex ones**: Always verify basic functionality works before adding complexity
     - Example: Test a router can handle basic requests before testing with sampling
     - Example: Test synchronous operations before async ones
     - Example: Test with minimal configuration before testing with full configuration
     - Example: Test single operations before testing batches or sequences
   - **Isolate features progressively**: 
     - Start with core functionality disabled/default
     - Enable one feature at a time
     - Test interactions between features only after individual features are verified
   - **Error handling progression**:
     - Test success cases first
     - Add failure cases incrementally
     - Test recovery and cleanup last
   - **Build confidence systematically**: 
     - Each test should prove one specific behavior
     - Later tests can assume earlier tests pass
     - Don't test everything in every test
   - **Mock minimally and progressively**:
     - Use real implementations wherever possible
     - If mocking is needed, start with the simplest mock
     - Add mock complexity only as needed for specific test cases
   - **Document your testing strategy**:
     - Comment why you're testing in this order
     - Note dependencies between tests
     - Highlight critical assumptions

6. **Incremental Test Implementation**:
   For each incremental path in the approved plan:
   
   a. **Test Harness Setup**:
      - Create minimal test harness for the current path
      - Use dependency injection to isolate components
      - Only mock external dependencies, not components in the test path
      - Reuse and extend harnesses from previous increments

   b. **Test Implementation**:
      - Write tests for the current path increment
      - Include comment: `// TESTING PATH: [current path description]`
      - Add detailed logging with prefix `INCREMENTAL_TEST:`
      - Make assertions explicit with CAPITAL letter comments
      - Ensure tests can be extended (not replaced) in next increment

   c. **Validation and Debugging**:
      - Run the tests for the current increment
      - If tests fail:
        - Analyze the failure
        - Add diagnostic logging
        - Debug the implementation issue
        - Document the issue and resolution
      - **If new uncertainties arise during implementation:**
        - STOP and document the uncertainty
        - Ask the user for clarification before proceeding
        - Do not make assumptions about critical behavior
      - Only proceed to next increment after current tests pass

   d. **Commit and Progress**:
      - Commit the working tests for this increment
      - Document what was tested and validated
      - Prepare harness extensions needed for next increment

   e. **Test Extension** (for increments 2+):
      - Extend existing tests to cover the larger path
      - Reuse existing assertions and add new ones
      - Maintain all previous test validations
      - Comment: `// EXTENDED FROM: [previous path] TO: [current path]`

7. **Final Integration Validation**:
   - After all increments are complete, run the full test suite
   - Verify that each incremental test still passes
   - Document the complete test coverage achieved
   - Create a final commit summarizing the incremental testing completed

**Key Principles**:
- **Always communicate uncertainty** - Identify areas where you lack confidence
- Start with the first meaningful interaction in a workflow
- Build tests progressively by extending the path one logical step at a time
- For linear flows (A→B→C), test A→B first, then extend to A→B→C
- For flows with modified components, you may start with interactions between those components
- Each test increment builds upon and extends the previous
- Never remove or replace tests, only extend them
- Debug and fix issues at each increment before proceeding
- Use minimal mocking - prefer real component interactions
- Maintain clear documentation of what each increment validates
- **Flag any assumptions made about component behavior**

**Formatting and Output Directives:**
- Use clear comments to show path progression
- Present each increment's tests in separate code blocks
- Include a summary table showing the incremental test progression
- Document any debugging steps taken between increments

**🚨 CRITICAL REMINDER: This is a TWO-PHASE process with mandatory stops:**
1. **Phase 1**: Analyze code, identify uncertainties, present test plan → STOP and wait for clarification/approval  
2. **Phase 2**: Implement tests → Only after explicit approval


**Remember: Identifying what you don't understand is just as important as planning what you do understand. The user EXPECTS and VALUES uncertainty identification.**

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

### System Code Implementation Plan

**⚠️ IMPORTANT: This is an INTERACTIVE, MULTI-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before implementation begins.**

You are a senior software engineer tasked with analyzing and implementing solutions based on the User's Goal. 

**This process has THREE distinct phases with MANDATORY stops:**
- **PHASE 1:** Requirements Clarification (STOP - await response)
- **PHASE 2:** Analysis and Planning with Uncertainty Identification (STOP - await approval)
- **PHASE 3:** Implementation (only after explicit approval)

## PHASE 1: Requirements Clarification

1. **First Clarify the User's Goal**
   - Ask the user for clarification. Types of questions to consider could be:
     - Architecture: microservices vs monolith, sync vs async, stateful vs stateless
     - Communication: events vs direct calls, choreography vs orchestration
     - State management: local vs shared state, immutable vs mutable, event sourcing vs current state only
     - Data flow: where state lives, caching strategy, consistency requirements, layer placement
     - **Whatever else you think is relevant based on the context of the codebase**

**🛑 STOP HERE - PHASE 1 CHECKPOINT**
- Present your clarifying questions to the user
- DO NOT PROCEED to Phase 2 until you receive responses
- DO NOT start any analysis or implementation
- WAIT for the user to answer your questions

---

## PHASE 2: Analysis and Planning (Only proceed after Phase 1 response)

2. **Context Gathering and Codebase Search**
   - Search the codebase for files, functions, references, or tests directly relevant to the User's Goal.
   - For each source found:
     - Summarize its relevance.
     - If not relevant, briefly note and disregard.
   - Return a list of the most applicable files or code snippets for further analysis.

3. **🔍 Uncertainty and Assumption Identification** (CRITICAL STEP):
   Before finalizing the implementation plan, explicitly identify:
   - **Low Confidence Areas**: Components or interactions you don't fully understand
   - **Assumptions Made**: Any guesses about how components work or should interact
   - **Missing Knowledge**: Information that would help create better implementation
   - **Complex Interactions**: Areas where the behavior might be non-obvious
   - **External Dependencies**: Services or systems you're unsure how to integrate
   
   **Format this as a clear "Uncertainty Report" with confidence levels:**
   ```
   ⚠️ AREAS OF UNCERTAINTY:
   
   Summary: X CRITICAL | X LOW | X MEDIUM | X HIGH uncertainties identified
   
   1. [Component/Feature]: [What you're unsure about]
      - Confidence Level: [HIGH/MEDIUM/LOW/CRITICAL]
      - Assumption: [What you're assuming]
      - Would benefit from: [What information would help]
      - Impact if wrong: [What could break if assumption is incorrect]
   ```
   
   **Confidence Level Guide:**
   - **CRITICAL**: No understanding, pure guessing. Implementation will likely be wrong without clarification.
   - **LOW**: Major assumptions made. High risk of incorrect implementation.
   - **MEDIUM**: Some assumptions but based on common patterns. Moderate risk.
   - **HIGH**: Minor uncertainty only. Low risk but clarification would still help.

4. **Create a DETAILED PLAN**
   - Before writing any code, provide a comprehensive plan. This plan should include:
     - **⚠️ Uncertainty Report:** Present the uncertainty report PROMINENTLY at the beginning
     - **Problem Overview:** Briefly restate the problem or goal based on the user's request and the gathered context.
     - **Proposed Solution Outline:** Describe the overall technical approach you will take to address the problem.
       - **If there is a change to an existing function, check that its callers expect this behavior and list these callers out for the user to confirm**
       - **If there are multiple implementation options or approaches, present them for the user to decide.**
       - Use visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify key concepts, system interactions, or data flow related to the changes.
     - **Implementation Principles:**
       - Build from simple to complex
       - Implement core "plumbing" first before adding features
       - Test basic functionality before adding complexity
       - Use minimal dependencies initially
     - **Step-by-Step Implementation:** Break down the solution into a sequence of smaller, manageable, and actionable tasks. For each step:
       - Describe the specific task to be performed.
       - Identify the file(s) that will be modified or created.
       - Explain the specific code changes or logic you intend to implement within those files -> and **how they contribute to the overall goal**
       - **Confidence level**: [CRITICAL/LOW/MEDIUM/HIGH] for this specific implementation step
       - **Structure initial steps to implement a simplified version or the core "plumbing" first, verifying basic functionality before adding complexity. The "API" should be written first.**
       - **If there are multiple options for implementation, present them all to the user. Rank the options in terms of relevance.**
     - **Commit Strategy:** Reiterate that you will commit changes (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`) after completing logical units of work or significant steps in the plan. The commit message should clearly describe the changes made in that step.
   - **Order uncertainties by confidence level** (CRITICAL first, then LOW, MEDIUM, HIGH)
   - Present this plan clearly to the user, formatted using Markdown.

**🛑 STOP HERE - PHASE 2 CHECKPOINT**
- You have now presented:
  1. **The Uncertainty Report with confidence levels (CRITICAL → LOW → MEDIUM → HIGH)**
  2. The complete implementation plan
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address CRITICAL and LOW confidence uncertainties first**
  - **Clarify assumptions you've made**
  - Choose between implementation options
  - Adjust the implementation approach
  - Modify the step ordering
- WAIT for the user to address uncertainties AND provide explicit approval like "looks good", "proceed", or "go ahead"

---

## PHASE 3: Implementation (Only proceed after explicit Phase 2 approval)

**⚠️ VERIFY: Have you received explicit approval for the implementation plan? If not, STOP and wait for approval.**

5. **General Implementation Guidelines**:
   - **Build incrementally from simple to complex**:
     - Start with minimal working implementation
     - Add features one at a time
     - Verify each addition works before proceeding
   - **Handle uncertainties during implementation**:
     - For CRITICAL uncertainties that arise: STOP and ask for clarification
     - For LOW uncertainties: Document and seek guidance before proceeding
     - For MEDIUM/HIGH: Note assumption and continue, flag for review
   - **Prefer explicit over implicit**:
     - Avoid silent failures
     - Use early returns
     - Log key decision points
   - **Document as you go**:
     - Add comments for non-trivial logic
     - Document assumptions made
     - Explain design decisions

6. **Implementation**
   - For each planned code change (corresponding to a step in the plan), execute the task:
     - Reference relevant code snippets (with filenames/line numbers) to justify your approach or show context.
     - Use Markdown headers for each major section of the implementation work, potentially corresponding to steps in the plan.
     - If the code changes are non-trivial (more than 4 lines of code modified or added), add comments summarizing what it does.
     - Add top level documentation to any new function or class you define describing its purpose in relation to the task or goal.
     - Try to avoid silent failures in your implementation/use early returns
     - Do not mock implementations; provide real, functional code based on the approved plan.
     - **If implementation decisions arise that weren't covered in the plan, pause and present options:**
       - List available approaches with trade-offs
       - Include confidence level for each option
       - WAIT FOR USER RESPONSE before continuing
     - After implementing a logical unit (typically a step or group of related steps from the plan), execute the commit strategy (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`).

7. **Verification of Implementation**
   - Document how to verify that the implemented changes successfully address the User's Goal and write the following to a **Testing Plan markdown file.**
   - Suggest log lines to monitor(along with a simplified code location) and explain the exact sequencing/ordering of these log lines that would confirm your implementation. Your log lines should follow the following conventions:
     - **There should IDEALLY ONLY BE 1 log line per function which logs the variables most relevant to the User's Goal.**
     - Prefix (e.g., class/module name or abbreviation of User's Goal)
     - Function/class name
     - Semantic Log Message
     - Order in the Callpath(1,2,3...)
   - Use visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) in your explanation

**🚨 CRITICAL REMINDER: This is a THREE-PHASE process with mandatory stops:**
1. **Phase 1**: Ask clarifying questions → STOP and wait for answers
2. **Phase 2**: Present uncertainties and implementation plan → STOP and wait for clarification/approval
3. **Phase 3**: Implement code → Only after explicit approval

**Never skip ahead or assume approval. Each phase requires explicit user interaction.**

**Remember: Identifying what you don't understand is just as important as planning what you do understand. The user EXPECTS and VALUES uncertainty identification.**

### **User's Goal:**  
<Users_Goal>  
<Example/First_Step>
<Base Implementation>  

At the end, prompt the user to check what else needs to be included in the plan
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
        ":CodeCompanion /code_workflow<CR>",
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
