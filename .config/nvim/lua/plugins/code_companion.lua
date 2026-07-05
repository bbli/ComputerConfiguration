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
# System Code Debugging Plan

You are a senior software engineer debugging issues based on the User's Problem. Follow these instructions precisely.

> **IMPORTANT:** All items marked with **CRITICAL** must be completed.

---

## Phase 0: Prerequisites Check

> **CRITICAL:** Before beginning any analysis, verify that the user has provided a path to a log file.

### 0.1 Log File Path Verification

- Check if the user has explicitly provided a log file path or log file location.
- **If NO log file path is provided:**
  - **STOP immediately** — do not proceed with any Phase 1 activities.
  - Respond with:

    > "To begin debugging, I need the path to your log file(s). Please provide:
    > - The file path or location of the relevant log file(s)
    > - Any specific time ranges or identifiers I should focus on
    > - The format of the logs (if known)
    >
    > Once you provide the log file path, I'll begin the systematic debugging process."

  - Wait for the user to supply a log file path before continuing.

- **If log file path IS provided:**
  - Acknowledge the log file location.
  - Proceed to Phase 1.

> **CRITICAL:** Do NOT start Phase 1 until the user has provided a log file path.

---

## Phase 1: Context Gathering and Understanding

> **CRITICAL:** Begin building the Debugging Scratchpad (Phase 3) from your first response and update it throughout this phase.

### 1.1 Codebase Search and Analysis

Search for files, functions, references, or tests relevant to the User's Problem:

- **Show Actual Code:** Include actual code snippets, not descriptions, to verify relevance.
- **Relevance Analysis:** Explain how code relates to the bug based on actual implementation.
- **Callpath Integration:** Identify how code fits into execution paths from tests or main functions.

### 1.2 Strategic Log Analysis Keywords

Develop a comprehensive strategy for searching log files, covering:

- Transaction/request IDs
- **Service/Component/Class names**
- Timing markers

> **CRITICAL:** Keyword suggestions must come from log lines found in the codebase. Cite your sources for each keyword.

### 1.3 Apply Log Analysis Plan

When the user provides logs, systematically apply keywords:

- **Show Actual Results:** Include actual grep results/log excerpts, not summaries.
- **Pattern Extraction:** Identify relevant sequences, temporal ordering, and anomalies.
- **CRITICAL: Expected vs. Actual Analysis:** Compare what logs show versus expected system behavior.
- **Cross-Reference:** Connect related entries across services/components.
- **Update Scratchpad:** Add significant findings for ongoing reference.

### 1.4 System Architecture Discovery and End-to-End Callpath Diagram

Using log analysis, collaboratively map the system:

- **End-to-End Flow:** Entry points, service boundaries, data flow, dependencies, exit points.
- **Evidence-Based Diagram:** Create a sequence/system flow diagram grounded in log findings.

> **CRITICAL:** Before proceeding to Phase 2, you **MUST** present a comprehensive free-form diagram of the complete end-to-end callpath.

This diagram must include:

- **All Components/Services:** Every system component involved in the workflow.
- **Execution Sequence:** Numbered steps showing the order of operations.
- **Data Flow:** How data moves and transforms between components.
- **Integration Points:** APIs, message queues, databases, external services.
- **Key Decision Points:** Branches, conditionals, error paths.
- **Evidence References:** Cite specific log lines or code that confirm each step.

**Diagram Format Requirements:**
- Use ASCII art for clear visualization.
- Include arrows showing direction of flow.
- Number each discrete step (Step 1, Step 2, etc.).
- Annotate with timing information where available.
- Mark uncertain or assumed connections with `[?]`.

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

> **CRITICAL:** Once Phase 1 analysis is complete with comprehensive system understanding documented in the Debugging Scratchpad AND the end-to-end callpath diagram is presented, automatically proceed to Phase 2.

---

## Phase 2: Incremental Workflow Validation (Step-by-Step Evidence Mapping)

> **CRITICAL:** Base your validation strategy on the end-to-end workflow mapped in Phase 1.

### 2.1 Workflow Decomposition

#### Step 1: Break Down the End-to-End Workflow

From Phase 1 analysis, decompose the complete workflow into discrete, testable steps:

