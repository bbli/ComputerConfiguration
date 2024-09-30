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
