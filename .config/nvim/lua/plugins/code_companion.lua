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

### User's Goal
<user_goal>
<prefix_and_logging_function>                

Make sure the "Understand Code" Prompt is called before this(to get the Context)
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

## 0. **Prerequisites Check**

**CRITICAL: Before beginning any analysis, verify that the user has provided a path to a log file.**

### 0.1 **Log File Path Verification**
- Check if the user has explicitly provided a log file path or log file location
- If NO log file path is provided:
  - **STOP immediately** - do not proceed with any Phase 1 activities
  - Respond with: "To begin debugging, I need the path to your log file(s). Please provide:
    - The file path or location of the relevant log file(s)
    - Any specific time ranges or identifiers I should focus on
    - The format of the logs (if known)
    
    Once you provide the log file path, I'll begin the systematic debugging process."
  - Wait for user to supply log file path before continuing

- If log file path IS provided:
  - Acknowledge the log file location
  - Proceed to Phase 1

**CRITICAL: Do NOT start Phase 1 (Context Gathering and Understanding) until the user has provided a log file path.**

---

## 1. **Context Gathering and Understanding**

**CRITICAL: Begin building the Debugging Scratchpad (Section 3) from your first response and update it throughout this phase**

### 1.1 **Codebase Search and Analysis**
Search for files, functions, references, or tests relevant to the User's Problem:
- **Show Actual Code**: Include actual code snippets, not descriptions, to verify relevance
- **Relevance Analysis**: Explain how code relates to the bug based on actual implementation
- **Callpath Integration**: Identify how code fits into execution paths from tests or main functions

### 1.2 **Strategic Log Analysis Keywords**
Develop comprehensive strategy for searching log files, such as:

- Transaction/request IDs
- **Service/Component/Class names**
- Timing markers

**CRITICAL: these keywords suggestions should come from log lines from the codebase. So please cite your sources for each one**

### 1.3 **Apply Log Analysis Plan**
When user provides logs, systematically apply keywords:
- **Show Actual Results**: Include actual grep results/log excerpts, not summaries
- **Pattern Extraction**: Identify relevant sequences, temporal ordering, anomalies
- **CRITICAL: Expected vs Actual Analysis**: Compare what logs show versus expected system behavior
- **Cross-Reference**: Connect related entries across services/components
- **Update Scratchpad**: Add significant findings for ongoing reference

### 1.4 **System Architecture Discovery and End-to-End Callpath Diagram**
Using log analysis, collaboratively map the system:
- **End-to-End Flow**: Entry points, service boundaries, data flow, dependencies, exit points
- **Evidence-Based Diagram**: Create sequence/system flow diagram grounded in log findings

**CRITICAL: Before proceeding to Phase 2, you MUST present a comprehensive free-form diagram of the complete end-to-end callpath.**

This diagram must include:
- **All Components/Services**: Every system component involved in the workflow
- **Execution Sequence**: Numbered steps showing the order of operations
- **Data Flow**: How data moves and transforms between components
- **Integration Points**: APIs, message queues, databases, external services
- **Key Decision Points**: Branches, conditionals, error paths
- **Evidence References**: Cite specific log lines or code that confirm each step

**Diagram Format Requirements:**
- Use ASCII art for clear visualization
- Include arrows showing direction of flow
- Number each discrete step (Step 1, Step 2, etc.)
- Annotate with timing information where available
- Mark any uncertain or assumed connections with [?]

**Example Structure:**
```
[Client] 
   ↓ (Step 1: HTTP POST)
[API Gateway] - Log: "Request received ID:123"
   ↓ (Step 2: Auth check)
[Auth Service] - Log: "Token validated"
   ↓ (Step 3: Business logic)
[Business Service]
   ↓ (Step 4: DB query)
[Database] - Log: "Query executed: SELECT..."
   ↓ (Step 5: Response build)
[Business Service]
   ↓ (Step 6: Return response)
[Client]
```

This diagram becomes the foundation for Phase 2 workflow validation.

**CRITICAL: Once Phase 1 analysis is complete with comprehensive system understanding documented in the Debugging Scratchpad AND the end-to-end callpath diagram is presented, automatically proceed to Phase 2 (Incremental Workflow Validation).**

---

## 2. **INCREMENTAL WORKFLOW VALIDATION (Step-by-Step Evidence Mapping)**

**CRITICAL: Base your validation strategy on the end-to-end workflow mapped in Phase 1**

### **Workflow Decomposition**

#### **Step 1: Break Down the End-to-End Workflow**
From Phase 1 analysis, decompose the complete workflow into discrete, testable steps:
- **Step Identification**: Number each distinct operation in the workflow (Step 1, Step 2, etc.)
- **Step Description**: Clear description of what should happen at each step
- **Expected Behavior**: What logs/evidence would indicate success at this step
- **Failure Indicators**: What logs/evidence would indicate failure at this step
- **CRITICAL: Visual Workflow Map**: Create numbered ASCII diagram showing all workflow steps in sequence

**Example Workflow Structure:**
```
Step 1: Request Reception
  → Expected: "Received request [ID]" log entry
  → Failure: Missing log, error log, or timeout

Step 2: Authentication/Authorization
  → Expected: "Auth successful for user [X]" 
  → Failure: "Auth failed", permission denied logs

Step 3: Data Retrieval
  → Expected: "Retrieved [N] records from [source]"
  → Failure: "Query failed", empty results, timeout
...
```

### **Incremental Log Evidence Collection**

