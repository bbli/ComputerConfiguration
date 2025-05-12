local M = {}
local group = vim.api.nvim_create_augroup("CodeCompanionCustom", { clear = true })
vim.g.mcphub_auto_approve = true

function CodeCompanionNext()
  -- 1. insert text
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  vim.api.nvim_feedkeys("i@cmd_runner Do the next step in the plan or fix the error from the output" .. esc, "n", false)
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
        ["Unit Tests"] = {
          strategy = "chat",
        },
        ["Apply"] = {
          condition = function()
            return false
          end,
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
              role = "user", -- Can use constants.USER_ROLE if available
              content = "@editor apply the generated code to #neovim://buffer",
              opts = {
                auto_submit = true,
              },
            },
          },
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
            --user_prompt = false, -- Whether to ask for user input before submitting
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
1. Update the code in #buffer{watch} using the @editor tool
2. Then use the #neovim://diagnostics/current resource to check if there are any compile errors.
3. If there are errors in the output, explain what they mean and then fix them using step 1

We'll repeat this cycle until there are no more error diagnostics.

#### Phase 2(very similar to Phase 1)
1. Use the #neovim://diagnostics/workspace resource to check if there are any compile errors. If not we are done.
2. If there are errors in the output, explain what they mean and then fix them by updating the code in #buffer{watch} using the @editor tool
3. Go back to step 1


Ensure no deviations from these steps.

### Specific Task Instruction


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
      { "<leader>an", CodeCompanionNext, desc = "Prompt CodeCompanion to go to next step", mode = { "n" } },
      {
        "<leader>at",
        ":CodeCompanion /tests<CR>",
        desc = "Generate Unit Tests",
        mode = { "v" },
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
