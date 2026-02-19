local M = {}
local space = " "

---Get file name or file type according to buffer number
---@param bufnr? integer
---@return string
function M.get_buffer_name(bufnr)
  bufnr = bufnr or 0

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    local fname = vim.fs and vim.fs.basename(name) or vim.fn.fnamemodify(name, ":t")
    return fname .. space
  end

  local ft = vim.bo[bufnr].filetype
  if ft ~= "" then
    return ft .. space
  end

  return "[No Name]" --> AFAIK buffers tested have types but just incase.
end

return M