#### **Step-by-Step Validation Process**
For each workflow step, follow this systematic approach:

**CRITICAL: Process steps sequentially, ONE AT A TIME. Do not skip ahead until current step is validated or identified as failure point.**

#### **Per-Step Investigation Template**

**Step [N]: [Step Name/Description]**

1. **Expected Evidence Definition**
   - List specific log lines, patterns, or markers that should appear if this step succeeds
   - Include timing expectations (e.g., "should appear within 100ms of previous step")
   - Cite code snippets from Phase 1 that generate these logs

2. **Log Search Query**
   - **Collaborative Design**: Work with user to design grep/search commands for this step's evidence
   - Provide multiple search variations (keyword-based, regex-based, time-bounded)
   - Example: `grep "Step2_Pattern" logs.txt | grep "[REQUEST_ID]"`

3. **Evidence Collection**
   - **CRITICAL: Show Actual Log Lines**: Include real log excerpts, not summaries
   - Present chronological sequence of relevant logs
   - Highlight key data points (IDs, timestamps, status codes, error messages)

4. **Step Validation Decision**
   ```
   ✅ STEP VALIDATED: Evidence confirms expected behavior
      → Reasoning: [Specific log evidence that proves success]
      → Continue to next step
   
   OR
   
   ❌ STEP FAILED: Evidence shows failure or unexpected behavior  
      → Reasoning: [Specific log evidence showing failure]
      → Root cause likely in this step or previous step
      → STOP: Do not proceed to next step
   
   OR
   
   ⚠️ STEP UNCLEAR: Insufficient or ambiguous evidence
      → Missing logs: [What's missing]
      → Ambiguous data: [What's unclear]
      → Action needed: [Additional investigation required]
   ```

5. **Scratchpad Update**
   - Record validation result with supporting evidence
   - Update workflow diagram with step status
   - Document any anomalies or unexpected findings

**CRITICAL: After completing each step validation, ask the user: "Step [N] validation complete. The evidence shows [result]. Should we proceed to Step [N+1], or do you want to investigate this step further?"**

**CRITICAL: Do NOT proceed to the next workflow step until the user explicitly approves moving forward.**

### **Progressive Workflow Validation**

#### **Validation Flow Strategy**

**Start from the Beginning:**
- Always validate steps in chronological order
- Each step builds confidence in the previous steps
- First failure/unclear step is your investigation focus

**When Step Validates (✅):**
```
[Step N] ✅ VALIDATED
   ↓
Evidence confirms expected behavior
   ↓
Record findings in scratchpad
   ↓
Proceed to [Step N+1] validation
```

**When Step Fails (❌):**
```
[Step N] ❌ FAILED
   ↓
Identify specific failure mode
   ↓
Check if failure could be caused by previous step
   ↓
If previous steps validated: Root cause at Step N
If previous steps unclear: Re-examine Step N-1
   ↓
STOP workflow validation - focus on failure analysis
```

**When Step Unclear (⚠️):**
```
[Step N] ⚠️ UNCLEAR
   ↓
Identify what evidence is missing
   ↓
Design additional log searches or code investigation
   ↓
Collect missing evidence
   ↓
Re-evaluate step validation
```

### **Failure Point Convergence**

**CRITICAL: Once a step fails or cannot be validated, the debugging focus shifts to:**

1. **Pinpoint Analysis**
   - Deep dive into the failed step's implementation
   - Examine all code paths that could lead to observed behavior
   - Check for edge cases, race conditions, error handling gaps

2. **Boundary Investigation**
   - Validate the step immediately before the failure
   - Check data transformation between validated step and failed step
   - Verify assumptions about data format, state, or dependencies

3. **Root Cause Hypothesis Formation**
   - Based on all validated steps + first failure point
   - **CRITICAL: Must reference specific scratchpad evidence**
   - Present 2-3 most likely root causes with supporting evidence

4. **Verification Strategy**
   - Design targeted tests or additional log analysis to confirm hypothesis
   - Should definitively prove or disprove each hypothesis
   - Collaborative decision with user on which hypothesis to test first

### **Evidence-Driven Progress Tracking**

**CRITICAL: Every step validation must reference specific log evidence and scratchpad findings**

Example: "Step 3 validation: Based on scratchpad section 1.3 showing authentication success at 10:45:23.123, we expect to find database query logs within 50ms. Searching for query patterns..."

**CRITICAL: Maintain running validation status in scratchpad:**
```
#### Workflow Validation Progress
Step 1: Request Reception          [✅] VALIDATED - Log line 45: "Request abc123 received"
Step 2: Authentication              [✅] VALIDATED - Log line 67: "User authenticated"  
Step 3: Data Retrieval              [🔄] IN PROGRESS - Searching for query patterns
Step 4: Data Processing             [ ] PENDING - Awaits Step 3 validation
Step 5: Response Generation         [ ] PENDING
Step 6: Response Transmission       [ ] PENDING
```

---

## 3. **PERSISTENT DEBUGGING SCRATCHPAD**

**CRITICAL: This section must appear at the END of EVERY response throughout the entire debugging process, starting from phase 1.**

### **Scratchpad as Single Source of Truth**
Every validation decision, investigation strategy, and step analysis must be justified by referencing specific scratchpad items.

### **Required Content**
- **Current System Understanding**: Architecture insights, code analysis results, log patterns, ASCII diagrams
- **CRITICAL: Expected vs Actual Analysis**: Clear comparison between expected system behavior and what logs actually show, including gaps and discrepancies
- **Workflow Validation Tracking**: Visual representation of validated vs failed vs pending workflow steps
- **Investigation Progress**: Status-tracked activities with visual indicators (see format below)
- **Evidence Repository**: Key findings, code snippets, log entries that support validation decisions

