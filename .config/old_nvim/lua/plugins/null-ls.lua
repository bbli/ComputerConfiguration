-- print("null-ls")
local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

function create_make_command()
    local git_dir = vim.fn.system("git rev-parse --show-toplevel")
    git_dir = string.gsub(git_dir, "%s+", "")
    
    print(git_dir)
    local path = vim.fn.expand('%:pt')
    print(path)
    local docker_path = string.gsub(path,git_dir,"/home/ir/iridium")
    -- local docker_path = string.gsub(path,"/home/ir/icreate_tall_refactor","/home/ir/iridium")
    print(docker_path)
    local file_name = vim.fn.expand('%:t')
    print(file_name)
    docker_path = string.gsub(docker_path,"/".. file_name,"")

    return docker_path
end

local pure_storage_lint = {
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "python" },
    -- null_ls.generator creates an async source
    -- that spawns the command with the given arguments and options
    generator = null_ls.generator({
        -- ./run is needed b/c makefile calls pylint.py -> which is available only inside the Docker container
        command = "/home/ir/icreate_tall_refactor/run",
        -- args = { "make", "-f", "/home/ir/pylint.make", "-C" },
        args = function(params)
            return {
            "make", "-f", "pylint.make", "-C",
            create_make_command()
            }
        end,
        to_stdin = true,
        from_stderr = true,
        -- choose an output format (raw, json, or line)
        format = "line",
        check_exit_code = function(code, stderr)
            local success = code <= 1

            if not success then
                -- can be noisy for things that run often (e.g. diagnostics), but can
                -- be useful for things that run on demand (e.g. formatting)
                print(stderr)
            end

            return success
        end,
        -- use helpers to parse the output from string matchers,
        -- or parse it manually with a function
        on_output = helpers.diagnostics.from_patterns({
            {
                pattern = [[E:(%d+),(%d+): (.*)]],
                groups = { "row", "col", "message" },
            },
            {
                pattern = [[:(%d+) [%w-/]+ (.*)]],
                groups = { "row", "message" },
            },
        }),
    }),
}

-- null_ls.register(pure_storage_lint)
-- null_ls.setup {  
--   debounce = 150,  
--   save_after_format = false,  
--   sources = {  
--     null_ls.builtins.diagnostics.pylint,  
--   },  
-- }
-- null_ls.setup({
--   sources = {
--     null_ls.builtins.diagnostics.pylint.with({
--         args = { "--from-stdin", "$FILENAME", "-f", "json" },
--       diagnostics_postprocess = function(diagnostic)
--         diagnostic.code = diagnostic.message_id
--       end,
--     }),
--   },
-- })

-- null_ls.register(no_really)
require("null-ls").setup({
    debug = true,
})
