--
-- vim-scripts/vim-signify
--

local M = {}
local space = " "

local symbols = { "+", "-", "~" }

function M.signify()
  if vim.fn.exists("*sy#repo#get_stats") == 0 then
    return ""
  end

  local ok, stats = pcall(vim.fn["sy#repo#get_stats"])
  if not ok or not stats then
    return ""
  end
  local added = stats[1]
  local modified = stats[2]
  local removed = stats[3]

  if added == -1 then
    return ""
  end

  local result = {}

  if added and added > 0 then
    table.insert(result, symbols[1] .. added .. space)
  end
  if removed and removed > 0 then
    table.insert(result, symbols[2] .. removed .. space)
  end
  if modified and modified > 0 then
    table.insert(result, symbols[3] .. modified .. space)
  end

  if #result > 0 then
    return table.concat(result)
  end

  return ""
end

return M