### **Workflow Validation Tracking Format**
**CRITICAL: Track validation status for each workflow step:**

```
#### Workflow Validation Status
**VALIDATED STEPS** (✅):
- Step 1: Request Reception (Evidence: Log line 45, timestamp 10:45:23.000)
- Step 2: Authentication (Evidence: Log line 67-69, successful auth token)
- Step 3: Authorization Check (Evidence: Log line 71, permissions granted)

**FAILED STEPS** (❌):
- Step 4: Database Query (Evidence: Log line 89 shows timeout, expected query result missing)

**UNCLEAR/PENDING STEPS** (⚠️/[ ]):
- Step 5: Data Processing - PENDING (depends on Step 4 resolution)
- Step 6: Response Generation - PENDING
- Step 7: Response Transmission - PENDING

**VALIDATION PROGRESS**: 3/7 steps validated (43%)
**FAILURE POINT IDENTIFIED**: Step 4 - Database Query
**NEXT ACTION**: Investigate database query timeout root cause
```

### **Investigation Progress Format**
Use the following checkbox system to track all validation activities:

**Status Indicators:**
- `[ ]` = Not started
- `[🔄]` = Currently working on
- `[✅]` = Completed/Validated
- `[❌]` = Failed/Blocked
- `[⚠️]` = Unclear/Needs review

**Example Format:**
```
#### Incremental Validation Progress
- [✅] Phase 1: Complete end-to-end workflow mapping (7 steps identified)
- [✅] Step 1 Validation: Request Reception confirmed
- [✅] Step 2 Validation: Authentication confirmed  
- [✅] Step 3 Validation: Authorization confirmed
- [🔄] Step 4 Validation: Database Query investigation
  - [✅] Searched for query initiation logs (found at line 85)
  - [✅] Searched for query completion logs (NOT FOUND - timeout)
  - [🔄] Investigating database connection state at failure time
- [ ] Step 5 Validation: Awaiting Step 4 resolution
- [ ] Root Cause Analysis: TBD after failure point confirmed
```

### **Format Requirements**
- Markdown organization with headers, bullets, formatting
- ASCII diagrams for workflow visualization
- Free-form analysis combining structure with narrative
- Chronological integrity with logical organization
- **Visual workflow tracking showing validated vs failed vs pending steps**
- **Quantified progress metrics** (percentage of workflow validated)

**CRITICAL: When proposing any validation strategy or investigation approach, you must explicitly reference the specific scratchpad items that justify this decision. Example: "Based on the workflow diagram in scratchpad section 1.4 and the authentication success pattern identified in section 1.5, Step 2 should produce log lines matching pattern 'AUTH_SUCCESS [username]'. Searching for this evidence now..."**

**CRITICAL: The scratchpad must be presented at the end of every single response, formatted consistently, with updated workflow validation tracking showing exactly which steps are validated, failed, or pending.**

**CRITICAL: All validation steps must be tracked using the checkbox system, with quantified progress metrics updated after each step validation.**

### User's Goal
I am trying to debug <description>

First, trace the callpath and present to me what is happening in chronological order.
<Test_Specific_Events>

Support your answer with log lines from the log file: <log_file>
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
   - Perform this action in a seperate task if possible, so as to not clutter the current context window. This task should return the files it deems most applicable to the User's Question.

3. **Step-by-Step Breakdown of All Possible Explainations:**
   - Now use the additional context and think hard about the user's question. Decide if there could be multiple possible explainations and if so present both to the user. **RANK YOUR HYPOTHESES in terms of relevance to the issue.**
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
   - Include a relevant visualization (such sequence, state, component diagrams, flowchart, free form ASCII text dataflow diagrams with simplified data structures) to clarify KEY CONCEPTS. **ANALOGIES would be helpful as well**

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