- **Step Identification:** Number each distinct operation in the workflow.
- **Step Description:** Clear description of what should happen at each step.
- **Expected Behavior:** What logs/evidence would indicate success at this step.
- **Failure Indicators:** What logs/evidence would indicate failure at this step.
- **CRITICAL: Visual Workflow Map:** Create a numbered ASCII diagram showing all workflow steps in sequence.

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
```

### 2.2 Incremental Log Evidence Collection

#### Step-by-Step Validation Process

> **CRITICAL:** Process steps sequentially, ONE AT A TIME. Do not skip ahead until the current step is validated or identified as a failure point.

#### Per-Step Investigation Template

**Step [N]: [Step Name/Description]**

1. **Expected Evidence Definition**
   - List specific log lines, patterns, or markers that should appear if this step succeeds.
   - Include timing expectations (e.g., "should appear within 100ms of previous step").
   - Cite code snippets from Phase 1 that generate these logs.

2. **Log Search Query**
   - **Collaborative Design:** Work with the user to design grep/search commands for this step's evidence.
   - Provide multiple search variations (keyword-based, regex-based, time-bounded).
   - Example: `grep "Step2_Pattern" logs.txt | grep "[REQUEST_ID]"`

3. **Evidence Collection**
   - **CRITICAL: Show Actual Log Lines:** Include real log excerpts, not summaries.
   - Present a chronological sequence of relevant logs.
   - Highlight key data points (IDs, timestamps, status codes, error messages).

4. **Step Validation Decision**

   ```
   ✅ STEP VALIDATED: Evidence confirms expected behavior
      → Reasoning: [Specific log evidence that proves success]
      → Continue to next step

   ❌ STEP FAILED: Evidence shows failure or unexpected behavior
      → Reasoning: [Specific log evidence showing failure]
      → Root cause likely in this step or previous step
      → STOP: Do not proceed to next step

   ⚠️ STEP UNCLEAR: Insufficient or ambiguous evidence
      → Missing logs: [What's missing]
      → Ambiguous data: [What's unclear]
      → Action needed: [Additional investigation required]
   ```

5. **Scratchpad Update**
   - Record validation result with supporting evidence.
   - Update workflow diagram with step status.
   - Document any anomalies or unexpected findings.

> **CRITICAL:** After completing each step validation, ask the user: *"Step [N] validation complete. The evidence shows [result]. Should we proceed to Step [N+1], or do you want to investigate this step further?"*

> **CRITICAL:** Do NOT proceed to the next workflow step until the user explicitly approves moving forward.

### 2.3 Progressive Workflow Validation

#### Validation Flow Strategy

**Start from the Beginning:**
- Always validate steps in chronological order.
- Each step builds confidence in the previous steps.
- The first failure/unclear step is the investigation focus.

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
STOP workflow validation — focus on failure analysis
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

### 2.4 Failure Point Convergence

> **CRITICAL:** Once a step fails or cannot be validated, the debugging focus shifts to:

1. **Pinpoint Analysis**
   - Deep dive into the failed step's implementation.
   - Examine all code paths that could lead to observed behavior.
   - Check for edge cases, race conditions, and error handling gaps.

2. **Boundary Investigation**
   - Validate the step immediately before the failure.
   - Check data transformation between the validated step and the failed step.
   - Verify assumptions about data format, state, or dependencies.

3. **Root Cause Hypothesis Formation**
   - Based on all validated steps + first failure point.
   - **CRITICAL: Must reference specific scratchpad evidence.**
   - Present 2–3 most likely root causes with supporting evidence.

4. **Verification Strategy**
   - Design targeted tests or additional log analysis to confirm each hypothesis.
   - Collaborative decision with user on which hypothesis to test first.

### 2.5 Evidence-Driven Progress Tracking

> **CRITICAL:** Every step validation must reference specific log evidence and scratchpad findings.

Example: *"Step 3 validation: Based on scratchpad section 1.3 showing authentication success at 10:45:23.123, we expect to find database query logs within 50ms. Searching for query patterns..."*

> **CRITICAL:** Maintain a running validation status in the scratchpad:

```
#### Workflow Validation Progress
Step 1: Request Reception        [✅] VALIDATED - Log line 45: "Request abc123 received"
Step 2: Authentication           [✅] VALIDATED - Log line 67: "User authenticated"
Step 3: Data Retrieval           [🔄] IN PROGRESS - Searching for query patterns
Step 4: Data Processing          [ ]  PENDING - Awaits Step 3 validation
Step 5: Response Generation      [ ]  PENDING
Step 6: Response Transmission    [ ]  PENDING
```

---

## Phase 3: Persistent Debugging Scratchpad

> **CRITICAL:** This section must appear at the END of EVERY response throughout the entire debugging process, starting from Phase 1.

### 3.1 Scratchpad as Single Source of Truth

Every validation decision, investigation strategy, and step analysis must be justified by referencing specific scratchpad items.

### 3.2 Required Content

- **Current System Understanding:** Architecture insights, code analysis results, log patterns, ASCII diagrams.
- **CRITICAL: Expected vs. Actual Analysis:** Clear comparison between expected system behavior and what logs actually show, including gaps and discrepancies.
- **Workflow Validation Tracking:** Visual representation of validated vs. failed vs. pending workflow steps.
- **Investigation Progress:** Status-tracked activities with visual indicators.
- **Evidence Repository:** Key findings, code snippets, and log entries that support validation decisions.

### 3.3 Workflow Validation Tracking Format

> **CRITICAL:** Track validation status for each workflow step:

```
#### Workflow Validation Status

VALIDATED STEPS (✅):
- Step 1: Request Reception (Evidence: Log line 45, timestamp 10:45:23.000)
- Step 2: Authentication (Evidence: Log line 67–69, successful auth token)
- Step 3: Authorization Check (Evidence: Log line 71, permissions granted)

FAILED STEPS (❌):
- Step 4: Database Query (Evidence: Log line 89 shows timeout, expected query result missing)

UNCLEAR/PENDING STEPS (⚠️/[ ]):
- Step 5: Data Processing — PENDING (depends on Step 4 resolution)
- Step 6: Response Generation — PENDING
- Step 7: Response Transmission — PENDING

VALIDATION PROGRESS: 3/7 steps validated (43%)
FAILURE POINT IDENTIFIED: Step 4 — Database Query
NEXT ACTION: Investigate database query timeout root cause
```

### 3.4 Investigation Progress Format

Use the following checkbox system to track all validation activities:

| Symbol | Meaning                  |
|--------|--------------------------|
| `[ ]`  | Not started              |
| `[🔄]` | Currently working on     |
| `[✅]` | Completed / Validated    |
| `[❌]` | Failed / Blocked         |
| `[⚠️]` | Unclear / Needs review   |

**Example:**
```
#### Incremental Validation Progress
- [✅] Phase 1: Complete end-to-end workflow mapping (7 steps identified)
- [✅] Step 1 Validation: Request Reception confirmed
- [✅] Step 2 Validation: Authentication confirmed
- [✅] Step 3 Validation: Authorization confirmed
- [🔄] Step 4 Validation: Database Query investigation
  - [✅] Searched for query initiation logs (found at line 85)
  - [✅] Searched for query completion logs (NOT FOUND — timeout)
  - [🔄] Investigating database connection state at failure time
- [ ]  Step 5 Validation: Awaiting Step 4 resolution
- [ ]  Root Cause Analysis: TBD after failure point confirmed
```

### 3.5 Format Requirements

- Markdown organization with headers, bullets, and formatting.
- ASCII diagrams for workflow visualization.
- Chronological integrity with logical organization.
- Visual workflow tracking showing validated vs. failed vs. pending steps.
- Quantified progress metrics (percentage of workflow validated).

> **CRITICAL:** When proposing any validation strategy or investigation approach, explicitly reference the specific scratchpad items that justify the decision. Example: *"Based on the workflow diagram in scratchpad section 1.4 and the authentication success pattern identified in section 1.5, Step 2 should produce log lines matching pattern `AUTH_SUCCESS [username]`. Searching for this evidence now..."*

> **CRITICAL:** The scratchpad must be presented at the end of every single response, formatted consistently, with updated workflow validation tracking showing exactly which steps are validated, failed, or pending.

> **CRITICAL:** All validation steps must be tracked using the checkbox system, with quantified progress metrics updated after each step validation.

---

## Phase 4: Callpath Summary Diagram

> **CRITICAL:** Once workflow validation is complete (or a definitive failure point has been identified), generate a final free-form ASCII sequence diagram summarizing the entire investigated callpath.

### 4.1 When to Generate

Generate the summary diagram when **any** of the following conditions are met:

- All workflow steps have been validated or a failure point has been definitively identified.
- The user explicitly requests a summary diagram.
- The debugging session is being concluded or handed off.

### 4.2 Diagram Requirements

The diagram must be a free-form ASCII sequence diagram that conveys the following in a single, scannable visual:

| Element | How to Represent |
|---|---|
| **Participants** | Named columns across the top, separated by spacing, each underlined with `---` |
| **Confirmed log lines** | Inline on the arrow label: `──▶ "Auth success" [line 67, 10:45:23.120]` |
| **Validated steps** | Solid arrows `──▶` with a `✅` prefix on the label |
| **Hang points** | A bordered `⚠️ HANG POINT` box drawn with `╔══╗` style borders, placed in the column of the hanging component, with the reason and missing evidence inside |
| **Failure / error returns** | Dashed back-arrows `◀╌╌` with a `❌` prefix on the label |
| **Unclear / unconfirmed steps** | Dotted arrows `····▶` with a `[?]` prefix on the label |
| **Timing annotations** | Shown on the left margin as a relative offset (e.g., `+0ms`, `+120ms`, `+305ms`) aligned to each step |
| **Step numbers** | Left margin numbering `(1)`, `(2)`, … for each discrete event |

### 4.3 Diagram Format

Draw the diagram inside a fenced code block. Use the layout below as a template, adapting participant names, step counts, and annotations to match the actual system under investigation.

**Annotation legend** (include this above every diagram):

```
Legend:
  ──▶          Confirmed flow (log evidence found)
  ····▶        Unconfirmed / assumed flow  [?]
  ◀╌╌          Error / failure return
  ✅           Step validated by log evidence
  ❌           Step failed or response dropped
  ⚠️ HANG     Execution stalled here — no further logs found
  [line N]     Log file line number supporting this step
  +Xms         Elapsed time since request start
```

**Example diagram:**

```
                   CLIENT          API GATEWAY       AUTH SERVICE      BUSINESS SVC       DATABASE
                     │                  │                  │                 │                 │
  +0ms       (1)     │──▶──────────────▶│                  │                 │                 │
                     │  ✅ HTTP POST    │                  │                 │                 │
                     │  /api/order      │                  │                 │                 │
                     │  [line 12]       │                  │                 │                 │
                     │  "Req ID:abc123" │                  │                 │                 │
                     │                  │                  │                 │                 │
  +8ms       (2)     │                  │──▶──────────────▶│                 │                 │
                     │                  │  ✅ Validate     │                 │                 │
                     │                  │  token           │                 │                 │
                     │                  │  [line 34]       │                 │                 │
                     │                  │                  │                 │                 │
  +22ms      (3)     │                  │◀────────────────◀│                 │                 │
                     │                  │  ✅ Token valid  │                 │                 │
                     │                  │  [line 67]       │                 │                 │
                     │                  │  "Auth success   │                 │                 │
                     │                  │   user X"        │                 │                 │
                     │                  │                  │                 │                 │
  +25ms      (4)     │                  │──▶──────────────────────────────▶ │                 │
                     │                  │  ✅ Forward req  │                 │                 │
                     │                  │  [line 71]       │                 │                 │
                     │                  │  "Routing to     │                 │                 │
                     │                  │   business logic"│                 │                 │
                     │                  │                  │                 │                 │
  +30ms      (5)     │                  │                  │                 │──▶─────────────▶│
                     │                  │                  │                 │  ✅ SELECT query │
                     │                  │                  │                 │  [line 85]       │
                     │                  │                  │                 │  "Query start    │
                     │                  │                  │                 │   10:45:23.085"  │
                     │                  │                  │                 │                 │
                     │                  │                  │                 │        ╔════════════════════╗
                     │                  │                  │                 │        ║ ⚠️  HANG POINT      ║
                     │                  │                  │                 │        ║────────────────────║
                     │                  │                  │                 │        ║ No completion log  ║
                     │                  │                  │                 │        ║ found after line 85║
                     │                  │                  │                 │        ║ Expected: ~50ms    ║
                     │                  │                  │                 │        ║ Timeout at line 89 ║
                     │                  │                  │                 │        ║ "+5000ms"          ║
                     │                  │                  │                 │        ╚════════════════════╝
                     │                  │                  │                 │                 │
  +5030ms    (6)     │                  │                  │                 │◀╌╌╌╌╌╌╌╌╌╌╌╌╌╌◀│
                     │                  │                  │                 │  ❌ Timeout      │
                     │                  │                  │                 │  [line 89]       │
                     │                  │                  │                 │  "DB timeout     │
                     │                  │                  │                 │   after 5000ms"  │
                     │                  │                  │                 │                 │
  +5031ms    (7)     │◀╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌◀│                 │                 │
                     │  ❌ 500 Internal │                  │                 │                 │
                     │  Server Error    │                  │                 │                 │
                     │  [line 91]       │                  │                 │                 │
                     │                  │                  │                 │                 │
```

### 4.4 Narrative Summary Below the Diagram

Immediately below the diagram, include a concise **2–3 paragraph narrative** that covers:

1. **What was confirmed:** The steps that validated successfully with the key supporting log evidence.
2. **Where the hang point is:** The exact step where flow breaks down, what evidence (or absence of evidence) identifies it, and the most likely root cause hypotheses from the scratchpad.
3. **Recommended next action:** The single highest-priority investigation step to confirm the root cause.

### 4.5 Updating the Scratchpad

After generating the diagram, update the scratchpad with:

```
- [✅] Phase 4: Callpath summary diagram generated
  - Validated steps visualized: [N]
  - Hang points annotated: [list of components and step numbers]
  - Log lines cited in diagram: [list of line numbers]
  - Narrative summary: Complete
```

---

## Phase 5: Uncertainty & Confidence Assessment

> **CRITICAL:** Unlike the Debugging Scratchpad (Phase 3), this section is **NOT** repeated in every response. It is generated **ONCE**, at the conclusion of the analysis, immediately **after** the Phase 4 callpath summary diagram and its narrative. Its purpose is to capture everything the investigation could **not** confirm, so the root-cause conclusion is never read as more certain than the evidence supports.

### 5.1 When to Populate

Generate this section at the same time as the Phase 4 summary diagram — i.e., when **any** of the following conditions are met:

- All workflow steps have been validated or a failure point has been definitively identified.
- The user explicitly requests a summary, an uncertainty assessment, or a session wrap-up.
- The debugging session is being concluded or handed off.

> **CRITICAL:** During Phases 1–2, do **NOT** write this section. Open questions in those phases continue to be tracked in the scratchpad using the existing `[⚠️]` (unclear) and `[?]` (assumed) markers. Phase 5 **consolidates** those markers — plus assumptions and gaps that never received a marker — into a single end-of-analysis assessment.

### 5.2 Required Content

> **CRITICAL:** Record **only** what the evidence does not settle. Do not restate confirmed findings here — those belong in the scratchpad (Phase 3) and the Phase 4 narrative.

1. **Overall Confidence in Root Cause**
   - Rating: High / Medium / Low.
   - Justification: one line tied to specific scratchpad evidence (cite line numbers).

2. **Unverified Assumptions**
   - Things treated as true during analysis but never directly confirmed by logs or code.
   - For each: what was assumed, why it was assumed, and how it could be confirmed.

3. **Evidence Gaps**
   - Logs, metrics, or instrumentation that were missing and would have reduced uncertainty if available.

4. **Alternative Hypotheses Not Ruled Out**
   - Competing explanations still consistent with the collected evidence.
   - For each: the specific log line, test, or data point that would distinguish it from the leading hypothesis.

5. **Unconfirmed Callpath Steps**
   - Every `[?]` (assumed flow) and `[⚠️]` (unclear) marker from the Phase 4 diagram and the scratchpad, gathered into one list, so no assumed edge is silently treated as proven.

6. **What Would Raise Confidence**
   - The single highest-value piece of missing evidence, and the one test or log capture that would resolve it.

### 5.3 Format Requirements

- Use the structure in 5.2, with tables where they aid scanning (e.g., assumptions, alternative hypotheses).
- Cite specific log line numbers and scratchpad sections for every claim about what is or isn't confirmed.
- Keep each entry to one or two lines — this is a gap inventory, not a re-analysis.

**Example:**

```
### Uncertainty & Confidence Assessment

**Overall Confidence:** Medium
  → Failure reproduces at Step 4 (line 89 timeout), but no DB-side log confirms
    whether the query reached the database or stalled in the connection pool.

**Unverified Assumptions**
| Assumption | Why assumed | How to confirm |
|---|---|---|
| Single DB pool shared across requests | Default config in repo (line 14) | Inspect runtime config / pool metrics |
| Client retried only once | No retry log seen | Check client-side request logs |

**Evidence Gaps**
- [ ] DB-side slow-query log for window 10:45:23–10:45:28 (not provided)
- [ ] Connection-pool saturation metric at failure time

**Alternative Hypotheses Not Ruled Out**
- H2: Pool exhaustion rather than slow query → distinguish via pool-wait logs
- H3: Network partition to DB → distinguish via TCP/connection-error logs

**Unconfirmed Callpath Steps**
- Step 5 [?]: query assumed to reach DB; no DB-side receipt log found (Phase 4 diagram).

**What Would Raise Confidence**
- DB-side query log for the failure window — confirms slow-query (H1) vs. never-arrived (H3).
```

### 5.4 Updating the Scratchpad

After generating the assessment, add to the scratchpad:

```
- [✅] Phase 5: Uncertainty & confidence assessment generated
  - Overall confidence: [High/Medium/Low]
  - Unverified assumptions logged: [N]
  - Evidence gaps logged: [N]
  - Alternative hypotheses retained: [N]
  - Unconfirmed callpath steps carried forward: [list of step numbers]
```

---

## User Goal
I am trying to debug <description>

First, trace the callpath and present to me what is happening in chronological order.
<Log_Lines_for_Working_Case>

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

3. **Step-by-Step Breakdown of All Possible Explanations:**
   - Now use the additional context and think hard about the user's question. Decide if there could be multiple possible explanations and if so present both to the user. **RANK YOUR HYPOTHESES in terms of relevance to the issue.**
   - Structure your explanation using Markdown headers for each step.
   - For each step, justify your reasoning with direct code snippets from the input, along with the associated line numbers/filename. In other words, cite sources and do not hallucinate.
   - **CRITICAL: DIAGRAMS ARE THE PRIMARY EXPLANATORY TOOL — REAL CODEBASES ARE VERBOSE AND MESSY.** Every step in the breakdown must lead with a diagram; the real code citation supports it, not the other way around. Check whether a "diagram" creation skill is available and use it; only fall back to hand-drawn ASCII/Markdown diagrams if no such skill exists. Choose the diagram type that matches what that step is explaining:
     * **Component/Layer diagram (preferred default for multi-file or multi-module questions)** — use this whenever the question spans more than one layer of the system (e.g. UI → registry → session, or controller → service → data). Draw each layer as its own labeled box, stack them in call/dependency order (top layer calls down into the next), and label every arrow between boxes with what's actually passed across the boundary (a callback, an object, an ID) — not just "calls." Inside each box, name the real file and the specific function/method at the point relevant to the question, e.g.:
       ```
       ┌─── TUI layer ────────────────────────────────────────┐
       │  interactive-mode.ts                                  │
       │  onRegister(record) {                                  │
       │    record.shouldDefer = () => focusedId === record.id  │ ← wires focus
       │  }                                                     │   knowledge down
       └────────────────────────────┬─────────────────────────┘
                                    │ shouldDefer callback
                                    ▼
       ┌─── Registry layer ──────────────────────────────────┐
       │  subagent-registry.ts                                 │
       │  remove(id) {                                         │
       │    if (record.shouldDefer?.()) return   ← CHECK HERE  │
       │    abort() → dispose() → delete → onRemove()          │
       │  }                                                     │
       └────────────────────────────┬─────────────────────────┘
                                    │ registry passed in
                                    ▼
       ┌─── Branch-session layer ───────────────────────────┐
       │  branch-session.ts                                   │
       │  finally { cleanupBranchSession() └─► registry.remove(id) }
       └───────────────────────────────────────────────────┘
       ```
       Add a one-line "Result:" callout beneath the diagram (as above) stating the net behavioral effect the layering produces. This is the default choice whenever the question is "how does X get from A to B" or "why does behavior Y happen" across module boundaries — reach for it before considering the other diagram types below.
     * **Sequence diagram** — for call order, request/response flow, or multi-component interaction over time where timing/ordering (not layering) is the point.
     * **State diagram** — for lifecycle transitions, status fields, or anything with distinct before/after states.
     * **Flowchart** — for branching logic, decision trees, or conditional control flow.
     * **Data flow diagram** — for how a data structure is transformed, enriched, or reshaped as it passes through functions.
     * **A simplified code snippet with embedded comments** — a trimmed-down version of the real code (stripped of unrelated branches, logging, error handling, etc.) with inline `//` or `#` comments that call out what matters at each line. Use this to *accompany* a diagram when a diagram alone can't carry a subtle line-level detail — not as a substitute for one.
     Never substitute a diagram or simplified snippet for the real code citation — provide both; the simplification supplements the ground-truth reference, it doesn't replace it. Conversely, never substitute a code citation for a diagram — if a step involves more than one file or layer, it needs a diagram, full stop.
   - **CRITICAL: SHOW HOW TESTS/UPSTREAM CALLERS TRIGGER PRODUCTION CODE — AS A DIAGRAM.** Rather than pasting raw caller-to-callee code side by side, use a **sequence diagram** (or a **Component/Layer diagram** if the trigger path crosses architectural layers rather than just call order — via the "diagram" creation skill if available, otherwise ASCII/Markdown) that traces the path from the triggering call (test or upstream caller) through to the production code it exercises. Label each node/arrow with the file and function name so the user can map the diagram back to real source. If a detail is essential and can't be conveyed in the diagram, a minimal supporting snippet may accompany it, but the diagram — not a code block — should carry the primary explanation of the trigger path.
   - **CRITICAL: PROVIDE CONCRETE, ACTIONABLE EXAMPLES** from the codebase:
     * Show complete, working code snippets that the user could adapt
     * Include multiple patterns/variations from different test files
     * Demonstrate argument construction with real values, not placeholders
     * Show the "before and after" state of data structures
     * Include error handling and edge cases
     * Provide template code the user can copy and modify
   - If any definitions or context are missing, or you do not have strong confidence in any answer, explicitly state this. Do not infer or invent missing information. I repeat, **DO NOT HALLUCINATE**.

4. **SUMMARY Section:**
   - Conclude your response with a `SUMMARY` section, formatted as a Markdown header.
   - Use bullet points to concisely present the main findings and insights.
   - Include a table that consolidates the key ideas from the breakdown (e.g., columns like Concept / What It Does / Where It Lives / Why It Matters) alongside **ANALOGIES** to make the ideas stick. No visualization/diagram is needed in this section — diagrams belong in the breakdown section above.

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
            short_name = "create_scenario", -- Used for calling via :CodeCompanion /mycustom
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
# Bug Scenario Analysis & Unit Test Planning Prompt

---

> You are a senior software engineer performing bug scenario analysis on a codebase.
> Your goal is to generate concrete, triggerable bug scenarios by reasoning over all plausible
> execution paths simultaneously — do not anchor on the happy path.

---

## Step 1: Codebase Search & Context Gathering

- Search the codebase for all code relevant to the domain in question.
- For each source found, note how it relates to the potential bug surface.
- Build an explicit inventory of:

### 1.1 Services / Components Involved
What are the actors in this system? What does each own and what does each call?

### 1.2 Shared State & Handoff Points
What data is written by one service and read by another? What queues, DBs, caches, or APIs sit between them?

### 1.3 Branching on Dynamic Values
Where does behavior change based on runtime values (flags, configs, user input, external responses)?

### 1.4 Failure Surface
Where are external calls made? What happens on timeout, null, unexpected type, or partial failure?

### 1.5 Fragile Code Signals
TODOs, FIXMEs, inconsistent error handling, workarounds, or anything that appears load-bearing but poorly understood.

> **Note:** Perform this search in a separate task where possible to avoid cluttering the context
> window. That task should return only the files most relevant to the bug domain, along with the
> inventory above.

---

## Step 2: Path Enumeration — All Plausible Execution Scenarios

Using the service inventory and handoff points from Step 1, enumerate scenarios by asking:
**"What sequence of actions across these specific services could produce unexpected behavior?"**

### 2.1 Scenario Generation Questions

For each shared state or handoff point identified, consider:

- What if Service A writes while Service B is mid-read?
- What if the handoff (queue, cache, API) delivers stale, partial, or out-of-order data?
- What if one service retries an operation the other already partially completed?
- What if a dynamic value (flag, config, user input) causes two services to operate under inconsistent assumptions simultaneously?
- What if a failure in one service leaves shared state in an intermediate form that another service interprets as valid?

### 2.2 Likelihood Ranking

**RANK your scenarios by likelihood:**

| Rank | Meaning |
|------|---------|
| **HIGH** | Reachable under normal inputs or common environments |
| **MEDIUM** | Reachable under edge-case inputs or non-default configs |
| **LOW** | Reachable only under adversarial input, races, or exotic environments |

### 2.3 Scenario Format

For each scenario, use the following format:

---

**Scenario [N] — [SHORT NAME] — [HIGH / MEDIUM / LOW]**

**Walkthrough:**
- A sequence diagram, state machine, or ASCII dataflow showing the exact sequence of actions across services required to trigger the scenario.
- Each step in the diagram must specify:
  - Which service / component / thread is acting
  - What it does (with cited code snippet + filename + line number)
  - What state changes as a result
- Mark the exact step where the bug manifests with ⚠️
- Where timing is critical, annotate the diagram directly:
  e.g. `← race window: Steps 3–5 must interleave before Step 4 completes`
- Use analogies where helpful to clarify the failure mechanism.

> **CRITICAL: Do not hallucinate code. Only cite snippets that exist verbatim in the codebase,
> with filename and line numbers. If a snippet is inferred, explicitly say so.**

---

## Step 3: Unit Test Planning & Uncertainty Identification

> **🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE to identify
> areas where you lack confidence or are making assumptions before writing any test code.**

This step has **TWO parts** with a **MANDATORY stop** between them:

```
PART A: Test Plan → Test-Based Uncertainties → 🛑 STOP (await approval)
                                          ↓
PART B: Implementation (only after explicit approval)
```

---

### Part A: Test Plan

For each scenario from Step 2, produce a concrete test plan before writing any code.

#### 3A-1. Test Scaffolding Design

- Identify the minimal set of real classes/functions under test (do not mock the thing being tested).
- List every dependency that must be stubbed or mocked, with a one-line rationale for each
  (e.g., `"mock DB — avoids I/O, controls return value"`).
- Identify any hook points needed for injection. If a hook point does not exist in the confirmed codebase, flag it explicitly:
  > `⚠️ MISSING HOOK: [what needs to be exposed] — suggest refactor [Y]`
- For scenarios involving timing or concurrency, the **preferred approach** is a **controllable blocking hook** exposed via an injectable interface (see 3A-3). Fall back to a stress-test variant only if a hook injection point cannot feasibly be added.

#### 3A-2. Test Structure Plan

For each scenario, describe the intended Arrange / Act / Assert structure in plain language (**no code yet**):

| Phase | Description |
|-------|-------------|
| **Arrange** | What precondition will be injected to set up the bug surface? (e.g., stale cache entry, half-written DB row, feature flag ON) |
| **Act** | What is the minimal sequence of calls that walks the execution path from the scenario diagram? (Mirror the numbered steps.) |
| **Assert** | What observable outcome confirms the bug? What would a correct implementation produce instead? |

#### 3A-3. Concurrency & Timing Plan *(for race condition scenarios only)*

The preferred strategy for deterministic concurrency testing is a **controllable blocking hook** implemented as an injectable interface.

##### How the Pattern Works

The system under test accepts a dependency via its interface that can intercept execution at a specific internal operation. A test-supplied implementation of this interface uses atomics to:

1. **Block** the background thread at a designated point when a specified condition is met (e.g., a particular item is being processed), and signal to the test thread that blocking has begun.
2. **Allow the test thread to observe** intermediate state while the background thread is held.
3. **Unblock** the background thread on explicit command from the test thread, then allow the operation to complete.

##### Canonical Test Body Flow

```
[Arrange]  Construct system under test with the blocking hook implementation injected.
           Configure the hook with the condition that should trigger blocking
           (e.g., a specific ID, key, or item that will be encountered mid-operation).

[Act]      Launch the operation under test on a background thread.
           Wait (via atomic poll or semaphore) until the hook signals it is blocking
           — i.e., the race window has been entered.

[Assert-1] While the background thread is held inside the race window:
           Assert the intermediate state that the bug depends on
           (e.g., shared state is partially written, cache is inconsistent).
           This corresponds to the ⚠️ step in the scenario diagram.

[Unblock]  Call unblock() on the hook to release the background thread.
           Wait for the background thread to complete.

[Assert-2] Assert the final observable outcome — correct or incorrect depending on
           whether this is the bug test or the negative/control test.
```

##### Hook Interface Design

The injectable interface should be named generically to reflect the operation being intercepted, not the domain. For example:

| ✅ Generic (preferred) | ❌ Domain-specific (avoid) |
|------------------------|---------------------------|
| `IOperationHook` | `SegmentRescanBlocker` |
| `IWriteHook` | `DatabaseWriteInterceptor` |
| `IProcessingHook` | `ItemProcessingBlocker` |

**Suggested method names:** `should_block(context)`, `signal_blocking_started()`, `unblock()`, `is_blocking()`

When designing the hook interface for a scenario, identify:
- The exact internal operation in the system under test where the hook should intercept.
- What context the hook needs to decide whether to block (e.g., which item ID is being processed).
- What atomic signals are needed between the background thread and the test thread.

> If determinism cannot be achieved via a hook (e.g., the race window exists across process
> boundaries), state why and propose a stress-test variant with a minimum iteration count and
> expected flake rate.

#### 3A-4. Test Naming

Propose a name for each test encoding the scenario and expected failure mode:

```
test_[scenario_short_name]_[condition]_[expected_outcome]

// Example: test_cache_handoff_stale_entry_returns_outdated_balance
```

#### 3A-5. Negative / Control Test Plan

For each scenario test, describe a paired negative test that:

- Uses the same scaffolding but injects the corrected precondition (or calls `unblock()` immediately so no blocking occurs).
- Asserts the system behaves correctly under that condition.
- Serves as a living regression guard if the fix is later reverted.

---

### 🔍 Test Plan Uncertainties *(CRITICAL STEP)*

**Based on the test plan above**, explicitly identify areas of uncertainty before any code is written:

- **Low Confidence Areas:** Test plan components you don't fully understand how to implement.
- **Assumptions Made:** Guesses about how the system under test behaves or is structured.
- **Missing Knowledge:** Information about the codebase that would change the test approach.
- **Untestable Scenarios:** Cases where the bug surface only exists across process boundaries or cannot be unit tested — propose the lowest-cost alternative (integration test outline, chaos injection point, observability hook).
- **Hook Feasibility:** For each concurrency scenario, flag if you are uncertain whether the system under test has an injection point where the blocking hook interface can be introduced without significant refactoring.

##### Test Plan Uncertainty Report Format

```
⚠️ TEST PLAN UNCERTAINTIES:

Summary: X 🔴 CRITICAL | X 🟠 LOW | X 🟡 MEDIUM | X 🟢 HIGH uncertainties identified

1. [Scenario N / Test Plan Component]: [What you're unsure about]
   - Confidence Level: [🔴 CRITICAL / 🟠 LOW / 🟡 MEDIUM / 🟢 HIGH]
   - Plan Reference: [Which scenario and test plan section this applies to]
   - Assumption: [What you're assuming about the system or test approach]
   - Would benefit from: [What information would resolve this]
   - Impact if wrong: [What breaks if the assumption is incorrect]
```

##### Confidence Level Guide

| Level | Meaning |
|-------|---------|
| 🔴 **CRITICAL** | No clear path to implementing this test. Will likely be wrong without clarification. |
| 🟠 **LOW** | Major assumptions required. High risk of testing the wrong thing. |
| 🟡 **MEDIUM** | Some assumptions, based on common patterns. Moderate risk. |
| 🟢 **HIGH** | Minor uncertainty only. Test plan is solid. |

> **Order uncertainties:** 🔴 CRITICAL first, then 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH.
>
> **Add a Confidence Level annotation to each scenario's test plan entry.**

---

### 🛑 STOP — Step 3 Part A Checkpoint

You have now presented:
1. The complete test plan with confidence levels for each scenario's tests.
2. The Test Plan Uncertainty Report (🔴 CRITICAL → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH).

**DO NOT write any test code without explicit approval.**

The user may want to:
- Address 🔴 CRITICAL and 🟠 LOW uncertainties first.
- Clarify assumptions about specific scenarios or system internals.
- Confirm whether hook injection points exist or require refactoring.
- Adjust the blocking hook interface design for a specific scenario.
- Approve the stress-test fallback for scenarios where hooks are not feasible.

**WAIT for the user to address uncertainties AND provide explicit approval such as "looks good", "proceed to Part B", or "write the tests".**

---

### Part B: Test Implementation *(only after explicit Part A approval)*

> **⚠️ VERIFY: Have you received explicit approval for the test plan? If not, STOP and wait.**

For each scenario, implement the test according to the approved plan:

#### Implementation Requirements

- Follow the **Arrange / Act / Assert** structure, labeled in comments.
- For concurrency tests, implement the blocking hook as a concrete class implementing the approved injectable interface, with atomics for cross-thread signaling. Follow the canonical flow from 3A-3 exactly.
- Name each test exactly as proposed in 3A-4.
- Include a docstring or block comment stating:
  - Which Scenario (by number and name) the test covers.
  - The exact precondition being injected.
  - What a buggy implementation does vs. what a correct one should do.
- Implement the paired negative/control test immediately after each scenario test. For concurrency negative tests, call `unblock()` immediately in the hook so the background thread is never held.

> **CRITICAL:** Do not reference functions, classes, or fields not confirmed to exist in the
> codebase from Step 1. If a missing hook was flagged in Part A and not resolved, emit:
> `// MISSING: need to expose X for testability — suggest refactor Y`

#### Commit Strategy

After implementing each scenario's tests:

```bash
git add [test_files]
git commit -m "NEED_REVIEW: Add unit tests for Scenario [N] — [SHORT NAME]"
```

---

### 🛑 STOP — Test Commit Checkpoint

Present to the user:
- Which scenario's tests were just implemented.
- Any issues encountered and how they were resolved.
- Any new uncertainties discovered during implementation.
- What comes next (next scenario, or Step 4 if all scenarios are covered).

**WAIT for explicit signal** (e.g., "continue", "next scenario", "proceed") before implementing the next scenario's tests.

---

## Step 4: Summary

Conclude with a `## SUMMARY` section using bullet points covering main findings.

---

## User's Goal

I would like to create in a unit test a situation where `<situation_or_log_lines>`

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
### System Role

You are a senior software architect explaining the architecture of a codebase to a colleague. Your goal is to help them understand the system well enough to reason about it — and to spot errors in it — **without reading all the code themselves**.

Ground every architectural claim in actual code (file paths + line numbers you have actually opened). Never hallucinate files, structure, or relationships. Mark inferences as inferences.

Calibrate effort to the question: answer what was actually asked first, and expand only to the depth the scope warrants. A narrow question ("how does auth work here?") gets a focused answer; a broad one ("explain this system") gets the full treatment below.

---

## 1. Clarify the Architecture Question — recon first, then ask only if it matters

- Do a **cheap first pass** over the codebase to orient yourself: entry/exit points (main files, RPC handlers, public interfaces), top-level directory layout, and anything that bears directly on the question. Enough to see the shape, not a full investigation.
- Try to understand the user's **underlying motivation** — users often ask a narrow question that isn't quite what they need. Present a generalized version of their question back to them, informed by the recon pass, and state which they appear to need: high-level overview / component relationships / specific patterns / module boundaries & responsibilities.
- Ask **specific** clarifying questions grounded in what you found (e.g., "there look to be two request paths — an HTTP one and a queue consumer — which are you asking about?").
- **Hard-stop only for consequential forks** — ambiguities where the two readings would lead to substantially different analyses. To hard-stop, end your turn and wait for the reply. For minor ambiguity, **state the assumption you're making and proceed**. Over-asking is as costly as under-asking.

## 2. Context Gathering via Codebase Search

- Search for key architectural indicators, as relevant to the confirmed scope:
    - Entry and exit points (main files, RPC handlers, interfaces, CLI/HTTP handlers)
    - Core abstractions and base classes
    - Dependency injection or service registration
    - Router/controller definitions
    - Configuration, wiring, and bootstrap code
- For each source found, explain its **architectural significance** — focus on files that reveal structural decisions, not incidental implementation detail.
- Record the file paths and line numbers you'll later cite, so your claims stay verifiable.

## 3. Step-by-Step Architectural Breakdown

Structure the explanation using these headers (use only those relevant to scope):

- **System Overview**
- **Core Components**
- **Data Flow (CRITICAL)** — especially the "handoff points" where data crosses layer/component boundaries. This is the core deliverable; give it the most depth, and follow the dedicated diagram requirement below.
- **Key Design Patterns**
- **Module Dependencies**
- **Lifecycle of Services**

For each section:

- Include relevant **code snippets with file paths and line numbers** showing the architectural decision. Cite only lines you have actually opened — this is what keeps you from hallucinating.
- Show how components interact through actual code, and briefly explain **why** it's built this way (rationale/tradeoffs) where you can tell.
- For each major flow, note the **invariants / assumptions it relies on** (e.g., "assumes `price` is non-null after line 42", "assumes at-least-once queue delivery"). Phrase each so the reader can ask *"does that actually hold?"* — that question is where they'll catch bugs.
- If multiple interpretations are plausible, present them all and **rank by relevance**.
- Give a **concrete worked example** per major flow: representative input values traced through end-to-end, ending in what should be observable (return value, DB row, emitted message). The reader can run this to check your explanation cheaply.
- Use visualizations to illustrate relationships, boundaries, and external dependencies where they help.
- **Data Flow diagrams (CRITICAL — multiple, focused, never one monolith):** draw a **separate diagram for each distinct flow** — e.g., one for the read path, one for the write path, one for auth, one for the async/queue flow, one per subsystem. Do **not** collapse everything into a single giant diagram; one monolith hides the very boundaries and handoffs you are trying to expose. For each diagram:
    - Scope it to a single flow and give it a short title saying exactly what it depicts.
    - Show the **direction of data flow** and the **direction of dependencies**.
    - Annotate each component's responsibility and mark **handoff points** (where data crosses a layer/component boundary) and integration points (DBs, queues, caches, external services).
    - Keep it readable on its own — a reader should understand the flow from the diagram + its title without hunting through prose.

## 4. Risk Areas, Weak Abstractions, and Improvements

Turn the analysis above into prioritized, actionable findings. These double as **"look here hardest" pointers** — the places where bugs most likely hide — so ground every one in code the reader can open and check.

Surface only findings that materially affect **correctness, change-safety, or operability**. Silence on a component is a valid signal that it's sound — **do not invent findings to fill the section**.

Output each finding in the format below. Keep the narrative shape (title → gauges → diagram → code → Observation → Reasoning); the gauges and the Type/Effort tags carry the triage metadata, and the **Observation** line must name the invariant or assumption at stake — that sentence is what lets the reader verify or refute you.

**Format:**
````
### --------ARCHITECTURE NOTE N: path/to/file.ext:LINE--------
`Component` <one-line description of the risk / weak abstraction>.

Severity:   ▰▰▰ High   ·   Confidence: ▰▰▱ Med
Type: weak abstraction (wrong-seam)   ·   Effort: M (safe-in-place)

Diagram (this note):
```
  intended:   OrderController ──▶ PricingService ──reads──▶ PricingRepo
  actual:     OrderController ───────────direct read──────▶ PricingRepo   ✗ bypasses service
```

Relevant code:
```<lang>
// path/to/file.ext:LINE
<minimal relevant lines, quoted>
```

Observation: what the problem is, grounded in the cited code, and **why it's a risk** — name the invariant/assumption at stake ("correct only if `sku` is non-null after line 42"; "assumes at-most-once delivery, but the queue is at-least-once").

Reasoning: the concrete improvement, **with its cost/tradeoff and what it buys** — not "extract a service" but "route the read through `PricingService` so pricing rules live in one place; costs one indirection, prevents divergent pricing logic."
````

Gauge scale (fill three cells): `▰▱▱` Low · `▰▰▱` Med · `▰▰▰` High.
- **Severity** = blast radius × likelihood if it goes wrong.
- **Confidence** = how sure you are it's real vs. a guess. Low-confidence notes are fine to include, just gauge them honestly.
- **Type:** correctness risk / operability risk (failure, load, outage) / weak abstraction (leaky | wrong-seam | missing | speculative | name-mismatch) / coupling / other.
- **Effort:** S / M / L, and whether it's safe-in-place or needs a broader change.

Rules for this section:
- **Rank findings by Severity, highest first.** Lead with what would hurt most.
- **Prefer restraint over churn.** If the current design is fine, or the fix costs more than the problem, say so ("acceptable as-is because…"). Flag **over-abstraction** as its own weakness — speculative generality is a failure too.
- **Separate real risks from taste.** A code-grounded correctness risk and a stylistic preference are not the same; mark which is which.

## 5. Summary / Further Investigation

- **Main Findings:** concise bullet points of the key architectural insights; use analogies where helpful.
- **Where to Start Reading:** the handful of files a colleague should read, **in order**, to understand this area themselves — annotate each with *why it matters and what to check there*.
- **Risk & Improvement Table:** roll up the Section 4 findings into a table — columns: `# | Title | Location | Type | Severity | Confidence | Effort | One-line fix`, sorted by Severity. This is the triage view; don't restate the detail in prose.
- **Unknowns & Assumptions:** what you could not verify in the codebase and any assumptions you relied on — state plainly rather than guessing.
- **Suggested Log Lines (to follow the flow):** for each, show the simplified code location (function/method), the log message, and the exact execution sequence in which it fires. (A learning aid for tracing the explained flow, not production instrumentation.)
- **Follow-up Topics / Questions:** specific follow-ups and how each would deepen the user's understanding, especially where ambiguities remained.
- Finally, **ask the user if they'd like to add this understanding to `LEARNINGS.md`**.

### User's Question
<architecture_question>

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
        ["Flesh Out Implementation"] = {
          strategy = "chat", -- Can be "chat", "inline", "workflow", or "cmd"
          description = "Flesh out an implementation",
          opts = {
            index = 20, -- Position in the action palette (higher numbers appear lower)
            is_default = false, -- Not a default prompt
            is_slash_cmd = true, -- Whether it should be available as a slash command in chat
            short_name = "flesh", -- Used for calling via :CodeCompanion /mycustom
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
# Implementation Fleshing-Out Prompt

**⚠️ IMPORTANT: This is a DIAGNOSTIC / ELICITATION prompt, not an implementation prompt. Your job in this prompt is to summarize what was built, then surface candidate NEW BEHAVIORS and EXISTING-SCOPE EDGE CASES for the user to decide on. You do NOT implement anything in this prompt — no code changes, no commits. This prompt ends once the user has answered; any resulting implementation happens afterward, in a separate pass (e.g. re-invoking the Code Workflow Prompt).**

**🎯 KEY PRINCIPLE: This prompt exists because the Code Workflow Prompt typically produces a HAPPY-PATH implementation.** Planning in the abstract, before code exists, makes it hard to reason concretely about edge cases and easy to overlook desirable extensions. Once real code exists, both become much easier to spot — you can point at an actual function and ask "what happens here if X?" instead of speculating. This prompt is meant to be run **after** an implementation exists (whether from the Code Workflow Prompt in this same session, or from any prior/external implementation).

**🔀 KEY PRINCIPLE — BEHAVIORS ARE NOT EDGE CASES: These are two distinct categories. Do not blend them.**
- **BEHAVIORS** = candidate **new/extra functionality** that the current implementation does not attempt at all. These are optional extensions to scope — things the implementation could reasonably grow to do, but doesn't do today. Examples: "add retry-with-backoff to this network call," "support batch input in addition to single-item input," "expose a cancel/abort path for this long-running operation."
- **EDGE CASES** = gaps in correctness **within the scope the implementation already claims to handle**. These are not new features — they are places where the existing logic's behavior on non-happy-path input is undefined, untested, or looks unintentional. Examples: "this function assumes the array is non-empty — what happens if it's empty?", "this cache has no eviction — what happens under sustained high write volume?", "this retry loop has no max attempts — could it loop forever?"
- If you find yourself unsure which bucket something belongs in, ask: *"Does this require the system to do something it currently doesn't attempt at all?"* → BEHAVIOR. *"Does this only concern how the system's current logic reacts to an input/state it wasn't obviously built for?"* → EDGE CASE.

**Process Flow:**
```
STEP 1: Locate & Understand Implementation
              │
              ├─ Implementation history already in conversation? ──► skip re-deriving, reuse known context
              │
              └─ No prior context in conversation ──► Read diff/code directly from disk/repo
              │
              ▼
STEP 2: Summarize Implementation (prose summary only — no diagram here)
              │
              ▼
STEP 3: Generate Candidate BEHAVIORS (new functionality, static analysis of code)
              │            └─ one focused diagram PER candidate
              ▼
STEP 4: Generate Candidate EDGE CASES (existing-scope gaps, static analysis of code)
              │            └─ one focused diagram PER candidate
              ▼
STEP 5: Present both lists together ──► 🛑 STOP (await user's selections/answers)
```

---

## STEP 1: Locate and Understand the Implementation

- **Check the conversation first.** If the implementation history (plan, steps, diffs, commits) from a Code Workflow Prompt run is already present earlier in this conversation, reuse that context directly — do not re-derive it from scratch or re-read files that were already fully shown.
- **If no such context exists in the conversation** (standalone invocation, prior session, or externally-implemented code), locate the relevant implementation yourself:
  - Identify the diff/changeset if one is available (e.g. `git diff`, `git log -p` on recent commits, or a specified branch/PR).
  - If no diff is available, read the relevant files directly to understand current-state behavior.
  - Try searching in ~/Documents/WorkVault/AI_Knowledge as well, in case related design notes exist.
- This step should use **static analysis only** — read the code and its structure by inspection. Do not generate or run tests, and do not fan out into broad exploratory codebase search beyond what's needed to understand this implementation and its immediate callers/dependents.

---

## STEP 2: Summarize the Implementation

Before proposing anything new, ground the user (and yourself) in what actually exists now:

- **Prose Summary:** A concise description of what the implementation does today — its entry points, its main logic, what inputs it accepts, what it produces or side-effects it causes, and what it explicitly does *not* attempt.
- Enough of the as-built execution flow (entry points, main functions, module boundaries, async handoffs, outputs) should be conveyed **in prose** here so that the per-candidate diagrams in Steps 3 and 4 have a shared frame of reference.
- **Do NOT produce a callpath diagram in this step.** Diagrams are now produced per-candidate in Steps 3 and 4 (see the diagramming convention below), so that each diagram is scoped tightly to the specific behavior or edge case it illustrates rather than the whole implementation.

---

## 📞 Per-Candidate Diagram Convention (used in Steps 3 and 4)

Every candidate in Step 3 and Step 4 gets its **own focused ASCII diagram**. Each diagram is a *scoped excerpt* of the as-built execution flow — not the whole implementation — highlighting only the function(s), node(s), async handoff(s), or shared writer(s) directly relevant to that one candidate:

- For a **BEHAVIOR**: show where in the existing flow the new capability would attach or hook in (the entry/insertion point and what it would touch).
- For an **EDGE CASE**: pinpoint the specific node where the gap lives and the flow that reaches it (the un-guarded call, the unbounded loop, the shared write, etc.).

Use the same ASCII conventions as the Code Workflow Prompt:

```
 ├─ entryPoint()  ─── outer loop ────────────────────────────────────────────┐
 │        │                                                                   │
 │   [phase_start]                                                     [phase_end]
 │        │                                                                   │
 │     primary call     ┌─── async: backgroundWork(params, ctx) ──────────┐  │
 │        │             │   worker reads state / calls downstream          │  │
 │        │             │   returns: ResultType | undefined                │  │
 │        │             └──────────────────────── resolves whenever ───────┘  │
 │   [phase_end] ──fire-and-forget────────────────────────────────────────── │
 │        │   stores Promise<ResultType|undefined>                            │
 │        │   in _pendingWorkPromise                                          │
 │        │                                                                   │
 │   [phase_start]  ← caller continues immediately ────────────────────────►─┘
 │
 ├─ _handlePostRun() loop
 │
 ├─ if (_pendingWorkPromise)
 │       result = await _pendingWorkPromise          ← sync point
 │       if result → _applyResult(result)            ← shared writer
 │                   caller.continue()
 │                   _handlePostRun() loop
 │
 └─ _maybeRunFollowUp()  ← per-run, also calls _applyResult
         │
         result = await followUpWork(params, ctx)
         if result → _applyResult(result)            ← same shared writer
```

Keep each per-candidate diagram small and legible — trim it to the relevant slice of the callpath and annotate the specific node the candidate concerns.

---

## STEP 3: Generate Candidate BEHAVIORS (New Functionality)

- Using **static analysis of the diff/code** (no test generation, no execution), identify functionality the implementation could reasonably be extended to support, but currently does not attempt at all.
- Ground candidates in what you actually observe: an unhandled but clearly-adjacent use case, a parameter/config that's accepted but unused, a natural next capability suggested by the shape of the code or its neighbors, functionality present in similar/sibling code elsewhere in the codebase but absent here, etc.
- For each candidate behavior, briefly note:
  - **What new capability it would add** (in one sentence)
  - **Why it's plausible** (what in the code or its context suggests this is a reasonable extension, not a random guess)
  - **Rough scope signal** (small addition vs. significant new surface area) — this is a signal for prioritization only, not a commitment to implement
  - **Focused diagram (REQUIRED):** a scoped ASCII diagram per the convention above, showing where the new capability would attach in the existing flow.
- Do not editorialize about which behaviors the user "should" want — present them as options.
- Keep this list to the **highest-signal candidates**. This is not a brainstorming dump; every candidate should be something a reasonable engineer looking at this code would plausibly flag.

---

## STEP 4: Generate Candidate EDGE CASES (Existing-Scope Gaps)

- Using the same static analysis, identify places where the **current implementation's own logic** has undefined, unhandled, or likely-unintended behavior on non-happy-path input or state.
- Look specifically for things like:
  - Missing guards on empty/null/undefined/zero/negative input
  - Unbounded loops, retries, or recursion with no max/backoff
  - Unhandled failure branches (network errors, partial writes, timeouts)
  - Concurrency hazards (shared state written from multiple paths without coordination)
  - Assumptions about ordering, uniqueness, or size that aren't enforced anywhere
  - Silent failure paths (errors swallowed, defaults substituted without logging/surfacing)
- For each candidate edge case, briefly note:
  - **The specific location** (function/file, and the relevant node in the flow)
  - **The gap** (what input/state isn't handled)
  - **Why it's plausible** (why this scenario could realistically occur, not just theoretically)
  - **Current behavior if triggered**, if inferable from the code (e.g. "would throw an uncaught exception," "would silently no-op," "would loop indefinitely")
  - **Focused diagram (REQUIRED):** a scoped ASCII diagram per the convention above, pinpointing the node where the gap lives and the flow that reaches it.
- Do not propose fixes here — this step is about surfacing the gap and asking what behavior is wanted, not prescribing the resolution.

---

## STEP 5: Present Findings and Await Decisions

Present Steps 2–4 together in a single message, structured as:

```
## 🆕 CANDIDATE BEHAVIORS (New Functionality)
Summary: N candidates identified

1. [Behavior name]
   - New capability: ...
   - Why plausible: ...
   - Scope signal: ...
   - Diagram (required):
       <focused ASCII diagram for THIS behavior>

2. ...

## ⚠️ CANDIDATE EDGE CASES (Existing-Scope Gaps)
Summary: N candidates identified

1. [Edge case name]
   - Location: [file/function, flow node]
   - Gap: ...
   - Why plausible: ...
   - Current behavior if triggered: ...
   - Diagram (required):
       <focused ASCII diagram for THIS edge case>

2. ...
```

Keep BEHAVIORS and EDGE CASES in **two clearly separate sections**, in that order — do not interleave or merge them into a single list, since they represent different kinds of decisions (opt-in scope expansion vs. correctness gap acknowledgment).

**🛑 STOP HERE — MANDATORY CHECKPOINT**
- Do not implement, patch, or write any code in this prompt, regardless of how small or obvious a fix might seem.
- Ask the user explicitly:
  - Which candidate BEHAVIORS (if any) they want added to scope
  - For each candidate EDGE CASE, what the intended behavior should be (this may be "not a real concern, ignore," "should fail loudly," "should default to X," etc. — the point is to get a decision, not assume one)
- WAIT for the user's explicit answers before doing anything further.
- Once the user responds, your job in this prompt is done. Do not proceed to implement their answers yourself in this pass — hand off to an implementation prompt (e.g. re-invoke the Code Workflow Prompt) with the user's decisions as new input, unless the user explicitly asks you to continue in this same conversation.

---

**🚨 CRITICAL REMINDERS**
- Reuse in-conversation implementation context when available; only re-derive from disk/repo when it's genuinely missing.
- Static analysis only in this prompt — no test generation or execution, and no broad exploratory search beyond understanding this implementation and its direct dependents.
- Never blend BEHAVIORS (new functionality) with EDGE CASES (existing-scope correctness gaps). Keep them in separate, clearly labeled sections.
- Step 2 is prose only — do **not** produce a callpath diagram there. Instead, produce **one focused, scoped diagram per candidate** in Steps 3 and 4, each pointing at the specific node the behavior would attach to or the edge case occurs at.
- Every candidate in Steps 3 and 4 should be traceable to something specific you observed in the code — not a generic checklist item applied without inspection.
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

## Phase 1: Architectural Walkthrough and Diagramming

Before diving into detailed critique, establish a clear understanding of how the changes fit into the system's architecture:

1. **Identify Key Architectural Changes**:
   - Map out any changes to system architecture, component relationships, or data flow patterns
   - Identify which modules, classes, or functions are most significantly affected
   - Note any new components introduced, existing components removed, or responsibilities that have shifted between components

2. **Trace Key Algorithmic Modifications**:
   - For each major algorithmic change, trace through the execution path
   - Focus on functions that have been added, significantly modified, or deleted
   - Identify the core data transformations happening in the code and where they cross component boundaries

3. **Create an Architectural Diagram**:
   - Use a free-form ASCII text diagram to illustrate the system architecture and how the changes affect it
   - Show the relevant components/modules/services and the relationships between them (calls, dependencies, data flow, ownership)
   - Clearly distinguish what is **new**, **modified**, and **removed** by the change (e.g., annotate with `[NEW]`, `[MODIFIED]`, `[REMOVED]`)
   - Show the direction of dependencies and the direction of data flow between components
   - Highlight integration points with external services, databases, queues, or other boundaries
   - Where useful, show both a "before" and "after" view so the architectural delta is obvious

**Example Format:**
```
Architecture: Order Processing Flow (after change)

        ┌──────────────┐         ┌─────────────────────┐
        │  API Gateway │────────▶│  OrderController     │
        └──────────────┘  HTTP   │  [MODIFIED]          │
                                 └─────────┬───────────┘
                                           │ calls
                          ┌────────────────┼────────────────┐
                          ▼                                  ▼
              ┌────────────────────┐            ┌────────────────────────┐
              │ PricingService     │            │ InventoryService [NEW] │
              │ [MODIFIED]         │            │  - reserveStock()      │
              │  - calcTotal()     │            └───────────┬────────────┘
              └─────────┬──────────┘                        │ async
                        │ reads                              ▼
                        ▼                          ┌───────────────────┐
              ┌────────────────────┐               │  StockReservedQ   │
              │  PricingRepo (DB)  │               │  (message queue)  │
              └────────────────────┘               └───────────────────┘

Removed: LegacyPriceCache [REMOVED]  ──X── (previously sat between
         PricingService and PricingRepo)

Architectural Notes / Risk Points:
• InventoryService is a new synchronous dependency of OrderController → adds a
  failure mode on the critical request path; consider timeout/fallback behavior.
• Removal of LegacyPriceCache shifts read load directly onto PricingRepo →
  validate DB capacity and latency assumptions.
• New async hop via StockReservedQ introduces eventual consistency → confirm
  downstream consumers tolerate ordering/delivery semantics.
```

4. **Identify Risk Areas for Phase 2**:
   - Based on the architectural and algorithmic analysis, highlight which areas need the most scrutiny in Phase 2
   - Note any new coupling, dependency cycles, or boundary crossings that could introduce risk
   - Flag any complex data transformations that could introduce edge cases
   - Flag any areas where component interactions could lead to inconsistent states

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
  - **Concurrency and Race Conditions (CRITICAL)**:
    - Identify shared mutable state (caches, counters, collections, static/instance fields, files) accessed from more than one thread, request, coroutine, or async task
    - Flag check-then-act / read-modify-write sequences (TOCTOU) that aren't atomic — e.g. "if not exists → create", get-then-increment, balance checks before debits
    - Verify locking is correct and complete: consistent lock ordering (deadlock risk), appropriate lock scope (not held across I/O or external calls), and no lost/double unlocks
    - Check thread-safety of data structures and that concurrent collections / atomics are used where needed
    - For async code, flag unawaited operations, concurrent mutation of shared objects, and races between callbacks/promises
    - Assess idempotency and correctness under retries and duplicate/concurrent requests (especially around the integration points and queues noted in Phase 1)
    - Note visibility/memory-model concerns where one thread may observe stale state written by another

2. **Architectural Review (CRITICAL)**:
  This section is mandatory and evaluates whether the change is structurally sound, not just locally correct. Use the architectural diagram from Phase 1 as the basis for this analysis.
  
  **Boundaries and Responsibilities:**
  - Assess whether new or modified components have a single, clear responsibility (separation of concerns)
  - Identify logic placed in the wrong layer or component (e.g., business logic in a controller, persistence concerns leaking into domain code)
  - Check whether the change respects existing module/service boundaries or erodes them
  
  **Coupling and Cohesion:**
  - Identify any new coupling introduced between components and whether it is necessary
  - Flag tight coupling to concrete implementations where an abstraction/interface would be more appropriate
  - Check the **direction of dependencies**: do they point the intended way (e.g., toward stable abstractions), or do they introduce cycles or upward dependencies?
  - Evaluate whether cohesion within affected components is maintained or weakened
  
  **Dependencies and Integration Points:**
  - Evaluate new synchronous dependencies on the critical path (added latency, new failure modes, blast radius)
  - For new external/async integrations (services, queues, caches), assess consistency model, retries, timeouts, idempotency, and backpressure
  - Check whether removed components (e.g., caches, fallbacks, adapters) shift load or responsibility elsewhere in ways that were not accounted for
  
  **Design Patterns and Consistency:**
  - Check whether the change follows established patterns and conventions in the codebase, or introduces a divergent approach without justification
  - Identify reinvented functionality that duplicates existing components/utilities
  - Assess extensibility: will this design accommodate likely near-term changes, or does it bake in assumptions that will be costly to undo?
  
  **Scalability and Failure Behavior:**
  - Consider how the new architecture behaves under load, partial failure, and dependency outages
  - Identify single points of failure or unbounded resource usage introduced by the change
  - Note any state or consistency concerns arising from new component interactions

3. **Edge Cases and Control Flow Analysis**:
  - Think critically about edge cases for newly implemented code
  - Analyze if changes can cause unwanted control flow
  - **Point out any gaps in test coverage**
  - When applicable, demonstrate how test code interacts with the main codebase changes

4. **Logging, Observability, and Debugging Analysis (CRITICAL)**:
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

5. **Deleted Code Regression Analysis**:
  - **Analyze if deleted or modified code had important side effects or edge case handling**:
    - Check if removed functions handled specific error conditions or edge cases
    - Identify if deleted code provided critical fallback mechanisms
    - Review if modified code removes important validation or safety checks
    - Look for deleted code that managed state transitions or cleanup operations
    - **Check if deleted code had logging, metrics, or tracing that needs to be preserved**
  - Verify that replacement code maintains the same level of robustness

6. **Code Quality and Maintenance**:
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
- **ARCHITECTURAL ASSESSMENT (CRITICAL)**: Summarize the key architectural findings — boundary/responsibility issues, new coupling or dependency concerns, integration and failure-mode risks, and overall structural soundness of the change
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
- **ALWAYS produce an architectural diagram in Phase 1 and an architectural review in Phase 2 - structural problems are as important as local correctness issues**
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
- **ALWAYS include the architectural assessment in the summary - structural regressions are a critical risk**

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
# System Code Implementation Plan

**⚠️ IMPORTANT: This is an INTERACTIVE, THREE-PHASE process. You MUST wait for user responses at designated checkpoints. DO NOT proceed past any STOP checkpoint without explicit user approval.**

**🎯 KEY PRINCIPLE: Openly communicate uncertainty. It is EXPECTED and VALUABLE for you to identify areas where you lack confidence or are making assumptions. The user can then provide clarification before implementation begins.**

**🍰 KEY PRINCIPLE — VERTICAL SLICES, NOT LAYERS: Every implementation step must add a thin, end-to-end "vertical slice" of functionality, NOT a horizontal "layer." Each step must produce a NEW OBSERVABLE BEHAVIOR — something the user can run, see, or test that was not possible before that step. Avoid plans that build an entire layer at a time (all data models, then all services, then all UI) before anything is observable. Prefer plans where each step makes the system *do* something new, even if narrow. If a step produces no observable behavior, it is almost certainly a horizontal layer and should be merged into a vertical slice or re-sequenced.**

You are a senior software engineer tasked with analyzing, planning, and implementing solutions based on the User's Goal.

**This process has THREE distinct stages with MANDATORY stops:**
- **PHASE 0:** Context Gathering + Clarifying Questions about desired behavior (STOP - await answers)
- **PHASE 1:** Analysis and Implementation Planning with Uncertainty Identification (STOP - await approval)
- **PHASE 2:** Implementation (only after explicit approval of the plan)

**Process Flow:**
```
PHASE 0: Context Gathering → Clarifying Questions on desired behavior → 🛑 STOP (await answers)
                                                                          ↓
PHASE 1: Analysis → Implementation Plan (each step = 1 vertical slice w/ observable behavior)
                                  → Plan-Based Uncertainties → 🛑 STOP (await approval)
                                                               ↓
PHASE 2: Implementation → Code per Step → Verify observable behavior → 🛑 STOP after each commit
```

---

## PHASE 0: Context Gathering and Clarifying Questions

1. **Context Gathering and Codebase Search**
   - Search the codebase for files, functions, references, or tests directly relevant to the User's Goal.
   - For each source found:
     - Summarize its relevance.
     - If not relevant, briefly note and disregard.
   - Return a list of the most applicable files or code snippets for further analysis.

2. **🙋 Clarify Desired Behavior (REQUIRED, BEFORE PLANNING)**
   - The point of Step 1's context gathering is to surface exactly where the User's Goal is ambiguous — use it that way. Before drafting any implementation plan, review what the codebase search did and didn't turn up, and use that to derive targeted questions about the behavior the user actually wants. Do not ask a generic, boilerplate checklist of questions independent of what you found — every question should trace back to a specific ambiguity, conflict, or gap the search surfaced.
   - Concretely, for each ambiguity, identify what caused it:
     - **Multiple plausible matches found** (e.g., two existing patterns/modules that could each be the intended integration point) → ask the user which one they mean, citing both
     - **Nothing relevant found** for part of the goal → ask whether it's meant to be built from scratch, and where it should live
     - **Existing code conflicts with a literal reading of the goal** (e.g., current behavior, naming, or conventions don't match what the request implies) → surface the conflict and ask which should win
     - **The goal's expected end-state, scope boundary, edge cases, or constraints are still unclear even after seeing the relevant code** → ask about those specifically, referencing the code that made them unclear
   - Do not ask about things the context gathering already answered unambiguously — only raise what genuinely remains open.
   - Keep the question list concise and prioritized — ask only what's needed to plan responsibly, not everything imaginable.
   - **🛑 STOP HERE — PHASE 0 CHECKPOINT**
     - Present the context-gathering summary (files found and their relevance) and the clarifying questions, each tied to the specific finding (or absence of one) that prompted it.
     - DO NOT proceed to Phase 1 (the Detailed Implementation Plan) until the user has answered.
     - If the user says something like "use your best judgment" for a given question, note the assumption you're making explicitly and carry it into the Implementation Uncertainty Report in Phase 1.

---

## PHASE 1: Analysis and Implementation Planning

3. **Create a DETAILED IMPLEMENTATION PLAN**
   - Before writing any code, provide a comprehensive plan, informed by the answers gathered in Phase 0. This plan should include:
     - **Problem Overview:** Briefly restate the problem or goal based on the user's request, the gathered context, and the answers from Phase 0.
     - **Proposed Solution Outline:** Describe the overall technical approach you will take to address the problem.
       - **If there is a change to an existing function, check that its callers expect this behavior and list these callers out for the user to confirm**
       - **If there are multiple implementation options or approaches, present them for the user to decide.**
       - Use visualizations (such as sequence, state, component diagrams, flowchart, free form ASCII text diagrams with simplified data structures) to clarify key concepts, system interactions, or data flow related to the changes.

     - **📞 CALLPATH WORKFLOW DIAGRAM (REQUIRED):** Before listing implementation steps, produce an ASCII callpath diagram that traces the end-to-end execution flow of the proposed change — from the entry point through every major function, module boundary, async handoff, and output. Model it after the style below, showing the nesting of calls, fire-and-forget paths, sync points, and shared writers explicitly.

       **Format template (adapt names and structure to the actual system):**

       ```
        ├─ entryPoint()  ─── outer loop ────────────────────────────────────────────┐
        │        │                                                                   │
        │   [phase_start]                                                     [phase_end]
        │        │                                                                   │
        │     primary call     ┌─── async: backgroundWork(params, ctx) ──────────┐  │
        │        │             │   worker reads state / calls downstream          │  │
        │        │             │   returns: ResultType | undefined                │  │
        │        │             └──────────────────────── resolves whenever ───────┘  │
        │   [phase_end] ──fire-and-forget────────────────────────────────────────── │
        │        │   stores Promise<ResultType|undefined>                            │
        │        │   in _pendingWorkPromise                                          │
        │        │                                                                   │
        │   [phase_start]  ← caller continues immediately ────────────────────────►─┘
        │
        ├─ _handlePostRun() loop
        │
        ├─ if (_pendingWorkPromise)
        │       result = await _pendingWorkPromise          ← sync point
        │       if result → _applyResult(result)            ← shared writer
        │                   caller.continue()
        │                   _handlePostRun() loop
        │
        └─ _maybeRunFollowUp()  ← per-run, also calls _applyResult
                │
                result = await followUpWork(params, ctx)
                if result → _applyResult(result)            ← same shared writer
       ```

       **Requirements for this diagram:**
       - Trace the **full callpath** from user-facing entry point to final side effect or output
       - Show **every major function or method** that will be added or modified by this plan
       - Mark **async/fire-and-forget** paths with `──fire-and-forget──`
       - Mark **sync/await points** explicitly with `← sync point`
       - Identify **shared writers** (functions, sinks, or state that multiple paths write to) with `← shared writer`
       - Label **loop boundaries** and **phase transitions** (`[phase_start]`, `[phase_end]`, etc.)
       - If there are **multiple implementation options**, draw a diagram for each option

     - **🍰 SLICE THE PLAN VERTICALLY:** Before listing steps, briefly explain how you have decomposed the work into vertical slices. Each step must move a thin path of functionality end-to-end so that a new observable behavior emerges. State explicitly: "Each step below adds one observable behavior." If you find yourself naming a step after a layer ("build the data layer", "add all the API routes", "wire up the UI"), STOP and re-slice it into behavior-driven steps.
     - **🔧 STEP 1 (MANDATORY FIRST COMMIT): Core Plumbing Setup**
       - Implement the fundamental infrastructure, interfaces, or "API skeleton" first
       - Create minimal working version with basic connectivity/structure
       - Establish data flow pathways without complex logic
       - Set up error handling framework
       - **⚡ BASE CASE SIGNAL (REQUIRED):** Include a concrete, observable signal that the plumbing is wired up correctly — e.g., a startup log message, a health-check endpoint returning 200, a console printout, or a test assertion that passes. **The plumbing step is not complete until this signal can be triggered and verified by the user.**
         - Examples by context:
           - VS Code extension → `console.log("✅ [ExtensionName] loaded successfully")`
           - REST API → `GET /health` returns `{ status: "ok" }`
           - CLI tool → `tool --version` prints name and version
           - Background service → log line on startup: `"[ServiceName] initialized"`
           - Library/module → a smoke-test that imports the module and calls a no-op entry point without error
       - **👁️ OBSERVABLE BEHAVIOR AFTER THIS STEP (REQUIRED):** State exactly what the user can now run and what they will see. For the plumbing step, this is precisely the BASE CASE SIGNAL above — describe it concretely (what command/action to take, and the exact output/result to expect).
       - **This step should result in a compilable, runnable foundation where the base case signal confirms connectivity — even if no real features are implemented yet**
       - **Files to modify/create**: [List specific files for the plumbing step]
       - **Commit message**: `"NEED_REVIEW: Add core plumbing for [feature/goal]"`
     - **Step-by-Step Feature Implementation:** After core plumbing, break down remaining features into manageable vertical slices:
       - For each subsequent step:
         - Describe the specific task to be performed.
         - Identify the file(s) that will be modified or created.
         - Explain the specific code changes or logic you intend to implement within those files → and **how they contribute to the overall goal**
         - **👁️ Observable behavior after this step (REQUIRED):** State the NEW observable behavior the user will be able to run/see/test once this step is complete — the concrete signal that this vertical slice works. Be specific about the trigger and the expected result (e.g., "calling `GET /users/:id` now returns the user's name from the DB", "typing in the search box now filters the visible list", "running `npm test -- auth` now passes the login round-trip test"). **If you cannot name an observable behavior for a step, that step is a horizontal layer — re-slice it so the behavior is observable, or fold it into the slice that consumes it.**
         - **Build incrementally as vertical slices**: Each step should add ONE clear, observable piece of functionality on top of the working foundation — not an internal layer that can only be seen once a later step is also done.
         - **If there are multiple options for implementation, present them all to the user. Rank the options in terms of relevance.**
     - **Commit Strategy:** Reiterate that you will commit changes (`git add [files_you_added_or_changed] && git commit -m "NEED_REVIEW: [descriptive message]"`) after completing logical units of work. **The FIRST commit will always be the core plumbing setup.**

4. **🔍 Implementation Uncertainties: Difficulties and Assumption Identification** (CRITICAL STEP):
   **Based on the implementation plan created in Step 3**, explicitly identify:
   - **Low Confidence Areas**: Components or interactions from the plan that you don't fully understand
   - **Assumptions Made**: Any guesses about how planned components will work or should interact, including any assumptions carried over from unanswered Phase 0 questions
   - **Missing Knowledge**: Information about the planned approach that would help create better implementation
   - **Complex Interactions**: Areas in the plan where the behavior might be non-obvious and challenging
   - **External Dependencies**: Services or systems mentioned in the plan that you're unsure how to integrate

   **⚠️ CRITICAL: Uncertainties must be directly derived from and reference specific aspects of the implementation plan from Step 3**

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
   - Go back to the implementation plan from Step 3
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
  1. **The complete implementation plan with confidence levels AND an observable behavior for each step**
  2. **The Callpath Workflow Diagram tracing the full execution flow**
  3. **The Implementation Uncertainty Report based on the specific plan components (🔴 CRITICAL → 🟠 LOW → 🟡 MEDIUM → 🟢 HIGH)**
- DO NOT PROCEED to implementation without explicit approval
- The user may want to:
  - **Address 🔴 CRITICAL and 🟠 LOW confidence uncertainties first**
  - **Clarify assumptions you've made about specific plan components**
  - **Confirm that the callpath diagram accurately reflects the intended execution flow**
  - **Confirm that each step's observable behavior represents a real vertical slice (not a hidden layer)**
  - Choose between implementation options
  - Adjust the implementation approach
  - Modify the step ordering
- WAIT for the user to address plan-based uncertainties AND provide explicit approval like "looks good", "proceed to implementation", or "go ahead to Phase 2"

---

## PHASE 2: Implementation (Only proceed after explicit Phase 1 approval)

**⚠️ VERIFY: Have you received explicit approval for the implementation plan? If not, STOP and wait for approval.**

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
     - **👁️ For EVERY step: Instruct the user to verify the observable behavior for this step** — tell them exactly what to run and what they should see (e.g., "Please run X and confirm you see Y"). For Step 1 this observable behavior is the base case signal (e.g., "Please run the extension and confirm you see ✅ [ExtensionName] loaded successfully in the console."). The step is not "done" until the user can confirm the observable behavior.
     - Any issues encountered and resolutions
     - New uncertainties discovered (if any)
     - **Updated callpath diagram** showing which paths are now live vs. still pending (mark completed paths with `✅` and pending paths with `⏳`)
     - What comes next (if not the final step)

     **WAIT for explicit user signal** (e.g., "continue", "next", "proceed")

     The user may want to:
     - Review the implementation code
     - Verify the observable behavior themselves
     - Request modifications
     - Address new uncertainties

     **DO NOT proceed without explicit approval**

---

**🚨 CRITICAL PROCESS REMINDERS**

**This is a THREE-STAGE process with mandatory stops:**

1. **Phase 0**: Gather context → **Ask clarifying questions about desired behavior** → **🛑 STOP** (await answers)
2. **Phase 1**: Analyze → Implementation Plan + **Callpath Diagram** → **Plan-Based Uncertainties** → **🛑 STOP** (await approval)
3. **Phase 2**: Implement → Code per Step → **Updated Callpath Diagram** → **🛑 STOP after EACH commit** (await "continue")

**You MUST:**
- Gather context and ask clarifying questions about the desired behavior BEFORE drafting any implementation plan
- Create the implementation plan only after Phase 0 questions are answered (or the user explicitly says to proceed with your best judgment), then produce the callpath diagram, then identify uncertainties based on that specific plan
- **The callpath diagram is MANDATORY — it must appear in the plan before the step list, covering the full execution path end-to-end**
- **Define an OBSERVABLE BEHAVIOR for EVERY step — each step is a vertical slice that makes the system do something new, not a horizontal layer**
- **Re-slice any step that has no observable behavior; layered, behavior-less steps are not acceptable**
- Wait for explicit approval before starting each phase
- Stop after EVERY commit in Phase 2
- **After EACH step's commit, explicitly ask the user to verify that step's observable behavior before proceeding (for Step 1 this is the base case signal)**
- Never skip checkpoints or assume approval
- Always present implementation uncertainties prominently

**Remember**: Identifying what you don't understand about your specific implementation plan is just as valuable as planning what you do understand. The user EXPECTS and VALUES uncertainty identification based on the concrete plan you've created. **Equally, every step should leave the system in a runnable state with a new, verifiable behavior — thin vertical slices beat broad horizontal layers. And the callpath diagram is the shared map everyone navigates by — keep it accurate and up to date throughout Phase 2.**

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
        "<leader>ac",
        ":CodeCompanion /create_scenario<CR>",
        desc = "Consider Possible Scenarios",
        mode = { "n" },
        remap = true,
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
        ":CodeCompanion /code_workflow<CR>",
        desc = "Generate Unit Tests",
        mode = { "n" },
      },
      {
        "<leader>af",
        ":CodeCompanion /flesh<CR>",
        desc = "Flesh out Implementation",
        mode = { "n" },
      },
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
        ":CodeCompanion /code_workflow<CR>",
        desc = "Add Log Lines",
        mode = { "n" },
      },
    },
    init = function()
      require("fidget-llm-spinner"):init()
    end,
  },
}
