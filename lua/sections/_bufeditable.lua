local space = " "

local M = {}

---Return read-only icon if file can't be modified
---@param bufnr? integer
---@return string
function M.editable(bufnr)
  bufnr = bufnr or 0
  local bo = vim.bo[bufnr]

  if bo.filetype == "help" then
    return ""
  end

  if bo.readonly == true then
    return "" .. space
  end

  return ""
end

return M