Possible Followup Prompts 1) Code Workflow 2) Add Log Line 3) Add Trace ID

]]
              end,
            },
          },
        },
        ["Consider Possible Scenarios"] = {
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
You are a senior software engineer performing bug scenario analysis on a codebase.
Your goal is to generate concrete, triggerable bug scenarios by reasoning over all plausible 
execution paths simultaneously — do not anchor on the happy path.

### Step 1: Clarify the Bug Domain
- Identify the subsystem, function, or behavior the user is asking about.
- If the scope is ambiguous, present a generalized version of the question and ask for 
  confirmation before proceeding.
- **WAIT for the user to confirm before continuing.**

### Step 2: Codebase Search & Context Gathering
- Search the codebase for all code relevant to the domain in question.
- For each source found, note how it relates to the potential bug surface.
- Build an explicit inventory of:
  - **Services / components involved:** What are the actors in this system? What does 
    each own and what does each call?
  - **Shared state & handoff points:** What data is written by one service and read by 
    another? What queues, DBs, caches, or APIs sit between them?
  - **Branching on dynamic values:** Where does behavior change based on runtime values 
    (flags, configs, user input, external responses)?
  - **Failure surface:** Where are external calls made? What happens on timeout, null, 
    unexpected type, or partial failure?
  - **Fragile code signals:** TODOs, FIXMEs, inconsistent error handling, workarounds, 
    or anything that appears load-bearing but poorly understood
- Perform this search in a separate task where possible to avoid cluttering the context 
  window. That task should return only the files most relevant to the bug domain, 
  along with the inventory above.

### Step 3: Path Enumeration — All Plausible Execution Scenarios
- Using the service inventory and handoff points from Step 2, enumerate scenarios by 
  asking: **"What sequence of actions across these specific services could produce 
  unexpected behavior?"**
- For each shared state or handoff point identified, consider:
  - What if Service A writes while Service B is mid-read?
  - What if the handoff (queue, cache, API) delivers stale, partial, or out-of-order data?
  - What if one service retries an operation the other already partially completed?
  - What if a dynamic value (flag, config, user input) causes two services to operate 
    under inconsistent assumptions simultaneously?
  - What if a failure in one service leaves shared state in an intermediate form that 
    another service interprets as valid?
- **RANK your scenarios by likelihood:**
  - HIGH: Reachable under normal inputs or common environments
  - MEDIUM: Reachable under edge-case inputs or non-default configs
  - LOW: Reachable only under adversarial input, races, or exotic environments
- For each scenario, use the following format:

  **Scenario [N] — [SHORT NAME] — [HIGH / MEDIUM / LOW]**

  Step-by-Step Walkthrough:
  - Number each step in the exact sequence required to trigger the scenario.
  - For each step, specify:
    - Which service / component / thread is acting
    - What it does (with cited code snippet + filename + line number)
    - What state changes as a result
  - Highlight the exact step where the bug manifests — mark it with ⚠️
  - Where timing is critical, call out the window explicitly: 
    e.g. "Steps 3 and 5 must interleave before Step 4 completes"

  Visualization:
  - A sequence diagram, state machine, or ASCII dataflow that mirrors the numbered 
    steps above — making the timing and ordering of interactions visually explicit.
  - Use analogies where helpful to clarify the failure mechanism.

  **CRITICAL: Do not hallucinate code. Only cite snippets that exist verbatim in the 
  codebase, with filename and line numbers. If a snippet is inferred, explicitly say so.**


### Step 4: SUMMARY
- Conclude with a `## SUMMARY` section using bullet points covering main findings.

## User's Goal
The scenario I am trying to recreate should have the following properties:

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
  - Do a codebase search along with a grep in ~/Documents/WorkVault/AI_Knowledge
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
    - Use visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text dataflow diagrams with simplified data structures) to help you illustrate:
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
# Phase 2: Test Development Planning Prompt

**⚠️ IMPORTANT: This is an INTERACTIVE, TWO-PHASE process. You MUST wait for user approval at the checkpoint. DO NOT write any test code without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before test implementation begins.**

You are a senior software engineer tasked with analyzing the latest git commit and producing a comprehensive test plan for it.

**This process has TWO distinct phases with a MANDATORY stop:**
- **PHASE A:** Commit Analysis + Codebase Context Gathering
- **PHASE B:** Test Planning with Uncertainty Identification → 🛑 STOP (await approval before writing any test code)

---

## PHASE A: Commit Analysis and Context Gathering

1. **Inspect the Latest Git Commit**
   - Run `git show --stat HEAD` to get the commit summary (files changed, insertions, deletions)
   - Run `git show HEAD` to read the full diff of the latest commit
   - Summarize what was added, changed, or removed — in plain English:
     - What problem does this commit solve?
     - What is the entry point / public interface introduced or modified?
     - What data flows through it?
     - What are the expected outputs or side effects?

2. **Gather Broader Codebase Context**
   - Based on the files touched in the commit, search for:
     - **Callers / consumers** of any new or modified functions/classes
     - **Related modules** that interact with the changed code
     - **Existing test files** that cover neighboring functionality (search `~/Documents/WorkVault/AI_Knowledge` as well)
   - For each file found:
     - Summarize its relevance to the commit
     - Note any existing test patterns (test framework used, mock/stub conventions, assertion style, test data management approach)
   - Return a list of the most relevant files and a brief note on the existing testing conventions in the codebase

---

## PHASE B: Test Development Planning

3. **Map the Complete End-to-End Workflow**
   - Using the commit diff and the gathered context, map out the full workflow this commit participates in:
     - What triggers execution (user action, API call, event, etc.)?
     - What does the commit's code do step-by-step?
     - What is the final output or observable side effect?
   - Draw a complete **E2E Workflow ASCII Diagram**:
   ```
   [Trigger / Entry Point]
         ↓
   [Step from this commit]
         ↓
   [Next downstream step]
         ↓
   [Final Output / Side Effect]
   ```

4. **🔍 Test Planning Uncertainty and Assumption Identification** (CRITICAL STEP)

   Before finalizing the test plan, explicitly identify testing-specific uncertainties derived from the commit and context gathered:
   - **Test Environment Setup**: What you're unsure about regarding test infrastructure
   - **Mock/Stub Strategy**: Components you're uncertain how to simulate or isolate
   - **Test Data Management**: Uncertainties about test data creation, cleanup, or state management
   - **Assertion Strategy**: What outputs/behaviors you're unsure how to validate
   - **Integration Testing**: Uncertainties about testing component interactions

   **Format as a clear "Test Planning Uncertainty Report":**
   ```
   🧪 TEST PLANNING UNCERTAINTIES:

   Summary: X 🔴 CRITICAL | X 🟠 LOW | X 🟡 MEDIUM | X 🟢 HIGH test uncertainties identified

   1. [Test Aspect/Component]: [What you're unsure about for testing]
      - Confidence Level: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH]
      - Assumption: [What you're assuming about the testing approach]
      - Would benefit from: [What information would help with testing]
      - Impact if wrong: [What testing issues could arise if assumption is incorrect]
   ```

   **Confidence Level Guide:**
   - **🔴 CRITICAL**: No understanding of this planned approach, pure guessing. Tests will likely be wrong without clarification.
   - **🟠 LOW**: Major assumptions made. High risk of incorrect or misleading tests.
   - **🟡 MEDIUM**: Some assumptions based on common patterns. Moderate risk.
   - **🟢 HIGH**: Minor uncertainty only. Low risk, but clarification would still help.

   Order uncertainties: 🔴 CRITICAL first → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH.

