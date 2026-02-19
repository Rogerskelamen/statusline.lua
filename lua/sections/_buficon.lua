local devicons = require("tables._icons")

local M = {}
local space = " "

---Get file icon according to buffer number
---@param bufnr? integer
---@return string
function M.get_file_icon(bufnr)
  bufnr = bufnr or 0

  local bt = vim.bo[bufnr].buftype
  if bt == "terminal" then
    return "" .. space
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return ""
  end

  local fname = vim.fs and vim.fs.basename(name) or vim.fn.fnamemodify(name, ":t")
  local icon = devicons.devicon_table[fname]
  if icon then
    return icon .. space
  end

  return ""
end

return M
