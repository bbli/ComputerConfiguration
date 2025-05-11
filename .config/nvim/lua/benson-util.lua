function FindGitRoot()
  local handle = io.popen("git rev-parse --show-toplevel")
  local git_root = handle:read("*a"):gsub("\n", "")
  handle:close()
  return git_root
end

function PP(title, message)
  vim.notify(message, vim.log.levels.INFO, {
    title = title,
  })
end

function PrintTable(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(k .. ":")
      PrintTable(v)
    else
      print(k .. ": " .. tostring(v))
    end
  end
end

function CloseWindowWithFileType(filetype)
  local win_ids = vim.api.nvim_list_wins()
  for _, win_id in ipairs(win_ids) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")
    if buf_filetype == filetype then
      vim.api.nvim_win_close(win_id, false)
      return true
    end
  end
  return false
end

function GetAllBuffers()
  return vim.api.nvim_list_bufs()
end