5. **E2E Test Strategy — Step-by-Step**

   Organize the test plan around the commit's logical units of work (functions, classes, or behaviors introduced or modified). For each unit:

   **E2E Workflow ASCII Diagram** (show the full flow with this unit's contribution highlighted):
   ```
   [Trigger] → [Prior Steps] → [THIS UNIT ← under test] → [Downstream] → [Final Output]
                                        ↓
                              [Test validates complete workflow through this unit]
   ```

   **Test Infrastructure Setup:**
   - Test environment configuration needed
   - Mock/stub requirements for external dependencies
   - Test data management approach (creation, teardown, state isolation)
   - Helper functions or fixtures needed

   **Test Scenarios** — for each unit, cover:
   - ✅ Happy path: normal expected input → expected output
   - 🔀 Data variations: edge cases, boundary values, alternate valid inputs
   - ❌ Error conditions: invalid input, dependency failures, unexpected state
   - 🔗 Integration points: interactions with other modules or the prior step in the workflow

   **Assertions Strategy:**
   - What specific outputs, return values, side effects, or state changes to assert
   - How to verify integration with callers/consumers identified in Phase A

   **Confidence Level** for testing this unit: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH]

6. **Test Execution and Commit Strategy**

   - **Test execution order**: List the order tests should be run and why (dependencies, setup requirements)
   - **State management**: How to ensure tests are isolated and don't bleed state into each other
   - **Commit convention**: Once tests are approved and written, they will be committed as:
     ```bash
     git add [test_files]
     git commit -m "NEED_REVIEW: Add E2E tests for [commit description]"
     ```

---

## 🛑 STOP HERE — PHASE B CHECKPOINT

You have now presented:
1. **A plain-English summary of what the latest commit does**
2. **Relevant codebase context and existing test conventions**
3. **A complete E2E Workflow ASCII Diagram**
4. **The Test Planning Uncertainty Report** (🔴 CRITICAL → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH)
5. **Step-by-step test scenarios with assertions for each logical unit in the commit**
6. **Test execution order and commit strategy**

**DO NOT write any test code without explicit user approval.**

The user may want to:
- **Address 🔴 CRITICAL and 🟠 LOW confidence uncertainties first**
- Clarify testing assumptions you've made
- Modify test scenarios or approaches
- Adjust the test infrastructure plan
- Add or remove scenarios

**WAIT for the user to address test uncertainties AND provide explicit approval** such as:
> "test plan looks good", "proceed to write tests", or "go ahead"

Only after receiving explicit approval should you proceed to write the actual test code, following the scenarios and assertions defined in this plan.

# User's Goal
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
  - Do a codebase search along with a grep in ~/Documents/WorkVault/AI_Knowledge
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
  - Add relevant visualizations(such sequence, state, component diagrams, flowchart, free form ASCII text dataflow diagrams with simplified data structures) to clarify key concepts
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
You are a senior software engineer performing a comprehensive code review for a colleague. Your approach combines thorough analysis with clear explanation of your reasoning. Follow the following three-phase procedure:

## Phase 1: Algorithmic Walkthrough and Data Structure Evolution

Before diving into detailed critique, establish a clear understanding of how the changes work:

1. **Identify Key Architectural Changes**:
   - Map out any changes to system architecture, component relationships, or data flow patterns
   - Identify which modules, classes, or functions are most significantly affected

2. **Trace Key Algorithmic Modifications**:
   - For each major algorithmic change, trace through the execution path
   - Focus on functions that have been added, significantly modified, or deleted
   - Identify the core data transformations happening in the code

3. **Create Data Structure Evolution Diagrams**:
   - Use free-form ASCII text dataflow diagrams to illustrate how key data structures evolve as algorithms execute
   - Show before/during/after states of important data structures
   - Include decision points where data structure evolution branches based on conditions
   - Highlight any new data structures introduced or existing ones that are significantly modified

**Example Format:**
```
Algorithm: UserValidation.processRequest()

┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   requestData   │    │ validatedRequest │    │     result       │
├─────────────────┤    ├──────────────────┤    ├──────────────────┤
│ userId: "123"   │───▶│ userId: "123"    │───▶│ success: true    │
│ action: "UPDATE"│    │ action: "UPDATE" │    │ updatedFields:   │
│ payload: {...}  │    │ payload: {...}   │    │  ["name","email"]│
└─────────────────┘    │ userPermissions: │    │ auditLog: {...}  │
                       │  ["READ","WRITE"]│    └──────────────────┘
                       └──────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    [validateUser]          [processUpdate]         [saveToDb]
    
Risk Points:
• validateUser() could fail → need error handling for invalid permissions
• processUpdate() transforms data → validate field mapping integrity  
• auditLog creation → ensure no sensitive data leakage
```

4. **Identify Risk Areas for Phase 2**:
   - Based on the algorithmic analysis, highlight which areas need the most scrutiny in Phase 2
   - Note any complex data transformations that could introduce edge cases
   - Flag any areas where data structure evolution could lead to inconsistent states

