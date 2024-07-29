M = {}
local api = vim.api
local lsp = vim.lsp
function length(array)
    local cnt = 0
    for x,y in ipairs(array) do
        cnt = cnt + 1 
    end
    return cnt
end

function GetWindowCountOfCurrentTab()
    local wins = api.nvim_tabpage_list_wins(api.nvim_get_current_tabpage())
    -- P(wins)
    return length(wins)
end

function M.smartJumpSplit()
    if (GetWindowCountOfCurrentTab() > 1) then
        print "make a horizontal split"
        api.nvim_command("split")
        vim.cmd [[wincmd p]]
        lsp.buf.definition()
    else
        print "make a vertical split"
        api.nvim_command("vs")
        lsp.buf.definition()
    end
end
function M.autoZenMode()
    if (GetWindowCountOfCurrentTab() == 1) then
        require("zen-mode").open()
    end
end
return M
