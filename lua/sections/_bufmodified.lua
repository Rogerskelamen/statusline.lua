local space = " "

local M = {}

local ignored_filetypes = {
  startify = true,
  TelescopePrompt = true,
}

---Return modified icon if file is modified
---@param bufnr? integer
---@return string
function M.buffer_modified(bufnr)
  bufnr = bufnr or 0
  local bo = vim.bo[bufnr]

  -- Ignore some special buffer
  if ignored_filetypes[bo.filetype] then
    return ""
  end

  if vim.bo.modifiable and vim.bo.modified then
    return "+" .. space
  end

  return ""
end

return M