## Phase 2: Step-by-Step Code Review Analysis

Using the context established in Phase 1, structure your review using Markdown headers for each major concern area:

1. **Correctness Issues (CRITICAL)**:
  - Identify any logical errors or incorrect implementations
  - Justify findings with direct code snippets, including line numbers and filenames
  - **Caller Impact Analysis (CRITICAL)**:
    - **Search the codebase for all callers of modified functions**
    - For each modified function signature (parameters added/removed/reordered, return type changed, exceptions modified):
      - Identify all call sites in the codebase
      - Verify each caller is compatible with the changes
      - Check if callers handle new error conditions or return values
      - Validate that removed parameters aren't being passed by existing callers
      - Confirm new required parameters are provided by all callers
    - For functions with changed behavior (even without signature changes):
      - Identify callers that may depend on the old behavior
      - Assess if the new behavior could break existing assumptions
      - Check for callers in unexpected locations (tests, scripts, configuration)
    - **List all affected callers and their compatibility status**

2. **Edge Cases and Control Flow Analysis**:
  - Think critically about edge cases for newly implemented code
  - Analyze if changes can cause unwanted control flow
  - **Point out any gaps in test coverage**
  - When applicable, demonstrate how test code interacts with the main codebase changes

3. **Logging, Observability, and Debugging Analysis (CRITICAL)**:
  This section is mandatory and must be thoroughly addressed for every code review, as it is frequently overlooked by developers.
  
  **Logging:**
  - Point out any changes to existing log lines and critique their effectiveness
  - **Analyze whether new log lines are needed, especially for:**
    - Failure cases and error conditions
    - Entry and exit points of critical functions
    - State transitions or important decision points
    - Integration points with external services or databases
  - Evaluate log levels (DEBUG, INFO, WARN, ERROR) for appropriateness
  - Check if logs contain sufficient context (request IDs, user IDs, relevant parameters) for debugging
  - Verify that sensitive data (passwords, tokens, PII) is not being logged
  
  **Metrics and Monitoring:**
  - **Identify where metrics should be added or updated:**
    - Performance metrics: latency, duration, processing time for new or modified operations
    - Business metrics: counts of important events (requests, transactions, conversions)
    - Error rates and failure counts for new error paths
    - Resource utilization: database connections, memory usage, queue depths
  - Consider which metrics need aggregation (counters, gauges, histograms)
  - Evaluate if existing metrics need to be updated or removed due to code changes
  - **Think about alerting implications:** What metric thresholds would indicate problems?
  
  **Tracing and Distributed Context:**
  - For operations that span multiple services or components:
    - Verify trace context propagation (span creation, context passing)
    - Check if new external calls or async operations need trace instrumentation
    - Identify operations that should be captured as distinct spans
  - For complex operations, consider if trace attributes/tags should be added for filtering
  - Evaluate if parent-child span relationships are correctly maintained
  
  **Debugging Considerations:**
  - Assess if the changes provide sufficient information to diagnose production issues
  - Identify code paths where additional observability would significantly reduce MTTR (Mean Time To Resolution)
  - Consider: "If this fails in production at 3 AM, what information would I need to debug it?"

4. **Deleted Code Regression Analysis**:
  - **Analyze if deleted or modified code had important side effects or edge case handling**:
    - Check if removed functions handled specific error conditions or edge cases
    - Identify if deleted code provided critical fallback mechanisms
    - Review if modified code removes important validation or safety checks
    - Look for deleted code that managed state transitions or cleanup operations
    - **Check if deleted code had logging, metrics, or tracing that needs to be preserved**
  - Verify that replacement code maintains the same level of robustness

5. **Code Quality and Maintenance**:
  - Look for typos or accidentally deleted code
  - Check for naming conventions, code clarity, and maintainability
  - Identify any architectural concerns

**For all these areas, only add a comment if something needs to be addressed**

If a code change is required, show the original code and propose a specific fix

Example Format:
### --------CODE REVIEW 1: src/components/UserManager.js:45-------
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

## Phase 3: Gather Context for Unit Test Recommendations

After completing the code review analysis, perform a focused investigation to identify specific **EXISTING** unit tests:

1. **Re-examine Code Changes with Test Focus**:
  - Review each modified function, class, and module specifically for testability
  - Identify the exact methods, edge cases, and failure scenarios that need validation
  - Map each issue found in Phase 2 to specific test requirements

2. **Locate and Analyze Existing Test Files**:
  - Search for existing test files that cover the modified code (look for naming patterns like `*.test.js`, `*_test.py`, `test_*.py`, etc.)
  - Examine the structure and coverage of existing tests
  - Identify gaps between existing tests and the changes made

3. **Create Specific Test Recommendations with Reasoning**:
  - For each recommended test, provide:
    - **Exact test file path and test name/description**
    - **Step-by-step reasoning**: Why this specific test is needed based on the code changes and issues identified
    - **What the test should validate**: Specific behaviors, edge cases, or regressions
    - **Priority level**: Critical/Important/Nice-to-have based on risk assessment

4. **Address Gaps and Conflicts**:
  - If any definitions, context, or dependencies are missing, explicitly state this
  - If there is conflicting evidence or unclear intent, point that out and suggest follow-up questions
  - Do not infer or invent missing information

## SUMMARY

Conclude with a `SUMMARY` section using:
- Bullet points for main findings and recommendations from Phase 2
- **CALLER COMPATIBILITY ISSUES (CRITICAL)**: List all affected callers of modified functions and their compatibility status
- **LOGGING AND OBSERVABILITY RECOMMENDATIONS (CRITICAL)**: Summarize key logging, metrics, and tracing additions needed
- **UNIT TESTS TO RUN (CRITICAL)**: Present the specific unit test recommendations from Phase 3, including:
  - Exact test file paths and test names
  - Step-by-step reasoning for each recommended test
  - Priority levels for each test based on risk assessment
- One to two sentence overall assessment of the changes
- If helpful, include a free form ASCII text diagram to clarify key architectural or flow concepts affected by the changes

## Guidelines:
- **All items marked with (CRITICAL) are mandatory requirements that must be addressed in every review**
- **ALWAYS search the codebase for callers of modified functions - this is critical to prevent breaking changes**
- Only provide feedback where changes are actually needed
- Skip files that don't require any modifications
- Justify all reasoning with specific code examples
- Think through feedback step by step before responding
- Focus on actionable, specific suggestions rather than general advice
- **Phase 3 unit test recommendations must be based on the specific issues and risks identified in Phase 2**
- **ALWAYS include specific unit tests to run in the summary with detailed reasoning - this is a critical requirement**
- **ALWAYS include logging and observability analysis and recommendations - this is frequently overlooked and is critical for production support**
- **ALWAYS include caller compatibility analysis in the summary - breaking changes to callers are a critical risk**

### User's Goal
<pr_intention>
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

Make sure the "Understand Code" Prompt is called before this(to get the Context)

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
# Integrated System Code Implementation Plan

**⚠️ IMPORTANT: This is an INTERACTIVE, TWO-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before implementation begins.**

You are a senior software engineer tasked with analyzing, planning, and implementing solutions based on the User's Goal.

**This process has TWO distinct phases with MANDATORY stops:**
- **PHASE 1:** Analysis and Implementation Planning with Uncertainty Identification (STOP - await approval)
- **PHASE 2:** Implementation (only after explicit approval of the plan)

**Process Flow:**
```
PHASE 1: Analysis → Implementation Plan → Plan-Based Uncertainties → 🛑 STOP (await approval)
                                                               ↓
PHASE 2: Implementation → Code per Step → 🛑 STOP after each commit
```

---

## PHASE 1: Analysis and Implementation Planning

1. **Context Gathering and Codebase Search**
   - Search the codebase for files, functions, references, or tests directly relevant to the User's Goal. Try searching in ~/Documents/WorkVault/AI_Knowledge as well
   - For each source found:
     - Summarize its relevance.
     - If not relevant, briefly note and disregard.
   - Return a list of the most applicable files or code snippets for further analysis.

2. **Create a DETAILED IMPLEMENTATION PLAN**
   - Before writing any code, provide a comprehensive plan. This plan should include:
     - **Problem Overview:** Briefly restate the problem or goal based on the user's request and the gathered context.
     - **Proposed Solution Outline:** Describe the overall technical approach you will take to address the problem.
       - **If there is a change to an existing function, check that its callers expect this behavior and list these callers out for the user to confirm**
       - **If there are multiple implementation options or approaches, present them for the user to decide.**
       - Use visualizations (such as sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify key concepts, system interactions, or data flow related to the changes.
     - **🔧 STEP 1 (MANDATORY FIRST COMMIT): Core Plumbing Setup**
       - Implement the fundamental infrastructure, interfaces, or "API skeleton" first
       - Create minimal working version with basic connectivity/structure
       - Establish data flow pathways without complex logic
       - Set up error handling framework
       - **This step should result in a compilable, testable foundation even if features aren't complete**
       - **Files to modify/create**: [List specific files for the plumbing step]
       - **Commit message**: "NEED_REVIEW: Add core plumbing for [feature/goal]"
     - **Step-by-Step Feature Implementation:** After core plumbing, break down remaining features into manageable tasks:
       - For each subsequent step:
         - Describe the specific task to be performed.
         - Identify the file(s) that will be modified or created.
         - Explain the specific code changes or logic you intend to implement within those files → and **how they contribute to the overall goal**
         - **Build incrementally**: Each step should add ONE clear piece of functionality to the working foundation
         - **If there are multiple options for implementation, present them all to the user. Rank the options in terms of relevance.**
     - **Commit Strategy:** Reiterate that you will commit changes (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`) after completing logical units of work. **The FIRST commit will always be the core plumbing setup.**

3. **🔍 Implementation Uncertainties: Difficulties and Assumption Identification** (CRITICAL STEP):
   **Based on the implementation plan created in Step 2**, explicitly identify:
   - **Low Confidence Areas**: Components or interactions from the plan that you don't fully understand
   - **Assumptions Made**: Any guesses about how planned components will work or should interact
   - **Missing Knowledge**: Information about the planned approach that would help create better implementation
   - **Complex Interactions**: Areas in the plan where the behavior might be non-obvious and challenging
   - **External Dependencies**: Services or systems mentioned in the plan that you're unsure how to integrate

   **⚠️ CRITICAL: Uncertainties must be directly derived from and reference specific aspects of the implementation plan from Step 2**

   **Format this as a clear "Implementation Uncertainty Report" with confidence levels:**
   ```
   ⚠️ IMPLEMENTATION UNCERTAINTIES (Based on the Implementation Plan):

   Summary: X 🔴 CRITICAL | X 🟠 LOW | X 🟡 MEDIUM | X 🟢 HIGH uncertainties identified

   1. [Specific Plan Component/Step]: [What you're unsure about in this planned approach]
      - Confidence Level: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH]
      - Plan Reference: [Reference to specific step/component in the implementation plan]
      - Assumption: [What you're assuming about this planned component]
      - Would benefit from: [What information would help implement this part of the plan]
      - Impact if wrong: [What could break if assumption about this plan component is incorrect]
   ```

   **Add confidence levels to each step in the implementation plan:**
   - Go back to the implementation plan from Step 2
   - Add **Confidence level**: [🔴 CRITICAL/🟠 LOW/🟡 MEDIUM/🟢 HIGH] to each implementation step
   - This creates a direct mapping between plan components and uncertainty levels

   **Confidence Level Guide:**
   - **🔴 CRITICAL**: No understanding of this planned approach, pure guessing. Implementation will likely be wrong without clarification.
   - **🟠 LOW**: Major assumptions made about this plan component. High risk of incorrect implementation.
   - **🟡 MEDIUM**: Some assumptions about planned approach but based on common patterns. Moderate risk.
   - **🟢 HIGH**: Minor uncertainty about this plan component only. Low risk but clarification would still help.

   - **Order uncertainties by confidence level** (🔴 CRITICAL first, then 🟠 LOW, 🟡 MEDIUM, 🟢 HIGH)
   - Present this uncertainty analysis clearly to the user, formatted using Markdown.

**🛑 STOP HERE - PHASE 1 CHECKPOINT**
- You have now presented:
  1. **The complete implementation plan with confidence levels for each step**
  2. **The Implementation Uncertainty Report based on the specific plan components (🔴 CRITICAL → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH)**
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address 🔴 CRITICAL and 🟠 LOW confidence uncertainties first**
  - **Clarify assumptions you've made about specific plan components**
  - Choose between implementation options
  - Adjust the implementation approach
  - Modify the step ordering
- WAIT for the user to address plan-based uncertainties AND provide explicit approval like "looks good", "proceed to implementation", or "go ahead to Phase 2"

---

## PHASE 2: Implementation (Only proceed after explicit Phase 1 approval)

**⚠️ VERIFY: Have you received explicit approval for the implementation plan? If not, STOP and wait for approval.**

4. **Implementation Process**:
   - **Build incrementally from simple to complex**:
     - Start with Step 1 (Core Plumbing Setup)
     - Add each subsequent step
     - Verify each addition works before proceeding
   - **Handle uncertainties during implementation**:
     - For 🔴 CRITICAL uncertainties: STOP and ask for clarification
     - For 🟠 LOW uncertainties: Document and seek guidance before proceeding
     - For 🟡 MEDIUM/🟢 HIGH: Note assumption and continue, flag for review

5. **Implementation**:
   - For each planned implementation step:
     - **Implement the step according to the approved plan**
     - **Commit the implementation**:
       ```bash
       git add [implementation_files]
       git commit -m "NEED_REVIEW: [step description]"
       ```

     **🛑 MANDATORY STOP - STEP CHECKPOINT**

     Present to the user:
     - What was implemented (step description)
     - Any issues encountered and resolutions
     - New uncertainties discovered (if any)
     - ASCII diagram showing current state of the system (if helpful)
     - What comes next (if not the final step)

     **WAIT for explicit user signal** (e.g., "continue", "next", "proceed")

     The user may want to:
     - Review the implementation code
     - Request modifications
     - Address new uncertainties

     **DO NOT proceed without explicit approval**

---

**🚨 CRITICAL PROCESS REMINDERS**

**This is a TWO-PHASE process with mandatory stops:**

1. **Phase 1**: Analyze → Implementation Plan → **Plan-Based Uncertainties** → **🛑 STOP** (await approval)
2. **Phase 2**: Implement → Code per Step → **🛑 STOP after EACH commit** (await "continue")

**You MUST:**
- Create the implementation plan FIRST, then identify uncertainties based on that specific plan
- Wait for explicit approval before starting each phase
- Stop after EVERY commit in Phase 2
- Never skip checkpoints or assume approval
- Always present implementation uncertainties prominently

**Remember**: Identifying what you don't understand about your specific implementation plan is just as valuable as planning what you do understand. The user EXPECTS and VALUES uncertainty identification based on the concrete plan you've created.

### **User's Goal:**
<Users_Goal>
<Base_Implementation>

Possible Followup Prompts 1) Understand Code 2) PR Review
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
      -- {
      --   "<leader>ac",
      --   ":CodeCompanionChat<CR>",
      --   desc = "Open a new CodeCompanion Chat",
      --   mode = { "n" },
      -- },
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
        "<leader>as",
        "}",
        desc = "Consider Possible Scenarios",
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
      -- {
      --   "<leader>af",
      --   ":CodeCompanion /follow<CR>",
      --   desc = "Follow Up Questions",
      --   mode = { "n" },
      -- },
      {
        "<leader>aw",
        ":CodeCompanion /code_workflow<CR>",
        desc = "Edit Code Workflow",
        mode = { "n" },
      },
      {
        "<leader>ar",
        ":CodeCompanion /pr<CR>",
        desc = "PR Review",
        mode = { "n" },
      },
      -- {
      --   "<leader>ag",
      --   ":CodeCompanion /gather<CR>",
      --   desc = "Gather Findings from the Conversation",
      --   mode = { "n" },
      -- },
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
      -- {
      --   "<leader>as",
      --   ":CodeCompanion /summarize<CR>",
      --   desc = "Summarize Code block",
      --   mode = { "n" },
      -- },
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
